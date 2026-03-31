import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { DatabaseModule } from './config/database';
import { HealthModule } from './modules/health/health.module';
import { AuthModule } from './modules/auth/auth.module';
import { ConsultationsModule } from './modules/consultations/consultations.module';
import { TranscriptionModule } from './modules/transcription/transcription.module';
import { SoapModule } from './modules/soap/soap.module';
import { PrescriptionsModule } from './modules/prescriptions/prescriptions.module';
import { ReferralsModule } from './modules/referrals/referrals.module';
import { FhirModule } from './modules/fhir/fhir.module';
import { WebsocketModule } from './websocket/websocket.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),
    DatabaseModule,
    HealthModule,
    AuthModule,
    ConsultationsModule,
    TranscriptionModule,
    SoapModule,
    PrescriptionsModule,
    ReferralsModule,
    FhirModule,
    WebsocketModule,
  ],
  controllers: [],
  providers: [],
})
export class AppModule {}
