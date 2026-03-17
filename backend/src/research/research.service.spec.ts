import { Test, TestingModule } from '@nestjs/testing';
import { ScheduleModule } from '@nestjs/schedule';
import { ResearchService } from './research.service';
import { writeFileSync, mkdirSync, rmSync, existsSync } from 'fs';
import { join } from 'path';

describe('ResearchService', () => {
  let service: ResearchService;
  let tmpDir: string;

  beforeEach(async () => {
    // Create a temp workspace
    tmpDir = join(__dirname, '..', '..', '..', '.test-workspace-' + Date.now());
    mkdirSync(tmpDir, { recursive: true });

    process.env.ROOT_DIR = tmpDir;

    const module: TestingModule = await Test.createTestingModule({
      imports: [ScheduleModule.forRoot()],
      providers: [ResearchService],
    }).compile();

    service = module.get<ResearchService>(ResearchService);
  });

  afterEach(() => {
    if (existsSync(tmpDir)) {
      rmSync(tmpDir, { recursive: true, force: true });
    }
    delete process.env.ROOT_DIR;
  });

  describe('readStatus', () => {
    it('should return default when status.json missing', () => {
      const status = service.readStatus();
      expect(status.running).toBe(false);
      expect(status.iteration).toBe(0);
      expect(status.message).toBe('No session yet');
    });

    it('should parse valid status.json', () => {
      const data = {
        running: true,
        iteration: 5,
        max_iterations: 50,
        score: 30,
        starting_score: 50,
        current_task: 'Test task',
        current_issue: 1,
        last_action: 'improved',
        subject: 'Andrej Karpathy',
        model: 'claude-opus-4-5',
        session_start: '2026-03-17T00:00:00Z',
      };
      writeFileSync(join(tmpDir, 'status.json'), JSON.stringify(data));

      const status = service.readStatus();
      expect(status.running).toBe(true);
      expect(status.iteration).toBe(5);
      expect(status.score).toBe(30);
      expect(status.current_task).toBe('Test task');
    });

    it('should handle malformed JSON gracefully', () => {
      writeFileSync(join(tmpDir, 'status.json'), '{ broken json');

      const status = service.readStatus();
      expect(status.running).toBe(false);
      expect(status.message).toBe('status.json malformed');
    });

    it('should handle partially written JSON', () => {
      writeFileSync(join(tmpDir, 'status.json'), '{"running": true, "iter');

      const status = service.readStatus();
      expect(status.running).toBe(false);
    });
  });

  describe('readDocument', () => {
    it('should return empty string when missing', () => {
      expect(service.readDocument()).toBe('');
    });

    it('should read document.md content', () => {
      writeFileSync(join(tmpDir, 'document.md'), '# Test Document\nContent here');
      expect(service.readDocument()).toContain('# Test Document');
    });
  });

  describe('readGoal', () => {
    it('should return empty string when missing', () => {
      expect(service.readGoal()).toBe('');
    });

    it('should read goal.md content', () => {
      writeFileSync(join(tmpDir, 'goal.md'), '# Research Goal: Test');
      expect(service.readGoal()).toContain('Research Goal: Test');
    });
  });

  describe('readCoverage', () => {
    it('should return empty string when missing', () => {
      expect(service.readCoverage()).toBe('');
    });
  });

  describe('getLog', () => {
    it('should return empty array when log missing', () => {
      expect(service.getLog()).toEqual([]);
    });

    it('should return last N lines', () => {
      const lines = Array.from({ length: 50 }, (_, i) => `[2026-03-17] Line ${i + 1}`);
      writeFileSync(join(tmpDir, 'research.log'), lines.join('\n'));

      const result = service.getLog(5);
      expect(result).toHaveLength(5);
      expect(result[4]).toContain('Line 50');
    });

    it('should return all lines when fewer than requested', () => {
      writeFileSync(join(tmpDir, 'research.log'), 'line1\nline2');

      const result = service.getLog(20);
      expect(result).toHaveLength(2);
    });
  });

  describe('writeFeedback', () => {
    it('should create feedback.md with content', () => {
      service.writeFeedback('Focus on primary sources');

      const path = join(tmpDir, 'feedback.md');
      expect(existsSync(path)).toBe(true);

      const { readFileSync } = require('fs');
      expect(readFileSync(path, 'utf-8')).toBe('Focus on primary sources');
    });
  });

  describe('togglePause', () => {
    it('should create pause.flag when not paused', () => {
      const result = service.togglePause();
      expect(result.paused).toBe(true);
      expect(existsSync(join(tmpDir, 'pause.flag'))).toBe(true);
    });

    it('should remove pause.flag when paused', () => {
      writeFileSync(join(tmpDir, 'pause.flag'), '');

      const result = service.togglePause();
      expect(result.paused).toBe(false);
      expect(existsSync(join(tmpDir, 'pause.flag'))).toBe(false);
    });

    it('should toggle correctly on multiple calls', () => {
      expect(service.togglePause().paused).toBe(true);
      expect(service.togglePause().paused).toBe(false);
      expect(service.togglePause().paused).toBe(true);
    });
  });

  describe('isRunning', () => {
    it('should return false when no process', () => {
      expect(service.isRunning()).toBe(false);
    });
  });

  describe('startResearch', () => {
    it('should reject when already running', () => {
      // Simulate a running process by starting one
      const result1 = service.startResearch(1);
      // The process will fail (no research.sh in tmpDir) but the guard check is what we test
      if (result1.started) {
        const result2 = service.startResearch(1);
        expect(result2.started).toBe(false);
        expect(result2.message).toContain('already running');
      }
    });
  });
});
