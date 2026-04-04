# Harness Core Contract

This file is the runtime-agnostic contract for harness work in this repository.

## Scope

- Applies to harness issues (`HARA-*`) in project `Harness Scaffolding`.
- Applies across `claude_local`, `codex_local`, and `opencode_local`.
- Adapter-specific behavior belongs in adapter overlays (tracked under `HARA-8`).

## Workspace And Sources

- Edit repository code only in `/workspace`.
- Primary context sources:
  - `harness/adr/ADR-000-original-harness-spec.md`
  - `harness/adr/ADR-001-agentic-harness-paperclip-adaptation.md`
  - `harness/adr/ADR-002-paperclip-issues-execution-plan.md`
  - Current issue description/comments/documents

## Execution Model

- One active issue per agent.
- Paperclip issues are the canonical execution queue.
- Use issue comments/documents for traceability; do not keep private side plans.
- Post PR links back to the issue thread.

## Required Issue Flow

1. Confirm correct issue (`HARA-*`) and acceptance criteria.
2. Run discovery before code changes.
3. Claim work via checkout and move to `in_progress`.
4. Implement in `/workspace` on a task branch.
5. Open PR with issue reference.
6. Move issue to `in_review` when PR is ready.
7. After review and merge, move issue to `done` with final summary.

## Discovery Gate (Must Be Posted In Issue)

Use this exact block before implementation:

```text
DISCOVERY: <issue-id>
READ: <files>
UNDERSTAND: <2-3 sentences>
UNKNOWNS: <list or NONE>
PLAN:
- <step>
- <step>
R: yes | blocked:<reason>
```

## Core Engineering Rules

- Runtime-agnostic governance first, adapter-specific details second.
- No direct commits to `main`.
- Keep PRs focused and reviewable.
- Do not fabricate test/build results.
- If blocked after three concrete attempts, escalate in the issue with evidence.

## Paperclip API Automation Policy

- Any repeatable harness operation that uses the Paperclip API must be scriptable.
- Prefer extending an existing script in `harness/scripts/` over adding ad hoc manual steps.
- When behavior changes, update `harness/scripts/README.md` in the same PR so usage stays accurate.
- UI-only actions are allowed for one-off debugging, not for core setup/runbook flows.

## Merge Ownership

- Builder merges after review approval.
- Reviewer never merges.
- CEO/Lead orchestrates and unblocks; does not merge code changes.
- Reviewer must post an approve/block summary in the issue thread.

## Verification Gate (Before Done)

Before marking complete, verify and report:

1. Acceptance criteria satisfied.
2. Relevant tests/checks run (or explicitly not run with reason).
3. Diff self-review completed.
4. PR link posted in issue.

Use this completion block in the issue comment:

```text
DONE: <issue-id>
CHANGES:
- <path>: <what changed>
CHECKS:
- <command>: pass | fail | not-run (<reason>)
SELF-AUDIT:
- <criterion>: pass | fail
PR: <url or NONE>
```

For harness workflow/config PRs, also apply `harness/templates/PR-CHECKLIST.md`

## Escalation Triggers

Escalate in issue comments when:

- scope contradicts prior discovery
- governance/security decision is required
- adapter/runtime constraints block execution
- review disagreement cannot be resolved with evidence

## Initial Role Split For This Repository

- CEO: orchestration, prioritization, approvals, delegation.
- Builder: implement `HARA-*` code/doc changes.
- Reviewer: validate acceptance criteria and quality before merge.

Start with CEO + Builder + Reviewer. Add Architect/Tester/Auditor roles as `HARA-6` progresses.

Role contract files:

- `harness/roles/ROLE-LEAD.md`
- `harness/roles/ROLE-ARCHITECT.md`
- `harness/roles/ROLE-BUILDER.md`
- `harness/roles/ROLE-REVIEWER.md`
- `harness/roles/ROLE-TESTER.md`
- `harness/roles/ROLE-AUDITOR.md`
