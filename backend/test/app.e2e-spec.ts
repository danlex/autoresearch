import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import * as request from 'supertest';
import { AppModule } from '../src/app.module';
import { writeFileSync, mkdirSync, rmSync, existsSync } from 'fs';
import { join } from 'path';

describe('Research API (e2e)', () => {
  let app: INestApplication;
  let tmpDir: string;

  beforeAll(async () => {
    tmpDir = join(__dirname, '..', '..', '.test-e2e-' + Date.now());
    mkdirSync(tmpDir, { recursive: true });
    process.env.ROOT_DIR = tmpDir;

    // Create minimal research files
    writeFileSync(join(tmpDir, 'goal.md'), '# Research Goal: Test Subject\n\n## Subject\nTest');
    writeFileSync(join(tmpDir, 'document.md'), '# Test — Research Document\nCoverage: 0%\n\n## Section 1\nContent');
    writeFileSync(join(tmpDir, 'coverage.md'), '# Coverage Report\nLast analyzed: never');
    writeFileSync(
      join(tmpDir, 'status.json'),
      JSON.stringify({
        running: false,
        iteration: 0,
        max_iterations: 50,
        score: 50,
        starting_score: 50,
        current_task: '',
        current_issue: 0,
        last_action: 'none',
        subject: 'Test Subject',
        model: 'claude-opus-4-5',
        session_start: '2026-03-17T00:00:00Z',
      }),
    );
    writeFileSync(
      join(tmpDir, 'research.log'),
      '[2026-03-17T00:00:00Z] Session started\n[2026-03-17T00:01:00Z] Iteration 1\n',
    );

    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    app.enableCors();
    app.useGlobalPipes(new ValidationPipe());
    await app.init();
  });

  afterAll(async () => {
    await app.close();
    if (existsSync(tmpDir)) {
      rmSync(tmpDir, { recursive: true, force: true });
    }
    delete process.env.ROOT_DIR;
  });

  describe('GET /api/status', () => {
    it('should return status object', () => {
      return request(app.getHttpServer())
        .get('/api/status')
        .expect(200)
        .expect((res) => {
          expect(res.body).toHaveProperty('running');
          expect(res.body).toHaveProperty('score');
          expect(res.body).toHaveProperty('iteration');
          expect(res.body.score).toBe(50);
        });
    });
  });

  describe('GET /api/document', () => {
    it('should return document content', () => {
      return request(app.getHttpServer())
        .get('/api/document')
        .expect(200)
        .expect((res) => {
          expect(res.body).toHaveProperty('content');
          expect(res.body.content).toContain('Research Document');
        });
    });
  });

  describe('GET /api/goal', () => {
    it('should return goal content', () => {
      return request(app.getHttpServer())
        .get('/api/goal')
        .expect(200)
        .expect((res) => {
          expect(res.body).toHaveProperty('content');
          expect(res.body.content).toContain('Research Goal');
        });
    });
  });

  describe('GET /api/coverage', () => {
    it('should return coverage content', () => {
      return request(app.getHttpServer())
        .get('/api/coverage')
        .expect(200)
        .expect((res) => {
          expect(res.body.content).toContain('Coverage Report');
        });
    });
  });

  describe('GET /api/log', () => {
    it('should return last 20 lines by default', () => {
      return request(app.getHttpServer())
        .get('/api/log')
        .expect(200)
        .expect((res) => {
          expect(res.body).toHaveProperty('lines');
          expect(Array.isArray(res.body.lines)).toBe(true);
          expect(res.body.lines.length).toBeLessThanOrEqual(20);
        });
    });

    it('should respect lines query param', () => {
      return request(app.getHttpServer())
        .get('/api/log?lines=1')
        .expect(200)
        .expect((res) => {
          expect(res.body.lines).toHaveLength(1);
        });
    });
  });

  describe('POST /api/feedback', () => {
    it('should accept valid feedback', () => {
      return request(app.getHttpServer())
        .post('/api/feedback')
        .send({ text: 'Focus on primary sources' })
        .expect(201)
        .expect((res) => {
          expect(res.body.ok).toBe(true);
        });
    });

    it('should reject feedback over 500 chars', () => {
      const longText = 'a'.repeat(501);
      return request(app.getHttpServer())
        .post('/api/feedback')
        .send({ text: longText })
        .expect(400);
    });

    it('should reject empty body', () => {
      return request(app.getHttpServer())
        .post('/api/feedback')
        .send({})
        .expect(400);
    });

    it('should reject non-string text', () => {
      return request(app.getHttpServer())
        .post('/api/feedback')
        .send({ text: 12345 })
        .expect(400);
    });
  });

  describe('POST /api/pause', () => {
    it('should toggle pause state', async () => {
      const res1 = await request(app.getHttpServer())
        .post('/api/pause')
        .expect(201);
      expect(res1.body).toHaveProperty('paused');

      const res2 = await request(app.getHttpServer())
        .post('/api/pause')
        .expect(201);
      expect(res2.body.paused).not.toBe(res1.body.paused);
    });
  });

  describe('POST /api/research/start', () => {
    it('should accept valid start request', () => {
      return request(app.getHttpServer())
        .post('/api/research/start')
        .send({ max_iterations: 1 })
        .expect(201)
        .expect((res) => {
          expect(res.body).toHaveProperty('started');
          expect(res.body).toHaveProperty('message');
        });
    });

    it('should reject max_iterations over 50', () => {
      return request(app.getHttpServer())
        .post('/api/research/start')
        .send({ max_iterations: 100 })
        .expect(400);
    });

    it('should reject max_iterations of 0', () => {
      return request(app.getHttpServer())
        .post('/api/research/start')
        .send({ max_iterations: 0 })
        .expect(400);
    });
  });
});
