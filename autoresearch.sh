#!/bin/bash
# ============================================================================
# autoresearch.sh — Research score calculator
# Score = 0% to 100%. Higher is better. 100% = done.
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load .env if present
if [[ -f "$SCRIPT_DIR/.env" ]]; then
  # shellcheck disable=SC1091
  source "$SCRIPT_DIR/.env"
fi

DOC_DIR="$SCRIPT_DIR/sections"

# --- Task completion ---
total_tasks=$(gh issue list --label "task" --state all --json number | jq 'length' 2>/dev/null | tr -d '[:space:]')
total_tasks=${total_tasks:-0}
done_tasks=$(gh issue list --label "task,implemented" --state closed --json number | jq 'length' 2>/dev/null | tr -d '[:space:]')
done_tasks=${done_tasks:-0}
rework=$(gh issue list --label "needs-better-research" --state open --json number | jq 'length' 2>/dev/null | tr -d '[:space:]')
rework=${rework:-0}

# Task completion: what % of tasks are done (penalize rework)
task_pct=0
if [[ "$total_tasks" -gt 0 ]]; then
  effective_done=$((done_tasks > rework ? done_tasks - rework : 0))
  task_pct=$(( (effective_done * 100) / total_tasks ))
fi

# --- Citation quality ---
uncited=0
cited=0
low_confidence=0
total_paragraphs=0

# Scan all section files (excluding sources and open-questions)
for section_file in "$DOC_DIR"/intellectual-contributions.md "$DOC_DIR"/education-and-teaching.md "$DOC_DIR"/views-on-ai-future.md "$DOC_DIR"/eureka-labs.md "$DOC_DIR"/key-relationships.md; do
  [[ -f "$section_file" ]] || continue
  while IFS= read -r line; do
    # Skip empty lines, headers, metadata
    [[ -z "$line" ]] && continue
    [[ "$line" =~ ^## ]] && continue
    [[ "$line" =~ ^### ]] && continue
    [[ "$line" =~ ^\*\*Confidence: ]] && continue
    [[ "$line" =~ ^\*\*Uncertainty: ]] && continue
    [[ "$line" =~ ^\> ]] && continue

    # Only count substantive paragraphs (>50 chars)
    [[ ${#line} -le 50 ]] && continue

    total_paragraphs=$((total_paragraphs + 1))

    # Check for inline citations [N]
    if echo "$line" | grep -qE '\[[0-9]+\]'; then
      cited=$((cited + 1))
    else
      uncited=$((uncited + 1))
    fi
  done < "$section_file"
done

# Count LOW confidence across all sections
for section_file in "$DOC_DIR"/*.md; do
  [[ -f "$section_file" ]] || continue
  local_low=$(grep -c "Confidence: LOW" "$section_file" 2>/dev/null || true)
  low_confidence=$((low_confidence + ${local_low:-0}))
done

# Citation quality: what % of paragraphs have citations
citation_pct=100
if [[ "$total_paragraphs" -gt 0 ]]; then
  citation_pct=$(( (cited * 100) / total_paragraphs ))
fi

# Confidence penalty: each LOW confidence section reduces score by 5%
confidence_penalty=$(( low_confidence * 5 ))

# --- Final score: weighted average ---
# 60% task completion + 30% citation quality + 10% base (no LOW confidence)
score=$(( (task_pct * 60 / 100) + (citation_pct * 30 / 100) + (10 - confidence_penalty) ))

# Clamp to 0-100
if [[ $score -lt 0 ]]; then score=0; fi
if [[ $score -gt 100 ]]; then score=100; fi

echo "$score"

# Print breakdown to stderr for debugging
>&2 echo "Score: ${score}% (tasks: ${task_pct}% [${done_tasks}/${total_tasks}, rework=${rework}] | citations: ${citation_pct}% [${cited}/${total_paragraphs}] | confidence: -${confidence_penalty}%)"
