#!/bin/bash
# shellcheck disable=SC2059
set -euo pipefail

# ============================================================================
# verify-sources.sh — Check all source URLs for availability
# Verifies every URL in sections/sources.md returns HTTP 200.
# Usage: bash verify-sources.sh
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCES_FILE="$SCRIPT_DIR/sections/sources.md"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
DIM='\033[2m'
BOLD='\033[1m'
RESET='\033[0m'

if [[ ! -f "$SOURCES_FILE" ]]; then
  echo "No sources.md found."
  exit 1
fi

printf '\n%b╔════════════════════════════════════════════════════════╗%b\n' "$BOLD" "$RESET"
printf '%b║              SOURCE VERIFICATION                       ║%b\n' "$BOLD" "$RESET"
printf '%b╚════════════════════════════════════════════════════════╝%b\n\n' "$BOLD" "$RESET"

total=0
alive=0
dead=0
timeout_count=0
skipped=0

dead_list=""

# Extract URLs from sources.md
while IFS= read -r line; do
  # Match URLs in parentheses (markdown links) or bare URLs
  urls=$(echo "$line" | grep -oE 'https?://[^)> "]+' || true)
  [[ -z "$urls" ]] && continue

  # Get the source reference number
  ref=$(echo "$line" | grep -oE '^\- \[[0-9]+\]' | head -1 || echo "")

  while IFS= read -r url; do
    [[ -z "$url" ]] && continue
    # Clean trailing punctuation
    # shellcheck disable=SC2001
    url=$(echo "$url" | sed 's/[,;.)]*$//')

    total=$((total + 1))

    # Skip known non-fetchable domains
    if echo "$url" | grep -qE 'x.com/|twitter.com/'; then
      printf '  %b⊘%b %s %b%s%b %b(skip: X/Twitter blocks bots)%b\n' "$YELLOW" "$RESET" "$ref" "$DIM" "$url" "$RESET" "$DIM" "$RESET"
      skipped=$((skipped + 1))
      continue
    fi

    # Check URL with curl (5s timeout, follow redirects)
    http_code=$(curl -sL -o /dev/null -w '%{http_code}' --max-time 5 "$url" 2>/dev/null || echo "000")

    if [[ "$http_code" == "200" || "$http_code" == "301" || "$http_code" == "302" ]]; then
      printf '  %b✓%b %s %b%s%b\n' "$GREEN" "$RESET" "$ref" "$DIM" "$url" "$RESET"
      alive=$((alive + 1))
    elif [[ "$http_code" == "000" ]]; then
      printf '  %b⏱%b %s %b%s%b %b(timeout)%b\n' "$YELLOW" "$RESET" "$ref" "$DIM" "$url" "$RESET" "$YELLOW" "$RESET"
      timeout_count=$((timeout_count + 1))
    elif [[ "$http_code" == "403" ]]; then
      printf '  %b⊘%b %s %b%s%b %b(403 forbidden — may require auth)%b\n' "$YELLOW" "$RESET" "$ref" "$DIM" "$url" "$RESET" "$DIM" "$RESET"
      skipped=$((skipped + 1))
    else
      printf '  %b✗%b %s %b%s%b %b(HTTP %s)%b\n' "$RED" "$RESET" "$ref" "$DIM" "$url" "$RESET" "$RED" "$http_code" "$RESET"
      dead=$((dead + 1))
      dead_list="${dead_list}  ${ref} ${url} (HTTP ${http_code})\n"
    fi
  done <<< "$urls"
done < "$SOURCES_FILE"

# Summary
printf '\n%b── Summary ──────────────────────────────────────────────%b\n\n' "$BOLD" "$RESET"
printf '  Total URLs: %b%s%b\n' "$BOLD" "$total" "$RESET"
printf '  %b✓ Alive:%b    %s\n' "$GREEN" "$RESET" "$alive"
printf '  %b✗ Dead:%b     %s\n' "$RED" "$RESET" "$dead"
printf '  %b⏱ Timeout:%b  %s\n' "$YELLOW" "$RESET" "$timeout_count"
printf '  %b⊘ Skipped:%b  %s\n' "$DIM" "$RESET" "$skipped"

if [[ $dead -gt 0 ]]; then
  printf '\n%b── Dead Sources ─────────────────────────────────────────%b\n\n' "$RED" "$RESET"
  printf '%b' "$dead_list"
fi

health=$(( total > 0 ? ((alive + skipped) * 100) / total : 0 ))
printf '\n  Source health: %b%s%%%b\n\n' "$BOLD" "$health" "$RESET"
