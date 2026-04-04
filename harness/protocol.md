# Harness Communication Protocol

Runtime-agnostic communication standards for Paperclip-based harness execution.

## Communication Transport

Paperclip-native communication replaces Claude-native intra-session orchestration:

| Original Harness | Paperclip Equivalent |
|------------------|---------------------|
| TeamCreate/SendMessage | Issue assignment + comments |
| Inline task status | Issue status transitions |
| Inter-agent chat | Issue comments + @mentions |
| Board handoffs | Checkout/release |

All communication must be traceable in issue threads. No private side channels.

## Status Mapping

Every agent action maps to a Paperclip primitive:

| Action | Paperclip Primitive |
|--------|--------------------|
| Report progress | Issue comment |
| Discovery complete | DISCOVERY gate comment posted |
| Ready to execute | Checkout (or accept assignment) |
| Blocked | Issue status → `blocked` + comment |
| Implementation done | PR opened, issue → `in_review` |
| Review feedback | Issue comment on PR |
| Merged | Issue → `done` |
| Need decision | Issue → `blocked` (unblocker = named in comment) |

## Token Economy Rules

1. No filler — no "please", "thank you", "of course"
2. No preamble — start with the point
3. No restatement — do not repeat what was already written
4. No hedging — state decisions, not possibilities
5. No over-commenting — comment code, not intent already obvious
6. Discovery is concise — 3-5 sentences maximum
7. Escalations are decision trees — not essays
8. Diffs not prose — code changes explained by diff, not narrative
9. Batch related work — group file operations
10. Context hygiene — exit a task clean before starting another

## Discovery Gate

Required before any code implementation:

```
DISCOVERY: <issue-id>
READ: <files>
UNDERSTAND: <2-3 sentences>
UNKNOWNS: <list or NONE>
PLAN:
- <step>
- <step>
R: yes | blocked:<reason>
```

Post in issue thread. Do not begin implementation until discovery is complete and `R: yes`.

## Done Message Format

```
DONE: <issue-id>
CHANGES:
- <path>: <what changed>
CHECKS:
- <command>: pass | fail | not-run (<reason>)
SELF-AUDIT:
- <criterion>: pass | fail
PR: <url or NONE>
```

## Block Comment Format

```
BLOCK: <file>:<line>
SPEC: <reference>
REQUIRED: <specific change>
```

Include file/line reference and spec reference. State exactly what must change, not what is wrong.

## Model Assignment

| Role | Model | Rationale |
|------|-------|-----------|
| CEO/Lead | Highest reasoning | Coordination decisions |
| Architect | Sonnet (routine) / Opus (tradeoffs) | Interface design |
| Builder | Sonnet | Implementation against interfaces |
| Reviewer | Sonnet (early) / Opus (complex) | Quality validation |
| Tester | Sonnet | Test authoring |
| Auditor | Opus | Security/architecture analysis |

## Discovery-to-Execution Gate

No transition without explicit go signal:

- Normal tasks: Lead/CEO explicit GO via issue comment or assignment
- Trivial tasks (<50 lines, single file, no new interfaces): Agent may self-authorize with evidence

```
SELF-GO: trivial change, 12 lines, single file, no new interfaces. Proceeding.
```

## Scalability Rules

- One active issue per agent
- No file scope overlap between concurrent builders (enforced by issue assignment)
- Checkout is the concurrency guard — never retry a 409 Conflict
- Escalate after three concrete failed attempts with evidence in the issue thread
