# Harness Gap Analysis: V1 Spec vs Latest Testharness

Date: 2026-04-06
Owner: harness discovery pass

## Decision

Use this document as the canonical parity target for HARA-12.

- Baseline remains `harness/adr/ADR-000-original-harness-spec.md` (V1 contract source).
- Delta source is `harness/latest_claude_harness_copy` with canonical behavior defined by `harness/latest_claude_harness_copy/CLAUDE.md` and role files under `harness/latest_claude_harness_copy/harness/roles/`.
- Human architecture docs under `harness/latest_claude_harness_copy/docs/architecture/` are reference-only and may explain, but do not override, canonical runtime contracts.

## Why This ADR Exists

ADR-000 captures the initial harness generation contract. The latest testharness has evolved significantly in role topology, lifecycle control, merge queue behavior, and session observability. HARA-12 needs an explicit parity map so implementation work is scoped and testable instead of ad hoc.

## Sources Compared

Primary baseline:

- `harness/adr/ADR-000-original-harness-spec.md`

Primary latest-harness sources:

- `harness/latest_claude_harness_copy/CLAUDE.md`
- `harness/latest_claude_harness_copy/LAUNCH-SCRIPT.md`
- `harness/latest_claude_harness_copy/harness/roles/`

Supporting context (reference-only in latest harness):

- `harness/latest_claude_harness_copy/docs/architecture/AGENT-ROLES.md`
- `harness/latest_claude_harness_copy/docs/architecture/COMMUNICATION-DSL.md`
- `harness/latest_claude_harness_copy/docs/architecture/SESSION-LIFECYCLE.md`
- `harness/latest_claude_harness_copy/docs/architecture/MILESTONE-WORKFLOW.md`
- `harness/latest_claude_harness_copy/docs/architecture/LEARNING-SYSTEM.md`
- `harness/latest_claude_harness_copy/docs/architecture/WORKTREE-MODEL.md`

## Executive Delta

Compared to ADR-000, latest testharness introduces:

1. Larger role graph (PM, QE, Contract Tester, Integration Tester, Security Researcher, Security Reviewer, and mode-specific builder variants).
2. Session-mode flags and upstream behavior (`worker`/`swarm`, hold vs release semantics).
3. Explicit runtime startup and shutdown automation for observability, merge queue, and branch hygiene.
4. Stronger lifecycle signals in DSL (`F:`, `S:`, `CHECKPOINT:`, `CONFIRMED-D:` and lead-only signals).
5. Structured session telemetry outputs (dashboard schema and metrics table requirements).
6. Learning-system formalization with immediate encoding and enforcement hierarchy.

## Parity Matrix for HARA-12

Legend:

- `Present`: already represented in this repo harness docs/scripts.
- `Partial`: concept exists but misses latest-harness behavior.
- `Missing`: no equivalent yet.
- `Native`: Paperclip primitives already cover the capability; no net-new HARA-12 implementation needed.
- `Native+Policy`: Paperclip primitive exists, but harness policy/docs still need alignment.
- `Non-native`: capability is outside core Paperclip primitives.

