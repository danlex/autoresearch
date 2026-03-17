#!/bin/bash
set -euo pipefail

# ============================================================================
# research.sh — Autonomous Research Orchestration Loop
# Picks up accepted task Issues, runs Claude Code to research, opens PRs.
# ============================================================================

# --- Configuration ---
MAX_ITERATIONS="${MAX_ITERATIONS:-50}"
RESEARCH_MODEL="${RESEARCH_MODEL:-claude-opus-4-5}"
HARD_RESEARCH_MODEL="${HARD_RESEARCH_MODEL:-claude-opus-4-5}"
NO_JUDGES="${NO_JUDGES:-0}"
POLL_INTERVAL="${POLL_INTERVAL:-60}"
POLL_MAX="${POLL_MAX:-7200}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- State ---
iteration=0
score=0
starting_score=0
current_task=""
current_issue=0
last_action="none"
session_start=""
goal_mtime=""
model="$RESEARCH_MODEL"
feedback=""
subject=""

# ============================================================================
# Utility Functions
# ============================================================================

log() {
  local msg="[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] $*"
  echo "$msg"
  echo "$msg" >> "$SCRIPT_DIR/research.log"
}

write_status() {
  cat > "$SCRIPT_DIR/status.json" <<STATUSEOF
{
  "running": ${1:-true},
  "iteration": $iteration,
  "max_iterations": $MAX_ITERATIONS,
  "score": $score,
  "starting_score": $starting_score,
  "current_task": $(echo "$current_task" | jq -Rs .),
  "current_issue": $current_issue,
  "last_action": "$last_action",
  "subject": $(echo "$subject" | jq -Rs .),
  "model": "$model",
  "session_start": "$session_start"
}
STATUSEOF
}

slugify() {
  echo "$1" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//' | sed 's/-$//' | cut -c1-50
}

compute_score() {
  bash "$SCRIPT_DIR/autoresearch.sh"
}

# ============================================================================
# GitHub Helpers
# ============================================================================

get_next_issue() {
  local issue_num=""

  # Priority 1: needs-better-research (rework)
  issue_num=$(gh issue list \
    --label "task,accepted,needs-better-research" \
    --state open \
    --json number,labels \
    --jq '[.[] | select(.labels | map(.name) | contains(["in-progress"]) | not)] | .[0].number // empty' \
    2>/dev/null || true)

  if [[ -n "$issue_num" ]]; then
    echo "$issue_num"
    return
  fi

  # Priority 2: by priority label (high > medium > low)
  for priority in priority-high priority-medium priority-low; do
    issue_num=$(gh issue list \
      --label "task,accepted,$priority" \
      --state open \
      --json number,labels \
      --jq '[.[] | select(.labels | map(.name) | contains(["in-progress"]) | not)] | .[0].number // empty' \
      2>/dev/null || true)

    if [[ -n "$issue_num" ]]; then
      echo "$issue_num"
      return
    fi
  done

  # Priority 3: any accepted task without priority label
  issue_num=$(gh issue list \
    --label "task,accepted" \
    --state open \
    --json number,labels \
    --jq '[.[] | select(.labels | map(.name) | contains(["in-progress"]) | not)] | .[0].number // empty' \
    2>/dev/null || true)

  if [[ -n "$issue_num" ]]; then
    echo "$issue_num"
    return
  fi

  echo ""
}

read_issue() {
  local issue_num="$1"
  gh issue view "$issue_num" --json title,body,labels,comments
}

get_issue_field() {
  local json="$1"
  local field="$2"
  echo "$json" | jq -r ".$field // empty"
}

has_label() {
  local json="$1"
  local label="$2"
  echo "$json" | jq -r ".labels[]?.name" | grep -q "^${label}$" 2>/dev/null
}

is_hard_task() {
  local json="$1"
  has_label "$json" "hard-task"
}

get_task_type() {
  local json="$1"
  if has_label "$json" "type-document"; then
    echo "document"
  elif has_label "$json" "type-review"; then
    echo "review"
  else
    echo "research"
  fi
}

get_section_from_body() {
  local body="$1"
  # Section value is on the line after "## Section"
  echo "$body" | grep -A1 "^## Section" | tail -1 | xargs
}

# ============================================================================
# Prompt Builders
# ============================================================================

