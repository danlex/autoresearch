#!/bin/bash
set -euo pipefail

# ============================================================================
# seed-tasks.sh — Create initial labels and task Issues for testing
# ============================================================================

echo "Creating labels..."

# Task lifecycle labels
gh label create "task"                  --color "808080" --description "One research question" --force
gh label create "accepted"             --color "2ea44f" --description "Approved for research" --force
gh label create "proposed"             --color "ffffff" --description "Awaiting /accept" --force
gh label create "in-progress"          --color "fbca04" --description "Being worked on" --force
gh label create "awaiting-review"      --color "f0883e" --description "PR open, judges evaluating" --force
gh label create "needs-review"         --color "f0883e" --description "PR needs review" --force
gh label create "needs-better-research" --color "d73a4a" --description "PR rejected, needs rework" --force
gh label create "hard-task"            --color "b60205" --description "Failed 3+ times" --force
gh label create "unanswerable"         --color "000000" --description "5 attempts failed" --force
gh label create "implemented"          --color "2ea44f" --description "Done and merged" --force

# Type labels
gh label create "type-research"  --color "0075ca" --description "Needs web search" --force
gh label create "type-document"  --color "006b75" --description "Needs synthesis" --force
gh label create "type-review"    --color "5319e7" --description "Needs quality check" --force

# Priority labels
gh label create "priority-high"   --color "d73a4a" --description "Research first" --force
gh label create "priority-medium" --color "fbca04" --description "Default priority" --force
gh label create "priority-low"    --color "808080" --description "Research last" --force

# Other labels
gh label create "goal"            --color "0075ca" --description "Research subject" --force
gh label create "goal-amendment"  --color "0075ca" --description "Goal change proposal" --force
gh label create "proposal"        --color "5319e7" --description "Improvement suggestion" --force
gh label create "source"          --color "0e8a16" --description "Source suggestion" --force
gh label create "ai-proposed"     --color "ffffff" --description "AI generated" --force
gh label create "coverage-gap"    --color "f0883e" --description "Gap found by Goal Manager" --force

echo ""
echo "Creating task Issues..."

gh issue create \
  --title "Research Karpathy's academic work at Stanford" \
  --body "## Type
Research

## Section
Intellectual Contributions

## Why needed
Foundation of his career — PhD work on visual recognition, ImageNet contributions, and early deep learning research.

## What to find
- PhD thesis topic and advisor
- Key papers published at Stanford
- Contributions to ImageNet and visual recognition
- CS231n course creation timeline

## Suggested sources
- Stanford AI Lab pages
- Google Scholar
- Karpathy's personal blog

## Acceptance criteria
- [ ] PhD advisor and thesis topic identified with Tier 1 source
- [ ] At least 3 key papers listed with citation counts
- [ ] CS231n origin documented" \
  --label "task,accepted,type-research,priority-high"

gh issue create \
  --title "Research Karpathy's role at OpenAI" \
  --body "## Type
Research

## Section
Intellectual Contributions

## Why needed
OpenAI founding member — understanding his contributions there is central to his story.

## What to find
- When he joined and in what capacity
- Key projects he led or contributed to
- Why he left (both times)
- His public statements about OpenAI

## Suggested sources
- OpenAI blog posts
- Karpathy's Twitter/X
- Tech press interviews

## Acceptance criteria
- [ ] Join date and role documented with Tier 1 source
- [ ] At least 2 key projects identified
- [ ] Departure context from primary sources" \
  --label "task,accepted,type-research,priority-high"

gh issue create \
  --title "Research Karpathy's work at Tesla Autopilot" \
  --body "## Type
Research

## Section
Intellectual Contributions

## Why needed
Led Tesla's AI/Autopilot team — major career chapter with significant technical contributions.

## What to find
- Role and title at Tesla
- Duration of tenure
- Key technical decisions and approaches
- His talks about Tesla's vision-only approach
- Why he left Tesla

## Suggested sources
- Tesla AI Day presentations
- Karpathy's conference talks
- Tesla blog posts

## Acceptance criteria
- [ ] Title and tenure documented
- [ ] Vision-only approach explained with Tier 1 source
- [ ] At least 2 Tesla AI Day contributions documented" \
  --label "task,accepted,type-research,priority-medium"

gh issue create \
  --title "Research Eureka Labs founding and mission" \
  --body "## Type
Research

## Section
Eureka Labs

## Why needed
His current venture — understanding what he's building now and why.

## What to find
- Founding date and announcement
- Stated mission and vision
- Any products or courses launched
- Team and funding (if public)

## Suggested sources
- Eureka Labs website
- Karpathy's announcement posts
- Tech press coverage

## Acceptance criteria
- [ ] Founding date confirmed with Tier 1 source
- [ ] Mission statement documented
- [ ] Any public products/courses listed" \
  --label "task,accepted,type-research,priority-medium"

gh issue create \
  --title "Synthesize Intellectual Contributions section" \
  --body "## Type
Document

## Section
Intellectual Contributions

## Why needed
After research tasks complete, this section needs synthesis into coherent narrative.

## What to find
N/A — synthesis task, no new research.

## Acceptance criteria
- [ ] Section reads as coherent prose, not bullet points
- [ ] All existing citations preserved
- [ ] No new claims added
- [ ] Confidence levels maintained" \
  --label "task,accepted,type-document,priority-low"

echo ""
echo "Done! Created 5 task Issues."
echo "Run './autoresearch.sh' to see the score."
