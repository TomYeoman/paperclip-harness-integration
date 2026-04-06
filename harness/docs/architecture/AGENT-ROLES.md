# Agent Roles

> HUMAN REFERENCE ONLY — canonical behavior is defined by harness runtime docs.

## Canonical Sources

- `harness/AGENTS.md`
- `harness/roles/ROLE-*.md`
- `harness/runtime-instructions/README.md`

## Role Topology

The harness uses a Lead-led operating model with role-specialized execution.

Core roles:

- Lead (CEO behavior)
- Builder
- Reviewer
- Tester
- Architect
- Auditor

Parity expansion roles:

- PM
- QE
- Contract Tester
- Integration Tester
- Security Researcher
- Security Reviewer

## Activation Policy

- `minimal`: Builder + Reviewer
- `core`: Builder + Reviewer + Tester + Architect
- `full`: Core + Auditor
- `parity`: Full + PM + QE + Contract Tester + Integration Tester + Security roles

Provisioning behavior is controlled by `harness/scripts/setup-harness-agent-configs.sh`.
