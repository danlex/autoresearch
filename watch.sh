#!/bin/bash
# shellcheck disable=SC2059
set -euo pipefail

# ============================================================================
# watch.sh — Real-time research monitor
# Usage:
#   bash watch.sh          — Dashboard with auto-refresh (default 15s)
#   bash watch.sh dashboard 30 — Dashboard with 30s refresh
#   bash watch.sh log      — Color-coded tail -f of research.log
#   bash watch.sh status   — One-shot status display
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

STATUS_FILE="$SCRIPT_DIR/status.json"
LOG_FILE="$SCRIPT_DIR/research.log"

# ============================================================================
# Utility Functions
# ============================================================================

colorize_log_line() {
  local line="$1"
  # Extract timestamp and message
  local timestamp=""
  local message="$line"
  if [[ "$line" =~ ^\[([0-9T:Z-]+)\]\ (.*) ]]; then
    timestamp="${BASH_REMATCH[1]}"
    message="${BASH_REMATCH[2]}"
  fi

  # Determine color based on content
  local color="$RESET"
  if [[ "$message" =~ (ERROR|FAIL|failed|FAILED) ]]; then
    color="$RED"
  elif [[ "$message" =~ (PASS|merged|improved|PASSED|Done|complete) ]]; then
    color="$GREEN"
  elif [[ "$message" =~ (WARNING|PAUSED|timeout|SKIP|no_change|rework|reverting) ]]; then
    color="$YELLOW"
  elif [[ "$message" =~ (Task\ #|Iteration|type=|Running|Proposing|Self-review) ]]; then
    color="$CYAN"
  fi

  if [[ -n "$timestamp" ]]; then
    printf '%b[%s]%b %b%s%b\n' "$DIM" "$timestamp" "$RESET" "$color" "$message" "$RESET"
  else
    printf '%b%s%b\n' "$color" "$line" "$RESET"
  fi
}

read_status_field() {
  local field="$1"
  if [[ -f "$STATUS_FILE" ]]; then
    jq -r ".$field // empty" "$STATUS_FILE" 2>/dev/null || echo ""
  else
    echo ""
  fi
}

get_score_breakdown() {
  local breakdown=""
  if [[ -x "$SCRIPT_DIR/autoresearch.sh" ]] || [[ -f "$SCRIPT_DIR/autoresearch.sh" ]]; then
    breakdown=$(bash "$SCRIPT_DIR/autoresearch.sh" 2>&1 >/dev/null || true)
  fi
  echo "$breakdown"
}

# ============================================================================
# Mode: status — One-shot status display
# ============================================================================

show_status() {
  if [[ ! -f "$STATUS_FILE" ]]; then
    echo "No status.json found. Is research.sh running?"
    exit 1
  fi

  local running iteration max_iterations score starting_score current_task
  local current_issue last_action subject model_name session_start

  running=$(read_status_field "running")
  iteration=$(read_status_field "iteration")
  max_iterations=$(read_status_field "max_iterations")
  score=$(read_status_field "score")
  starting_score=$(read_status_field "starting_score")
  current_task=$(read_status_field "current_task" | tr -d '\n')
  current_issue=$(read_status_field "current_issue")
  last_action=$(read_status_field "last_action")
  subject=$(read_status_field "subject" | tr -d '\n')
  model_name=$(read_status_field "model")
  session_start=$(read_status_field "session_start")

  # Running status with color
  local running_display
  if [[ "$running" == "true" ]]; then
    running_display="${GREEN}RUNNING${RESET}"
  else
    running_display="${RED}STOPPED${RESET}"
  fi

  # Paused check
  if [[ -f "$SCRIPT_DIR/pause.flag" ]]; then
    running_display="${YELLOW}PAUSED${RESET}"
  fi

  # Last action color
  local action_display
  case "${last_action:-none}" in
    merged|improved)  action_display="${GREEN}${last_action}${RESET}" ;;
    rejected|timeout) action_display="${RED}${last_action}${RESET}" ;;
    no_change|waiting) action_display="${YELLOW}${last_action}${RESET}" ;;
    *)                action_display="${last_action:-none}" ;;
  esac

  # Score delta
  local delta=""
  if [[ -n "$starting_score" && -n "$score" ]]; then
    local diff=$((score - starting_score))
    if [[ $diff -gt 0 ]]; then
      delta="${GREEN}(+${diff})${RESET}"
    elif [[ $diff -lt 0 ]]; then
      delta="${RED}(${diff})${RESET}"
    else
      delta="${DIM}(+0)${RESET}"
    fi
  fi

  printf '\n'
  printf '%b  Subject:%b     %s\n' "$BOLD" "$RESET" "${subject:-unknown}"
  printf '%b  Status:%b      %b\n' "$BOLD" "$RESET" "$running_display"
  printf '%b  Iteration:%b   %s / %s\n' "$BOLD" "$RESET" "${iteration:-0}" "${max_iterations:-0}"
  printf '%b  Score:%b       %s%% %b  (started: %s%%)\n' "$BOLD" "$RESET" "${score:-0}" "$delta" "${starting_score:-0}"
  printf '%b  Task:%b        #%s — %s\n' "$BOLD" "$RESET" "${current_issue:-0}" "${current_task:-none}"
  printf '%b  Last Action:%b %b\n' "$BOLD" "$RESET" "$action_display"
  printf '%b  Model:%b       %s\n' "$BOLD" "$RESET" "${model_name:-unknown}"
  printf '%b  Session:%b     %s\n' "$BOLD" "$RESET" "${session_start:-unknown}"

  # Score breakdown
  local breakdown
  breakdown=$(get_score_breakdown)
  if [[ -n "$breakdown" ]]; then
    printf '%b  Breakdown:%b   %b%s%b\n' "$BOLD" "$RESET" "$DIM" "$breakdown" "$RESET"
  fi

  printf '\n'
}

# ============================================================================
# Mode: log — Color-coded tail -f
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
# Mode: dashboard — Auto-refresh (default 15s, configurable)
# ============================================================================

show_dashboard() {
  local refresh_interval="${1:-15}"

  # Trap for clean exit
  # shellcheck disable=SC2059
  trap 'printf "\n${RESET}"; exit 0' INT TERM

  while true; do
    # Clear screen
    clear

    # Header
    printf '%b%b' "$BOLD" "$CYAN"
    printf '  ╔══════════════════════════════════════════╗\n'
    printf '  ║       AUTORESEARCH MONITOR               ║\n'
    printf '  ╚══════════════════════════════════════════╝%b\n' "$RESET"

    # Status section
    show_status

    # Separator
    printf '%b  ── Recent Log ──────────────────────────────%b\n\n' "$DIM" "$RESET"

    # Last 15 log lines with color
    if [[ -f "$LOG_FILE" ]]; then
      tail -15 "$LOG_FILE" | while IFS= read -r line; do
        printf '  '
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
refresh="${2:-15}"

case "$mode" in
  log)
    show_log
    ;;
  status)
    show_status
    ;;
  dashboard|"")
    show_dashboard "$refresh"
    ;;
  *)
    echo "Usage: bash watch.sh [dashboard|log|status] [refresh_seconds]"
    echo "  bash watch.sh                # dashboard, 15s refresh"
    echo "  bash watch.sh dashboard 30   # dashboard, 30s refresh"
    echo "  bash watch.sh log            # tail log with colors"
    echo "  bash watch.sh status         # one-shot status"
    exit 1
    ;;
esac
