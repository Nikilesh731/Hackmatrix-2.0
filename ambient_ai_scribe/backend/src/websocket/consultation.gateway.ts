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

  handleConnection(client: Socket) {
    this.logger.log(`Client connected: ${client.id}`);
  }

  handleDisconnect(client: Socket) {
    this.logger.log(`Client disconnected: ${client.id}`);
    
    // Clean up any active streams for this client
    for (const [consultationId, stream] of this.activeStreams) {
      this.logger.log(`Cleaning up stream for consultation: ${consultationId}`);
    }
    this.activeStreams.clear();
  }

  @SubscribeMessage('stream_start')
  handleStreamStart(
    @ConnectedSocket() client: Socket,
    @MessageBody() message: StreamStartMessage,
  ) {
    this.logger.log(
      `Stream started - Consultation: ${message.consultationId}, ` +
      `Client: ${client.id}, Timestamp: ${message.timestamp}`,
    );

    // Track the active stream
    this.activeStreams.set(message.consultationId, {
      startTime: new Date(message.timestamp),
      chunkCount: 0,
    });

    // Acknowledge the stream start
    client.emit('stream_started', {
      consultationId: message.consultationId,
      timestamp: new Date().toISOString(),
    });
  }

  @SubscribeMessage('audio_chunk')
  handleAudioChunk(
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

    // Acknowledge the chunk
    client.emit('chunk_received', {
      consultationId: message.consultationId,
      sequenceNumber: message.sequenceNumber,
      timestamp: new Date().toISOString(),
    });
  }

  @SubscribeMessage('stream_stop')
  handleStreamStop(
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

    // Remove the stream from active streams
    this.activeStreams.delete(message.consultationId);

    // Acknowledge the stream stop
    client.emit('stream_stopped', {
      consultationId: message.consultationId,
      totalChunks: stream.chunkCount,
      duration: duration,
      timestamp: new Date().toISOString(),
    });
  }
}
