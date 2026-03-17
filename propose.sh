#!/bin/bash
# shellcheck disable=SC2059
set -euo pipefail

# ============================================================================
# propose.sh — Propose and manage research tasks
# Usage:
#   bash propose.sh                  — Interactive (prompt for all fields)
#   bash propose.sh "question"       — Quick create with interactive section/priority
#   bash propose.sh list             — List proposed tasks
#   bash propose.sh accept           — Accept all proposed tasks
#   bash propose.sh accept high      — Accept only high priority proposed tasks
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load .env if present
if [[ -f "$SCRIPT_DIR/.env" ]]; then
  # shellcheck disable=SC1091
  source "$SCRIPT_DIR/.env"
fi

# --- ANSI Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
DIM='\033[2m'
BOLD='\033[1m'
RESET='\033[0m'

# ============================================================================
# Utility Functions
# ============================================================================

die() {
  printf '%bERROR: %s%b\n' "$RED" "$1" "$RESET" >&2
  exit 1
}

info() {
  printf '%b%s%b\n' "$CYAN" "$1" "$RESET"
}

success() {
  printf '%b%s%b\n' "$GREEN" "$1" "$RESET"
}

get_sections() {
  if [[ -f "$SCRIPT_DIR/document.md" ]]; then
    grep "^## " "$SCRIPT_DIR/document.md" | sed 's/^## //' | grep -v "Sources\|Open Questions" || true
  fi
}

# ============================================================================
# Command: list — Show proposed tasks
# ============================================================================

cmd_list() {
  info "Proposed tasks:"
  printf '\n'

  local issues
  issues=$(gh issue list --label "task,proposed" --state open --json number,title,labels --jq '.[] | "\(.number)\t\(.title)\t\(.labels | map(.name) | join(","))"' 2>/dev/null || true)

  if [[ -z "$issues" ]]; then
    printf '  %bNo proposed tasks found.%b\n' "$DIM" "$RESET"
    return
  fi

  local count=0
  while IFS=$'\t' read -r number title labels; do
    count=$((count + 1))

    # Extract priority and type from labels
    local priority="medium"
    local task_type="research"
    if [[ "$labels" == *"priority-high"* ]]; then
      priority="high"
    elif [[ "$labels" == *"priority-low"* ]]; then
      priority="low"
    fi
    if [[ "$labels" == *"type-document"* ]]; then
      task_type="document"
    elif [[ "$labels" == *"type-review"* ]]; then
      task_type="review"
    fi

    # Priority color
    local pcolor="$YELLOW"
    if [[ "$priority" == "high" ]]; then
      pcolor="$RED"
    elif [[ "$priority" == "low" ]]; then
      pcolor="$DIM"
    fi

    printf '  %b#%-4s%b %b[%-6s]%b %b%-10s%b %s\n' \
      "$BOLD" "$number" "$RESET" "$pcolor" "$priority" "$RESET" "$CYAN" "$task_type" "$RESET" "$title"
  done <<< "$issues"

  printf '\n  %bTotal: %d proposed tasks%b\n' "$DIM" "$count" "$RESET"
}

# ============================================================================
# Command: accept — Accept proposed tasks
# ============================================================================

cmd_accept() {
  local filter_priority="${1:-}"
  local label_filter="task,proposed"

  if [[ -n "$filter_priority" ]]; then
    label_filter="task,proposed,priority-${filter_priority}"
    info "Accepting proposed tasks with priority: $filter_priority"
  else
    info "Accepting all proposed tasks"
  fi

  local issue_numbers
  issue_numbers=$(gh issue list --label "$label_filter" --state open --json number --jq '.[].number' 2>/dev/null || true)

  if [[ -z "$issue_numbers" ]]; then
    printf '  %bNo proposed tasks found matching filter.%b\n' "$DIM" "$RESET"
    return
  fi

  local count=0
  for num in $issue_numbers; do
    gh issue edit "$num" --add-label "accepted" --remove-label "proposed" 2>/dev/null || {
      printf '  %bFailed to accept #%s%b\n' "$RED" "$num" "$RESET"
      continue
    }
    local title
    title=$(gh issue view "$num" --json title --jq '.title' 2>/dev/null || echo "unknown")
    printf '  %bAccepted%b #%s — %s\n' "$GREEN" "$RESET" "$num" "$title"
    count=$((count + 1))
  done

  printf '\n  %bAccepted %d tasks.%b\n' "$GREEN" "$count" "$RESET"
}

# ============================================================================
# Command: create — Interactive task creation
# ============================================================================

prompt_field() {
  local prompt_text="$1"
  local default_value="${2:-}"
  local result=""

  if [[ -n "$default_value" ]]; then
    printf '%b%s%b %b[%s]%b: ' "$BOLD" "$prompt_text" "$RESET" "$DIM" "$default_value" "$RESET"
  else
    printf '%b%s%b: ' "$BOLD" "$prompt_text" "$RESET"
  fi

  read -r result
  if [[ -z "$result" && -n "$default_value" ]]; then
    result="$default_value"
  fi
  echo "$result"
}

