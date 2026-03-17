# Autoresearch

A single-subject autonomous research system. You define the goal. Claude Opus researches. Three judges evaluate every PR. Nothing merges without 3/3 unanimous approval.

## How It Works

```
goal.md (you define the subject)
    ↓
seed-tasks.sh creates task Issues on GitHub
    ↓
You /accept tasks with priority
    ↓
research.sh picks highest priority accepted task
  Creates branch, builds type-specific prompt
  Runs claude -p (Claude Opus, temp 0.5)
    ↓
Score improved → commit, push, open PR
  NO_JUDGES=1 → auto-merge
  With judges → 3x Claude Opus (temp 0.1/0.3/0.8) review
    ↓
3/3 APPROVED → merge → document.md updated
Any rejection → consolidated feedback → retry
    ↓
Findings accumulate. Score drops toward zero.
```

## Model Assignment

| Role | Model | Temperature | Focus |
|------|-------|-------------|-------|
| Researcher | claude-opus-4-5 | 0.5 | Balanced exploration |
| Judge 1 | claude-opus-4-5 | 0.1 | Evidence, strict |
| Judge 2 | claude-opus-4-5 | 0.3 | Consistency |
| Judge 3 | claude-opus-4-5 | 0.8 | Completeness |

## Quick Start

### Prerequisites

- [GitHub CLI](https://cli.github.com/) (`gh auth login`)
- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) (`npm install -g @anthropic-ai/claude-code`)
- `jq` (`brew install jq`)
- `ANTHROPIC_API_KEY` environment variable

### Run Locally

```bash
# 1. Clone and enter repo
git clone https://github.com/danlex/autoresearch.git
cd autoresearch

# 2. Create labels and seed task Issues
./seed-tasks.sh

# 3. Check score (should be 50 = 5 tasks × 10)
./autoresearch.sh

# 4. Run one research iteration (auto-merge, no judges)
export ANTHROPIC_API_KEY="your-key"
NO_JUDGES=1 MAX_ITERATIONS=1 ./research.sh

# 5. Run full loop
NO_JUDGES=1 ./research.sh
```

### Run via NestJS Backend

```bash
cd backend
npm install
npm run build
npm start

# API at http://localhost:3000
# GET  /api/status      — current research status
# GET  /api/document     — research document content
# GET  /api/goal         — research goal
# GET  /api/log?lines=20 — last N log lines
# POST /api/feedback     — send feedback to research loop
# POST /api/pause        — toggle pause
# POST /api/research/start — trigger a research run
```

The backend includes a cron job that triggers research every hour automatically.

### Deploy to GitHub Codespaces

1. Open the repo on GitHub
2. Click **Code → Codespaces → Create codespace on main**
3. In the Codespace terminal:
   ```bash
   # Set your API key
   export ANTHROPIC_API_KEY="your-key"

   # Install Claude Code CLI
   npm install -g @anthropic-ai/claude-code

   # Start the backend (includes hourly cron)
   cd backend && npm install && npm run build && npm start &

   # Or run research directly
   NO_JUDGES=1 ./research.sh
   ```
4. The Codespace keeps running even if you close the browser tab
5. To keep it alive long-term, go to **Settings → Codespaces → Default idle timeout** and increase it

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `ANTHROPIC_API_KEY` | Anthropic API key | required |
| `MAX_ITERATIONS` | Max research iterations per session | 50 |
| `RESEARCH_MODEL` | Claude model for research | claude-opus-4-5 |
| `NO_JUDGES` | Auto-merge PRs (skip judges) | 0 |

## Files

| File | Purpose |
|------|---------|
| `goal.md` | Research subject and goals |
| `document.md` | Accumulated research findings |
| `research.sh` | Main orchestration loop |
| `autoresearch.sh` | Score calculator (lower = better) |
| `seed-tasks.sh` | Creates labels + starter Issues |
| `coverage.md` | Coverage analysis report |
| `changelog.md` | Research changelog |
| `model-versions.md` | Fine-tune model versions |
| `backend/` | NestJS API + hourly cron |

## Oversight

- All activity visible on GitHub (Issues, PRs, commits)
- `touch pause.flag` to pause the loop
- Write `feedback.md` to guide the next iteration
- Close any PR or Issue to intervene
- Monitor `status.json` and `research.log` for live state

## Current Subject

**Andrej Karpathy** — AI researcher, educator, entrepreneur. Founder of Eureka Labs. Former OpenAI, Tesla.
