# HARA-12 Manual Test Scenarios

Purpose: execute parity scenarios for ADR-003 domains in a dedicated Paperclip test company/project.

## Environment Guardrails

- use a dedicated test company/project (not production company state)
- seed/refresh fixture project + scenario issues with `harness/scripts/bootstrap-harness-parity-fixtures.sh`
- capture issue identifiers, status transitions, PR URLs, and review evidence
- record failures with exact step and observed response

## Scenario 1: Happy path lifecycle

Goal: validate `todo -> in_progress -> in_review -> done` with PR and review evidence.

Steps:

1. Create or pick a test issue.
2. Checkout and move to `in_progress`.
3. Open PR and move issue to `in_review`.
4. Post reviewer summary.
5. Merge PR and move issue to `done`.

Expected evidence:

- issue status transition history
- PR URL
- `REVIEW:` comment
- `DONE:` comment

## Scenario 2: Block / unblock path

Goal: validate `in_progress -> blocked -> in_progress` with unblock evidence.

Steps:

1. Move active issue to `blocked` with blocker detail.
2. Resolve blocker and post unblock comment.
3. Move back to `in_progress`.

Expected evidence:

- blocker comment
- unblock evidence comment
- status transition sequence

## Scenario 3: Merge queue path

Goal: validate queued PR remains `in_review` until merge confirmation.

Steps:

1. Enable merge queue (or use queue-enabled repo).
2. Queue PR merge.
3. Post `QUEUE:` evidence while queued.
4. Confirm merge.
5. Post `CONFIRMED-D:` evidence and close issue.

Expected evidence:

- queued state proof
- `QUEUE:` comment
- merge confirmation proof
- `CONFIRMED-D:` comment before `done`

## Scenario 4: Non-queue path

Goal: validate approved + merged PR can transition directly to `done`.

Steps:

1. Use repo without merge queue.
2. Merge approved PR directly.
3. Move issue to `done` with DONE block.

Expected evidence:

- merged PR proof
- direct `in_review -> done` transition evidence

## Scenario 5: Role provisioning parity

Goal: validate `HARNESS_ROLE_SET=parity` provisions expected roles and instruction paths.

Steps:

1. Run `harness/scripts/setup-harness-agent-configs.sh` with `HARNESS_ROLE_SET=parity`.
2. List agents.
3. Verify role names and `instructionsFilePath` values.

Expected evidence:

- script output log
- agent list with expected parity roles
- instruction path checks for each parity role

## Scenario 6: Learning path

Goal: validate immediate `L:` capture and retro linkage.

Steps:

1. During active issue execution, post an `L:` comment using lesson-event template.
2. Update issue document `retro` with matching lesson entry.
3. Attempt closure.

Expected evidence:

- `L:` comment
- retro document revision
- close gate passes only after retro update

## Scenario 7: Canonical source path

Goal: validate runtime follows canonical docs over human-reference docs.

Steps:

1. Inspect runtime entrypoint required reads.
2. Confirm canonical docs are referenced.
3. Confirm human docs carry non-authoritative banner.

Expected evidence:

- runtime entrypoint file reads
- canonical precedence declaration
- banner presence in all architecture docs

## Execution Log

| Scenario | Result (pass/fail/not-run) | Evidence refs |
| --- | --- | --- |
| 1 | pass | company `d48d56c4-46d6-4da6-adfa-ae8e282fdf65`, issue `HARAA-3` (`todo -> in_progress -> in_review -> done`) with PR/review evidence |
| 2 | pass | company `d48d56c4-46d6-4da6-adfa-ae8e282fdf65`, issue `HARAA-2` (`todo -> in_progress -> blocked -> in_progress -> done`) |
| 3 | not-run | requires merge-queue-enabled test repo |
| 4 | pass | direct merge evidence on PR `#4` (`57331d8580d033a854a49916bd3be9663ceff3d9`) and issue `HARAA-3` non-queue close |
| 5 | pass | `setup-harness-agent-configs.sh` run with `HARNESS_ROLE_SET=parity` in company `d48d56c4-46d6-4da6-adfa-ae8e282fdf65` |
| 6 | pass | issue `HARAA-2` has `L:` comment and `retro` document (`id=91c87065-564a-4393-8b47-726b0972c8ae`) before close |
| 7 | pass | `harness/runtime-instructions/README.md`, `harness/CANONICAL-SOURCES.md`, `harness/docs/architecture/*.md` |

## Execution Notes

- dedicated test company used: `d48d56c4-46d6-4da6-adfa-ae8e282fdf65` (`Harness Parity Validation 2026-04-06`)
- scenario 2 attempted agent checkout on `HARAA-1`, but encountered active run lock conflict (`executionRunId` already set), so lifecycle validation continued on `HARAA-2` via board-driven transitions in the isolated test company
- scenario 1 and scenario 4 were completed on `HARAA-3` with PR `#4` review + direct-merge evidence (`mergedAt=2026-04-06T21:55:48Z`)
- parity provisioning validated via API agent listing for PM/QE/Contract Tester/Integration Tester/Security Researcher/Security Reviewer and expected `instructionsFilePath` values