build_research_prompt() {
  local title="$1"
  local body="$2"
  local section="$3"
  local comments="$4"
  local goal_content
  goal_content=$(cat "$SCRIPT_DIR/goal.md")

  local doc_section=""
  if [[ -n "$section" ]]; then
    # Use fixed-string matching to avoid regex injection from section names
    local start_line
    start_line=$(while IFS= read -r line_num_and_text; do
      local lnum="${line_num_and_text%%:*}"
      local ltext="${line_num_and_text#*:}"
      if [[ "$ltext" == "## ${section}" ]]; then
        echo "$lnum"
        break
      fi
    done < <(grep -nF "## ${section}" "$SCRIPT_DIR/document.md"))
    if [[ -n "$start_line" ]]; then
      local end_line
      end_line=$(tail -n +"$((start_line + 1))" "$SCRIPT_DIR/document.md" | grep -n "^## " | head -1 | cut -d: -f1)
      if [[ -n "$end_line" ]]; then
        doc_section=$(sed -n "${start_line},$((start_line + end_line - 1))p" "$SCRIPT_DIR/document.md")
      else
        doc_section=$(tail -n +"$start_line" "$SCRIPT_DIR/document.md")
      fi
    fi
  fi

  local feedback_block=""
  if [[ -n "$feedback" ]]; then
    feedback_block="
USER FEEDBACK (apply this guidance):
${feedback}"
  fi

  local comment_block=""
  if [[ -n "$comments" && "$comments" != "[]" && "$comments" != "null" ]]; then
    comment_block="
PREVIOUS FEEDBACK ON THIS TASK (from failed attempts):
${comments}"
  fi

  cat <<PROMPTEOF
You are a research agent investigating a specific question. Your job is to find verifiable facts and update the research document.

RESEARCH GOAL:
${goal_content}

CURRENT DOCUMENT SECTION (${section:-General}):
${doc_section:-No existing content yet.}

TASK: ${title}
${body}

CURRENT SCORE: ${score} (lower is better, 0 = done)
${feedback_block}
${comment_block}

INSTRUCTIONS:
1. Use WebSearch and WebFetch to find information about this specific question.
2. Find at minimum 2 sources, with at least 1 Tier 1 source.
   - Tier 1: Self-published content (subject's own blog/tweets/talks), official docs, institutional pages
   - Tier 2: Mainstream press, Wikipedia with citations
   - Tier 3: Blogs, aggregators — never rely on Tier 3 alone
3. Update the relevant section in document.md with your findings.
4. For each finding, note:
   - Confidence: HIGH / MEDIUM / LOW
   - Depth: HIGH / MEDIUM / LOW
   - Sources with tier classification
5. Add all sources to the ## Sources section of document.md with URLs.
6. Be precise. Only state what sources confirm. Flag uncertainties.
7. Do NOT modify sections outside your assigned area unless adding to Sources.
8. Write findings as clear, factual prose — not bullet dumps.

WORKING DIRECTORY: ${SCRIPT_DIR}
Edit the file: document.md
PROMPTEOF
}

build_document_prompt() {
  local title="$1"
  local body="$2"
  local section="$3"
  local goal_content
  goal_content=$(cat "$SCRIPT_DIR/goal.md")
  local doc_content
  doc_content=$(cat "$SCRIPT_DIR/document.md")

  cat <<PROMPTEOF
You are a document synthesis agent. Your job is to improve the coherence and quality of an existing research document WITHOUT adding new claims.

RESEARCH GOAL:
${goal_content}

FULL DOCUMENT:
${doc_content}

TASK: ${title}
${body}

INSTRUCTIONS:
1. Synthesize the referenced sections into coherent narrative prose.
2. Do NOT use web search. Do NOT add new claims or facts.
3. Preserve all existing confidence levels and source citations.
4. Improve flow, remove redundancy, strengthen transitions.
5. Keep the same section structure.
6. Do NOT remove any sourced claims.

WORKING DIRECTORY: ${SCRIPT_DIR}
Edit the file: document.md
PROMPTEOF
}

build_review_prompt() {
  local title="$1"
  local body="$2"
  local section="$3"
  local doc_content
  doc_content=$(cat "$SCRIPT_DIR/document.md")

  cat <<PROMPTEOF
You are a quality review agent. Your job is to evaluate the research document and flag issues.

FULL DOCUMENT:
${doc_content}

SECTION TO REVIEW: ${section:-Entire document}

TASK: ${title}
${body}

INSTRUCTIONS:
1. Evaluate quality only. Do NOT add new content or research.
2. Flag:
   - Claims without sufficient sources
   - Confidence levels that seem too high for the evidence
   - Contradictions between sections
   - Gaps in coverage
3. Update confidence badges where warranted (HIGH/MEDIUM/LOW).
4. Add notes in the Open Questions section for unresolved issues.
5. Do NOT use web search.

WORKING DIRECTORY: ${SCRIPT_DIR}
Edit the file: document.md
PROMPTEOF
}

# ============================================================================
# Research Execution
# ============================================================================

run_research() {
  local task_type="$1"
  local prompt="$2"
  local tools=""
  local max_turns=0

  case "$task_type" in
    research)
      tools="Bash,Read,Write,WebSearch,WebFetch"
      max_turns=15
      ;;
    document)
      tools="Bash,Read,Write"
      max_turns=8
      ;;
    review)
      tools="Bash,Read,Write"
      max_turns=6
      ;;
  esac

  log "Running Claude Code: type=$task_type, model=$model, max_turns=$max_turns"

  # Write prompt to temp file to avoid ARG_MAX limits on large documents
  local prompt_file
  prompt_file=$(mktemp "$SCRIPT_DIR/.prompt-XXXXXX.txt")
  printf '%s' "$prompt" > "$prompt_file"

  # Pipe prompt via stdin to avoid shell ARG_MAX on large documents
  cat "$prompt_file" | claude -p \
    --model "$model" \
    --allowedTools "$tools" \
    --max-turns "$max_turns" \
    2>&1 | tee -a "$SCRIPT_DIR/research.log" || true

  rm -f "$prompt_file"
}

