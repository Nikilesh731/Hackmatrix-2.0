import { IsString, IsOptional, IsEnum } from 'class-validator';

export class UpdateConsultationDto {
  @IsOptional()
  @IsEnum(['not_started', 'in_progress', 'paused', 'completed', 'cancelled'])
  status?: string;

  @IsOptional()
  @IsString()
  notes?: string;
}
