import { Controller, Get, Post, Body, Query } from '@nestjs/common';
import { IsString, MaxLength, IsOptional, IsNumber, Min, Max } from 'class-validator';
import { Type } from 'class-transformer';
import { ResearchService } from './research.service';

class FeedbackDto {
  @IsString()
  @MaxLength(500)
  text: string;
}

class StartDto {
  @IsOptional()
  @IsNumber()
  @Type(() => Number)
  @Min(1)
  @Max(50)
  max_iterations?: number;
}

@Controller('api')
export class ResearchController {
  constructor(private readonly researchService: ResearchService) {}

  @Get('status')
  getStatus() {
    return this.researchService.readStatus();
  }

  @Get('document')
  getDocument() {
    return { content: this.researchService.readDocument() };
  }

  @Get('goal')
  getGoal() {
    return { content: this.researchService.readGoal() };
  }

  @Get('coverage')
  getCoverage() {
    return { content: this.researchService.readCoverage() };
  }

  @Get('log')
  getLog(@Query('lines') lines?: string) {
    const n = Math.min(Math.max(parseInt(lines, 10) || 20, 1), 1000);
    return { lines: this.researchService.getLog(n) };
  }

  @Get('score')
  getScore() {
    return { score: this.researchService.getScore() };
  }

  @Post('feedback')
  postFeedback(@Body() dto: FeedbackDto) {
    this.researchService.writeFeedback(dto.text);
    return { ok: true };
  }

  @Post('pause')
  togglePause() {
    return this.researchService.togglePause();
  }

  @Post('research/start')
  startResearch(@Body() dto: StartDto) {
    return this.researchService.startResearch(dto?.max_iterations || 1);
  }
}
