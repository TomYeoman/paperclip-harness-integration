# Harness Templates

Template inventory for harness issue evidence and workflow consistency.

## Available Templates

| Template | Purpose | Required When |
|----------|---------|---------------|
| `ISSUE-COMMENT-TEMPLATES.md` | Standard comment blocks for discovery/review/queue/close | Always (workflow evidence) |
| `PR-CHECKLIST.md` | PR review checklist for harness workflow/config changes | Harness workflow/config PRs |
| `LESSON-EVENT-TEMPLATE.md` | Immediate `L:` lesson capture block | Every lesson discovered during execution |
| `LESSONS-TEMPLATE.md` | Issue `retro` document structure | Before moving merged issue to `done` |
| `MILESTONE-GATE-TEMPLATE.md` | Milestone acceptance gate evidence | Milestone parent or architecture-impacting work |

## Learning Loop Contract

Required evidence chain:

1. Post `L:` event immediately in issue comments using `LESSON-EVENT-TEMPLATE.md`.
2. Carry those events into issue document key `retro` using `LESSONS-TEMPLATE.md`.
3. Close issue only after the retro update is complete.

## Milestone Contract

For architecture-impacting and milestone parent issues:

1. Include `Related ADRs` in issue/spec artifacts.
2. Post a `MILESTONE-GATE:` comment using `MILESTONE-GATE-TEMPLATE.md`.
3. Record pass/fail acceptance evidence before close.
