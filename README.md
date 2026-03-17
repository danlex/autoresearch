# Autoresearch

> One subject. One goal. Fully autonomous research powered by Claude Opus.

Define a research subject in `goal.md`. The system generates tasks, researches them using Claude Code (`claude -p`), opens PRs, and builds a verified research document — all without human intervention. Three Claude Opus judges at different temperatures evaluate every PR. Nothing merges without 3/3 unanimous approval. Verified findings accumulate in `document.md` until the score hits zero.

---

## The Loop

```
 You write goal.md
       │
       ▼
 Tasks generated as GitHub Issues
       │
       ▼
 You /accept with priority ──────────────── (or auto-accept)
       │
       ▼
 ┌─────────────────────────────────────┐
 │  research.sh picks next task        │
 │  Creates branch                     │
 │  Builds type-specific prompt        │
 │  Runs: claude -p (Opus, temp 0.5)   │
 │  Tools: WebSearch, WebFetch, Read,  │
 │         Write, Bash                 │
 └──────────────┬──────────────────────┘
                │
        Score improved?
       ╱              ╲
     Yes               No
      │                 │
  Commit, push,     Delete branch,
  open PR           reopen Issue
      │
      ▼
 ┌──────────────────────────────────┐
 │  Three judges review in parallel │
 │                                  │
 │  Judge 1 (temp 0.1) → Evidence   │
 │  Judge 2 (temp 0.3) → Consistency│
 │  Judge 3 (temp 0.8) → Completeness│
 └──────────────┬───────────────────┘
                │
          3/3 Approved?
         ╱            ╲
       Yes              No
        │                │
    Auto-merge       Feedback posted,
    Close Issue      Issue re-queued
        │            (up to 5 retries)
        ▼
  document.md updated
  Score decreases
  Loop continues
```

---

## One-Command Deploy

```bash
export ANTHROPIC_API_KEY="sk-..."
bash deploy.sh
```

That's it. `deploy.sh` handles everything:
- Installs `jq`, `gh`, Claude Code CLI if missing
- Authenticates GitHub CLI
- Builds the NestJS backend
- Seeds task Issues if none exist
- Starts the backend with hourly cron on port 3000
- Generates `stop.sh` for clean shutdown

After deploy, start researching:

```bash
NO_JUDGES=1 ./research.sh
```

---

## How It Works

### Score System

The score measures how much work remains. **Lower is better. Zero means done.**

```
score = (open accepted tasks × 10) + (needs-rework × 5) + (LOW depth findings × 3)
```

`autoresearch.sh` computes this. `research.sh` only commits when the score improves.

### Task Types

| Type | What it does | Tools | Turns |
|------|-------------|-------|-------|
| `type-research` | Web search, find sources, update document | Bash, Read, Write, WebSearch, WebFetch | 15 |
| `type-document` | Synthesize sections into narrative | Bash, Read, Write | 8 |
| `type-review` | Evaluate quality, flag issues | Bash, Read, Write | 6 |

### Source Requirements

Every finding needs 2+ sources with at least 1 Tier 1:

| Tier | What counts | Can stand alone? |
|------|-------------|-----------------|
| **Tier 1** | Subject's own content, official docs, institutional pages | Yes |
| **Tier 2** | Mainstream press, Wikipedia with citations | With Tier 1 |
| **Tier 3** | Blogs, aggregators | Never |

### Model Assignment

Same model. Different temperature. Different context. Genuine independence through cognitive mode.

| Role | Model | Temp | Context | Focus |
|------|-------|------|---------|-------|
| Researcher | claude-opus-4-5 | 0.5 | goal + doc section + task | Balanced exploration |
| Judge 1 | claude-opus-4-5 | 0.1 | diff + task + criteria only | Evidence — strict, literal |
| Judge 2 | claude-opus-4-5 | 0.3 | diff + full document | Consistency — contradiction detection |
| Judge 3 | claude-opus-4-5 | 0.8 | diff + task only, no document | Completeness — edge cases |

---

## Setup

### Prerequisites

- [GitHub CLI](https://cli.github.com/) — `gh auth login`
- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) — `npm install -g @anthropic-ai/claude-code`
- `jq` — `brew install jq` (macOS) or `apt install jq` (Linux)
- `ANTHROPIC_API_KEY` environment variable

### Local

