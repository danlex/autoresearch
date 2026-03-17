#!/bin/bash
open=$(gh issue list --label "task,accepted" --state open \
  --json number | jq length 2>/dev/null || echo 0)
rework=$(gh issue list --label "needs-better-research" --state open \
  --json number | jq length 2>/dev/null || echo 0)
low=$(grep -c "Depth: LOW" document.md 2>/dev/null || echo 0)
echo $(( (open * 10) + (rework * 5) + (low * 3) ))
