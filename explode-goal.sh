#!/bin/bash
set -euo pipefail

# ============================================================================
# explode-goal.sh — Generate 30-50 research task Issues from goal.md
# Reads goal.md, calls Claude to decompose into specific questions,
# creates one GitHub Issue per question with labels and section assignment.
# Usage: bash explode-goal.sh
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load .env if present
if [[ -f "$SCRIPT_DIR/.env" ]]; then
  # shellcheck disable=SC1091
  source "$SCRIPT_DIR/.env"
fi

log() {
  local msg
  msg="[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] $*"
  echo "$msg"
}

# --- Prerequisites ---
if [[ ! -f "$SCRIPT_DIR/goal.md" ]]; then
  log "ERROR: goal.md not found"
  exit 1
fi

if ! command -v claude &>/dev/null; then
  log "ERROR: Claude Code CLI not found"
  exit 1
fi

if [[ -z "${ANTHROPIC_API_KEY:-}" && -z "${CLAUDE_CODE_OAUTH_TOKEN:-}" ]]; then
  log "ERROR: ANTHROPIC_API_KEY or CLAUDE_CODE_OAUTH_TOKEN must be set"
  exit 1
fi

# --- Ensure labels exist ---
log "Ensuring labels exist..."
for label in task proposed ai-proposed type-research type-document type-review \
  priority-high priority-medium priority-low accepted; do
  gh label create "$label" --force 2>/dev/null || true
done

# --- Read goal ---
goal_content=$(cat "$SCRIPT_DIR/goal.md")

# --- Read existing issues to avoid duplicates ---
existing_titles=$(gh issue list --label "task" --state all --json title --jq '.[].title' 2>/dev/null || true)

# --- Read document sections ---
sections=$(grep "^## " "$SCRIPT_DIR/document.md" | sed 's/^## //' | grep -v "Sources\|Open Questions" || true)

log "Goal loaded. Sections: $(echo "$sections" | tr '\n' ', ')"
log "Calling Claude to generate research questions..."

# --- Build prompt ---
prompt_file=$(mktemp "$SCRIPT_DIR/.explode-XXXXXX.txt")
trap 'rm -f "$prompt_file"' EXIT

cat > "$prompt_file" <<PROMPTEOF
You are a research planner. Given the research goal below, generate 30-50 specific, actionable research questions.

RESEARCH GOAL:
${goal_content}

DOCUMENT SECTIONS:
${sections}

EXISTING TASKS (do not duplicate these):
${existing_titles}

OUTPUT FORMAT — You MUST output ONLY a JSON array. No markdown, no explanation, no code fences.
Each element must be an object with exactly these fields:
{
  "title": "Short specific question (under 80 chars)",
  "section": "Exact section name from the list above",
  "type": "research|document|review",
  "priority": "high|medium|low",
  "body": "2-3 sentences explaining what to find and why",
  "sources": "Suggested sources to check",
  "criteria": "2-3 bullet acceptance criteria"
}

RULES:
- 70% should be type "research" (needs web search)
- 20% should be type "document" (synthesis of existing findings)
- 10% should be type "review" (quality check)
- Priority distribution: 30% high, 50% medium, 20% low
- Each question must map to exactly one section
- Be specific: "What was Karpathy's PhD thesis topic?" not "Research his education"
- Document tasks should only be created for sections that will have research content
- Review tasks should cover cross-section consistency and source verification
- Do NOT duplicate any existing tasks listed above
- Generate between 30 and 50 questions

OUTPUT ONLY THE JSON ARRAY. Nothing else.
PROMPTEOF

# --- Call Claude ---
local_args=(-p --permission-mode acceptEdits --allowedTools "Read" --max-turns 5)

raw_output=$(cat "$prompt_file" | claude "${local_args[@]}" 2>/dev/null || echo "[]")

# --- Extract JSON from response (Claude may wrap in markdown) ---
json_output=$(echo "$raw_output" | sed -n '/^\[/,/^\]/p' | head -500)

if [[ -z "$json_output" ]]; then
  # Try extracting from code fence
  # shellcheck disable=SC2016
  json_output=$(echo "$raw_output" | sed -n '/```json/,/```/p' | sed '1d;$d')
fi

if [[ -z "$json_output" ]]; then
  log "ERROR: Could not parse Claude output as JSON"
  log "Raw output:"
  echo "$raw_output"
  exit 1
fi

# --- Validate JSON ---
task_count=$(echo "$json_output" | jq 'length' 2>/dev/null || echo 0)
if [[ "$task_count" -lt 1 ]]; then
  log "ERROR: No tasks generated. Raw output:"
  echo "$raw_output"
  exit 1
fi

log "Generated $task_count research questions. Creating Issues..."

# --- Create Issues ---
created=0
skipped=0

for i in $(seq 0 $((task_count - 1))); do
  title=$(echo "$json_output" | jq -r ".[$i].title")
  section=$(echo "$json_output" | jq -r ".[$i].section")
  task_type=$(echo "$json_output" | jq -r ".[$i].type")
  priority=$(echo "$json_output" | jq -r ".[$i].priority")
  body_text=$(echo "$json_output" | jq -r ".[$i].body")
  sources=$(echo "$json_output" | jq -r ".[$i].sources")
  criteria=$(echo "$json_output" | jq -r ".[$i].criteria")

  # Skip duplicates
  if echo "$existing_titles" | grep -qF "$title" 2>/dev/null; then
    log "  SKIP (duplicate): $title"
    skipped=$((skipped + 1))
    continue
  fi

  # Build issue body
  issue_body="## Type
$(echo "${task_type:0:1}" | tr '[:lower:]' '[:upper:]')${task_type:1}

## Section
${section}

## Why needed
${body_text}

## What to find
${body_text}

## Suggested sources
${sources}

## Acceptance criteria
${criteria}"

  # Map type/priority to labels
  type_label="type-${task_type}"
  priority_label="priority-${priority}"

  gh issue create \
    --title "$title" \
    --body "$issue_body" \
    --label "task,proposed,ai-proposed,${type_label},${priority_label}" \
    2>/dev/null || {
      log "  ERROR creating: $title"
      continue
    }

  created=$((created + 1))
  log "  [$created] $title (${task_type}, ${priority}, ${section})"
done

log ""
log "=========================================="
log "  Done! Created $created Issues, skipped $skipped duplicates."
log "  Total generated: $task_count"
log ""
log "  To accept all high-priority tasks:"
log "    gh issue list --label 'proposed,priority-high' --json number --jq '.[].number' | xargs -I{} gh issue edit {} --add-label accepted --remove-label proposed"
log ""
log "  To accept individually:"
log "    gh issue edit <number> --add-label accepted --remove-label proposed"
log "=========================================="
