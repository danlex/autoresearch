#!/bin/bash
# shellcheck disable=SC2059
set -euo pipefail

# ============================================================================
# quality-report.sh — Research quality analysis
# Scans all section files and reports on citation gaps, thin areas,
# confidence issues, and missing topics from goal.md.
# Usage: bash quality-report.sh
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SECTIONS_DIR="$SCRIPT_DIR/sections"

if [[ -f "$SCRIPT_DIR/.env" ]]; then
  # shellcheck disable=SC1091
  source "$SCRIPT_DIR/.env"
fi

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
DIM='\033[2m'
BOLD='\033[1m'
RESET='\033[0m'

# --- Score ---
printf '\n%b╔════════════════════════════════════════════════════════╗%b\n' "$BOLD$CYAN" "$RESET"
printf '%b║              RESEARCH QUALITY REPORT                   ║%b\n' "$BOLD$CYAN" "$RESET"
printf '%b╚════════════════════════════════════════════════════════╝%b\n\n' "$BOLD$CYAN" "$RESET"

score_output=$(bash "$SCRIPT_DIR/autoresearch.sh" 2>&1)
score=$(echo "$score_output" | head -1)
breakdown=$(echo "$score_output" | tail -1)
printf '%bOverall Score:%b %b%s%%%b\n' "$BOLD" "$RESET" "$GREEN" "$score" "$RESET"
printf '%b%s%b\n\n' "$DIM" "$breakdown" "$RESET"

# ============================================================================
# Per-Section Analysis
# ============================================================================

printf '%b── Section Analysis ──────────────────────────────────────%b\n\n' "$BOLD" "$RESET"

total_paragraphs=0
total_cited=0
total_uncited=0
section_issues=""

