import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as WebSocket from 'ws';

interface PendingChunk {
  data: string;
  sequenceNumber?: number;
  timestamp: number;
}

@Injectable()
export class WebSocketProxyService {
  private readonly logger = new Logger(WebSocketProxyService.name);
  private readonly apiKey: string;
  private clients = new Map<string, WebSocket>();
  private pendingChunks = new Map<string, PendingChunk[]>();
  private readonly MAX_PENDING_CHUNKS = 20;
  private readonly CONNECTION_TIMEOUT = 5000; // 5 seconds

  constructor(private configService: ConfigService) {
    this.apiKey = this.configService.get<string>('SARVAM_API_KEY') || 'sk_rst5oqny_bzfy7r1clA7AnzFoo2MtG72Q';
  }

  async connectClient(consultationId: string): Promise<boolean> {
    // Clean up any existing dead client first
    this.cleanupDeadClients();
    
    if (this.clients.has(consultationId)) {
      const existingClient = this.clients.get(consultationId)!;
      if (existingClient.readyState === WebSocket.OPEN) {
        this.logger.log(`Sarvam client already connected for consultationId=${consultationId}`);
        return true;
      } else {
        // Remove stale client
        this.clients.delete(consultationId);
        this.logger.warn(`Removed stale Sarvam client for consultationId=${consultationId}`);
      }
    }

    return new Promise((resolve) => {
      this.logger.log(`Connecting Sarvam client for consultationId=${consultationId}`);
      
      const ws = new WebSocket(
        'wss://api.sarvam.ai/speech-to-text/ws?language-code=en-IN',
        {
          headers: {
            'Api-Subscription-Key': this.apiKey,
          },
        }
      );

      const timeout = setTimeout(() => {
        this.logger.error(`Connection timeout for consultationId=${consultationId}`);
        ws.terminate();
        resolve(false);
      }, this.CONNECTION_TIMEOUT);

      ws.on('open', () => {
        clearTimeout(timeout);
        this.clients.set(consultationId, ws);
        this.logger.log(`Sarvam client connected for consultationId=${consultationId}`);
        
        // Flush any pending chunks
        this.flushPendingChunks(consultationId);
        
        resolve(true);
      });

      ws.on('message', (data) => {
        try {
          const parsed = JSON.parse(data.toString());
          this.logger.log(`Sarvam response for ${consultationId}:`, parsed);
          // Note: Transcript handling will be done by SarvamService
        } catch (error) {
          this.logger.error(`Failed to parse Sarvam response for ${consultationId}:`, error);
        }
      });

      ws.on('error', (err) => {
        clearTimeout(timeout);
        this.logger.error(`Sarvam client error for consultationId=${consultationId}:`, err);
        this.clients.delete(consultationId);
        resolve(false);
      });

      ws.on('close', (code, reason) => {
        clearTimeout(timeout);
        this.logger.log(`Sarvam client closed for consultationId=${consultationId}, code: ${code}, reason: ${reason}`);
        this.clients.delete(consultationId);
      });
    });
  }

  hasClient(consultationId: string): boolean {
    const client = this.clients.get(consultationId);
    return client !== undefined && client.readyState === WebSocket.OPEN;
  }

  sendToClient(consultationId: string, payload: any): boolean {
    const client = this.clients.get(consultationId);
    if (!client || client.readyState !== WebSocket.OPEN) {
      return false;
    }

    try {
      client.send(JSON.stringify(payload));
      this.logger.log(`Chunk forwarded to Sarvam for consultationId=${consultationId}`);
      return true;
    } catch (error) {
      this.logger.error(`Failed to send to Sarvam client for consultationId=${consultationId}:`, error);
      this.clients.delete(consultationId);
      return false;
    }
  }

  closeClient(consultationId: string): void {
    const client = this.clients.get(consultationId);
    if (client) {
      try {
        if (client.readyState === WebSocket.OPEN) {
          client.close();
        }
      } catch (error) {
        this.logger.error(`Error closing Sarvam client for consultationId=${consultationId}:`, error);
      }
      this.clients.delete(consultationId);
      this.logger.log(`Sarvam client closed and removed for consultationId=${consultationId}`);
    }
    
    // Clear pending chunks
    this.pendingChunks.delete(consultationId);
  }

  cleanupDeadClients(): void {
    for (const [consultationId, client] of this.clients.entries()) {
      if (client.readyState === WebSocket.CLOSED || client.readyState === WebSocket.CLOSING) {
        this.clients.delete(consultationId);
        this.logger.log(`Cleaned up dead Sarvam client for consultationId=${consultationId}`);
      }
    }
  }

  queuePendingChunk(consultationId: string, data: string, sequenceNumber?: number): void {
    if (!this.pendingChunks.has(consultationId)) {
      this.pendingChunks.set(consultationId, []);
    }
    
    const chunks = this.pendingChunks.get(consultationId)!;
    chunks.push({
      data,
      sequenceNumber,
      timestamp: Date.now()
    });
    
    // Keep only the most recent chunks
    if (chunks.length > this.MAX_PENDING_CHUNKS) {
      chunks.shift();
    }
    
    this.logger.log(`Chunk queued for consultationId=${consultationId}, queue size: ${chunks.length}`);
  }

  private flushPendingChunks(consultationId: string): void {
    const chunks = this.pendingChunks.get(consultationId);
    if (!chunks || chunks.length === 0) {
      return;
    }
    
    this.logger.log(`Flushing ${chunks.length} pending chunks for consultationId=${consultationId}`);
    
    for (const chunk of chunks) {
      this.sendToClient(consultationId, {
        audio: {
          data: chunk.data,
          sample_rate: 16000,
          encoding: "pcm_s16le"
        }
      });
    }
    
    this.pendingChunks.delete(consultationId);
  }
}
