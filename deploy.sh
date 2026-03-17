#!/bin/bash
set -euo pipefail

# ============================================================================
# deploy.sh — One-command setup for Codespaces or any fresh environment
# Usage: bash deploy.sh
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=========================================="
echo "  Autoresearch — Deploy"
echo "=========================================="

# --- Check ANTHROPIC_API_KEY ---
if [[ -z "${ANTHROPIC_API_KEY:-}" ]]; then
  echo ""
  echo "ANTHROPIC_API_KEY is not set."
  read -rsp "Paste your Anthropic API key (input hidden): " api_key
  echo ""
  export ANTHROPIC_API_KEY="$api_key"
  # Write to .env file (gitignored) instead of bashrc for security
  echo "export ANTHROPIC_API_KEY='$api_key'" > "$SCRIPT_DIR/.env"
  chmod 600 "$SCRIPT_DIR/.env"
  echo "Key saved to .env (chmod 600). Source it with: source .env"
fi

# --- Install system dependencies ---
echo ""
echo "[1/6] Checking dependencies..."

if ! command -v jq &>/dev/null; then
  echo "  Installing jq..."
  if command -v apt-get &>/dev/null; then
    sudo apt-get update -qq && sudo apt-get install -yqq jq
  elif command -v brew &>/dev/null; then
    brew install jq
  else
    echo "ERROR: Cannot install jq. Install manually."
    exit 1
  fi
fi
echo "  jq: $(jq --version)"

if ! command -v gh &>/dev/null; then
  echo "  Installing GitHub CLI..."
  if command -v apt-get &>/dev/null; then
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt-get update -qq && sudo apt-get install -yqq gh
  elif command -v brew &>/dev/null; then
    brew install gh
  else
    echo "ERROR: Cannot install gh. Install manually."
    exit 1
  fi
fi
echo "  gh: $(gh --version | head -1)"

# --- Authenticate GitHub CLI if needed ---
if ! gh auth status &>/dev/null; then
  echo ""
  echo "GitHub CLI not authenticated."
  if [[ -n "${GITHUB_TOKEN:-}" ]]; then
    echo "$GITHUB_TOKEN" | gh auth login --with-token
    echo "  Authenticated via GITHUB_TOKEN"
  else
    echo "  Run: gh auth login"
    gh auth login
  fi
fi

# --- Install Claude Code CLI ---
echo ""
echo "[2/6] Installing Claude Code CLI..."
if ! command -v claude &>/dev/null; then
  npm install -g @anthropic-ai/claude-code
fi
echo "  claude: $(claude --version 2>/dev/null || echo 'installed')"

# --- Install backend ---
echo ""
echo "[3/6] Building NestJS backend..."
cd "$SCRIPT_DIR/backend"
npm install --silent 2>&1 | tail -1
npx nest build
cd "$SCRIPT_DIR"
echo "  Backend ready"

# --- Seed tasks if none exist ---
echo ""
echo "[4/6] Checking GitHub Issues..."
issue_count=$(gh issue list --label "task" --state open --json number | jq length 2>/dev/null || echo 0)
if [[ "$issue_count" -eq 0 ]]; then
  echo "  No task Issues found. Running seed-tasks.sh..."
  bash seed-tasks.sh
else
  echo "  Found $issue_count existing task Issues"
fi

# --- Show score ---
echo ""
echo "[5/6] Current score..."
score=$(bash autoresearch.sh)
echo "  Score: $score (lower = better, 0 = done)"

# --- Start backend + research ---
echo ""
echo "[6/6] Starting services..."
echo ""
echo "  Starting NestJS backend on port 3000..."
cd "$SCRIPT_DIR/backend"
nohup node dist/main.js > "$SCRIPT_DIR/backend.log" 2>&1 &
BACKEND_PID=$!
cd "$SCRIPT_DIR"
echo "  Backend PID: $BACKEND_PID"
echo ""

# Write a stop script
cat > "$SCRIPT_DIR/stop.sh" <<'STOPEOF'
#!/bin/bash
echo "Stopping autoresearch..."
touch pause.flag
pkill -f "node dist/main.js" 2>/dev/null && echo "Backend stopped" || echo "Backend not running"
pkill -f "research.sh" 2>/dev/null && echo "Research stopped" || echo "Research not running"
rm -f pause.flag
echo "Done."
STOPEOF
chmod +x "$SCRIPT_DIR/stop.sh"

echo "=========================================="
echo "  Deploy complete!"
echo "=========================================="
echo ""
echo "  Backend:  http://localhost:3000/api/status"
echo "  Cron:     research runs every hour automatically"
echo "  Score:    $score"
echo ""
echo "  To start research now:"
echo "    NO_JUDGES=1 ./research.sh"
echo ""
echo "  To stop everything:"
echo "    ./stop.sh"
echo ""
echo "  Monitor:"
echo "    tail -f research.log"
echo "    curl localhost:3000/api/status"
echo ""
