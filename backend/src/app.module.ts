import { Module } from '@nestjs/common';
import { ScheduleModule } from '@nestjs/schedule';
import { ResearchModule } from './research/research.module';

@Module({
  imports: [ScheduleModule.forRoot(), ResearchModule],
})
export class AppModule {}
