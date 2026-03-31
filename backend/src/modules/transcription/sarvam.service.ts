import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as WebSocket from 'ws';

interface StreamingSession {
  ws: WebSocket;
  partialTranscript: string;
  finalTranscript: string;
  onTranscript?: (text: string) => void;
  isFinalized: boolean;
}

@Injectable()
export class SarvamService {
  private readonly logger = new Logger(SarvamService.name);
  private readonly apiKey: string;
  private activeSessions = new Map<string, StreamingSession>();

  constructor(private configService: ConfigService) {
    this.apiKey = this.configService.get<string>('SARVAM_API_KEY') || 'sk_rst5oqny_bzfy7r1clA7AnzFoo2MtG72Q';
  }

  startStreamingSession(consultationId: string, onTranscript?: (text: string) => void): boolean {
    if (this.activeSessions.has(consultationId)) {
      this.logger.warn(`⚠️ Session already exists for consultation: ${consultationId}`);
      return false;
    }

    const ws = new WebSocket(
      'wss://api.sarvam.ai/speech-to-text/ws?language-code=en-IN',
      {
        headers: {
          'Api-Subscription-Key': this.apiKey,
        },
      }
    );

    const session: StreamingSession = {
      ws,
      partialTranscript: '',
      finalTranscript: '',
      onTranscript,
      isFinalized: false,
    };

    ws.on('open', () => {
      this.logger.log(`✅ Sarvam WS session created: ${consultationId}`);
    });

    ws.on('message', (data) => {
      try {
        const parsed = JSON.parse(data.toString());
        this.logger.log(`🧠 SARVAM RAW RESPONSE for ${consultationId}:`, parsed);
        
        // Extract transcript safely from various possible response formats
        const transcript = this.extractTranscript(parsed);
        
        if (transcript) {
          session.partialTranscript = transcript;
          
          if (onTranscript) {
            onTranscript(transcript);
          }
          
          this.logger.log(`📝 Sarvam interim transcript for ${consultationId}: ${transcript}`);
        }
      } catch (error) {
        this.logger.error(`❌ Failed to parse Sarvam response for ${consultationId}:`, error);
      }
    });

    ws.on('error', (err) => {
      this.logger.error(`❌ Sarvam WS error for consultation ${consultationId}:`, err);
      this.cleanupSession(consultationId);
    });

    ws.on('close', (code, reason) => {
      this.logger.log(`🔌 Sarvam WS closed: ${consultationId}, code: ${code}, reason: ${reason}`);
      
      // When connection closes, the partial transcript becomes the final transcript
      if (session.partialTranscript && !session.isFinalized) {
        session.finalTranscript = session.partialTranscript;
        session.isFinalized = true;
        this.logger.log(`🏁 Final transcript captured for ${consultationId}: ${session.finalTranscript}`);
      }
      
      this.cleanupSession(consultationId);
    });

    this.activeSessions.set(consultationId, session);
    return true;
  }

  sendAudioChunk(consultationId: string, audioData: string, sequenceNumber?: number): void {
    const session = this.activeSessions.get(consultationId);
    if (!session || session.ws.readyState !== WebSocket.OPEN) {
      this.logger.warn(`⚠️ No active Sarvam session for consultation: ${consultationId}`);
      return;
    }

    try {
      session.ws.send(JSON.stringify({
        audio: {
          data: audioData, // base64 PCM
          sample_rate: 16000,
          encoding: "pcm_s16le"
        }
      }));
      
      this.logger.log(`🎵 Audio chunk forwarded to Sarvam for ${consultationId}, seq: ${sequenceNumber || 'unknown'}`);
    } catch (error) {
      this.logger.error(`❌ Failed to send audio chunk to Sarvam for consultation ${consultationId}:`, error);
    }
  }

  async stopStreamingSession(consultationId: string): Promise<string | null> {
    const session = this.activeSessions.get(consultationId);
    if (!session) {
      this.logger.warn(`⚠️ No active session to stop for consultation: ${consultationId}`);
      return null;
    }

    this.logger.log(`🛑 Stopping Sarvam session for consultation: ${consultationId}`);

    // Close the WebSocket gracefully
    if (session.ws.readyState === WebSocket.OPEN) {
      session.ws.close();
    }

    // Wait a short time for the final transcript to be captured
    await new Promise(resolve => setTimeout(resolve, 1000));

    const finalTranscript = session.finalTranscript || session.partialTranscript;
    
    if (finalTranscript) {
      this.logger.log(`🏁 Final transcript retrieved for ${consultationId}: ${finalTranscript}`);
    } else {
      this.logger.warn(`⚠️ No final transcript available for ${consultationId}`);
    }

    this.cleanupSession(consultationId);
    return finalTranscript || null;
  }

  getFinalTranscript(consultationId: string): string | null {
    const session = this.activeSessions.get(consultationId);
    if (!session) {
      this.logger.warn(`⚠️ No session found for consultation: ${consultationId}`);
      return null;
    }

    return session.finalTranscript || session.partialTranscript || null;
  }

  private extractTranscript(data: any): string | null {
    // Handle various possible Sarvam response formats safely
    if (data.transcript) return data.transcript;
    if (data.text) return data.text;
    if (data.result?.transcript) return data.result.transcript;
    if (data.results?.[0]?.transcript) return data.results[0].transcript;
    if (data.results?.[0]?.text) return data.results[0].text;
    
    return null;
  }

  private cleanupSession(consultationId: string): void {
    const session = this.activeSessions.get(consultationId);
    if (session) {
      try {
        if (session.ws.readyState === WebSocket.OPEN) {
          session.ws.close();
        }
      } catch (error) {
        this.logger.error(`❌ Error closing WebSocket for ${consultationId}:`, error);
      }
      
      this.activeSessions.delete(consultationId);
      this.logger.log(`🧹 Cleaned up session for consultation: ${consultationId}`);
    }
  }

  // Legacy methods for backward compatibility
  createSarvamConnection(consultationId: string, onTranscript: (text: string) => void): WebSocket {
    this.startStreamingSession(consultationId, onTranscript);
    const session = this.activeSessions.get(consultationId);
    return session?.ws;
  }

  closeConnection(consultationId: string): void {
    this.stopStreamingSession(consultationId);
  }
}
