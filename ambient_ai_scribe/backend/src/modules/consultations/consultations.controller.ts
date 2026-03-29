import { Controller, Get, Post, Param, Body } from '@nestjs/common';
import { ConsultationsService } from './consultations.service';

@Controller('consultations')
export class ConsultationsController {
  constructor(private readonly consultationsService: ConsultationsService) {}

  @Get()
  findAll() {
    // TODO: Implement consultation listing
    return this.consultationsService.findAll();
  }

  @Post()
  create(@Body() createConsultationDto: any) {
    return this.consultationsService.create(createConsultationDto);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    // TODO: Implement consultation retrieval
    return this.consultationsService.findOne(id);
  }
}
