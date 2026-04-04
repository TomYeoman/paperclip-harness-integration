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

## Lifecycle States

Harness work follows this canonical lifecycle:

| State | Meaning | Allowed Next States |
|-------|---------|-------------------|
| `backlog` | Triaged, not yet ready | `todo` |
| `todo` | Ready to work, assigned | `in_progress`, `blocked`, `cancelled` |
| `in_progress` | actively executing | `in_review`, `blocked`, `cancelled` |
| `in_review` | PR open, awaiting review | `in_progress`, `done`, `blocked` |
| `done` | merged and verified | — (terminal) |
| `blocked` | awaiting external input | `in_progress`, `cancelled` |
| `cancelled` | abandoned | — (terminal) |

### State Transition Rules

1. `backlog` → `todo`: Lead assigns the issue
2. `todo` → `in_progress`: Agent checks out the issue
3. `in_progress` → `in_review`: Builder opens PR, posts link in issue
4. `in_review` → `done`: Reviewer approves and Builder merges
5. `in_review` → `in_progress`: Reviewer requests changes
6. Any active → `blocked`: Agent posts BLOCK comment, updates status
7. `blocked` → `in_progress`: Blocker resolved, agent resumes work
8. `todo`/`in_progress`/`in_review` → `cancelled`: Lead cancels with reason

### State Transition Commands

```bash
# Start work (agent self-transition on checkout)
POST /api/issues/{id}/checkout

# Move to in_review when PR is ready
PATCH /api/issues/{id} { "status": "in_review", "comment": "PR: https://..." }

# Mark done after merge
PATCH /api/issues/{id} { "status": "done", "comment": "Merged" }

# Block on external dependency
PATCH /api/issues/{id} { "status": "blocked", "comment": "BLOCK: awaiting X from Y" }
```

## Role Responsibilities

| Role | On Checkout | During Work | On Complete | Never |
|------|------------|-------------|-------------|-------|
| Builder | Checkouts issue, posts DISCOVERY | Implements, runs checks | Opens PR, moves to `in_review`, posts PR link | Merges |
| Reviewer | — | Reviews PR | Posts approve/block summary, approves merge | Checks out, implements |
| Lead | Assigns to `todo` | Orchestrates, unblocks | Confirms final verification | Merges code |
| Tester | — | Validates acceptance criteria | Posts test results | Merges |

## Escalation Rules

### When to Escalate

1. **Scope conflict**: Acceptance criteria contradicts discovered behavior
2. **Blocker persists**: 3 concrete attempts failed
3. **Decision needed**: Governance or security decision required
4. **Review disagreement**: Cannot resolve with evidence after 2 rounds

### Escalation Format

```
ESCALATE: <issue-id>
TYPE: scope | blocker | decision | review
STATUS: <current status>
EVIDENCE:
- <concrete observation 1>
- <concrete observation 2>
REQUIRED: <what needs to happen>
```

### Unblock Protocol

1. Agent posts BLOCK comment with specific required action
2. Status → `blocked`, unblocker named in comment
3. Unblocker resolves → posts comment confirming resolution
4. Agent confirms resumption → status → `in_progress`

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

## GitHub PR Preflight

Before claiming a task that requires a PR:

1. GitHub CLI auth is valid in runtime environment (`gh auth status`).
2. Target repo is accessible (`gh repo view`).
3. Push remote is reachable (`git ls-remote <remote>`).

If preflight fails, post `BLOCK` in the issue with exact failure output and required setup step.

## Scalability Rules

- One active issue per agent
- No file scope overlap between concurrent builders (enforced by issue assignment)
- Checkout is the concurrency guard — never retry a 409 Conflict
- Escalate after three concrete failed attempts with evidence in the issue thread