| Domain | ADR-000 / Current Paperclip Harness | Latest Testharness | Parity Status | Native Paperclip Coverage | HARA-12 Action |
| --- | --- | --- | --- | --- | --- |
| Core roles | Lead, Architect, Builder, Reviewer, Tester, Auditor | Same core roles plus PM, QE, Contract Tester, Integration Tester, Security Researcher, Security Reviewer, platform-specific builders | Partial | Native+Policy (agents + instructions-path support exists, expanded catalog not modeled yet) | Yes: extend role matrix + setup script flags; keep advanced roles opt-in |
| Orchestration DSL | Paperclip-native issue assignment/comments/status mapping is in place (`harness/protocol.md`) | Adds `F:`, `S:`, `CHECKPOINT:`, `CONFIRMED-D:`, plus lead-only control signals | Present | Native (transport and lifecycle signaling already mapped to Paperclip primitives) | No net-new implementation; optional doc appendix for latest-harness signal aliases |
| Session start | Required issue flow + discovery + GitHub preflight + checkout are documented/scripted | Adds mode flags, debug mode, OTEL startup, state file reads | Present | Native (Paperclip issue queue + checkout + preflight scripts cover core startup path) | No net-new HARA-12 action; keep current checklist, treat mode flags as org-specific optional |
| Session end | Done block, in-review->done lifecycle, PR linkage, and retro capture are defined | Adds queue checks, stale branch cleanup, metrics dashboard, flag reset | Present | Native (Paperclip lifecycle + templates cover core closeout path) | No net-new HARA-12 action; optional metrics/cleanup enhancements can be deferred |
| Merge governance | Builder merge ownership, reviewer non-merge, no direct main commits | Merge queue-first workflow (`gh pr merge --merge --auto`) with post-queue confirmation signal before close | Partial | Native+Policy (Paperclip tracks state, but GitHub queue semantics are external) | Yes: add queue-aware DONE criteria only when merge queue is enabled |
| Worktree model | Project workspace policy + git-worktree strategy script (`setup-harness-workspace-policy.sh`) + HARA-17 policy | Native isolation plus manual fallback, role-specific prep, absolute paths | Present | Native (execution workspace policy already provides first-class isolation) | No net-new HARA-12 action; validate in parity runbook |
| Runtime setup | Bootstrap + agent setup + GitHub preflight scripts exist | Richer env constraints and runtime-specific injection patterns | Partial | Native+Policy (foundation exists, some adapter-specific checks are uneven) | Targeted follow-up in adapter overlays (HARA-8); HARA-12 references only |
| Observability | Basic logs/comments/templates | OTEL startup, Grafana visibility, session metrics outputs | Missing | Non-native (OTEL/Grafana stack is external to core Paperclip primitives) | Optional/deferred; track separately, not required for HARA-12 parity claim |
| Learning loop | Retro template + lessons capture requirement exist | Immediate L-event encoding, enforcement hierarchy, anti-batching | Partial | Native+Policy (issue docs/comments support this, enforcement language is weaker) | Yes: tighten protocol/role non-negotiables for immediate lesson encoding |
| Milestone flow | Spec/TDD standards and issue flow are present | Stronger PRD-ADR linkage, model-audit gates, cross-role handoffs | Partial | Native+Policy (Paperclip supports the workflow, contract detail needs tightening) | Yes: strengthen milestone checklist + acceptance gates |
| Canonical source model | ADR-driven harness docs, runtime instruction entrypoints | Explicit canonical-vs-reference split | Partial | Native+Policy (repo can define this directly) | Small doc action: explicitly codify canonical precedence |

## Implementation Blueprint (Exact Files + Wiring)

This section is the low-ambiguity build plan for HARA-12. Unless explicitly deferred in the issue thread, the builder should follow this file plan exactly.

### Cross-cutting required artifact

Add:

- `harness/adr/HARA-12-parity-runbook.md`

Purpose:

- single evidence file proving each parity-matrix row is either implemented or explicitly no-op due to native Paperclip coverage
- include one section per matrix domain with: `status`, `files changed`, `wiring applied`, `verification evidence`

### Domain-by-domain file and wiring plan

1. Core roles (`Native+Policy`, required)

Add:

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

Edit:

- `harness/roles/README.md`
- `harness/AGENTS.md`
- `harness/runtime-instructions/README.md`
- `harness/scripts/setup-harness-agent-configs.sh`
- `harness/scripts/setup-harness-docker.sh`
- `harness/scripts/README.md`

Wiring:

- in `setup-harness-agent-configs.sh`, add a new `HARNESS_ROLE_SET=parity` (keep existing `minimal|core|full` behavior unchanged)
- add name env vars and defaults for new roles (`HARNESS_PM_NAME`, `HARNESS_QE_NAME`, `HARNESS_CONTRACT_TESTER_NAME`, `HARNESS_INTEGRATION_TESTER_NAME`, `HARNESS_SECURITY_RESEARCHER_NAME`, `HARNESS_SECURITY_REVIEWER_NAME`)
- extend `desiredRoleSpecs()` so `parity` provisions all new roles with explicit `instructionsPath` under `/workspace/harness/runtime-instructions/.../AGENTS.md`
- pass through new env vars in `setup-harness-docker.sh` `optional_envs`
- in each new runtime entrypoint, require reads of `/workspace/harness/AGENTS.md` + exactly one role contract

2. Orchestration DSL (`Native`, no net-new)

Add/Edit:

- no functional file changes required for HARA-12

Wiring:

- no new transport wiring; keep issue assignment/comments/status mapping as canonical
- document no-op rationale in `harness/adr/HARA-12-parity-runbook.md`

3. Session start (`Native`, no net-new)

Add/Edit:

- no functional file changes required for HARA-12

Wiring:

- no new startup mechanism; rely on existing required issue flow + preflight
- document no-op rationale in runbook

4. Session end (`Native`, no net-new)

Add/Edit:

- no functional file changes required for HARA-12

Wiring:

- no new shutdown mechanism; rely on existing DONE + PR + retro flow
- document no-op rationale in runbook

5. Merge governance (`Native+Policy`, required)

Add:

- none

Edit:

- `harness/protocol.md`
- `harness/AGENTS.md`
- `harness/templates/ISSUE-COMMENT-TEMPLATES.md`
- `harness/templates/PR-CHECKLIST.md`

Wiring:

- add queue-aware lifecycle rule: if merge queue is enabled in target repo, issue stays `in_review` when PR is queued
- add explicit merge-confirmation gate before `done` (no `done` on queued-only state)
- add issue comment templates for queue lifecycle evidence (`QUEUE:` and `CONFIRMED-D:` blocks)
- preserve direct-merge behavior for repos without merge queue

6. Worktree model (`Native`, no net-new)

Add/Edit:

- no functional file changes required for HARA-12

Wiring:

- keep existing execution workspace policy + git-worktree strategy
- document no-op rationale in runbook

7. Runtime setup (`Native+Policy`, deferred to HARA-8)

HARA-12 action:

- no mandatory file change in this issue beyond recording defer rationale in runbook

Follow-up file set (HARA-8 overlay hardening):

- `harness/adapters/README.md`
- `harness/adapters/claude-local.md`
- `harness/adapters/codex-local.md`
- `harness/adapters/opencode-local.md`
- `harness/scripts/README.md` (if script flags/prereqs change)

8. Observability (`Non-native`, optional)

HARA-12 action:

- defer (record defer rationale in runbook)

If later adopted, expected file additions:

- `harness/scripts/setup-harness-observability.sh`
- `harness/templates/SESSION-METRICS-TEMPLATE.md`
- `harness/observability/README.md`

9. Learning loop (`Native+Policy`, required)

Add:

- `harness/templates/LESSON-EVENT-TEMPLATE.md`

Edit:

- `harness/protocol.md`
- `harness/AGENTS.md`
- `harness/roles/ROLE-LEAD.md`
- `harness/templates/ISSUE-COMMENT-TEMPLATES.md`
- `harness/templates/README.md`

Wiring:

- define immediate `L:` event capture rules (do not defer to end-of-session batching)
- require evidence trail: issue comment (`L:`) -> template-backed lesson entry -> retro document update at completion
- require Lead to enforce lesson capture before closing issue

10. Milestone flow (`Native+Policy`, required)

Add:

- `harness/templates/MILESTONE-GATE-TEMPLATE.md`

Edit:

- `harness/spec-driven.md`
- `harness/AGENTS.md`
- `harness/templates/ISSUE-COMMENT-TEMPLATES.md`
- `harness/templates/PR-CHECKLIST.md`
- `harness/templates/README.md`

Wiring:

- keep Paperclip issue-centric execution (do not introduce `tasks/MILESTONES.md` as a second source of truth)
- require architecture-impacting issues to include `Related ADRs` and explicit acceptance gate evidence
- add milestone/acceptance gate comment template and checklist linkage

11. Canonical source model (`Native+Policy`, required)

Add:

- `harness/CANONICAL-SOURCES.md`

Edit:

- `harness/AGENTS.md`
- `harness/runtime-instructions/README.md`
- `harness/adr/README.md`

Wiring:

- define precedence explicitly: runtime-canonical docs vs human-reference docs
- require any future human-reference architecture docs to carry a non-authoritative banner
- ensure runtime entrypoints and setup scripts point only at canonical docs

12. Manual testing + assertions (`required`)

Add:

- `harness/testing/HARA-12-manual-test-scenarios.md`
- `harness/testing/HARA-12-assertion-matrix.md`

Edit:

- `harness/adr/HARA-12-parity-runbook.md`
- `harness/templates/PR-CHECKLIST.md`

Wiring:

- run scenarios in Paperclip against a dedicated test company/project (no production company state)
- each scenario must record concrete evidence: issue IDs, status transitions, checkout/release behavior, PR URL, reviewer summary, and final `done` transition
- include explicit pass/fail assertions for queue-enabled and queue-disabled repos
- require the PR checklist to include a `Manual parity scenarios executed` item referencing the scenario doc

Required scenario set (minimum):

1. Happy path: `todo -> in_progress -> in_review -> done` with PR + review evidence
2. Block/unblock path: `in_progress -> blocked -> in_progress` with unblock evidence
3. Merge queue path: queued PR remains `in_review` until merge confirmation
4. Non-queue path: approved + merged PR transitions directly to `done`
5. Role provisioning path: `HARNESS_ROLE_SET=parity` provisions all expected role agents with correct `instructionsPath`
6. Learning path: `L:` event captured immediately with template-backed evidence and included in retro
7. Canonical source path: runtime agent follows canonical docs, not human-reference docs

13. Human-readable documentation migration (`required`)

Add:

- `harness/docs/README.md`
- `harness/docs/architecture/AGENT-ROLES.md`
- `harness/docs/architecture/COMMUNICATION-DSL.md`
- `harness/docs/architecture/SESSION-LIFECYCLE.md`
- `harness/docs/architecture/MILESTONE-WORKFLOW.md`
- `harness/docs/architecture/LEARNING-SYSTEM.md`
- `harness/docs/architecture/WORKTREE-MODEL.md`