```bash
git clone https://github.com/danlex/autoresearch.git
cd autoresearch
export ANTHROPIC_API_KEY="sk-..."

# Seed 5 starter tasks
./seed-tasks.sh

# Run one iteration to test
NO_JUDGES=1 MAX_ITERATIONS=1 ./research.sh

# Run full loop
NO_JUDGES=1 ./research.sh
```

### GitHub Codespaces

1. Go to [github.com/danlex/autoresearch](https://github.com/danlex/autoresearch)
2. Click **Code → Codespaces → Create codespace on main**
3. In the terminal:
   ```bash
   export ANTHROPIC_API_KEY="sk-..."
   bash deploy.sh
   NO_JUDGES=1 ./research.sh
   ```
4. The backend cron runs research every hour automatically
5. Increase **Settings → Codespaces → Default idle timeout** to keep it running

### NestJS Backend (port 3000)

The backend serves research state over REST and triggers research on a schedule.

```
GET  /api/status           → current loop state (iteration, score, task)
GET  /api/document          → document.md content
GET  /api/goal              → goal.md content
GET  /api/coverage          → coverage.md content
GET  /api/score             → live score from autoresearch.sh
GET  /api/log?lines=50      → last N lines of research.log
POST /api/feedback          → { "text": "focus on primary sources" }
POST /api/pause             → toggle pause.flag
POST /api/research/start    → { "max_iterations": 3 }
```

Hourly cron: if score > 0 and no research running, starts 3 iterations automatically.

---

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `ANTHROPIC_API_KEY` | *required* | Anthropic API key |
| `MAX_ITERATIONS` | `50` | Max iterations per research session |
| `RESEARCH_MODEL` | `claude-opus-4-5` | Model for research tasks |
| `HARD_RESEARCH_MODEL` | `claude-opus-4-5` | Model for tasks that failed 3+ times |
| `NO_JUDGES` | `0` | Set to `1` to auto-merge PRs (skip judge review) |
| `POLL_INTERVAL` | `60` | Seconds between verdict polls |
| `POLL_MAX` | `7200` | Max seconds to wait for verdict |
| `GITHUB_TOKEN` | *from gh cli* | Used in Codespaces for auth |

---

## Intervention

You are always in control. The system never stops — you observe and intervene at any time.

| Action | How |
|--------|-----|
| **Pause** | `touch pause.flag` or `POST /api/pause` |
| **Resume** | `rm pause.flag` or `POST /api/pause` |
| **Give feedback** | Write `feedback.md` or `POST /api/feedback` |
| **Stop** | `./stop.sh` or `Ctrl+C` |
| **Skip a task** | Close the GitHub Issue |
| **Reprioritize** | Change Issue labels (`priority-high/medium/low`) |
| **Add a task** | Create Issue with labels `task`, `accepted`, `type-research`, `priority-medium` |
| **Change subject** | Edit `goal.md` |

---

## Repository Structure

```
autoresearch/
├── goal.md                 ← research subject (you edit this)
├── document.md             ← accumulated findings (built by Claude)
├── autoresearch.sh         ← score calculator
├── research.sh             ← main orchestration loop
├── seed-tasks.sh           ← bootstrap labels + starter Issues
├── deploy.sh               ← one-command setup
├── stop.sh                 ← generated by deploy.sh
├── coverage.md             ← coverage analysis
├── changelog.md            ← research changelog
├── model-versions.md       ← fine-tune model tracking
├── status.json             ← live state (gitignored)
├── research.log            ← session log (gitignored)
├── pause.flag              ← pause control (gitignored)
├── feedback.md             ← feedback to loop (gitignored)
└── backend/
    ├── src/
    │   ├── main.ts
    │   ├── app.module.ts
    │   └── research/
    │       ├── research.module.ts
    │       ├── research.controller.ts
    │       └── research.service.ts
    ├── package.json
    └── tsconfig.json
```

---

## Roadmap

- [x] Phase 1: Core research loop (`research.sh` + `claude -p`)
- [x] Phase 1.5: NestJS backend with hourly cron
- [ ] Phase 2: GitHub Actions workflows (13 workflows — judges, goal manager, approval, verdict)
- [ ] Phase 3: Next.js live dashboard (3-panel: goal, document, controls)
- [ ] Phase 4: GitHub Pages public site (5 static pages)
- [ ] Phase 5: Fine-tuning pipeline (QLoRA on Qwen3.5-4B → Hetzner GPU)
- [ ] Phase 6: .devcontainer, bot accounts, full automation

---

## License

MIT
