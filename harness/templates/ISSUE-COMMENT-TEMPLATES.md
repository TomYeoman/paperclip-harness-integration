# Issue Comment Templates

Standardized templates for harness execution. Use these formats in issue comments to ensure consistency.

## Discovery Gate

```
DISCOVERY: <issue-id>
READ: <comma-separated file paths>
UNDERSTAND: <2-3 sentences describing what needs to be done>
UNKNOWNS: <list of unknowns or NONE>
PLAN:
- <step>
- <step>
R: yes | blocked:<reason>
```

Example:

```
DISCOVERY: HARA-15
READ: harness/protocol.md, harness/AGENTS.md
UNDERSTAND: Need to add automated status reporting to the heartbeat workflow. The protocol already has status mapping; this extends it with a periodic check script.
UNKNOWNS: NONE
PLAN:
- Create harness/scripts/heartbeat-status-report.sh
- Document required env vars in harness/scripts/README.md
- Test the script with a dry-run invocation
R: yes
```

## Done Message

```
DONE: <issue-id>
CHANGES:
- <path>: <what changed>
- <path>: <what changed>
CHECKS:
- <command>: pass | fail | not-run (<reason>)
SELF-AUDIT:
- <criterion>: pass | fail
PR: <url or NONE>
```

Example:

```
DONE: HARA-9
CHANGES:
- harness/protocol.md: Added Lifecycle States section with transition matrix
- harness/templates/ISSUE-COMMENT-TEMPLATES.md: Created new file with templates
CHECKS:
- bash -n harness/scripts/*.sh: pass
- Documentation reviewed: pass
SELF-AUDIT:
- Acceptance criteria satisfied: pass
- No contradictions with existing docs: pass
PR: https://github.com/anomalyco/harness/pull/42
```

## Block Comment

```
BLOCK: <file>:<line>
SPEC: <reference>
REQUIRED: <specific change>
```

Example:

```
BLOCK: harness/protocol.md:45
SPEC: harness/spec-driven.md section 3.2
REQUIRED: Add explicit error handling for the new status transition validation
```

## Escalation

```
ESCALATE: <issue-id>
TYPE: scope | blocker | decision | review
STATUS: <current status>
EVIDENCE:
- <concrete observation 1>
- <concrete observation 2>
REQUIRED: <what needs to happen>
```

Example:

```
ESCALATE: HARA-20
TYPE: decision
STATUS: in_progress
EVIDENCE:
- PR introduces new workflow automation pattern
- No existing pattern covers this case in tdd-standards.md
REQUIRED: ARCHITECT review to approve the pattern before merge
```

## Review Summary (Reviewer posts on issue)

```
REVIEW: <issue-id>
PR: <url>
DECISION: approved | blocked
REASONS:
- <reason>
REQUIRED-CHANGES:
- <change or NONE>
```

Example:

```
REVIEW: HARA-9
PR: https://github.com/anomalyco/harness/pull/42
DECISION: approved
REASONS:
- Lifecycle states clearly documented with transition matrix
- Role responsibilities align with existing role contracts
- No contradictions detected
REQUIRED-CHANGES: NONE
```

## Self-Go (Trivial tasks)

```
SELF-GO: <reason>, <lines>, <files>, <interfaces>
```

Example:

```
SELF-GO: fix typo in docs, 3 lines, single file, no new interfaces. Proceeding.
```

## Progress Update

```
PROGRESS: <issue-id>
- <completed step>
- <completed step>
NEXT: <what comes next>
BLOCKED: <yes | no>
```

Example:

```
PROGRESS: HARA-15
- Created heartbeat-status-report.sh skeleton
- Reviewed env var handling in existing scripts
NEXT: Implement status aggregation logic
BLOCKED: no
```
