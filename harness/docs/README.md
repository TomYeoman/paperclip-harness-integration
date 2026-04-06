# Harness Human-Reference Docs

These documents are for human orientation and onboarding.

> HUMAN REFERENCE ONLY — canonical behavior is defined by harness runtime docs.

When guidance conflicts, canonical runtime docs win. See `harness/CANONICAL-SOURCES.md`.

## Architecture Docs

- `harness/docs/architecture/AGENT-ROLES.md`
- `harness/docs/architecture/COMMUNICATION-DSL.md`
- `harness/docs/architecture/SESSION-LIFECYCLE.md`
- `harness/docs/architecture/MILESTONE-WORKFLOW.md`
- `harness/docs/architecture/LEARNING-SYSTEM.md`
- `harness/docs/architecture/WORKTREE-MODEL.md`

## Mapping: Human Doc -> Canonical Sources

| Human Doc | Canonical Sources |
| --- | --- |
| `AGENT-ROLES.md` | `harness/AGENTS.md`, `harness/roles/ROLE-*.md`, `harness/runtime-instructions/README.md` |
| `COMMUNICATION-DSL.md` | `harness/protocol.md`, `harness/templates/ISSUE-COMMENT-TEMPLATES.md` |
| `SESSION-LIFECYCLE.md` | `harness/AGENTS.md`, `harness/protocol.md` |
| `MILESTONE-WORKFLOW.md` | `harness/spec-driven.md`, `harness/protocol.md`, `harness/templates/MILESTONE-GATE-TEMPLATE.md` |
| `LEARNING-SYSTEM.md` | `harness/protocol.md`, `harness/AGENTS.md`, `harness/templates/LESSON-EVENT-TEMPLATE.md`, `harness/templates/LESSONS-TEMPLATE.md` |
| `WORKTREE-MODEL.md` | `harness/scripts/setup-harness-workspace-policy.sh`, `harness/scripts/README.md` |
