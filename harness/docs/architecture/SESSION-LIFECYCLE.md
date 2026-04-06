# Session Lifecycle

> HUMAN REFERENCE ONLY — canonical behavior is defined by harness runtime docs.

## Canonical Sources

- `harness/AGENTS.md`
- `harness/protocol.md`

## High-Level Flow

1. Identify issue scope and acceptance criteria.
2. Post discovery evidence.
3. Checkout and move issue to `in_progress`.
4. Execute work and post progress/learning evidence.
5. Open PR and move issue to `in_review`.
6. Apply queue-aware close behavior:
   - queue disabled: merge -> `done`
   - queue enabled: `QUEUE:` evidence while queued, `CONFIRMED-D:` before `done`
7. Complete retro and close with evidence.

## Lifecycle Guarantees

- one active assignee per issue
- traceable evidence in issue comments/documents
- close gates enforced before `done`