# ============================================================================
# PR Management
# ============================================================================

create_pr() {
  local issue_num="$1"
  local title="$2"
  local branch="$3"
  local task_type="$4"
  local old_score="$5"
  local new_score="$6"

  git add document.md goal.md coverage.md changelog.md 2>/dev/null || true
  git commit -m "research(#${issue_num}): ${title}" || {
    log "ERROR: Nothing to commit"
    return 1
  }
  git push origin "$branch"

  local pr_body
  pr_body=$(cat <<PRBODYEOF
## Research Update

**Task:** #${issue_num} — ${title}
**Type:** ${task_type}
**Score:** ${old_score} -> ${new_score} (delta: $((old_score - new_score)))

### Changes
- Updated document.md with research findings
- Added sources to Sources section

Closes #${issue_num}
PRBODYEOF
)

  gh pr create \
    --title "research(#${issue_num}): ${title}" \
    --body "$pr_body" \
    --label "needs-review" \
    --head "$branch" \
    --base main

  gh issue edit "$issue_num" --add-label "awaiting-review" --remove-label "in-progress"
}

handle_pr_verdict() {
  local issue_num="$1"
  local branch="$2"

  if [[ "$NO_JUDGES" == "1" ]]; then
    log "NO_JUDGES mode: auto-merging PR"
    local pr_num
    pr_num=$(gh pr list --head "$branch" --json number --jq '.[0].number' 2>/dev/null || echo "")
    if [[ -n "$pr_num" ]]; then
      gh pr merge "$pr_num" --merge --delete-branch
      gh issue close "$issue_num" --comment "Implemented (auto-merged, no judges)"
      gh issue edit "$issue_num" --add-label "implemented" --remove-label "awaiting-review"
      log "PR #${pr_num} auto-merged, Issue #${issue_num} closed"
      last_action="merged"
    fi
    return
  fi

  # Poll for verdict (judges mode)
  log "Waiting for judge verdicts (polling every ${POLL_INTERVAL}s, max ${POLL_MAX}s)..."
  local elapsed=0
  while [[ $elapsed -lt $POLL_MAX ]]; do
    sleep "$POLL_INTERVAL"
    elapsed=$((elapsed + POLL_INTERVAL))

    local pr_num
    pr_num=$(gh pr list --head "$branch" --json number --jq '.[0].number' 2>/dev/null || echo "")
    if [[ -z "$pr_num" ]]; then
      log "PR no longer open — checking if merged"
      local pr_state
      pr_state=$(gh pr view "$branch" --json state --jq '.state' 2>/dev/null || echo "UNKNOWN")
      if [[ "$pr_state" == "MERGED" ]]; then
        log "PR merged by judges"
        last_action="merged"
        return
      elif [[ "$pr_state" == "CLOSED" ]]; then
        log "PR closed (changes requested) — Issue will re-enter queue"
        last_action="rejected"
        return
      fi
    fi

    # Check review count
    local review_count
    review_count=$(gh pr view "$pr_num" --json reviews --jq '.reviews | length' 2>/dev/null || echo 0)
    log "Poll: ${elapsed}s elapsed, ${review_count} reviews on PR #${pr_num}"

    if [[ "$review_count" -ge 3 ]]; then
      log "3 reviews received — verdict workflow should handle merge"
      sleep 10  # give verdict.yml time to act
    fi
  done

  log "WARNING: Poll timeout after ${POLL_MAX}s — PR still pending"
  last_action="timeout"
}

