import { Module } from '@nestjs/common';
import { ResearchController } from './research.controller';
import { ResearchService } from './research.service';

@Module({
  controllers: [ResearchController],
  providers: [ResearchService],
})
export class ResearchModule {}