Edit:

- `harness/CANONICAL-SOURCES.md`
- `harness/AGENTS.md`
- `harness/runtime-instructions/README.md`

Wiring:

- migrate human-readable docs from `harness/latest_claude_harness_copy/docs/architecture/` into `harness/docs/architecture/` with Paperclip-specific wording
- every migrated human-readable doc must start with a non-authoritative banner:
  `HUMAN REFERENCE ONLY — canonical behavior is defined by harness runtime docs`
- every migrated doc must include `Canonical Sources` links to specific runtime docs (`harness/AGENTS.md`, `harness/protocol.md`, `harness/spec-driven.md`, role contracts)
- `harness/docs/README.md` must include a one-to-one mapping table (human doc -> canonical source doc)
- `harness/CANONICAL-SOURCES.md` must declare precedence order and conflict resolution rule (canonical docs win)

## Scope Decision for HARA-12

HARA-12 should be filtered by native coverage:

### Out of Scope for Net-New HARA-12 Implementation (already native)

1. Orchestration transport mechanics (issue assignment/comment/status flow).
2. Core session start path (discovery + checkout + preflight).
3. Core session end path (in_review -> done with PR + retro evidence).
4. Baseline worktree isolation behavior.

These remain documented and verified, but do not require new parity features.

### Layer A: Required for parity claim (Native+Policy gaps)

1. Role topology expansion contract (including which roles are optional vs mandatory).
2. Merge lifecycle policy for queue-enabled repos (clear DONE semantics).
3. Learning-loop enforcement updates to prevent regression of known failures.
4. Milestone workflow tightening (PRD/ADR linkage and completion-gate evidence).
5. Canonical source precedence note (runtime-canonical vs human-reference docs).
6. Manual parity scenario testing with assertion evidence.
7. Migration of human-readable architecture docs with explicit canonical mapping.

### Layer B: Optional now, but ADR-tracked

1. Full OTEL/Grafana orchestration scripts and dashboards.
2. Advanced metrics (cycle-time/overhead/vFTE style outputs).
3. Organization-specific session modes and upstream signaling semantics.
4. Deeper adapter-specific runtime checks beyond current overlays.

Layer B can be deferred if Layer A is complete and explicitly documented as deferred with follow-up issues.

## Proposed HARA-12 Subtasks

If HARA-12 is too large for one PR, split into child tasks:

1. `HARA-12A` Role parity and activation matrix (`harness/roles/*`, `harness/roles/README.md`, setup scripts).
2. `HARA-12B` Merge + lifecycle policy parity (`harness/protocol.md`, queue-aware close conditions).
3. `HARA-12C` Learning + milestone contract parity (`harness/protocol.md`, `harness/spec-driven.md`, templates).
4. `HARA-12D` Canonical source precedence + human-doc migration (`harness/CANONICAL-SOURCES.md`, `harness/docs/architecture/*`).
5. `HARA-12E` Parity runbook validation (prove native-covered rows need no net-new features).
6. `HARA-12F` Manual parity scenario execution via Paperclip (scenario matrix + assertion evidence).

## Acceptance Criteria for "Parity Achieved"

Parity for HARA-12 is achieved when all of the following are true:

1. A documented role matrix includes new roles and clear enablement policy per runtime.
2. All `required` domains in the file/wiring blueprint are implemented with the exact Add/Edit targets listed (or explicitly deferred with rationale).
3. Parity matrix rows marked `Native` have explicit no-op rationale (why no net-new HARA-12 feature is needed).
4. `harness/protocol.md` defines queue-aware close semantics for repos that use merge queue.
5. Learning/milestone contract updates are encoded with clear checkable evidence requirements.
6. Human-readable docs are migrated under `harness/docs/architecture/` with explicit canonical-source mapping.
7. Manual scenario suite is executed in Paperclip with pass/fail evidence captured in runbook artifacts.
8. A runbook demonstrates one end-to-end flow using updated contracts (issue -> build -> review -> merge/queue -> done).

## Risks

1. Overfitting to testharness organization-specific workflows that are not universally portable.
2. Expanding role count without corresponding execution policy, causing idle or conflicting agents.
3. Encoding dashboard/metrics requirements that are not scriptable in current local environment.

## Mitigations

1. Separate normative core from optional advanced overlays in docs.
2. Keep default role set minimal; make advanced roles opt-in via setup script flags.
3. Gate parity claims on reproducible script and documentation behavior, not manual operator knowledge.

## Follow-up

After HARA-12 completion, update:

- `harness/adr/README.md` to include this ADR and any follow-on ADRs.
- Relevant HARA issue acceptance criteria to reference this parity matrix directly.
