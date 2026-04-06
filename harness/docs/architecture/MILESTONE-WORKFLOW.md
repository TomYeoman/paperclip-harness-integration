# Milestone Workflow

> HUMAN REFERENCE ONLY — canonical behavior is defined by harness runtime docs.

## Canonical Sources

- `harness/spec-driven.md`
- `harness/protocol.md`
- `harness/templates/MILESTONE-GATE-TEMPLATE.md`

## Milestone Contract

Milestones are managed through Paperclip issues and parent/child hierarchy.

Required for architecture-impacting milestone work:

1. Explicit `Related ADRs` in spec/issue artifacts.
2. Acceptance criteria expressed in observable behavior.
3. `MILESTONE-GATE:` evidence comment before closure.

## Gate Decision

- `ready`: all required acceptance evidence is present.
- `blocked`: missing checks, unresolved risks, or unclear ADR linkage.

Milestone evidence must stay in issue comments/documents, not separate hidden trackers.
