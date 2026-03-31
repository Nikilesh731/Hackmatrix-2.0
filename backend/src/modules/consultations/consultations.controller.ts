import { Controller, Get, Post, Param, Body, Logger, HttpStatus, HttpCode } from '@nestjs/common';
import { ConsultationsService } from './consultations.service';

@Controller('consultations')
export class ConsultationsController {
  private readonly logger = new Logger(ConsultationsController.name);

  constructor(private readonly consultationsService: ConsultationsService) {}

  @Get()
  findAll() {
    this.logger.log('GET /api/consultations - Fetching all consultations');
    // TODO: Implement consultation listing
    return this.consultationsService.findAll();
  }

  @Post()
  @HttpCode(HttpStatus.CREATED)
  create(@Body() createConsultationDto: any) {
    this.logger.log(`POST /api/consultations - Creating consultation with data: ${JSON.stringify(createConsultationDto)}`);
    const result = this.consultationsService.create(createConsultationDto);
    this.logger.log(`Consultation created successfully: ${JSON.stringify(result)}`);
    return result;
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    this.logger.log(`GET /api/consultations/${id} - Fetching consultation`);
    // TODO: Implement consultation retrieval
    return this.consultationsService.findOne(id);
  }
}
