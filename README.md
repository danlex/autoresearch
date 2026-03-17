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

The score goes from **0% to 100%**. Higher is better. 100% = done.

```
score = (task_completion × 60%) + (citation_quality × 30%) + (confidence × 10%)
```

| Component | Weight | What it measures |
|-----------|--------|-----------------|
| Task completion | 60% | % of Issues labeled `implemented` (penalizes rework) |
| Citation quality | 30% | % of content paragraphs with inline `[N]` citations |
| Confidence | 10% | Penalizes LOW confidence sections (-5% each) |

`autoresearch.sh` computes this with a full breakdown to stderr.
`research.sh` only creates PRs when the score improves or document changes.

### Self-Review

Before any PR is created, Claude runs a **self-review** checking for:
- Uncited factual claims (every claim needs `[N]`)
- Phantom citations (references to sources that don't exist)
- Confidence levels that don't match source quality
- Suspiciously specific unsourced claims (hallucination detection)

Failed self-review = no PR, feedback posted on the Issue for next attempt.

### Adaptive Task Generation

The system generates its own follow-up tasks:
- **`explode-goal.sh`** — Reads `goal.md`, generates 30-50 specific research questions as GitHub Issues
- **Post-merge proposals** — After each merge, Claude proposes 1-3 follow-up questions based on discoveries
- **Retry escalation** — 3 failures → `hard-task` label, 5 failures → `unanswerable` + auto-close

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

Hourly cron: if score < 100% and no research running, starts 3 iterations automatically.

### Real-Time Monitor

```bash
bash watch.sh              # Live dashboard (refreshes every 5s)
bash watch.sh log          # Color-coded tail of research.log
bash watch.sh status       # One-shot status
```

The dashboard shows: score with breakdown, current task, iteration count, last action (color-coded), and the last 15 log lines — all in a terminal UI with auto-refresh.

### Propose Research

```bash
bash propose.sh                      # Interactive — prompts for question
bash propose.sh "What was X?"        # Quick — creates Issue from title
bash propose.sh list                 # Show all proposed tasks
bash propose.sh accept               # Accept all proposed tasks
bash propose.sh accept high          # Accept high-priority only
```

Proposed tasks are created as GitHub Issues labeled `proposed`. Accept them to add to the research queue. The system also proposes tasks automatically after each merge.

### Generate Tasks from Goal

```bash
bash explode-goal.sh    # Reads goal.md, generates 30-50 task Issues
```

Claude analyzes your research goal and generates specific, actionable research questions — each assigned to a section with type and priority labels. Run once after editing `goal.md`.

---

## Environment Variables

Copy `.env.example` to `.env` and fill in your values. `.env` is gitignored. All scripts auto-load it — no need to `source` manually.

```bash
cp .env.example .env
nano .env   # add your keys
bash research.sh   # just run it
```

| Variable | Default | Description |
|----------|---------|-------------|
| `ANTHROPIC_API_KEY` | — | Anthropic API key (or use OAuth token) |
| `CLAUDE_CODE_OAUTH_TOKEN` | — | Alternative: OAuth token from `claude setup-token` |
| `MAX_ITERATIONS` | `50` | Max iterations per research session |
| `RESEARCH_MODEL` | `claude-opus-4-5` | Model for research tasks |
| `HARD_RESEARCH_MODEL` | `claude-opus-4-5` | Model for tasks that failed 3+ times |
| `NO_JUDGES` | `0` | Set to `1` to auto-merge PRs (skip judge review) |
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

## Research Files

These markdown files are the knowledge backbone of the system. Claude reads and writes them. You own them.

### `goal.md` — The Research Goal

The only file you **must** edit. Everything starts here. It defines:

- **Subject** — who or what to research (e.g., "Andrej Karpathy — AI researcher, educator, entrepreneur")
- **Anchors** — known identifiers to ground the search (Twitter handle, GitHub, LinkedIn, career timeline)
- **What I Want to Understand** — 3-7 specific areas of inquiry. Each becomes a section in `document.md` and drives task generation
- **Completion Criteria** — what "done" looks like (e.g., "all tasks closed with HIGH confidence, zero contradictions, every finding backed by 2+ sources")
- **Out of Scope** — explicit boundaries to prevent drift (e.g., "personal life, financial details")

The system reads `goal.md` on every iteration. If you change it mid-session, `research.sh` detects the mtime change and adapts. The Goal Manager workflow (Phase 2) will version-tag changes and regenerate tasks automatically.

**Rule:** `goal.md` holds intent only — no task checklists, no findings. Tasks live in GitHub Issues.

### `document.md` — The Research Document

The evolving output. Starts with section headers matching your "What I Want to Understand" areas, then fills up across merged PRs. Structure:

```
# Subject Name — Research Document
Coverage: 42% | Tasks: 12/30 | Sources: 18 | Last updated: 2026-03-17

## Intellectual Contributions
[findings with inline confidence badges and source citations]

## Education and Teaching
[...]

## Sources
- [1] https://karpathy.github.io/... (Tier 1 — self-published)
- [2] https://nytimes.com/... (Tier 2 — mainstream press)

## Open Questions
- What was the exact timeline of...
```

Every finding in the document carries:
- **Confidence**: `HIGH` / `MEDIUM` / `LOW` — how certain the claim is based on source quality
- **Depth**: `HIGH` / `MEDIUM` / `LOW` — how thoroughly the topic has been explored
- **Source citations** with tier classification

The header block (`Coverage`, `Tasks`, `Sources`, `Last updated`) is updated automatically by the verdict workflow after each merge. `research.sh` and Claude never edit the header directly — they only add content to sections.

**Rule:** Claude adds to this file. You read it. Judges verify it. Nobody deletes sourced claims.

### `coverage.md` — Coverage Analysis

Written by the Goal Manager workflow (Phase 2). Maps every aspect of `goal.md` to existing GitHub Issues and identifies:
- **Gaps** — areas with no tasks
- **Partial coverage** — areas with tasks but incomplete findings
- **Overlaps** — duplicate or conflicting tasks
- **Orphans** — tasks that don't map to any goal area

Currently a placeholder. When the Goal Manager runs, it produces a full report and creates new proposed Issues for any gaps it finds.

### `changelog.md` — Research Changelog

Append-only log of every merged PR. Written by the verdict workflow after a successful 3/3 merge. Each entry records:
- Date and Issue number
- What was researched or synthesized
- Score delta (before → after)
- Sources added

Gives you a chronological view of how the research document was built, complementing `document.md` which shows the current state.

### `model-versions.md` — Fine-Tune Model Versions

Tracks each QLoRA fine-tune of the Qwen3.5-4B expert model (Phase 5). After a milestone completes and training runs on Hetzner, this file gets a new row:

```
| Version | Date | Score | Coverage | Base Model |
|---------|------|-------|----------|------------|
| v1      | 2026-03-20 | 82.4 | 35% | Qwen3.5-4B |
| v2      | 2026-03-25 | 87.1 | 58% | Qwen3.5-4B |
```

Each version corresponds to a LoRA adapter pushed to HuggingFace Hub. The llama-server on Hetzner loads the latest adapter for inference.

Currently a placeholder — populated when the fine-tuning pipeline is implemented.

### Runtime Files (gitignored)

These files are created and consumed by `research.sh` at runtime. They are **not committed** to the repo.

**`status.json`** — Live snapshot of the research loop state. Written every iteration.
```json
{
  "running": true,
  "iteration": 7,
  "max_iterations": 50,
  "score": 30,
  "starting_score": 50,
  "current_task": "Research Karpathy's role at OpenAI",
  "current_issue": 2,
  "last_action": "improved",
  "subject": "Andrej Karpathy",
  "model": "claude-opus-4-5",
  "session_start": "2026-03-17T08:00:00Z"
}
```
The NestJS backend reads this file and serves it at `GET /api/status`.

**`research.log`** — Append-only session log. Every action, score change, error, and Claude output gets timestamped here. Survives across sessions. The backend tails it at `GET /api/log`.

**`feedback.md`** — Write text here to inject guidance into the next iteration. `research.sh` reads it, includes the content in the next Claude prompt, then deletes the file. Use it for things like: "focus on primary sources for the Tesla section" or "the Stanford dates seem wrong, re-verify".

**`pause.flag`** — Touch this file to pause the loop. `research.sh` polls every 5 seconds and resumes when the file is removed. The backend's `POST /api/pause` toggles this.

---

## Repository Structure

```
autoresearch/
├── goal.md                 ← YOU EDIT THIS — research subject and goals
├── document.md             ← accumulated findings (built by Claude)
├── coverage.md             ← gap/overlap analysis (by Goal Manager)
├── changelog.md            ← append-only merge log
├── model-versions.md       ← fine-tune model tracking
│
├── research.sh             ← main orchestration loop
├── autoresearch.sh         ← score calculator (0-100%)
├── explode-goal.sh         ← generate 30-50 tasks from goal.md
├── propose.sh              ← propose + accept research tasks
├── watch.sh                ← real-time terminal dashboard
├── seed-tasks.sh           ← bootstrap labels + 5 starter Issues
├── deploy.sh               ← one-command setup for Codespaces
├── stop.sh                 ← generated by deploy.sh
├── .env.example            ← template for secrets (copy to .env)
│
├── status.json             ← live loop state (gitignored)
├── research.log            ← session log (gitignored)
├── feedback.md             ← human → loop guidance (gitignored)
├── pause.flag              ← pause control (gitignored)
│
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
- [x] Phase 1.6: Score system (0-100%, citation quality + task completion)
- [x] Phase 1.7: Self-review (hallucination detection before merge)
- [x] Phase 1.8: Adaptive tasks (`explode-goal.sh` + post-merge proposals)
- [x] Phase 1.9: `.devcontainer` for one-click Codespaces
- [x] Phase 1.10: Test suite (83 tests — bash unit/integration + NestJS unit/e2e)
- [ ] Phase 2: GitHub Actions workflows (judges, goal manager, approval, verdict)
- [ ] Phase 3: Next.js live dashboard (3-panel: goal, document, controls)
- [ ] Phase 4: GitHub Pages public site (5 static pages)

---

## Current Status

**Subject:** Andrej Karpathy — AI researcher, educator, entrepreneur.

| Metric | Value |
|--------|-------|
| Score | 11% |
| Tasks | 1/30 completed, 11 accepted, 24 proposed |
| Sources | 15 (9 Tier 1, 6 Tier 2) |
| Sections | 1/5 with content (Intellectual Contributions) |

Run `./autoresearch.sh` for live score breakdown.

---

## License

MIT
