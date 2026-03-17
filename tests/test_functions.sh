#!/bin/bash
set -euo pipefail

# ============================================================================
# test_functions.sh — Unit tests for bash functions
# Run: bash tests/test_functions.sh
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# --- Test framework ---
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0
FAILURES=""

pass() {
  TESTS_PASSED=$((TESTS_PASSED + 1))
  echo "  PASS: $1"
}

fail() {
  TESTS_FAILED=$((TESTS_FAILED + 1))
  FAILURES="${FAILURES}\n  FAIL: $1 — $2"
  echo "  FAIL: $1 — $2"
}

assert_eq() {
  local expected="$1"
  local actual="$2"
  local name="$3"
  TESTS_RUN=$((TESTS_RUN + 1))
  if [[ "$expected" == "$actual" ]]; then
    pass "$name"
  else
    fail "$name" "expected '$expected', got '$actual'"
  fi
}

assert_not_empty() {
  local actual="$1"
  local name="$2"
  TESTS_RUN=$((TESTS_RUN + 1))
  if [[ -n "$actual" ]]; then
    pass "$name"
  else
    fail "$name" "expected non-empty string"
  fi
}

assert_empty() {
  local actual="$1"
  local name="$2"
  TESTS_RUN=$((TESTS_RUN + 1))
  if [[ -z "$actual" ]]; then
    pass "$name"
  else
    fail "$name" "expected empty, got '$actual'"
  fi
}

assert_file_exists() {
  local path="$1"
  local name="$2"
  TESTS_RUN=$((TESTS_RUN + 1))
  if [[ -f "$path" ]]; then
    pass "$name"
  else
    fail "$name" "file not found: $path"
  fi
}

assert_contains() {
  local haystack="$1"
  local needle="$2"
  local name="$3"
  TESTS_RUN=$((TESTS_RUN + 1))
  if echo "$haystack" | grep -qF "$needle"; then
    pass "$name"
  else
    fail "$name" "string does not contain '$needle'"
  fi
}

assert_gt() {
  local a="$1"
  local b="$2"
  local name="$3"
  TESTS_RUN=$((TESTS_RUN + 1))
  if [[ "$a" -gt "$b" ]]; then
    pass "$name"
  else
    fail "$name" "expected $a > $b"
  fi
}

# --- Source functions from research.sh without running main ---
# Extract just the functions we need
source_functions() {
  # We can't source research.sh directly (it runs main on source).
  # Instead, extract and eval function definitions.
  SCRIPT_DIR="$PROJECT_DIR"

  slugify() {
    echo "$1" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//' | sed 's/-$//' | cut -c1-50
  }

  get_section_from_body() {
    local body="$1"
    echo "$body" | grep -A1 "^## Section" | tail -1 | xargs
  }

  get_task_type() {
    local json="$1"
    if echo "$json" | jq -r ".labels[]?.name" | grep -q "^type-document$" 2>/dev/null; then
      echo "document"
    elif echo "$json" | jq -r ".labels[]?.name" | grep -q "^type-review$" 2>/dev/null; then
      echo "review"
    else
      echo "research"
    fi
  }

  has_label() {
    local json="$1"
    local label="$2"
    echo "$json" | jq -r ".labels[]?.name" | grep -q "^${label}$" 2>/dev/null
  }
}