cleanup_failed() {
  local issue_num="$1"
  local branch="$2"

  git checkout main 2>/dev/null || true
  git branch -D "$branch" 2>/dev/null || true
  gh issue edit "$issue_num" --remove-label "in-progress" 2>/dev/null || true
  last_action="no_change"
}

# ============================================================================
# Startup Checks
# ============================================================================

startup() {
  session_start=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
  log "============================================"
  log "Research session starting"
  log "MAX_ITERATIONS=$MAX_ITERATIONS"
  log "RESEARCH_MODEL=$RESEARCH_MODEL"
  log "NO_JUDGES=$NO_JUDGES"
  log "============================================"

  # Verify prerequisites
  if ! gh auth status &>/dev/null; then
    log "ERROR: GitHub CLI not authenticated. Run 'gh auth login'"
    exit 1
  fi

  if ! command -v claude &>/dev/null; then
    log "ERROR: Claude Code CLI not found. Run 'npm install -g @anthropic-ai/claude-code'"
    exit 1
  fi

  if [[ -z "${ANTHROPIC_API_KEY:-}" ]]; then
    log "ERROR: ANTHROPIC_API_KEY not set"
    exit 1
  fi

  if ! command -v jq &>/dev/null; then
    log "ERROR: jq not found. Install with 'brew install jq'"
    exit 1
  fi

  # Ensure we're on main
  git checkout main 2>/dev/null || git checkout -b main
  git pull origin main 2>/dev/null || true

  # Clean up stale in-progress labels from previous crashed sessions
  local stale_issues
  stale_issues=$(gh issue list --label "in-progress" --state open --json number --jq '.[].number' 2>/dev/null || true)
  if [[ -n "$stale_issues" ]]; then
    log "Cleaning up stale in-progress labels..."
    for stale_num in $stale_issues; do
      gh issue edit "$stale_num" --remove-label "in-progress" 2>/dev/null || true
      log "  Removed in-progress from Issue #$stale_num"
    done
  fi

  # Clean up orphaned task branches
  for orphan_branch in $(git branch --list 'task/*' 2>/dev/null); do
    git branch -D "$orphan_branch" 2>/dev/null || true
    log "  Deleted orphaned branch $orphan_branch"
  done

  # Compute initial score
  starting_score=$(compute_score)
  score=$starting_score
  log "Initial score: $score"

  # Parse subject from goal.md (cached, re-parsed on goal change)
  subject=$(head -5 "$SCRIPT_DIR/goal.md" | grep -i "^#" | head -1 | sed 's/^#* *//' | sed 's/ *—.*//')
  log "Subject: $subject"

  # Record goal.md mtime
  goal_mtime=$(stat -f %m "$SCRIPT_DIR/goal.md" 2>/dev/null || stat -c %Y "$SCRIPT_DIR/goal.md" 2>/dev/null || echo 0)

  write_status true
}

# ============================================================================
# Main Loop
# ============================================================================

