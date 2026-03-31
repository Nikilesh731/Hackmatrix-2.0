import { Module } from '@nestjs/common';
import { SarvamService } from './sarvam.service';
import { WebSocketProxyService } from './websocket-proxy.service';

@Module({
  providers: [SarvamService, WebSocketProxyService],
  exports: [SarvamService, WebSocketProxyService],
})
export class TranscriptionModule {}
