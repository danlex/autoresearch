import { Injectable, Logger } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { readFileSync, writeFileSync, existsSync, unlinkSync } from 'fs';
import { execSync, spawn } from 'child_process';
import { join, resolve } from 'path';

@Injectable()
export class ResearchService {
  private readonly logger = new Logger(ResearchService.name);
  private readonly rootDir: string;
  private researchProcess: ReturnType<typeof spawn> | null = null;

  constructor() {
    // Use ROOT_DIR env var if set, otherwise resolve relative to dist/
    this.rootDir = process.env.ROOT_DIR || resolve(__dirname, '..', '..', '..');
  }

  private resolvePath(file: string): string {
    return join(this.rootDir, file);
  }

  readStatus(): Record<string, any> {
    const path = this.resolvePath('status.json');
    if (!existsSync(path)) {
      return { running: false, iteration: 0, score: 0, message: 'No session yet' };
    }
    try {
      return JSON.parse(readFileSync(path, 'utf-8'));
    } catch (e) {
      this.logger.warn(`Failed to parse status.json: ${e.message}`);
      return { running: false, iteration: 0, score: 0, message: 'status.json malformed' };
    }
  }

  readDocument(): string {
    const path = this.resolvePath('document.md');
    return existsSync(path) ? readFileSync(path, 'utf-8') : '';
  }

  readGoal(): string {
    const path = this.resolvePath('goal.md');
    return existsSync(path) ? readFileSync(path, 'utf-8') : '';
  }

  readCoverage(): string {
    const path = this.resolvePath('coverage.md');
    return existsSync(path) ? readFileSync(path, 'utf-8') : '';
  }

  getLog(lines: number = 20): string[] {
    const path = this.resolvePath('research.log');
    if (!existsSync(path)) return [];
    const content = readFileSync(path, 'utf-8');
    const allLines = content.split('\n').filter(Boolean);
    return allLines.slice(-lines);
  }

  writeFeedback(text: string): void {
    writeFileSync(this.resolvePath('feedback.md'), text);
  }

  togglePause(): { paused: boolean } {
    const path = this.resolvePath('pause.flag');
    if (existsSync(path)) {
      unlinkSync(path);
      return { paused: false };
    }
    writeFileSync(path, '');
    return { paused: true };
  }

  getScore(): number {
    try {
      const result = execSync('bash autoresearch.sh', {
        cwd: this.rootDir,
        timeout: 30000,
      });
      return parseInt(result.toString().trim(), 10) || 0;
    } catch {
      return -1;
    }
  }

  isRunning(): boolean {
    return this.researchProcess !== null && this.researchProcess.exitCode === null;
  }

  startResearch(maxIterations: number = 1): { started: boolean; message: string } {
    if (this.isRunning()) {
      return { started: false, message: 'Research already running' };
    }

    this.logger.log(`Starting research loop (max_iterations=${maxIterations})`);

    this.researchProcess = spawn('bash', ['research.sh'], {
      cwd: this.rootDir,
      env: {
        ...process.env,
        MAX_ITERATIONS: String(maxIterations),
        NO_JUDGES: process.env.NO_JUDGES || '1',
      },
      stdio: 'pipe',
    });

    this.researchProcess.stdout?.on('data', (data) => {
      this.logger.log(data.toString().trim());
    });

    this.researchProcess.stderr?.on('data', (data) => {
      this.logger.error(data.toString().trim());
    });

    this.researchProcess.on('close', (code) => {
      this.logger.log(`Research process exited with code ${code}`);
      this.researchProcess = null;
    });

    return { started: true, message: `Research started (max_iterations=${maxIterations})` };
  }

  @Cron(CronExpression.EVERY_HOUR)
  handleHourlyCron() {
    this.logger.log('Hourly cron: checking if research should run...');
    const score = this.getScore();
    if (score < 100 && !this.isRunning()) {
      this.logger.log(`Score is ${score}%, starting research iteration`);
      this.startResearch(3);
    } else if (score >= 100) {
      this.logger.log('Score is 100% — all tasks complete');
    } else {
      this.logger.log('Research already running, skipping');
    }
  }
}