main_loop() {
  while [[ $iteration -lt $MAX_ITERATIONS ]]; do
    iteration=$((iteration + 1))
    log "--- Iteration $iteration / $MAX_ITERATIONS ---"

    # 1. Pause check
    while [[ -f "$SCRIPT_DIR/pause.flag" ]]; do
      log "PAUSED — waiting for pause.flag removal..."
      write_status true
      sleep 5
    done

    # 2. Feedback check
    if [[ -f "$SCRIPT_DIR/feedback.md" ]]; then
      feedback=$(cat "$SCRIPT_DIR/feedback.md")
      rm -f "$SCRIPT_DIR/feedback.md"
      log "Feedback received: $feedback"
    fi

    # 3. Goal change check
    local current_goal_mtime
    current_goal_mtime=$(stat -f %m "$SCRIPT_DIR/goal.md" 2>/dev/null || stat -c %Y "$SCRIPT_DIR/goal.md" 2>/dev/null || echo 0)
    if [[ "$current_goal_mtime" != "$goal_mtime" ]]; then
      log "goal.md changed — goal-manager will handle sync"
      goal_mtime="$current_goal_mtime"
      subject=$(head -5 "$SCRIPT_DIR/goal.md" | grep -i "^#" | head -1 | sed 's/^#* *//' | sed 's/ *—.*//')
      log "Subject updated: $subject"
    fi

    # 4. Select next task
    local issue_num
    issue_num=$(get_next_issue)

    if [[ -z "$issue_num" ]]; then
      log "No accepted tasks available. Waiting 60s..."
      current_task=""
      current_issue=0
      last_action="waiting"
      write_status true
      sleep 60
      continue
    fi

    # 5. Read task details
    local issue_json
    issue_json=$(read_issue "$issue_num")
    local title
    title=$(get_issue_field "$issue_json" "title")
    local body
    body=$(get_issue_field "$issue_json" "body")
    local comments
    comments=$(echo "$issue_json" | jq -r '.comments[]?.body // empty' | head -500)

    current_task="$title"
    current_issue="$issue_num"

    # Check if hard task
    if is_hard_task "$issue_json"; then
      model="$HARD_RESEARCH_MODEL"
      log "Hard task detected — using $model"
    else
      model="$RESEARCH_MODEL"
    fi

    local task_type
    task_type=$(get_task_type "$issue_json")
    local section
    section=$(get_section_from_body "$body")
    local slug
    slug=$(slugify "$title")
    local branch="task/${issue_num}-${slug}"

    log "Task #${issue_num}: ${title} (type: ${task_type}, section: ${section:-none})"

    # 6. Label issue in-progress
    gh issue edit "$issue_num" --add-label "in-progress"

    # 7. Create branch from latest main
    git checkout main
    git pull origin main --rebase 2>/dev/null || true
    git checkout -b "$branch"

    # 8-9. Build prompt and run research
    local prompt=""
    case "$task_type" in
      research)
        prompt=$(build_research_prompt "$title" "$body" "$section" "$comments")
        ;;
      document)
        prompt=$(build_document_prompt "$title" "$body" "$section")
        ;;
      review)
        prompt=$(build_review_prompt "$title" "$body" "$section")
        ;;
    esac

    local old_score=$score
    write_status true

    run_research "$task_type" "$prompt"

    # 10. Compute new score
    local new_score
    new_score=$(compute_score)
    score=$new_score

    log "Score: $old_score -> $new_score (delta: $((old_score - new_score)))"

    # 11-12. Handle result
    # For document/review tasks, score won't change (formula counts open tasks, not quality).
    # Check if document.md was actually modified instead.
    local doc_changed=false
    if [[ "$task_type" != "research" ]]; then
      if ! git diff --quiet document.md 2>/dev/null; then
        doc_changed=true
        log "Document modified by $task_type task"
      fi
    fi

    if [[ $new_score -lt $old_score ]] || [[ "$doc_changed" == "true" ]]; then
      log "Score improved! Creating PR..."

      if create_pr "$issue_num" "$title" "$branch" "$task_type" "$old_score" "$new_score"; then
        last_action="improved"
        write_status true
        handle_pr_verdict "$issue_num" "$branch"
        # Return to main and pull latest (includes the just-merged PR)
        git checkout main 2>/dev/null || true
        git pull origin main 2>/dev/null || true
      else
        log "PR creation failed — cleaning up"
        cleanup_failed "$issue_num" "$branch"
      fi
    else
      log "Score did not improve — reverting"
      cleanup_failed "$issue_num" "$branch"
    fi

    # 14. Update status
    write_status true
    log "Iteration $iteration complete. Score: $score"

    # Clear per-iteration feedback
    feedback=""
  done
}

# ============================================================================
# Shutdown
# ============================================================================

shutdown() {
  log "============================================"
  log "Research session complete"
  log "Iterations: $iteration / $MAX_ITERATIONS"
  log "Score: $starting_score -> $score"
  log "============================================"
  write_status false
}

# Trap for clean shutdown on SIGINT/SIGTERM
trap 'log "Interrupted — shutting down"; shutdown; exit 0' INT TERM

# --- Run ---
cd "$SCRIPT_DIR"
startup
main_loop
shutdown
