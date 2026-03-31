import {
  WebSocketGateway,
  WebSocketServer,
  SubscribeMessage,
  OnGatewayConnection,
  OnGatewayDisconnect,
  ConnectedSocket,
  MessageBody,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { Logger } from '@nestjs/common';
import { SarvamService } from '../modules/transcription/sarvam.service';
import { WebSocketProxyService } from '../modules/transcription/websocket-proxy.service';
import { ConsultationsService } from '../modules/consultations/consultations.service';

interface StreamStartMessage {
  event: 'stream_start';
  consultationId: string;
  timestamp: string;
}

interface AudioChunkMessage {
  event: 'audio_chunk';
  consultationId: string;
  sequenceNumber: number;
  timestamp: string;
  data: string; // base64 encoded audio data
  size: number;
}

interface StreamStopMessage {
  event: 'stream_stop';
  consultationId: string;
  timestamp: string;
}

type AudioStreamMessage = StreamStartMessage | AudioChunkMessage | StreamStopMessage;

@WebSocketGateway({
  cors: {
    origin: ['http://localhost:3001', /^http:\/\/localhost:\d+$/],
    credentials: true,
  },
})
export class ConsultationGateway
  implements OnGatewayConnection, OnGatewayDisconnect
{
  @WebSocketServer()
  server: Server;

  private readonly logger = new Logger(ConsultationGateway.name);
  private activeStreams = new Map<string, { startTime: Date; chunkCount: number }>();

  constructor(private sarvamService: SarvamService, private webSocketProxyService: WebSocketProxyService, private consultationsService: ConsultationsService) {}

  handleConnection(client: Socket) {
    this.logger.log(`Client connected: ${client.id}`);
  }

  handleDisconnect(client: Socket) {
    this.logger.log(`Client disconnected: ${client.id}`);
    
    // Clean up any active streams for this client
    for (const [consultationId, stream] of this.activeStreams) {
      this.logger.log(`Cleaning up stream for consultation: ${consultationId}`);
      this.sarvamService.stopStreamingSession(consultationId);
      this.webSocketProxyService.closeClient(consultationId);
    }
    this.activeStreams.clear();
  }

  @SubscribeMessage('stream_start')
  async handleStreamStart(
    @ConnectedSocket() client: Socket,
    @MessageBody() message: StreamStartMessage,
  ) {
    this.logger.log(
      `Stream started - Consultation: ${message.consultationId}, ` +
      `Client: ${client.id}, Timestamp: ${message.timestamp}`,
    );

    // Connect downstream Sarvam client first
    this.logger.log(`Connecting Sarvam client for consultation: ${message.consultationId}`);
    const connected = await this.webSocketProxyService.connectClient(message.consultationId);

    if (!this.webSocketProxyService.hasClient(message.consultationId)) {
      this.logger.error(`Failed to connect Sarvam client for consultation: ${message.consultationId}`);
      client.emit('transcription_status', {
        consultationId: message.consultationId,
        state: 'connection_failed',
        message: 'Failed to establish transcription connection',
        timestamp: new Date().toISOString(),
      });
      return;
    }

    // Track active stream
    this.activeStreams.set(message.consultationId, {
      startTime: new Date(message.timestamp),
      chunkCount: 0,
    });

    // Start Sarvam streaming session
    const sessionStarted = this.sarvamService.startStreamingSession(
      message.consultationId,
      (transcript) => {
        this.logger.log(`📡 Emitting transcript_update for consultation: ${message.consultationId}`);
        client.emit('transcript_update', {
          consultationId: message.consultationId,
          text: transcript,
          timestamp: new Date().toISOString(),
        });
      }
    );

    if (!sessionStarted) {
      this.logger.warn(`⚠️ Failed to start Sarvam session for consultation: ${message.consultationId}`);
    }

    // Acknowledge stream start
    client.emit('stream_started', {
      consultationId: message.consultationId,
      timestamp: new Date().toISOString(),
    });
  }

  @SubscribeMessage('audio_chunk')
  async handleAudioChunk(
    @ConnectedSocket() client: Socket,
    @MessageBody() message: AudioChunkMessage,
  ) {
    const stream = this.activeStreams.get(message.consultationId);
    if (!stream) {
      this.logger.warn(
        `Received audio chunk for unknown stream - Consultation: ${message.consultationId}`,
      );
      return;
    }

    stream.chunkCount++;

    this.logger.log(
      `Audio chunk received - Consultation: ${message.consultationId}, ` +
      `Client: ${client.id}, Sequence: ${message.sequenceNumber}, ` +
      `Size: ${message.size} bytes, Timestamp: ${message.timestamp}, ` +
      `Total chunks: ${stream.chunkCount}`,
    );

    // Check if downstream client is available
    if (!this.webSocketProxyService.hasClient(message.consultationId)) {
      this.logger.warn(`No Sarvam client available for consultation: ${message.consultationId}, attempting reconnect`);
      
      // Try one reconnect attempt
      const reconnected = await this.webSocketProxyService.connectClient(message.consultationId);
      
      if (!this.webSocketProxyService.hasClient(message.consultationId)) {
        this.logger.error(`Failed to reconnect Sarvam client for consultation: ${message.consultationId}`);
        client.emit('transcription_status', {
          consultationId: message.consultationId,
          state: 'downstream_unavailable',
          message: 'Transcription service temporarily unavailable',
          timestamp: new Date().toISOString(),
        });
        return;
      }
      
      this.logger.log(`Successfully reconnected Sarvam client for consultation: ${message.consultationId}`);
    }

    // Send audio chunk to Sarvam WebSocket for transcription
    const payload = {
      audio: {
        data: message.data,
        sample_rate: 16000,
        encoding: "pcm_s16le"
      }
    };

    const sent = this.webSocketProxyService.sendToClient(message.consultationId, payload);
    if (!sent) {
      // Queue the chunk if sending failed
      this.webSocketProxyService.queuePendingChunk(message.consultationId, message.data, message.sequenceNumber);
    }

    // Acknowledge the chunk
    client.emit('chunk_received', {
      consultationId: message.consultationId,
      sequenceNumber: message.sequenceNumber,
      timestamp: new Date().toISOString(),
    });
  }

  @SubscribeMessage('stream_stop')
  async handleStreamStop(
    @ConnectedSocket() client: Socket,
    @MessageBody() message: StreamStopMessage,
  ) {
    const stream = this.activeStreams.get(message.consultationId);
    if (!stream) {
      this.logger.warn(
        `Received stream stop for unknown stream - Consultation: ${message.consultationId}`,
      );
      return;
    }

    const duration = new Date(message.timestamp).getTime() - stream.startTime.getTime();
    
    this.logger.log(
      `Stream stopped - Consultation: ${message.consultationId}, ` +
      `Client: ${client.id}, Duration: ${duration}ms, ` +
      `Total chunks: ${stream.chunkCount}, Timestamp: ${message.timestamp}`,
    );

    // Immediate acknowledgment (as required for backward compatibility)
    client.emit('stream_stopped', {
      consultationId: message.consultationId,
      totalChunks: stream.chunkCount,
      duration: duration,
      timestamp: new Date().toISOString(),
    });

    try {
      // Finalize Sarvam stream and get final transcript
      this.logger.log(`🏁 Finalizing Sarvam session for consultation: ${message.consultationId}`);
      const finalTranscript = await this.sarvamService.stopStreamingSession(message.consultationId);
      
      if (finalTranscript && finalTranscript.trim()) {
        this.logger.log(`✅ Final transcript received for ${message.consultationId}: ${finalTranscript}`);
        
        // Persist transcript using consultations service
        try {
          await this.consultationsService.updateTranscript(message.consultationId, finalTranscript);
          this.logger.log(`💾 Transcript persisted for consultation: ${message.consultationId}`);
        } catch (persistError) {
          this.logger.error(`❌ Failed to persist transcript for ${message.consultationId}:`, persistError);
        }
        
        // Emit final transcript to client
        client.emit('transcription_final', {
          consultationId: message.consultationId,
          transcript: finalTranscript,
          isFinal: true,
          timestamp: new Date().toISOString(),
        });
        
        this.logger.log(`📡 Emitted transcription_final for consultation: ${message.consultationId}`);
      } else {
        this.logger.warn(`⚠️ No final transcript available for consultation: ${message.consultationId}`);
        
        // Emit processing status instead of failing silently
        client.emit('transcription_status', {
          consultationId: message.consultationId,
          state: 'processing',
          message: 'Transcription is being processed',
          timestamp: new Date().toISOString(),
        });
      }
    } catch (error) {
      this.logger.error(`❌ Error finalizing transcription for ${message.consultationId}:`, error);
      
      // Emit error status
      client.emit('transcription_status', {
        consultationId: message.consultationId,
        state: 'error',
        message: 'Failed to process transcription',
        timestamp: new Date().toISOString(),
      });
    }

    // Clean up WebSocket proxy client
    this.webSocketProxyService.closeClient(message.consultationId);

    // Remove stream from active streams
    this.activeStreams.delete(message.consultationId);
  }
}