for section_file in "$SECTIONS_DIR"/intellectual-contributions.md \
                    "$SECTIONS_DIR"/education-and-teaching.md \
                    "$SECTIONS_DIR"/views-on-ai-future.md \
                    "$SECTIONS_DIR"/eureka-labs.md \
                    "$SECTIONS_DIR"/key-relationships.md; do

  [[ -f "$section_file" ]] || continue

  name=$(basename "$section_file" .md | sed 's/-/ /g')
  lines=$(wc -l < "$section_file" | tr -d ' ')
  paragraphs=0
  cited=0
  uncited=0
  uncited_lines=""
  confidence_high=0
  confidence_medium=0
  confidence_low=0

  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    [[ "$line" =~ ^## ]] && continue
    [[ "$line" =~ ^### ]] && continue
    [[ "$line" =~ ^\*\*Confidence ]] && {
      if [[ "$line" =~ "HIGH" ]]; then confidence_high=$((confidence_high + 1)); fi
      if [[ "$line" =~ "MEDIUM" ]]; then confidence_medium=$((confidence_medium + 1)); fi
      if [[ "$line" =~ "LOW" ]]; then confidence_low=$((confidence_low + 1)); fi
      continue
    }
    [[ "$line" =~ ^\*\*Uncertainty ]] && continue
    [[ "$line" =~ ^\> ]] && continue
    [[ ${#line} -le 50 ]] && continue

    paragraphs=$((paragraphs + 1))
    if echo "$line" | grep -qE '\[[0-9]+\]'; then
      cited=$((cited + 1))
    else
      uncited=$((uncited + 1))
      # Truncate long lines for display
      local_snippet=$(echo "$line" | cut -c1-80)
      uncited_lines="${uncited_lines}    ${DIM}→ ${local_snippet}...${RESET}\n"
    fi
  done < "$section_file"

  total_paragraphs=$((total_paragraphs + paragraphs))
  total_cited=$((total_cited + cited))
  total_uncited=$((total_uncited + uncited))

  # Section health color
  local_pct=0
  if [[ $paragraphs -gt 0 ]]; then
    local_pct=$(( (cited * 100) / paragraphs ))
  fi
  local_color="$RED"
  if [[ $local_pct -ge 80 ]]; then local_color="$GREEN"
  elif [[ $local_pct -ge 60 ]]; then local_color="$BLUE"
  elif [[ $local_pct -ge 40 ]]; then local_color="$YELLOW"
  fi

  # Size indicator
  size_label="thin"
  size_color="$RED"
  if [[ $lines -gt 80 ]]; then size_label="rich"; size_color="$GREEN"
  elif [[ $lines -gt 40 ]]; then size_label="moderate"; size_color="$BLUE"
  elif [[ $lines -gt 15 ]]; then size_label="thin"; size_color="$YELLOW"
  else size_label="empty"; size_color="$RED"
  fi

  printf '  %b%-40s%b %b%s%b (%s lines)\n' "$BOLD" "$name" "$RESET" "$size_color" "$size_label" "$RESET" "$lines"
  printf '    Citations: %b%s/%s%b (%s%%)' "$local_color" "$cited" "$paragraphs" "$RESET" "$local_pct"
  printf '  Confidence: %b%sH%b/%b%sM%b/%b%sL%b\n' \
    "$GREEN" "$confidence_high" "$RESET" \
    "$YELLOW" "$confidence_medium" "$RESET" \
    "$RED" "$confidence_low" "$RESET"

  # Flag issues
  if [[ $lines -lt 20 ]]; then
    section_issues="${section_issues}  ${RED}!${RESET} ${name}: needs more research (only $lines lines)\n"
  fi
  if [[ $uncited -gt 3 ]]; then
    section_issues="${section_issues}  ${YELLOW}!${RESET} ${name}: $uncited uncited paragraphs\n"
  fi
  if [[ $confidence_low -gt 0 ]]; then
    section_issues="${section_issues}  ${YELLOW}!${RESET} ${name}: $confidence_low LOW confidence subsections\n"
  fi

  # Show uncited paragraphs if any
  if [[ $uncited -gt 0 && $uncited -le 5 ]]; then
    printf '%b' "$uncited_lines"
  elif [[ $uncited -gt 5 ]]; then
    printf '    %b(%s uncited paragraphs — run with --verbose to see all)%b\n' "$DIM" "$uncited" "$RESET"
  fi

  printf '\n'
done

# ============================================================================
# Source Analysis
# ============================================================================

printf '%b── Source Analysis ───────────────────────────────────────%b\n\n' "$BOLD" "$RESET"

src_file="$SECTIONS_DIR/sources.md"
if [[ -f "$src_file" ]]; then
  tier1=$(grep -c "Tier 1" "$src_file" 2>/dev/null || echo 0)
  tier2=$(grep -c "Tier 2" "$src_file" 2>/dev/null || echo 0)
  tier3=$(grep -c "Tier 3" "$src_file" 2>/dev/null || echo 0)
  src_total=$((tier1 + tier2 + tier3))

  printf '  Total: %b%s%b sources\n' "$BOLD" "$src_total" "$RESET"
  printf '  %bTier 1:%b %s (self-published, official)  %b%.0f%%%b\n' "$GREEN" "$RESET" "$tier1" "$DIM" "$(( src_total > 0 ? (tier1 * 100) / src_total : 0 ))" "$RESET"
  printf '  %bTier 2:%b %s (press, Wikipedia)           %b%.0f%%%b\n' "$BLUE" "$RESET" "$tier2" "$DIM" "$(( src_total > 0 ? (tier2 * 100) / src_total : 0 ))" "$RESET"
  printf '  %bTier 3:%b %s (blogs, aggregators)         %b%.0f%%%b\n' "$DIM" "$RESET" "$tier3" "$DIM" "$(( src_total > 0 ? (tier3 * 100) / src_total : 0 ))" "$RESET"

  # Check for phantom citations (referenced in sections but not in sources)
  printf '\n  Checking for phantom citations...\n'
  phantom_count=0
  for section_file in "$SECTIONS_DIR"/intellectual-contributions.md \
                      "$SECTIONS_DIR"/education-and-teaching.md \
                      "$SECTIONS_DIR"/views-on-ai-future.md \
                      "$SECTIONS_DIR"/eureka-labs.md \
                      "$SECTIONS_DIR"/key-relationships.md; do
    [[ -f "$section_file" ]] || continue
    # Extract all [N] references
    grep -oE '\[[0-9]+\]' "$section_file" 2>/dev/null | sort -t'[' -k1 -n | uniq | while read -r ref; do
      num=$(echo "$ref" | tr -d '[]')
      if ! grep -qF "[$num]" "$src_file" 2>/dev/null; then
        printf '    %b✗ %s referenced in %s but not in sources.md%b\n' "$RED" "$ref" "$(basename "$section_file")" "$RESET"
        phantom_count=$((phantom_count + 1))
      fi
    done
  done
  if [[ $phantom_count -eq 0 ]]; then
    printf '    %b✓ No phantom citations found%b\n' "$GREEN" "$RESET"
  fi
else
  printf '  %bNo sources.md found%b\n' "$RED" "$RESET"
fi

# ============================================================================
# Goal Coverage
# ============================================================================

printf '\n%b── Goal Coverage ────────────────────────────────────────%b\n\n' "$BOLD" "$RESET"

if [[ -f "$SCRIPT_DIR/goal.md" ]]; then
  printf '  Checking goal.md areas against research...\n\n'
  while IFS= read -r goal_line; do
    [[ "$goal_line" =~ ^-\  ]] || continue
    area="${goal_line#- }"

    # Search all sections for coverage
    found=false
    for section_file in "$SECTIONS_DIR"/*.md; do
      [[ -f "$section_file" ]] || continue
      if grep -qiF "$area" "$section_file" 2>/dev/null; then
        found=true
        break
      fi
    done

    if $found; then
      printf '    %b✓%b %s\n' "$GREEN" "$RESET" "$area"
    else
      printf '    %b✗%b %s %b(not found in any section)%b\n' "$RED" "$RESET" "$area" "$DIM" "$RESET"
    fi
  done < "$SCRIPT_DIR/goal.md"
fi

# ============================================================================
# Open Questions
# ============================================================================

printf '\n%b── Open Questions ───────────────────────────────────────%b\n\n' "$BOLD" "$RESET"

oq_file="$SECTIONS_DIR/open-questions.md"
if [[ -f "$oq_file" ]]; then
  oq_count=$(grep -c "^-\|^\*\|^[0-9]" "$oq_file" 2>/dev/null || echo 0)
  review_notes=$(grep -c "Unresolved Review Notes" "$oq_file" 2>/dev/null || echo 0)
  printf '  Open questions: %b%s%b\n' "$YELLOW" "$oq_count" "$RESET"
  printf '  Unresolved review notes: %b%s%b\n' "$YELLOW" "$review_notes" "$RESET"
else
  printf '  %bNo open questions file%b\n' "$GREEN" "$RESET"
fi

# ============================================================================
# Issues Summary
# ============================================================================

printf '\n%b── Issues to Address ────────────────────────────────────%b\n\n' "$BOLD" "$RESET"

if [[ -n "$section_issues" ]]; then
  printf '%b' "$section_issues"
else
  printf '  %b✓ No major issues found%b\n' "$GREEN" "$RESET"
fi

# Summary
printf '\n%b── Summary ──────────────────────────────────────────────%b\n\n' "$BOLD" "$RESET"
cite_pct=0
if [[ $total_paragraphs -gt 0 ]]; then
  cite_pct=$(( (total_cited * 100) / total_paragraphs ))
fi
printf '  Paragraphs: %s total, %b%s cited%b (%s%%), %b%s uncited%b\n' \
  "$total_paragraphs" "$GREEN" "$total_cited" "$RESET" "$cite_pct" "$YELLOW" "$total_uncited" "$RESET"
printf '  Score: %b%s%%%b\n\n' "$BOLD" "$score" "$RESET"
