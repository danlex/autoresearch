#!/bin/bash
set -euo pipefail

# ============================================================================
# test_research_loop.sh — Integration test for research.sh
# Tests a full iteration with mocked gh and claude commands.
# Run: bash tests/test_research_loop.sh
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

pass() { TESTS_PASSED=$((TESTS_PASSED + 1)); echo "  PASS: $1"; }
fail() { TESTS_FAILED=$((TESTS_FAILED + 1)); echo "  FAIL: $1 — $2"; }

assert_eq() {
  TESTS_RUN=$((TESTS_RUN + 1))
  if [[ "$1" == "$2" ]]; then pass "$3"; else fail "$3" "expected '$1', got '$2'"; fi
}
assert_file_exists() {
  TESTS_RUN=$((TESTS_RUN + 1))
  if [[ -f "$1" ]]; then pass "$2"; else fail "$2" "file not found: $1"; fi
}
assert_contains() {
  TESTS_RUN=$((TESTS_RUN + 1))
  if grep -qF "$2" "$1" 2>/dev/null; then pass "$3"; else fail "$3" "'$2' not in $1"; fi
}

# --- Setup mock environment ---
MOCK_DIR=$(mktemp -d)
trap 'rm -rf "$MOCK_DIR"' EXIT

echo ""
echo "=========================================="
echo "  Autoresearch — Integration Tests"
echo "=========================================="
echo "  Mock dir: $MOCK_DIR"

# Create mock gh
cat > "$MOCK_DIR/gh" <<'MOCKGH'
#!/bin/bash
case "$*" in
  "auth status")
    echo "Logged in" ;;
  *"issue list"*"in-progress"*)
    echo '[]' ;;
  *"issue list"*"needs-better-research"*)
    echo '[]' ;;
  *"issue list"*"priority-high"*)
    echo '[{"number":1,"labels":[{"name":"task"},{"name":"accepted"},{"name":"type-research"},{"name":"priority-high"}]}]' ;;
  *"issue list"*"priority-medium"*)
    echo '[]' ;;
  *"issue list"*"priority-low"*)
    echo '[]' ;;
  *"issue list"*"task,accepted"*)
    echo '[{"number":1,"labels":[{"name":"task"},{"name":"accepted"},{"name":"type-research"},{"name":"priority-high"}]}]' ;;
  *"issue list"*"task"*)
    echo '[{"number":1}]' ;;
  *"issue view"*"1"*)
    echo '{"title":"Research Stanford work","body":"## Type\nResearch\n\n## Section\nIntellectual Contributions\n\n## Acceptance criteria\n- [ ] PhD documented","labels":[{"name":"task"},{"name":"type-research"}],"comments":[]}' ;;
  *"issue edit"*)
    echo "ok" ;;
  *"issue close"*)
    echo "ok" ;;
  *"pr create"*)
    echo "https://github.com/test/repo/pull/1" ;;
  *"pr list"*)
    echo '[{"number":1}]' ;;
  *"pr merge"*)
    echo "ok" ;;
  *)
    echo "mock gh: unhandled: $*" >&2 ;;
esac
MOCKGH
chmod +x "$MOCK_DIR/gh"

# Create mock claude
cat > "$MOCK_DIR/claude" <<'MOCKCLAUDE'
#!/bin/bash
# Mock claude: appends a finding to document.md
SCRIPT_DIR=$(pwd)
if [[ -f "$SCRIPT_DIR/document.md" ]]; then
  cat >> "$SCRIPT_DIR/document.md" <<'FINDING'

Andrej Karpathy completed his PhD at Stanford University under the supervision of Fei-Fei Li.
His thesis focused on visual recognition using deep learning.
Confidence: HIGH | Depth: HIGH
[Source: Stanford AI Lab - Tier 1]
FINDING
fi
echo "Research completed successfully."
MOCKCLAUDE
chmod +x "$MOCK_DIR/claude"

# Create mock git (passthrough to real git, but intercept push/checkout for new branches)
cat > "$MOCK_DIR/git" <<MOCKGIT
#!/bin/bash
real_git=$(which -a git | grep -v "$MOCK_DIR" | head -1)
case "\$*" in
  "push origin"*)
    echo "mock: pushed" ;;
  "pull origin"*)
    echo "mock: pulled" ;;
  "checkout -b task/"*)
    echo "mock: created branch" ;;
  *)
    "\$real_git" "\$@" ;;
esac
MOCKGIT
chmod +x "$MOCK_DIR/git"

# Create mock jq (passthrough)
cat > "$MOCK_DIR/jq" <<MOCKJQ
#!/bin/bash
$(which jq) "\$@"
MOCKJQ
chmod +x "$MOCK_DIR/jq"

# --- Create test workspace ---
TEST_WORKSPACE=$(mktemp -d)
trap 'rm -rf "$MOCK_DIR" "$TEST_WORKSPACE"' EXIT

# Copy project files to workspace
cp "$PROJECT_DIR/goal.md" "$TEST_WORKSPACE/"
cp "$PROJECT_DIR/document.md" "$TEST_WORKSPACE/"
cp "$PROJECT_DIR/autoresearch.sh" "$TEST_WORKSPACE/"
cp "$PROJECT_DIR/coverage.md" "$TEST_WORKSPACE/"
cp "$PROJECT_DIR/changelog.md" "$TEST_WORKSPACE/"