prompt_choice() {
  local prompt_text="$1"
  shift
  local options=("$@")
  local default="${options[0]}"

  printf '%b%s%b\n' "$BOLD" "$prompt_text" "$RESET"
  local i=1
  for opt in "${options[@]}"; do
    if [[ $i -eq 1 ]]; then
      printf '  %b%d)%b %s %b(default)%b\n' "$CYAN" "$i" "$RESET" "$opt" "$DIM" "$RESET"
    else
      printf '  %b%d)%b %s\n' "$CYAN" "$i" "$RESET" "$opt"
    fi
    i=$((i + 1))
  done
  printf '%bChoice%b: ' "$BOLD" "$RESET"

  local choice
  read -r choice

  if [[ -z "$choice" || "$choice" -lt 1 || "$choice" -gt ${#options[@]} ]] 2>/dev/null; then
    echo "$default"
  else
    echo "${options[$((choice - 1))]}"
  fi
}

prompt_section() {
  local sections
  sections=$(get_sections)

  if [[ -z "$sections" ]]; then
    prompt_field "Section name"
    return
  fi

  printf '%bSection:%b\n' "$BOLD" "$RESET"
  local i=1
  local section_arr=()
  while IFS= read -r section; do
    section_arr+=("$section")
    printf '  %b%d)%b %s\n' "$CYAN" "$i" "$RESET" "$section"
    i=$((i + 1))
  done <<< "$sections"
  printf '  %b%d)%b %b(other — type custom)%b\n' "$CYAN" "$i" "$RESET" "$DIM" "$RESET"
  printf '%bChoice%b: ' "$BOLD" "$RESET"

  local choice
  read -r choice

  if [[ -z "$choice" ]]; then
    echo "${section_arr[0]}"
  elif [[ "$choice" -ge 1 && "$choice" -le ${#section_arr[@]} ]] 2>/dev/null; then
    echo "${section_arr[$((choice - 1))]}"
  else
    prompt_field "Custom section name"
  fi
}

cmd_create() {
  local question="${1:-}"

  printf '\n%b%b  ╔══════════════════════════════════════════╗%b\n' "$BOLD" "$CYAN" "$RESET"
  printf '%b%b  ║       PROPOSE RESEARCH TASK              ║%b\n' "$BOLD" "$CYAN" "$RESET"
  printf '%b%b  ╚══════════════════════════════════════════╝%b\n\n' "$BOLD" "$CYAN" "$RESET"

  # Question
  if [[ -z "$question" ]]; then
    question=$(prompt_field "Research question")
    if [[ -z "$question" ]]; then
      die "Question cannot be empty"
    fi
  else
    printf '  %bQuestion:%b %s\n\n' "$BOLD" "$RESET" "$question"
  fi

  # Section
  local section
  section=$(prompt_section)
  if [[ -z "$section" ]]; then
    die "Section cannot be empty"
  fi
  printf '\n'

  # Priority
  local priority
  priority=$(prompt_choice "Priority:" "medium" "high" "low")
  printf '\n'

  # Type
  local task_type
  task_type=$(prompt_choice "Type:" "research" "document" "review")
  printf '\n'

  # Confirmation
  printf '%b  ── Summary ──────────────────────────────%b\n' "$DIM" "$RESET"
  printf '  %bQuestion:%b %s\n' "$BOLD" "$RESET" "$question"
  printf '  %bSection:%b  %s\n' "$BOLD" "$RESET" "$section"
  printf '  %bPriority:%b %s\n' "$BOLD" "$RESET" "$priority"
  printf '  %bType:%b     %s\n' "$BOLD" "$RESET" "$task_type"
  printf '\n'

  printf '%bCreate this task? %b%b[Y/n]%b: ' "$BOLD" "$RESET" "$DIM" "$RESET"
  local confirm
  read -r confirm
  if [[ "$confirm" =~ ^[Nn] ]]; then
    printf '\n  %bCancelled.%b\n' "$YELLOW" "$RESET"
    exit 0
  fi

  # Build issue body
  local capitalize_type
  capitalize_type="$(echo "${task_type:0:1}" | tr '[:lower:]' '[:upper:]')${task_type:1}"

  local issue_body
  issue_body="## Type
${capitalize_type}

## Section
${section}

## Why needed
Human-proposed research question.

## What to find
${question}"

  # Create issue
  local issue_url
  issue_url=$(gh issue create \
    --title "$question" \
    --body "$issue_body" \
    --label "task,proposed,human-proposed,type-${task_type},priority-${priority}" \
    2>/dev/null) || die "Failed to create issue. Is 'gh' authenticated?"

  printf '\n'
  success "  Task created!"
  printf '  %bURL:%b %s\n' "$BOLD" "$RESET" "$issue_url"
  printf '\n  %bTo accept: bash propose.sh accept%b\n' "$DIM" "$RESET"
  printf '  %bOr:        gh issue edit <number> --add-label accepted --remove-label proposed%b\n\n' "$DIM" "$RESET"
}

# ============================================================================
# Ensure labels exist
# ============================================================================

ensure_labels() {
  # Create labels if they don't exist (--force is idempotent)
  gh label create "human-proposed" --color "d4c5f9" --description "Proposed by human" --force 2>/dev/null || true
}

# ============================================================================
# Entry Point
# ============================================================================

# Check prerequisites
if ! gh auth status &>/dev/null 2>&1; then
  die "GitHub CLI not authenticated. Run 'gh auth login'"
fi

mode="${1:-}"

case "$mode" in
  list)
    cmd_list
    ;;
  accept)
    cmd_accept "${2:-}"
    ;;
  "")
    ensure_labels
    cmd_create ""
    ;;
  *)
    # If it starts with a dash, it's an unknown flag
    if [[ "$mode" == -* ]]; then
      echo "Usage: bash propose.sh [list|accept [priority]|\"question\"]"
      exit 1
    fi
    # Otherwise treat as a question
    ensure_labels
    cmd_create "$mode"
    ;;
esac
