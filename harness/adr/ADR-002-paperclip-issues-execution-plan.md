# Harness Planning In Paperclip Issues

Date: 2026-04-04

## Goal

Use Paperclip's own issue system as the canonical execution plan for harness development, so the control plane improves itself using its native primitives.

## Canonical Workflow

1. Keep strategy and scope in `harness/adr/ADR-001-agentic-harness-paperclip-adaptation.md`.
2. Keep harness execution inside a dedicated Paperclip project (`Harness Scaffolding`).
3. Materialize execution tasks as Paperclip issues within that project.
4. Run work through normal assignment + checkout + status transitions.
5. Store implementation notes in issue comments/documents (`plan`, `retro`) rather than ad hoc chat.

## Project Scaffolding (Recommended)

Use a dedicated project to make filtering and execution context explicit:

- Project name: `Harness Scaffolding`
- Primary workspace cwd: `/workspace`
- Work type tag: label `harness`

This gives you a clean query surface for harness-only work and makes it obvious that code changes happen in the bind-mounted repo workspace.

## Initial Issue Policy

Automation scripts intentionally create only one starter issue:

- `HARNESS: Hello world`

This avoids opinionated backlog generation and keeps setup generic for new teams.
Create additional harness issues manually from your own plan.

### Docker one-command path

If Paperclip is running in Docker, use the consolidated setup script:

```sh
PAPERCLIP_API_KEY=<board-token> \
PAPERCLIP_COMPANY_ID=<company-id> \
HARNESS_ROLE_SET=core \
HARNESS_ADAPTER_TYPE=opencode_local \
./harness/scripts/setup-harness-docker.sh
```

This runs:

1. project/label/bootstrap issue setup
2. role-agent configuration

### Project and starter issue bootstrap

Create/refresh project metadata and the starter issue:

```sh
PAPERCLIP_API_BASE=http://localhost:3100 \
PAPERCLIP_API_KEY=<board-or-agent-token> \
PAPERCLIP_COMPANY_ID=<company-id> \
./harness/scripts/bootstrap-harness-project-context.sh
```

This script ensures:

- project `Harness Scaffolding` exists with workspace `/workspace`
- label `harness` exists
- starter issue `HARNESS: Hello world` exists and is linked to the project/label
- starter issue asks the assigned agent to run `pwd && ls -a` and post output

## Operational Notes

- Paperclip issues are canonical for execution tracking.
- GitHub is canonical for PR/review artifacts.
- Every PR URL should be posted back to the related Paperclip issue comment thread.
- Reviewers also post an approve/block summary in the related Paperclip issue thread.

## Reproducibility Principle

Harness setup must be scriptable and replayable for new users/companies.

- Do not rely on ad hoc UI-only setup.
- Prefer scripts that can recreate project context, starter issue bootstrap, and agent configuration.
- When API behavior changes, update `harness/scripts/README.md` in the same PR.
- Exemption: local-only issue operations for a specific environment/run do not require script updates if harness behavior is unchanged.
- For harness workflow/config PRs, run `harness/templates/PR-CHECKLIST.md` before merge.

Current setup scripts:

- `harness/scripts/bootstrap-harness-project-context.sh`
- `harness/scripts/setup-harness-agent-configs.sh`
- `harness/scripts/setup-harness-docker.sh`
- `harness/scripts/README.md`

### Agent config setup

Host mode:

```sh
PAPERCLIP_API_BASE=http://localhost:3100 \
PAPERCLIP_API_KEY=<board-token> \
PAPERCLIP_COMPANY_ID=<company-id> \
HARNESS_ROLE_SET=core \
HARNESS_ADAPTER_TYPE=opencode_local \
./harness/scripts/setup-harness-agent-configs.sh
```

Docker mode:

```sh
PAPERCLIP_API_KEY=<board-token> \
PAPERCLIP_COMPANY_ID=<company-id> \
HARNESS_RUN_CONTEXT_BOOTSTRAP=false \
HARNESS_RUN_AGENT_SETUP=true \
HARNESS_ROLE_SET=core \
HARNESS_ADAPTER_TYPE=opencode_local \
./harness/scripts/setup-harness-docker.sh
```

Role set options:

- `minimal`: Builder + Reviewer
- `core`: Builder + Reviewer + Tester + Architect
- `full`: Builder + Reviewer + Tester + Architect + Auditor
