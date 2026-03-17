# CLAUDE.md — Project Standards and Best Practices

## Project Overview

Autoresearch is an autonomous research system. `research.sh` orchestrates Claude Code (`claude -p`) to research GitHub Issues, open PRs, and build a verified research document. A NestJS backend provides REST API access and hourly cron scheduling.

**Repo:** https://github.com/danlex/autoresearch
**Owner:** Alexandru DAN (danlex, dan_lex@yahoo.com)

---

## Shell Scripts (.sh)

### Safety — Critical
- Always `set -euo pipefail` at the top of every script
- Never embed user-derived variables in regex — use `grep -F` (fixed-string) or exact string comparison (`[[ "$a" == "$b" ]]`)
- Never pass large strings as shell arguments — write to temp file, pipe via stdin to avoid `ARG_MAX` limits
- Always quote variables: `"$var"` not `$var` — prevents word splitting and glob expansion
- Use `${var:-default}` for optional env vars, fail explicitly with `exit 1` for required ones
- Never use `eval` or backtick command substitution — use `$(...)` instead
- Sanitize any input used in file paths — prevent path traversal
- Clean up temp files in a trap: `trap 'rm -f "$tmpfile"' EXIT`
- Never store secrets in scripts or commit them — use env vars or `.env` files (gitignored)

### Defensive Coding
- Always handle command failures: `cmd || { log "failed"; return 1; }`
- Check if files exist before reading: `[[ -f "$file" ]] || { log "missing"; exit 1; }`
- Use `2>/dev/null || true` only when you intentionally want to ignore errors — add a comment explaining why
- Separate `local` declaration from assignment to avoid masking return values:
  ```bash
  # Bad — masks the return value of cmd
  local x="$(cmd)"
  # Good
  local x
  x=$(cmd)
  ```
- Validate numeric values before arithmetic: `[[ "$val" =~ ^[0-9]+$ ]] || val=0`

### Style
- Functions: `snake_case`
- Local variables: `snake_case`
- Constants/env vars: `UPPER_SNAKE_CASE`
- Use `local` for all function variables — no globals except top-level state
- One function per concern — keep functions under 40 lines
- Add a header comment block for each script
- Indent with 2 spaces
- Use `[[ ]]` not `[ ]` for conditionals
- Use `$(( ))` for arithmetic, not `expr`

### Linting
- All `.sh` files must pass `shellcheck` with zero warnings
- Run `shellcheck *.sh` before every commit
- Address warnings properly — don't just add `# shellcheck disable` unless truly necessary with an explanation

### GitHub CLI (`gh`)
- Always handle `gh` failures — network/rate limits are common
- Pipe JSON through `jq` — never parse structured data with grep/sed/awk
- Use `--json` + `--jq` flags instead of separate `jq` calls where possible
- Use `--state open` explicitly — don't rely on defaults
- Be aware of pagination — `gh` returns max 30 items by default, use `--limit` for more

### Performance
- Cache values that don't change within a loop iteration (e.g., subject parsed from goal.md)
- Minimize subprocess spawning in hot paths — prefer bash builtins over external commands
- Use `$(<file)` instead of `$(cat file)` for reading files (bash builtin, no fork)

---

## TypeScript / NestJS Backend

### Architecture
- Follow NestJS conventions: Module → Controller → Service
- Controllers handle HTTP concerns (routing, validation, response shaping)
- Services contain business logic and file I/O
- One module per domain (e.g., `ResearchModule`)

### Safety
- Wrap all `JSON.parse` calls in try/catch — files may be partially written by concurrent processes
- Use configurable paths via env vars (e.g., `ROOT_DIR`) — never rely on `__dirname` traversal alone
- Validate all user input at the controller level with DTOs and `class-validator`
- Enable global `ValidationPipe` — already done in `main.ts`
- Use `@MaxLength()` on string inputs to prevent abuse
- Return consistent error shapes: `{ error: string }`

### Style
- Use TypeScript strict mode where practical
- Prefer `readonly` for injected services and config
- Use `Logger` from `@nestjs/common`, not `console.log`
- DTOs: one class per request body, decorators for validation
- Name files: `feature.controller.ts`, `feature.service.ts`, `feature.module.ts`
- Use `async/await` over raw Promises

