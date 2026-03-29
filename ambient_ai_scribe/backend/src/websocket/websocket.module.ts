import { Module } from '@nestjs/common';
import { ConsultationGateway } from './consultation.gateway';

@Module({
  providers: [ConsultationGateway],
  exports: [ConsultationGateway],
})
export class WebsocketModule {}
