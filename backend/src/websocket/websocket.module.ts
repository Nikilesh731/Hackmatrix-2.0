import { Module } from '@nestjs/common';
import { ConsultationGateway } from './consultation.gateway';
import { TranscriptionModule } from '../modules/transcription/transcription.module';
import { ConsultationsModule } from '../modules/consultations/consultations.module';

@Module({
  imports: [TranscriptionModule, ConsultationsModule],
  providers: [ConsultationGateway],
  exports: [ConsultationGateway],
})
export class WebsocketModule {}