### Error Handling
- Services should throw `HttpException` subclasses for expected errors
- Unexpected errors bubble to NestJS global exception filter
- Log errors with context: `this.logger.error(message, stack)`
- Never expose internal paths or stack traces in API responses

### Dependencies
- Pin major versions in `package.json`
- Run `npm audit` before adding new dependencies
- Prefer NestJS ecosystem packages (`@nestjs/schedule`, `@nestjs/config`) over generic alternatives

---

## Testing

### Philosophy
- Tests exist to catch regressions, not to achieve coverage numbers
- Test behavior, not implementation — test what functions return, not how they compute it
- Mock external boundaries (GitHub API, Claude CLI, filesystem) — not internal functions
- Every bug fix should come with a test that would have caught it

### Before Every Commit
1. `shellcheck *.sh` — zero warnings
2. `bash tests/test_functions.sh` — all bash unit tests pass
3. `cd backend && npm test` — all NestJS tests pass

### Test Categories
| Category | Location | Runner | What it tests |
|----------|----------|--------|--------------|
| Bash unit | `tests/test_functions.sh` | bash | Pure functions: slugify, section parsing, score calc |
| Bash integration | `tests/test_research_loop.sh` | bash | Full iteration with mocked gh/claude |
| NestJS unit | `backend/src/**/*.spec.ts` | jest | Service methods, file I/O, process spawning |
| NestJS e2e | `backend/test/app.e2e-spec.ts` | jest + supertest | API endpoints end-to-end |

### Mocking Strategy
- **GitHub CLI:** Create mock `gh` script that returns fixture JSON
- **Claude CLI:** Create mock `claude` script that modifies document.md predictably
- **Filesystem:** Use temp directories for isolation
- **Time:** Use fixed timestamps in test assertions

---

## Git

### Identity
```bash
git -c user.name="Alexandru DAN" -c user.email="dan_lex@yahoo.com" commit
```

### Commit Messages
Format: `type: short description`

Types: `feat`, `fix`, `docs`, `test`, `refactor`, `chore`

Always include:
```
Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>
```

### Branch Hygiene
- `main` is protected — all changes via PRs (when judges are active)
- Task branches: `task/{issue_number}-{slug}`
- Clean up local branches after merge
- Never force-push to main

---

## Architecture Rules

### Single Source of Truth
- `goal.md` → research intent (human-edited)
- `document.md` → research findings (Claude-written, judge-verified)
- GitHub Issues → all tasks (created, tracked, closed there)
- `autoresearch.sh` → scoring formula
- `status.json` → runtime loop state

### Separation of Concerns
- `research.sh` is the only file that calls `claude -p`
- NestJS backend spawns `research.sh` — never calls Claude directly
- Score is computed by `autoresearch.sh` — research.sh doesn't hardcode scoring logic
- GitHub is the task store — no task state in local files

### File Ownership
- `goal.md`: human-only writes (system reads)
- `document.md`: Claude writes, judges verify, humans read
- `status.json`, `research.log`: research.sh writes, backend reads
- `feedback.md`: human/backend writes, research.sh reads and deletes
- `pause.flag`: human/backend creates/removes, research.sh polls

### Runtime Files (gitignored)
These are ephemeral and must never be committed:
- `status.json` — may be partially written
- `research.log` — grows unbounded
- `feedback.md` — consumed and deleted each iteration
- `pause.flag` — presence/absence is the signal
- `.prompt-*.txt` — temp prompt files
- `.env` — secrets

---

## Security

- Never commit API keys, tokens, or secrets
- `.env` files are gitignored with chmod 600
- `deploy.sh` prompts for keys with hidden input (`read -rsp`)
- Validate and sanitize all inputs at system boundaries (API endpoints, Issue body parsing)
- Don't trust Issue body content — treat it as untrusted input when building shell commands
- Use `jq` for JSON handling — never construct JSON with string concatenation

---

## Code Review Checklist

Before approving any change:
- [ ] `shellcheck *.sh` passes
- [ ] All tests pass
- [ ] No secrets in diff
- [ ] No hardcoded paths or values that should be configurable
- [ ] Error paths handled (not just happy path)
- [ ] New functions have corresponding tests
- [ ] Commit message follows convention
