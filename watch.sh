#!/bin/bash
# shellcheck disable=SC2059
set -euo pipefail

# ============================================================================
# watch.sh — Real-time research monitor
# Usage:
#   bash watch.sh              — Dashboard (default 30s refresh)
#   bash watch.sh live         — Status + streaming Claude output
#   bash watch.sh dashboard 60 — Dashboard with custom refresh
#   bash watch.sh log          — Color-coded tail of research.log
#   bash watch.sh status       — One-shot status
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -f "$SCRIPT_DIR/.env" ]]; then
  # shellcheck disable=SC1091
  source "$SCRIPT_DIR/.env"
fi

# --- ANSI Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
DIM='\033[2m'
BOLD='\033[1m'
RESET='\033[0m'
BG_GREEN='\033[42m'
BG_RED='\033[41m'
BG_YELLOW='\033[43m'

STATUS_FILE="$SCRIPT_DIR/status.json"
LOG_FILE="$SCRIPT_DIR/research.log"

# ============================================================================
# Helpers
# ============================================================================

read_status_field() {
  if [[ -f "$STATUS_FILE" ]]; then
    jq -r ".$1 // empty" "$STATUS_FILE" 2>/dev/null || echo ""
  else
    echo ""
  fi
}

score_bar() {
  local pct="${1:-0}"
  local width=30
  local filled=$(( (pct * width) / 100 ))
  local empty=$((width - filled))
  local color="$RED"
  if [[ $pct -ge 80 ]]; then color="$GREEN"
  elif [[ $pct -ge 60 ]]; then color="$BLUE"
  elif [[ $pct -ge 40 ]]; then color="$YELLOW"
  fi
  printf '%b' "$color"
  for ((i=0; i<filled; i++)); do printf '█'; done
  printf '%b' "$DIM"
  for ((i=0; i<empty; i++)); do printf '░'; done
  printf '%b %b%s%%%b' "$RESET" "$BOLD" "$pct" "$RESET"
}

