# Harness Canonical Sources

This file defines source precedence for harness behavior.

## Precedence Order

1. Runtime-canonical governance docs:
   - `harness/AGENTS.md`
   - `harness/protocol.md`
   - `harness/spec-driven.md`
   - `harness/tdd-standards.md`
2. Role contracts and runtime entrypoints:
   - `harness/roles/ROLE-*.md`
   - `harness/runtime-instructions/*/AGENTS.md`
3. Operational templates and scripts:
   - `harness/templates/*.md`
   - `harness/scripts/*.sh`
4. ADRs and planning artifacts:
   - `harness/adr/*.md`
5. Human-reference architecture docs:
   - `harness/docs/architecture/*.md`

## Conflict Resolution Rule

If two sources disagree, higher-precedence canonical runtime docs win.

- Human-reference docs never override runtime contracts.
- Runtime entrypoints must always point to canonical runtime docs and role contracts.
- Any behavior change must update canonical runtime docs first, then human-reference docs.

## Banner Requirement For Human Docs

Every file under `harness/docs/architecture/` must start with:

`HUMAN REFERENCE ONLY — canonical behavior is defined by harness runtime docs`