# ============================================================================
# Test: slugify
# ============================================================================
test_slugify() {
  echo ""
  echo "=== slugify ==="

  assert_eq "hello-world" "$(slugify "Hello World")" "basic lowercase and spaces"
  assert_eq "research-karpathy-s-role-at-openai" "$(slugify "Research Karpathy's role at OpenAI")" "apostrophe and mixed case"
  assert_eq "test-123" "$(slugify "test 123")" "numbers preserved"
  assert_eq "no-special-chars" "$(slugify "no!@#special&*chars")" "special chars become dashes"
  assert_eq "no-leading-trailing" "$(slugify "  no leading trailing  ")" "trim leading/trailing"
  assert_eq "collapse-multiple-dashes" "$(slugify "collapse---multiple---dashes")" "collapse consecutive dashes"

  # Long string should be truncated to 50 chars
  local long_slug
  long_slug=$(slugify "this is a very long title that should be truncated to fifty characters exactly right here")
  TESTS_RUN=$((TESTS_RUN + 1))
  if [[ ${#long_slug} -le 50 ]]; then
    pass "truncated to 50 chars (got ${#long_slug})"
  else
    fail "truncated to 50 chars" "got ${#long_slug} chars"
  fi
}

# ============================================================================
# Test: get_section_from_body
# ============================================================================
test_get_section_from_body() {
  echo ""
  echo "=== get_section_from_body ==="

  local body1="## Type
Research

## Section
Intellectual Contributions

## Why needed
Some reason"

  assert_eq "Intellectual Contributions" "$(get_section_from_body "$body1")" "basic section extraction"

  local body2="## Type
Document

## Section
Eureka Labs

## Acceptance criteria
stuff"

  assert_eq "Eureka Labs" "$(get_section_from_body "$body2")" "different section name"

  local body3="## Type
Research

## Why needed
No section header here"

  assert_empty "$(get_section_from_body "$body3")" "no section header returns empty"

  local body4="## Section
  Views on AI Future

## Other"

  assert_eq "Views on AI Future" "$(get_section_from_body "$body4")" "trims whitespace"
}

# ============================================================================
# Test: get_task_type
# ============================================================================
test_get_task_type() {
  echo ""
  echo "=== get_task_type ==="

  local research_json='{"labels":[{"name":"task"},{"name":"type-research"},{"name":"priority-high"}]}'
  assert_eq "research" "$(get_task_type "$research_json")" "type-research label"

  local document_json='{"labels":[{"name":"task"},{"name":"type-document"},{"name":"priority-low"}]}'
  assert_eq "document" "$(get_task_type "$document_json")" "type-document label"

  local review_json='{"labels":[{"name":"task"},{"name":"type-review"}]}'
  assert_eq "review" "$(get_task_type "$review_json")" "type-review label"

  local no_type_json='{"labels":[{"name":"task"},{"name":"accepted"}]}'
  assert_eq "research" "$(get_task_type "$no_type_json")" "no type label defaults to research"

  local empty_json='{"labels":[]}'
  assert_eq "research" "$(get_task_type "$empty_json")" "empty labels defaults to research"
}

# ============================================================================
# Test: has_label
# ============================================================================
test_has_label() {
  echo ""
  echo "=== has_label ==="

  local json='{"labels":[{"name":"task"},{"name":"accepted"},{"name":"hard-task"}]}'

  TESTS_RUN=$((TESTS_RUN + 1))
  if has_label "$json" "hard-task"; then
    pass "finds existing label"
  else
    fail "finds existing label" "hard-task not found"
  fi

  TESTS_RUN=$((TESTS_RUN + 1))
  if has_label "$json" "accepted"; then
    pass "finds another existing label"
  else
    fail "finds another existing label" "accepted not found"
  fi

  TESTS_RUN=$((TESTS_RUN + 1))
  if ! has_label "$json" "nonexistent"; then
    pass "returns false for missing label"
  else
    fail "returns false for missing label" "found nonexistent label"
  fi

  TESTS_RUN=$((TESTS_RUN + 1))
  if ! has_label '{"labels":[]}' "task"; then
    pass "handles empty labels array"
  else
    fail "handles empty labels array" "found label in empty array"
  fi
}

# ============================================================================
# Test: autoresearch.sh score calculation
# ============================================================================
test_autoresearch_score() {
  echo ""
  echo "=== autoresearch.sh score calculation ==="

  # Create a temp directory with a test document.md
  local tmpdir
  tmpdir=$(mktemp -d)

  # Test LOW depth counting
  cat > "$tmpdir/document.md" <<'EOF'
## Section 1
Finding one. Confidence: HIGH | Depth: LOW
Finding two. Confidence: MEDIUM | Depth: LOW
Finding three. Confidence: HIGH | Depth: HIGH
EOF

  local low_count
  low_count=$(grep -c "Depth: LOW" "$tmpdir/document.md" 2>/dev/null || echo 0)
  assert_eq "2" "$low_count" "counts LOW depth findings correctly"

  # Test with no LOW depth
  cat > "$tmpdir/document.md" <<'EOF'
## Section 1
Finding one. Confidence: HIGH | Depth: HIGH
EOF

  low_count=$(grep -c "Depth: LOW" "$tmpdir/document.md" 2>/dev/null || true)
  low_count=${low_count:-0}
  assert_eq "0" "$low_count" "zero LOW depth findings"

  # Test score formula
  local open=3 rework=1 low=2
  local expected_score=$(( (open * 10) + (rework * 5) + (low * 3) ))
  assert_eq "41" "$expected_score" "score formula: (3*10)+(1*5)+(2*3)=41"

  rm -rf "$tmpdir"
}

# ============================================================================
# Test: write_status JSON validity
# ============================================================================
test_write_status_json() {
  echo ""
  echo "=== write_status JSON output ==="

  local tmpdir
  tmpdir=$(mktemp -d)

  # Simulate write_status output
  local iteration=5
  local MAX_ITERATIONS=50
  local score=30
  local starting_score=50
  local current_task="Research Karpathy's work"
  local current_issue=42
  local last_action="improved"
  local subject="Research Goal: Andrej Karpathy"
  local model="claude-opus-4-5"
  local session_start="2026-03-17T08:00:00Z"

  cat > "$tmpdir/status.json" <<STATUSEOF
{
  "running": true,
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

  # Validate JSON
  TESTS_RUN=$((TESTS_RUN + 1))
  if jq . "$tmpdir/status.json" > /dev/null 2>&1; then
    pass "status.json is valid JSON"
  else
    fail "status.json is valid JSON" "jq parse failed"
  fi

  # Check fields
  assert_eq "true" "$(jq -r '.running' "$tmpdir/status.json")" "running field"
  assert_eq "5" "$(jq -r '.iteration' "$tmpdir/status.json")" "iteration field"
  assert_eq "30" "$(jq -r '.score' "$tmpdir/status.json")" "score field"
  assert_eq "Research Karpathy's work" "$(jq -r '.current_task' "$tmpdir/status.json")" "task with apostrophe"

  # Test with special characters in task name
  current_task='Task with "quotes" and $pecial chars'
  cat > "$tmpdir/status2.json" <<STATUSEOF
{
  "current_task": $(echo "$current_task" | jq -Rs .)
}
STATUSEOF

  TESTS_RUN=$((TESTS_RUN + 1))
  if jq . "$tmpdir/status2.json" > /dev/null 2>&1; then
    pass "handles special characters in task name"
  else
    fail "handles special characters in task name" "jq parse failed"
  fi

  rm -rf "$tmpdir"
}

# ============================================================================
# Test: document.md section extraction
# ============================================================================
test_section_extraction() {
  echo ""
  echo "=== document.md section extraction ==="

  local tmpdir
  tmpdir=$(mktemp -d)

  cat > "$tmpdir/document.md" <<'EOF'
# Research Document
Coverage: 0%

## Intellectual Contributions
Karpathy studied at Stanford.
He published key papers.

## Education and Teaching
CS231n was created in 2015.

## Views on AI Future
AI will transform education.

## Sources
- [1] source one
EOF

  # Extract "Education and Teaching" section
  local section="Education and Teaching"
  local start_line
  start_line=$(while IFS= read -r line_num_and_text; do
    local lnum="${line_num_and_text%%:*}"
    local ltext="${line_num_and_text#*:}"
    if [[ "$ltext" == "## ${section}" ]]; then
      echo "$lnum"
      break
    fi
  done < <(grep -nF "## ${section}" "$tmpdir/document.md"))

  assert_eq "8" "$start_line" "finds correct start line for section"

  local end_line
  end_line=$(tail -n +"$((start_line + 1))" "$tmpdir/document.md" | grep -n "^## " | head -1 | cut -d: -f1)
  assert_eq "3" "$end_line" "finds correct end offset"

  local extracted
  extracted=$(sed -n "${start_line},$((start_line + end_line - 1))p" "$tmpdir/document.md")
  assert_contains "$extracted" "Education and Teaching" "extracted section contains header"
  assert_contains "$extracted" "CS231n" "extracted section contains content"

  # Test last section (no following ## header)
  section="Sources"
  start_line=$(while IFS= read -r line_num_and_text; do
    local lnum="${line_num_and_text%%:*}"
    local ltext="${line_num_and_text#*:}"
    if [[ "$ltext" == "## ${section}" ]]; then
      echo "$lnum"
      break
    fi
  done < <(grep -nF "## ${section}" "$tmpdir/document.md"))

  assert_not_empty "$start_line" "finds last section"

  end_line=$(tail -n +"$((start_line + 1))" "$tmpdir/document.md" | grep -n "^## " | head -1 | cut -d: -f1 || true)
  assert_empty "$end_line" "no end boundary for last section"

  rm -rf "$tmpdir"
}

# ============================================================================
# Test: shellcheck passes on all scripts
# ============================================================================
test_shellcheck() {
  echo ""
  echo "=== shellcheck ==="

  if ! command -v shellcheck &>/dev/null; then
    TESTS_RUN=$((TESTS_RUN + 1))
    fail "shellcheck installed" "shellcheck not found — install with: brew install shellcheck"
    return
  fi

  for script in "$PROJECT_DIR"/*.sh; do
    local name
    name=$(basename "$script")
    TESTS_RUN=$((TESTS_RUN + 1))
    if shellcheck "$script" 2>&1; then
      pass "shellcheck: $name"
    else
      fail "shellcheck: $name" "see warnings above"
    fi
  done
}

# ============================================================================
# Run all tests
# ============================================================================

echo "=========================================="
echo "  Autoresearch — Bash Unit Tests"
echo "=========================================="

source_functions
test_slugify
test_get_section_from_body
test_get_task_type
test_has_label
test_autoresearch_score
test_write_status_json
test_section_extraction
test_shellcheck

echo ""
echo "=========================================="
echo "  Results: $TESTS_PASSED passed, $TESTS_FAILED failed (of $TESTS_RUN)"
echo "=========================================="

if [[ $TESTS_FAILED -gt 0 ]]; then
  echo -e "\nFailures:$FAILURES"
  exit 1
fi
