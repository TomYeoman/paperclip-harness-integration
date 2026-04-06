# Harness Communication Protocol

Runtime-agnostic communication standards for Paperclip-based harness execution.

## Communication Transport

All coordination is Paperclip-native:

- Issue assignment for ownership
- Issue comments for progress, decisions, and handoffs
- Status transitions for lifecycle state
- Checkout/release for execution locks

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
| Queued for merge (queue enabled) | Issue stays `in_review` + `QUEUE:` evidence comment |
| Merged (queue disabled) | Issue → `done` |
| Merge confirmed (queue enabled) | `CONFIRMED-D:` evidence comment + issue → `done` |
| Lesson discovered during execution | Post `L:` issue comment + capture lesson entry |
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

## Merge Queue Lifecycle Rule

When target repo uses merge queue:

1. Builder queues merge (for example via `gh pr merge --merge --auto`).
2. Issue remains `in_review` while PR state is queued-only.
3. Builder posts `QUEUE:` evidence in issue comments.
4. Transition to `done` is allowed only after merge confirmation.
5. Builder posts `CONFIRMED-D:` evidence and then moves issue to `done`.

When merge queue is not enabled:

- keep direct merge flow; approved + merged PR may transition directly to `done`.

## Learning Event Capture Rule

Learning events must be captured immediately when discovered.

Rules:

1. Post an `L:` issue comment in the same heartbeat/session when the lesson is observed.
2. Use the lesson event template (`harness/templates/LESSON-EVENT-TEMPLATE.md`) for structure.
3. Do not batch multiple lessons only at end-of-session.
4. Before closing the issue, ensure `retro` issue document includes the captured lessons.

Required evidence chain:

- `L:` issue comment
- template-backed lesson event entry
- `retro` issue document update at completion

## Milestone Acceptance Gate Rule

For architecture-impacting or milestone parent issues:

1. Include `Related ADRs` in issue/spec artifacts.
2. Post `MILESTONE-GATE:` evidence comment before transition to `done`.
3. Gate evidence must list acceptance criteria, verification outcomes, and unresolved risks.

## Block Comment Format

```
BLOCK: <file>:<line>
SPEC: <reference>
REQUIRED: <specific change>
```

Include file/line reference and spec reference. State exactly what must change, not what is wrong.

## Model Configuration

Model choice is enforced through Paperclip agent configuration, not this document.

- Source of truth: agent `adapterType` + `adapterConfig.model`
- Default provisioning path: `harness/scripts/setup-harness-agent-configs.sh`
- Runtime override path: explicit agent/issue adapter overrides when needed

This protocol defines communication behavior. Agent config defines model behavior.

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