colorize_log_line() {
  local line="$1"
  local timestamp="" message="$line"
  if [[ "$line" =~ ^\[([0-9T:Z-]+)\]\ (.*) ]]; then
    timestamp="${BASH_REMATCH[1]}"
    message="${BASH_REMATCH[2]}"
  fi

  local color="$RESET"
  local icon=" "
  if [[ "$message" =~ (ERROR|FAIL|failed|FAILED|REJECTED) ]]; then
    color="$RED"; icon="✗"
  elif [[ "$message" =~ (merged|auto-merged|PR\ #) ]]; then
    color="$GREEN"; icon="✓"
  elif [[ "$message" =~ (PASSED|APPROVE|improved) ]]; then
    color="$GREEN"; icon="+"
  elif [[ "$message" =~ (WARNING|PAUSED|timeout|no_change|reverting|No\ document) ]]; then
    color="$YELLOW"; icon="!"
  elif [[ "$message" =~ (Judge\ review|Judge\ [0-9]|Round\ [0-9]) ]]; then
    color="$MAGENTA"; icon="⚖"
  elif [[ "$message" =~ (Proposed:|follow-up) ]]; then
    color="$BLUE"; icon="→"
  elif [[ "$message" =~ (Task\ #|Iteration) ]]; then
    color="$CYAN"; icon="▸"
  elif [[ "$message" =~ (Running\ Claude|max_turns) ]]; then
    color="$WHITE"; icon="◆"
  elif [[ "$message" =~ (Header\ updated|Changelog|Post-merge|Score:) ]]; then
    color="$DIM"; icon="·"
  fi

  if [[ -n "$timestamp" ]]; then
    # Show only time, not date
    local short_time="${timestamp##*T}"
    short_time="${short_time%%Z*}"
    printf '  %b%s%b %b%s %s%b\n' "$DIM" "$short_time" "$RESET" "$color" "$icon" "$message" "$RESET"
  else
    printf '  %b%s %s%b\n' "$color" "$icon" "$line" "$RESET"
  fi
}

# ============================================================================
# Task Pipeline (from GitHub)
# ============================================================================

get_pipeline_counts() {
  # Single API call for all task stats
  local all_issues
  all_issues=$(gh issue list --label "task" --state all --limit 200 --json state,labels 2>/dev/null || echo "[]")

  local completed proposed accepted in_progress total
  total=$(echo "$all_issues" | jq 'length')
  completed=$(echo "$all_issues" | jq '[.[] | select(.state == "CLOSED") | select(.labels | map(.name) | contains(["implemented"]))] | length')
  proposed=$(echo "$all_issues" | jq '[.[] | select(.state == "OPEN") | select(.labels | map(.name) | contains(["proposed"]))] | length')
  accepted=$(echo "$all_issues" | jq '[.[] | select(.state == "OPEN") | select(.labels | map(.name) | contains(["accepted"])) | select(.labels | map(.name) | contains(["in-progress"]) | not)] | length')
  in_progress=$(echo "$all_issues" | jq '[.[] | select(.labels | map(.name) | contains(["in-progress"]))] | length')

  echo "$completed $proposed $accepted $in_progress $total"
}

# ============================================================================
# Status Display
# ============================================================================

show_status() {
  local running iteration max_iterations score current_task
  local current_issue last_action subject

  if [[ ! -f "$STATUS_FILE" ]]; then
    printf '  %bNo session yet. Run: bash research.sh%b\n' "$DIM" "$RESET"
    return
  fi

  running=$(read_status_field "running")
  iteration=$(read_status_field "iteration")
  max_iterations=$(read_status_field "max_iterations")
  score=$(read_status_field "score")
  current_task=$(read_status_field "current_task" | tr -d '\n')
  current_issue=$(read_status_field "current_issue")
  last_action=$(read_status_field "last_action")
  subject=$(read_status_field "subject" | tr -d '\n')

  # Status badge
  local status_badge
  if [[ -f "$SCRIPT_DIR/pause.flag" ]]; then
    status_badge="${BG_YELLOW}${WHITE} PAUSED ${RESET}"
  elif [[ "$running" == "true" ]]; then
    status_badge="${BG_GREEN}${WHITE} RUNNING ${RESET}"
  else
    status_badge="${BG_RED}${WHITE} STOPPED ${RESET}"
  fi

  # Score
  local live_score
  live_score=$(bash "$SCRIPT_DIR/autoresearch.sh" 2>/dev/null || echo "$score")
  local breakdown
  breakdown=$(bash "$SCRIPT_DIR/autoresearch.sh" 2>&1 >/dev/null || true)

  # Last action
  local action_icon
  case "${last_action:-none}" in
    merged)    action_icon="${GREEN}✓ merged${RESET}" ;;
    improved)  action_icon="${GREEN}↑ improved${RESET}" ;;
    no_change) action_icon="${YELLOW}— no change${RESET}" ;;
    waiting)   action_icon="${DIM}⏳ waiting${RESET}" ;;
    rejected)  action_icon="${RED}✗ rejected${RESET}" ;;
    *)         action_icon="${DIM}${last_action:-none}${RESET}" ;;
  esac

  printf '\n'
  printf '  %b%-14s%b %s\n' "$BOLD" "Subject" "$RESET" "${subject:-unknown}"
  printf '  %b%-14s%b %b\n' "$BOLD" "Status" "$RESET" "$status_badge"
  printf '  %b%-14s%b ' "$BOLD" "Score" "$RESET"
  score_bar "$live_score"
  printf '\n'
  printf '  %b%-14s%b %b%s%b\n' "$BOLD" "Breakdown" "$RESET" "$DIM" "$breakdown" "$RESET"
  printf '  %b%-14s%b %s / %s\n' "$BOLD" "Iteration" "$RESET" "${iteration:-0}" "${max_iterations:-0}"
  printf '  %b%-14s%b %b\n' "$BOLD" "Last Action" "$RESET" "$action_icon"

  if [[ -n "$current_task" && "$current_task" != "null" ]]; then
    printf '  %b%-14s%b %b#%s%b %s\n' "$BOLD" "Current Task" "$RESET" "$CYAN" "${current_issue:-?}" "$RESET" "$current_task"
  fi

  printf '\n'
}

# ============================================================================
# Pipeline Display
# ============================================================================

show_pipeline() {
  local counts
  counts=$(get_pipeline_counts 2>/dev/null || echo "0 0 0 0 0")
  local completed proposed accepted in_progress total
  read -r completed proposed accepted in_progress total <<< "$counts"

  printf '  %b%-14s%b ' "$BOLD" "Pipeline" "$RESET"
  printf '%b●%b%s done  ' "$GREEN" "$RESET" "$completed"
  printf '%b●%b%s active  ' "$CYAN" "$RESET" "$in_progress"
  printf '%b●%b%s queued  ' "$BLUE" "$RESET" "$accepted"
  printf '%b●%b%s proposed  ' "$DIM" "$RESET" "$proposed"
  printf '%b(%s total)%b\n' "$DIM" "$total" "$RESET"
}

# ============================================================================
# Section Coverage
# ============================================================================

show_sections() {
  printf '  %b%-14s%b' "$BOLD" "Sections" "$RESET"
  local first=true
  for f in "$SCRIPT_DIR/sections"/intellectual-contributions.md \
           "$SCRIPT_DIR/sections"/education-and-teaching.md \
           "$SCRIPT_DIR/sections"/views-on-ai-future.md \
           "$SCRIPT_DIR/sections"/eureka-labs.md \
           "$SCRIPT_DIR/sections"/key-relationships.md; do
    [[ -f "$f" ]] || continue
    local name
    name=$(basename "$f" .md | sed 's/-/ /g')
    local lines
    lines=$(wc -l < "$f" | tr -d ' ')
    local color="$RED"
    if [[ $lines -gt 50 ]]; then color="$GREEN"
    elif [[ $lines -gt 20 ]]; then color="$BLUE"
    elif [[ $lines -gt 5 ]]; then color="$YELLOW"
    fi
    if $first; then
      first=false
    else
      printf '  %b%-14s%b' "" "" "$RESET"
    fi
    printf ' %b■%b %s %b(%s lines)%b\n' "$color" "$RESET" "$name" "$DIM" "$lines" "$RESET"
  done
}

