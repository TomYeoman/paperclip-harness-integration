# Harness Migration Tracker

Last updated: 2026-04-06

This document summarizes harness migration progress from upstream harness concepts into Paperclip-native execution.
It is an operational status report and does not override canonical runtime docs.

## Source Set

| Source                                                        | Purpose                                                     |
| ------------------------------------------------------------- | ----------------------------------------------------------- |
| `harness/adr/ADR-000-original-harness-spec.md`                | Upstream baseline contract                                  |
| `harness/adr/ADR-001-agentic-harness-paperclip-adaptation.md` | Adaptation strategy and transferability model               |
| `harness/adr/ADR-002-paperclip-issues-execution-plan.md`      | Issue-native execution + scriptability policy               |
| `harness/adr/ADR-003-latest-harness-gap-analysis.md`          | Parity matrix + implementation blueprint                    |
| `harness/adr/HARA-12-parity-runbook.md`                       | Domain-by-domain implementation evidence                    |
| `harness/testing/HARA-12-assertion-matrix.md`                 | Manual scenario pass/fail evidence                          |
| `harness/personal_commentary.md`                              | Operator notes, future considerations, and merge-queue TODO |

## Executive Snapshot

- Parity implementation is substantially complete for required Layer A domains.
- HARA-12 subissues HARA-23 through HARA-27 are complete.
- HARA-28 remains blocked only on one environment-dependent queue scenario.
- Core migration pattern is successful: orchestration moved from Claude-native team tools to Paperclip issues, assignments, comments, checkouts, and routines.

## ADR-003 Domain Status

Status legend:

- `implemented`
- `native-no-op` (Paperclip primitive already provides capability)
- `deferred` (explicitly tracked follow-up)
- `implemented-except-queue` (only queue-specific evidence pending)

| Domain                      | Status                   | What landed                                                                                                  | Remaining                                     |
| --------------------------- | ------------------------ | ------------------------------------------------------------------------------------------------------------ | --------------------------------------------- |
| Core roles                  | implemented              | PM, QE, Contract Tester, Integration Tester, Security Researcher, Security Reviewer + parity role-set wiring | None                                          |
| Orchestration DSL           | native-no-op             | Issue/comment/status transport already canonical                                                             | None                                          |
| Session start               | native-no-op             | Discovery + checkout + preflight already enforced                                                            | None                                          |
| Session end                 | native-no-op             | DONE + PR + retro close path already enforced                                                                | None                                          |
| Merge governance            | implemented              | Queue-aware `in_review` policy + `QUEUE`/`CONFIRMED-D` evidence templates                                    | Real queue environment evidence still pending |
| Worktree model              | native-no-op             | Existing workspace/worktree policy already sufficient                                                        | None                                          |
| Runtime setup               | deferred (HARA-8)        | Baseline setup scripts and adapter overlays exist                                                            | Overlay hardening follow-up                   |
| Observability               | deferred (optional)      | Deferred by design in parity scope                                                                           | Optional OTEL/Grafana track                   |
| Learning loop               | implemented              | Immediate `L:` capture + retro evidence chain + lead close gating                                            | None                                          |
| Milestone flow              | implemented              | `Related ADRs` + milestone gate template/checklist wiring                                                    | None                                          |
| Canonical source model      | implemented              | Explicit precedence in `harness/CANONICAL-SOURCES.md`                                                        | None                                          |
| Manual testing + assertions | implemented-except-queue | Scenario matrix + assertion matrix + most scenarios passed                                                   | Scenario #3 (real merge queue path)           |
| Human docs migration        | implemented              | Architecture docs migrated with non-authoritative banner + canonical mapping                                 | None                                          |

## HARA-12 Subissue Tracker

