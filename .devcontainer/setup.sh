#!/bin/bash
set -euo pipefail

# ============================================================================
# .devcontainer/setup.sh — One-time Codespace setup
# Runs automatically via postCreateCommand
# ============================================================================

echo "Setting up Autoresearch Codespace..."

# Install Claude Code CLI
npm install -g @anthropic-ai/claude-code

# Install jq
sudo apt-get update -qq && sudo apt-get install -yqq jq

# Install backend dependencies
cd backend && npm install && npx nest build && cd ..

echo "Setup complete. deploy.sh will run automatically on start."