# ============================================================================
# Source Stats
# ============================================================================

show_sources() {
  local src="$SCRIPT_DIR/sections/sources.md"
  if [[ ! -f "$src" ]]; then
    printf '  %b%-14s%b %bno sources yet%b\n' "$BOLD" "Sources" "$RESET" "$DIM" "$RESET"
    return
  fi
  local tier1 tier2 tier3 total
  tier1=$(grep -c "Tier 1" "$src" 2>/dev/null || echo 0)
  tier2=$(grep -c "Tier 2" "$src" 2>/dev/null || echo 0)
  tier3=$(grep -c "Tier 3" "$src" 2>/dev/null || echo 0)
  total=$((tier1 + tier2 + tier3))
  printf '  %b%-14s%b %b%s%b total  (%bT1:%b%s  %bT2:%b%s  %bT3:%b%s)\n' \
    "$BOLD" "Sources" "$RESET" \
    "$WHITE" "$total" "$RESET" \
    "$GREEN" "$RESET" "$tier1" \
    "$BLUE" "$RESET" "$tier2" \
    "$DIM" "$RESET" "$tier3"
}

# ============================================================================
# Mode: log
# ============================================================================

show_log() {
  if [[ ! -f "$LOG_FILE" ]]; then
    echo "No research.log found."
    exit 1
  fi
  printf '%bTailing %s%b (Ctrl+C to stop)\n\n' "$BOLD" "$LOG_FILE" "$RESET"
  tail -f "$LOG_FILE" | while IFS= read -r line; do
    colorize_log_line "$line"
  done
}

# ============================================================================
# Mode: live — Status + streaming log
# ============================================================================

show_live() {
  printf '%b%b' "$BOLD" "$CYAN"
  printf '  ╔════════════════════════════════════════════════════════╗\n'
  printf '  ║              AUTORESEARCH — LIVE                      ║\n'
  printf '  ╚════════════════════════════════════════════════════════╝%b\n' "$RESET"

  show_status
  show_pipeline
  show_sources
  show_sections

  printf '\n%b  ── Live Output ──────────────────────────────────────────%b\n\n' "$DIM" "$RESET"

  if [[ ! -f "$LOG_FILE" ]]; then
    printf '  %bWaiting for research.log...%b\n' "$DIM" "$RESET"
    while [[ ! -f "$LOG_FILE" ]]; do sleep 1; done
  fi

  tail -f "$LOG_FILE" | while IFS= read -r line; do
    colorize_log_line "$line"
  done
}

# ============================================================================
# Mode: dashboard — Auto-refresh
# ============================================================================

show_dashboard() {
  local refresh_interval="${1:-30}"

  # shellcheck disable=SC2059
  trap 'printf "\n${RESET}"; exit 0' INT TERM

  while true; do
    clear

    printf '%b%b' "$BOLD" "$CYAN"
    printf '  ╔════════════════════════════════════════════════════════╗\n'
    printf '  ║              AUTORESEARCH MONITOR                     ║\n'
    printf '  ╚════════════════════════════════════════════════════════╝%b\n' "$RESET"

    show_status
    show_pipeline
    show_sources
    show_sections

    # Recent log
    printf '\n%b  ── Recent Activity ──────────────────────────────────────%b\n\n' "$DIM" "$RESET"

    if [[ -f "$LOG_FILE" ]]; then
      # Show last 20 meaningful lines (skip empty waits)
      grep -v "No accepted tasks available\|Waiting 60s\|PAUSED —" "$LOG_FILE" 2>/dev/null | tail -20 | while IFS= read -r line; do
        colorize_log_line "$line"
      done
    else
      printf '  %bNo log file yet.%b\n' "$DIM" "$RESET"
    fi

    printf '\n%b  Refreshing every %ss — Ctrl+C to exit%b\n' "$DIM" "$refresh_interval" "$RESET"
    sleep "$refresh_interval"
  done
}

# ============================================================================
# Entry Point
# ============================================================================

mode="${1:-dashboard}"
refresh="${2:-30}"

case "$mode" in
  live)      show_live ;;
  log)       show_log ;;
  status)    show_status; show_pipeline; show_sources; show_sections ;;
  dashboard) show_dashboard "$refresh" ;;
  *)
    echo "Usage: bash watch.sh [live|dashboard|log|status] [seconds]"
    echo ""
    echo "  bash watch.sh              dashboard (30s refresh)"
    echo "  bash watch.sh live         status + streaming log (recommended)"
    echo "  bash watch.sh dashboard 60 custom refresh interval"
    echo "  bash watch.sh log          color-coded tail of research.log"
    echo "  bash watch.sh status       one-shot full status"
    exit 1
    ;;
esac
