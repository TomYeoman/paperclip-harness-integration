# Harness Planning In Paperclip Issues

Date: 2026-04-04

## Goal

Use Paperclip's own issue system as the canonical execution plan for harness development, so the control plane improves itself using its native primitives.

## Canonical Workflow

1. Keep strategy and scope in `harness/discovery.md`.
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

## Proposed Initial Backlog

Create one parent issue plus child issues.

### Parent

- Title: `HARNESS: Paperclip-native orchestration migration`
- Priority: `high`
- Status: `todo`
- Description:
  - Migrate Claude-oriented harness design into runtime-agnostic governance compatible with `claude_local`, `codex_local`, and `opencode_local`.
  - Make Paperclip issues/comments/checkout the orchestration source of truth.

### Children

1. `HARNESS: Define runtime-agnostic core contract`
   - Priority: `high`
   - Deliverables: `AGENTS.md` core contract, scope boundaries, verification gates.

2. `HARNESS: Define role contracts (Lead/Architect/Builder/Reviewer/Tester/Auditor)`
   - Priority: `high`
   - Deliverables: role files with non-negotiables and escalation rules.

3. `HARNESS: Define protocol + spec-driven + TDD standards`
   - Priority: `high`
   - Deliverables: communication protocol, spec chain policy, TDD guidance.

4. `HARNESS: Add adapter overlays for claude_local/codex_local/opencode_local`
   - Priority: `high`
   - Deliverables: runtime notes, instructions path policy, env diagnostics checklist.

5. `HARNESS: Establish Paperclip issue lifecycle for harness execution`
   - Priority: `high`
   - Deliverables: issue state model, assignment policy, reviewer handoff trigger.

6. `HARNESS: Seed launch/session artifacts`
   - Priority: `medium`
   - Deliverables: launch template, build journal starter, lessons starter.

7. `HARNESS: Run pilot milestone with Lead/Builder/Reviewer`
   - Priority: `high`
   - Deliverables: one end-to-end issue -> PR -> review -> merge flow.

8. `HARNESS: Expand to Architect/Tester/Auditor and routines`
   - Priority: `medium`
   - Deliverables: routine cadence, audit loop, milestone carry-forward process.

## How To Seed These Issues Quickly

Use `harness/scripts/seed-harness-issues.sh` with:

- `PAPERCLIP_API_BASE`
- optional `PAPERCLIP_API_KEY` (agent key)
- optional `PAPERCLIP_COMPANY_ID` (auto-detected when exactly one company exists)

Auth modes:

- Board mode: run `pnpm paperclipai auth login --api-base <base-url>` first.
- Agent-key mode: set `PAPERCLIP_API_KEY` directly.

The script creates the parent issue first, then child issues linked via `parentId`.

### Docker one-command path

If Paperclip is running in Docker quickstart, seed directly through the container:

```sh
./harness/scripts/seed-harness-issues-docker.sh
```

Optional env overrides:

```sh
PAPERCLIP_API_BASE=http://localhost:3100 \
PAPERCLIP_COMPANY_ID=<company-id> \
PAPERCLIP_API_KEY=<agent-key-optional> \
./harness/scripts/seed-harness-issues-docker.sh
```

Defaults used by the wrapper:

- compose file: `docker/docker-compose.quickstart.yml`
- compose env file: `.env`
- service name: `paperclip`

### Post-seed context bootstrap

After seeding, attach project/linking context to all `HARNESS:` issues:

```sh
PAPERCLIP_API_BASE=http://localhost:3100 \
PAPERCLIP_API_KEY=<board-or-agent-token> \
PAPERCLIP_COMPANY_ID=<company-id> \
./harness/scripts/bootstrap-harness-project-context.sh
```

This script ensures:

- project `Harness Scaffolding` exists with workspace `/workspace`
- label `harness` exists
- every `HARNESS:` issue is assigned to that project, tagged with the label, and annotated with a `Harness Execution Context` block

## Operational Notes

- Paperclip issues are canonical for execution tracking.
- GitHub is canonical for PR/review artifacts.
- Every PR URL should be posted back to the related Paperclip issue comment thread.