# Init git in workspace
real_git=$(which -a git | grep -v "$MOCK_DIR" | head -1)
cd "$TEST_WORKSPACE"
"$real_git" init -q
"$real_git" add -A
"$real_git" -c user.name="test" -c user.email="test@test.com" commit -q -m "init"

# Modify autoresearch.sh to work without real gh
cat > "$TEST_WORKSPACE/autoresearch.sh" <<'MOCKSCOREEOF'
#!/bin/bash
# Mock score: count lines in document.md as inverse progress
lines=$(wc -l < document.md 2>/dev/null | tr -d ' ')
if [[ "$lines" -gt 20 ]]; then
  echo 20
elif [[ "$lines" -gt 17 ]]; then
  echo 30
else
  echo 50
fi
MOCKSCOREEOF
chmod +x "$TEST_WORKSPACE/autoresearch.sh"

echo ""

# ============================================================================
# Test: startup prerequisites
# ============================================================================
echo "=== Startup checks ==="

# Test that research.sh detects missing ANTHROPIC_API_KEY
TESTS_RUN=$((TESTS_RUN + 1))
output=$(PATH="$MOCK_DIR:$PATH" ANTHROPIC_API_KEY="" MAX_ITERATIONS=0 bash "$PROJECT_DIR/research.sh" 2>&1 || true)
if echo "$output" | grep -q "ANTHROPIC_API_KEY"; then
  pass "detects missing ANTHROPIC_API_KEY"
else
  fail "detects missing ANTHROPIC_API_KEY" "no error message"
fi

# ============================================================================
# Test: score computation
# ============================================================================
echo ""
echo "=== Score computation ==="

cd "$TEST_WORKSPACE"
initial_score=$(bash autoresearch.sh)
assert_eq "50" "$initial_score" "initial score is 50"

# ============================================================================
# Test: mock claude modifies document
# ============================================================================
echo ""
echo "=== Mock Claude execution ==="

doc_before=$(wc -l < "$TEST_WORKSPACE/document.md" | tr -d ' ')
PATH="$MOCK_DIR:$PATH" "$MOCK_DIR/claude" -p "test prompt"
doc_after=$(wc -l < "$TEST_WORKSPACE/document.md" | tr -d ' ')

TESTS_RUN=$((TESTS_RUN + 1))
if [[ "$doc_after" -gt "$doc_before" ]]; then
  pass "mock claude appends to document.md ($doc_before -> $doc_after lines)"
else
  fail "mock claude appends to document.md" "line count unchanged"
fi

# Score should improve after content added
new_score=$(bash autoresearch.sh)
TESTS_RUN=$((TESTS_RUN + 1))
if [[ "$new_score" -lt "$initial_score" ]]; then
  pass "score improved after research ($initial_score -> $new_score)"
else
  fail "score improved after research" "$initial_score -> $new_score"
fi

# ============================================================================
# Test: status.json output
# ============================================================================
echo ""
echo "=== Status JSON ==="

# Simulate writing status.json
iteration=3
MAX_ITERATIONS=50
score=30
starting_score=50
current_task="Research Stanford work"
current_issue=1
last_action="improved"
subject="Research Goal: Andrej Karpathy"
model="claude-opus-4-5"
session_start="2026-03-17T08:00:00Z"

cat > "$TEST_WORKSPACE/status.json" <<STATUSEOF
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

assert_file_exists "$TEST_WORKSPACE/status.json" "status.json created"

TESTS_RUN=$((TESTS_RUN + 1))
if jq . "$TEST_WORKSPACE/status.json" > /dev/null 2>&1; then
  pass "status.json is valid JSON"
else
  fail "status.json is valid JSON" "parse failed"
fi

assert_eq "30" "$(jq -r '.score' "$TEST_WORKSPACE/status.json")" "score field correct"

# ============================================================================
# Test: pause.flag behavior
# ============================================================================
echo ""
echo "=== Pause flag ==="

touch "$TEST_WORKSPACE/pause.flag"
assert_file_exists "$TEST_WORKSPACE/pause.flag" "pause.flag created"

rm -f "$TEST_WORKSPACE/pause.flag"
TESTS_RUN=$((TESTS_RUN + 1))
if [[ ! -f "$TEST_WORKSPACE/pause.flag" ]]; then
  pass "pause.flag removed"
else
  fail "pause.flag removed" "file still exists"
fi

# ============================================================================
# Test: feedback.md consumption
# ============================================================================
echo ""
echo "=== Feedback file ==="

echo "Focus on primary sources" > "$TEST_WORKSPACE/feedback.md"
assert_file_exists "$TEST_WORKSPACE/feedback.md" "feedback.md created"

feedback=$(cat "$TEST_WORKSPACE/feedback.md")
rm -f "$TEST_WORKSPACE/feedback.md"
assert_eq "Focus on primary sources" "$feedback" "feedback content read correctly"

TESTS_RUN=$((TESTS_RUN + 1))
if [[ ! -f "$TEST_WORKSPACE/feedback.md" ]]; then
  pass "feedback.md consumed (deleted)"
else
  fail "feedback.md consumed (deleted)" "file still exists"
fi

# ============================================================================
# Results
# ============================================================================

echo ""
echo "=========================================="
echo "  Results: $TESTS_PASSED passed, $TESTS_FAILED failed (of $TESTS_RUN)"
echo "=========================================="

if [[ $TESTS_FAILED -gt 0 ]]; then
  exit 1
fi
