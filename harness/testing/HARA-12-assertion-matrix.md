# HARA-12 Assertion Matrix

This matrix records pass/fail assertions for the required manual parity scenarios.

## Assertions

| Scenario | Assertion | Queue mode | Result | Evidence |
| --- | --- | --- | --- | --- |
| 1 | Happy path reaches `done` with PR + review evidence | any | not-run | pending dedicated execution run |
| 2 | Block/unblock path preserves evidence and lifecycle integrity | any | pass | company `d48d56c4-46d6-4da6-adfa-ae8e282fdf65`, issue `HARAA-2` transition evidence |
| 3 | Queued PR remains `in_review` until merge confirmation | enabled | not-run | requires merge-queue-enabled test repo |
| 4 | Non-queue repo allows direct `in_review -> done` after merge | disabled | not-run | pending non-queue test run |
| 5 | Parity role set provisions full role catalog with instruction paths | any | pass | `setup-harness-agent-configs.sh` parity run + agent list verification in company `d48d56c4-46d6-4da6-adfa-ae8e282fdf65` |
| 6 | Learning event captured immediately and reflected in retro | any | pass | issue `HARAA-2` `L:` comment + `retro` document id `91c87065-564a-4393-8b47-726b0972c8ae` |
| 7 | Runtime behavior follows canonical docs over human-reference docs | any | pass | canonical/source docs and runtime entrypoint checks |

## Queue-Specific Assertions

- enabled repos must include `QUEUE:` and `CONFIRMED-D:` comments before `done`
- disabled repos must not require queued-state evidence

## Exit Criteria For Full Pass

All required scenarios must reach `pass` with concrete evidence refs (issue IDs, transitions, PR URLs, review comments, and final close evidence).
