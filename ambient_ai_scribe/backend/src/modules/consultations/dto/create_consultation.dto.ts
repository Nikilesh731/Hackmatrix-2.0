import { IsString, IsNotEmpty, IsOptional } from 'class-validator';

export class CreateConsultationDto {
  @IsString()
  @IsNotEmpty()
  patientId: string;

  @IsOptional()
  notes?: string;
}
