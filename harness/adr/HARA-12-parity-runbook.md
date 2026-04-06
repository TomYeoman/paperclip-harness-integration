# HARA-12 Parity Runbook

Date: 2026-04-06
Owner: HARA-12 implementation stream
Source matrix: `harness/adr/ADR-003-latest-harness-gap-analysis.md`

This runbook tracks parity status for each ADR-003 domain.

## 1) Core roles

- status: implemented
- files changed:
  - `harness/roles/ROLE-PM.md`
  - `harness/roles/ROLE-QE.md`
  - `harness/roles/ROLE-CONTRACT-TESTER.md`
  - `harness/roles/ROLE-INTEGRATION-TESTER.md`
  - `harness/roles/ROLE-SECURITY-RESEARCHER.md`
  - `harness/roles/ROLE-SECURITY-REVIEWER.md`
  - `harness/runtime-instructions/pm/AGENTS.md`
  - `harness/runtime-instructions/qe/AGENTS.md`
  - `harness/runtime-instructions/contract-tester/AGENTS.md`
  - `harness/runtime-instructions/integration-tester/AGENTS.md`
  - `harness/runtime-instructions/security-researcher/AGENTS.md`
  - `harness/runtime-instructions/security-reviewer/AGENTS.md`
  - `harness/scripts/setup-harness-agent-configs.sh`
  - `harness/scripts/setup-harness-docker.sh`
- wiring applied:
  - added `HARNESS_ROLE_SET=parity`
  - added parity role name env vars and instruction paths
  - preserved `minimal|core|full` behavior
- verification evidence:
  - `bash -n harness/scripts/setup-harness-agent-configs.sh`
  - `bash -n harness/scripts/setup-harness-docker.sh`

## 2) Orchestration DSL

- status: native-no-op
- files changed: none
- wiring applied: none (Paperclip issue/comment/status transport remains canonical)
- verification evidence:
  - no-op rationale: existing `harness/protocol.md` already maps lifecycle signals to Paperclip primitives

## 3) Session start

- status: native-no-op
- files changed: none
- wiring applied: none (existing discovery/checkout/preflight flow retained)
- verification evidence:
  - no-op rationale: startup behavior already enforced in `harness/AGENTS.md` required issue flow

## 4) Session end

- status: native-no-op
- files changed: none
- wiring applied: none (DONE + PR + retro close path retained)
- verification evidence:
  - no-op rationale: close semantics are managed by canonical lifecycle and templates

## 5) Merge governance

- status: implemented
- files changed:
  - `harness/protocol.md`
  - `harness/AGENTS.md`
  - `harness/templates/ISSUE-COMMENT-TEMPLATES.md`
  - `harness/templates/PR-CHECKLIST.md`
- wiring applied:
  - queue-aware close rule (`queued` remains `in_review`)
  - `QUEUE:` and `CONFIRMED-D:` evidence blocks
  - direct merge behavior preserved for non-queue repos
- verification evidence:
  - policy sections and templates updated in canonical docs above

## 6) Worktree model

- status: native-no-op
- files changed: none
- wiring applied: none (existing execution workspace policy/worktree script retained)
- verification evidence:
  - no-op rationale: worktree controls already implemented via `harness/scripts/setup-harness-workspace-policy.sh`

## 7) Runtime setup

- status: deferred-HARA-8
- files changed: none in HARA-12
- wiring applied: defer adapter-overlay hardening to HARA-8
- verification evidence:
  - defer rationale recorded per ADR blueprint (runtime setup listed as Native+Policy follow-up)

## 8) Observability

- status: deferred-optional
- files changed: none in HARA-12
- wiring applied: defer OTEL/Grafana and metrics automation
- verification evidence:
  - defer rationale recorded per ADR blueprint (non-native optional domain)

## 9) Learning loop

- status: implemented
- files changed:
  - `harness/protocol.md`
  - `harness/AGENTS.md`
  - `harness/roles/ROLE-LEAD.md`
  - `harness/templates/ISSUE-COMMENT-TEMPLATES.md`
  - `harness/templates/LESSON-EVENT-TEMPLATE.md`
  - `harness/templates/LESSONS-TEMPLATE.md`
  - `harness/templates/README.md`
- wiring applied:
  - immediate `L:` event capture requirement
  - evidence chain (`L:` comment -> lesson template -> retro update)
  - lead close-gate enforcement for missing lesson evidence
- verification evidence:
  - learning capture and retro gates encoded in protocol/AGENTS/checklist

## 10) Milestone flow

- status: implemented
- files changed:
  - `harness/spec-driven.md`
  - `harness/protocol.md`
  - `harness/AGENTS.md`
  - `harness/templates/ISSUE-COMMENT-TEMPLATES.md`
  - `harness/templates/MILESTONE-GATE-TEMPLATE.md`
  - `harness/templates/README.md`
  - `harness/templates/PR-CHECKLIST.md`
- wiring applied:
  - `Related ADRs` requirement for architecture-impacting work
  - `MILESTONE-GATE:` acceptance evidence requirement
  - milestone gate checks added to workflow templates/checklist
- verification evidence:
  - milestone gate rules codified in canonical policy docs

## 11) Canonical source model

- status: implemented
- files changed:
  - `harness/CANONICAL-SOURCES.md`
  - `harness/AGENTS.md`
  - `harness/runtime-instructions/README.md`
  - `harness/adr/README.md`
- wiring applied:
  - explicit precedence ordering and conflict rule
  - runtime entrypoints constrained to canonical sources
  - non-authoritative treatment of human-reference docs
- verification evidence:
  - canonical precedence and conflict rules present in `harness/CANONICAL-SOURCES.md`

## 12) Manual testing + assertions

- status: pending-HARA-12F
- files changed: pending
- wiring applied: pending scenario + assertion docs and execution evidence
- verification evidence:
  - completion tracked in `harness/testing/HARA-12-manual-test-scenarios.md` and `harness/testing/HARA-12-assertion-matrix.md` (added in HARA-12F)

## 13) Human-readable documentation migration

- status: implemented
- files changed:
  - `harness/docs/README.md`
  - `harness/docs/architecture/AGENT-ROLES.md`
  - `harness/docs/architecture/COMMUNICATION-DSL.md`
  - `harness/docs/architecture/SESSION-LIFECYCLE.md`
  - `harness/docs/architecture/MILESTONE-WORKFLOW.md`
  - `harness/docs/architecture/LEARNING-SYSTEM.md`
  - `harness/docs/architecture/WORKTREE-MODEL.md`
- wiring applied:
  - required human-reference banner added to every migrated architecture doc
  - canonical source links included per document
  - one-to-one mapping table captured in `harness/docs/README.md`
- verification evidence:
  - banner and canonical-source presence validated across all migrated docs

## Current Parity Claim State

- implemented domains: 1, 5, 9, 10, 11, 13
- native no-op domains: 2, 3, 4, 6 (explicit rationale recorded)
- deferred domains: 7, 8 (ADR-defined defer rationale recorded)
- pending execution domain: 12 (completed in HARA-12F)
