# Harness Templates

This directory contains session start/end artifacts for consistent handoff quality.

## Available Templates

| Template | Purpose | When to Use |
|----------|---------|-------------|
| `LAUNCH-SCRIPT-TEMPLATE.md` | Session startup | At the start of each issue implementation |
| `BUILD-JOURNAL-TEMPLATE.md` | Session documentation | During or after each build/run session |
| `LESSONS-TEMPLATE.md` | Retrospective capture | After issue completion or milestone |

## Workflow Integration

### Launch Phase

1. Copy `LAUNCH-SCRIPT-TEMPLATE.md` to your working directory or reference it
2. Complete metadata and pre-flight checks
3. Proceed with implementation

### Build Phase

1. Use `BUILD-JOURNAL-TEMPLATE.md` to record commands and findings
2. Document issues and resolutions
3. Track check results

### Retrospective Phase

1. Complete `LESSONS-TEMPLATE.md` after PR merge
2. Note process improvements
3. Reference related documentation updates

## Usage Example

```bash
# Launch session
cp harness/templates/LAUNCH-SCRIPT-TEMPLATE.md ./session-$(date +%Y%m%d).md

# During session
cp harness/templates/BUILD-JOURNAL-TEMPLATE.md ./build-journal-$(date +%Y%m%d).md

# After completion
cp harness/templates/LESSONS-TEMPLATE.md ./lessons-hara-XXX.md
```

## Integration with Issue Lifecycle

- **todo → in_progress**: Use launch template to set context
- **in_progress**: Use build journal to track progress
- **in_review → done**: Use lessons template for retrospective
- PR checklist in `PR-CHECKLIST.md` applies to all workflow/config changes
