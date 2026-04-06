# Harness Issue Comment Templates

Use these templates for consistent, auditable issue evidence.

## Discovery Gate

```text
DISCOVERY: <issue-id>
READ: <files>
UNDERSTAND: <2-3 sentences>
UNKNOWNS: <list or NONE>
PLAN:
- <step>
- <step>
R: yes | blocked:<reason>
```

## Queue Evidence (merge queue enabled)

```text
QUEUE: <issue-id>
PR: <url>
QUEUE-MODE: enabled
STATE: queued
NEXT: stay in_review until merge confirmed
```

## Merge Confirmation Evidence

```text
CONFIRMED-D: <issue-id>
PR: <url>
MERGE-COMMIT: <sha>
MERGED-AT: <timestamp>
EVIDENCE: <command or link used to verify>
TRANSITION: in_review -> done
```

## Review Summary

```text
REVIEW: <issue-id>
PR: <url>
DECISION: approved | blocked
REASONS:
- <reason>
REQUIRED-CHANGES:
- <change or NONE>
```

## Completion

```text
DONE: <issue-id>
CHANGES:
- <path>: <what changed>
CHECKS:
- <command>: pass | fail | not-run (<reason>)
SELF-AUDIT:
- <criterion>: pass | fail
PR: <url or NONE>
```
