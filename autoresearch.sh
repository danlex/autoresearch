#!/bin/bash
open=$(gh issue list --label "task,accepted" --state open --json number | jq 'length' 2>/dev/null | tr -d '[:space:]')
open=${open:-0}
rework=$(gh issue list --label "needs-better-research" --state open --json number | jq 'length' 2>/dev/null | tr -d '[:space:]')
rework=${rework:-0}
low=$(grep -c "Depth: LOW" document.md 2>/dev/null || true)
low=${low:-0}
echo $(( (open * 10) + (rework * 5) + (low * 3) ))