| Issue   | Scope                                  | Current Status | Notes                                                  |
| ------- | -------------------------------------- | -------------- | ------------------------------------------------------ |
| HARA-23 | Role parity and activation matrix      | done           | Landed role expansion + parity setup wiring            |
| HARA-24 | Merge/lifecycle policy parity          | done           | Landed queue-aware lifecycle policy                    |
| HARA-25 | Learning + milestone parity            | done           | Landed `L:` and milestone-gate enforcement             |
| HARA-26 | Canonical source + human-doc migration | done           | Landed source precedence + architecture docs migration |
| HARA-27 | Parity runbook validation              | done           | Landed evidence-oriented parity runbook                |
| HARA-28 | Manual parity scenario execution       | blocked        | Blocked only by real merge-queue scenario              |

## Paperclip Integration Adaptations (Worthy Call-outs)

| Adaptation                                                                      | Why it matters                                                                                          |
| ------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------- |
| Claude team-tool orchestration replaced with Paperclip control-plane primitives | Moves coordination into auditable platform state (`agents`, `issues`, `comments`, `checkout`, `wakeup`) |
| Single-assignee + atomic checkout as the concurrency guard                      | Stronger than informal "don’t overlap" discipline; prevents silent dual ownership                       |
| Heartbeat/async workflow with explicit handoff evidence                         | Makes state transitions resilient and reviewable across bounded runs                                    |
| Issue documents (`plan`, `retro`, `assertion`) used as durable artifacts        | Avoids hidden planning and preserves reproducible context                                               |
| Queue-aware close semantics integrated into harness policy                      | Aligns Paperclip lifecycle with GitHub merge-queue behavior                                             |
| Canonical precedence model (`harness/CANONICAL-SOURCES.md`)                     | Prevents drift between runtime contracts and human-reference docs                                       |
| Scriptability-first API automation policy                                       | Repeatable setup and migration operations are captured in `harness/scripts`                             |
| Per-role model flexibility retained                                             | Enables role-specific model strategy across CEO/Builder/Reviewer/etc.                                   |

## Manual Validation Coverage (From Assertion Matrix)

| Scenario                     | Result  | Evidence summary                                                            |
| ---------------------------- | ------- | --------------------------------------------------------------------------- |
| 1. Happy path lifecycle      | pass    | `HARAA-3` with review + close evidence                                      |
| 2. Block/unblock path        | pass    | `HARAA-2` status transition evidence                                        |
| 3. Merge queue path          | not-run | Requires merge-queue-enabled repo                                           |
| 4. Non-queue path            | pass    | Direct merge evidence + close transition                                    |
| 5. Role provisioning parity  | pass    | `HARNESS_ROLE_SET=parity` provisioned expected roles and instructions paths |
| 6. Learning capture path     | pass    | `L:` event + retro linkage evidence                                         |
| 7. Canonical source behavior | pass    | Runtime docs preferred over human-reference docs                            |

## Remaining Work

| Item                                    | Blocker                                                | Action to clear                                                                           |
| --------------------------------------- | ------------------------------------------------------ | ----------------------------------------------------------------------------------------- |
| Real merge-queue scenario (#3)          | No merge-queue-enabled validation target + token scope | Provision queue-enabled repo + token, run scenario, record `QUEUE`/`CONFIRMED-D` evidence |
| Runtime setup parity hardening (HARA-8) | Deferred scope                                         | Tighten adapter overlay docs/checks where needed                                          |
| Observability parity (optional)         | Deferred scope                                         | Implement only if we choose to adopt OTEL/Grafana layer                                   |

## Team Notes from Personal Commentary

- Harness setup strategy is now script-centric: repeatable API operations are captured under `harness/scripts`, minimizing one-off UI drift.
- Model-per-role flexibility is a strategic advantage and should remain intentional (not accidental per-agent drift).
- Future extension idea worth socializing: specialized modality roles (image/audio/video) can follow the same role+adapter pattern when needed.

## Immediate Next Steps

1. Provision a merge-queue-enabled test repo and token with branch protection read + PR write.
2. Execute scenario #3 end-to-end and append evidence to:
   - `harness/testing/HARA-12-assertion-matrix.md`
   - `harness/adr/HARA-12-parity-runbook.md`
3. Unblock and close HARA-28 and then HARA-12.
