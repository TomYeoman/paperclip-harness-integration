# ADR: Staging Deployment Quality Gate

**Status**: Accepted
**Date**: 2026-03-25
**Issue**: #493

## Context

As the team approaches PROMOTE decisions for GoKit services, there is no documented, agent-friendly protocol for staging deployment validation. Builders and Leads have no shared language for: when to deploy to staging, what tests to run, and how to handle rollback if tests fail or a deployment is unstable.

Without a gate, staging may host broken code for extended periods, contaminating Integration Tester results and eroding confidence in the staging environment as a signal.

This ADR formalises the staging deployment quality gate: a post-code-review, pre-PROMOTE checkpoint that gives the team confidence before promoting work to production-facing environments.

## Scope

**In scope:**
- GoKit services only — services identified by the presence of a `service.json` file in their repository root
- Triggered once per milestone, after all milestone PRs have merged and been reviewed, before Lead sends `PROMOTE:`

**Out of scope:**
- Sonic runtime services (separate follow-up ticket required)
- Per-PR or per-merge staging deployments — too expensive and not the right cadence
- Developer iteration (use `make start` / `make tail-logs` locally)

## Decision

### Gate Model

The staging quality gate operates as a bounded, time-limited validation window:

1. Lead triggers `gh workflow run deploy-staging.yml` for the target GoKit service
2. Lead immediately spawns an Integration Tester with the staging endpoint and deploy metadata
3. Integration Tester runs health check + smoke + contract tests in parallel with a 5-minute countdown
4. At T+5:00, rollback is unconditional — regardless of test state
5. Integration Tester sends `V:` with PASS/FAIL + evidence before T+5:00 if tests complete; otherwise sends `V:` after rollback with partial results

### Rollback Semantics

Rollback is **unconditional** at T+5:00. No test result can extend the window.

If Integration Tester tests are still running at T+4:30:
- Integration Tester delays 30 seconds (max 2 retries) to attempt test completion
- After max retries, Integration Tester sends `V:` with partial results and flags rollback forced
- Lead triggers rollback regardless

Rollback is not a failure signal on its own — it is a safety mechanism. The gate result is determined by the Integration Tester `V:` output, not by whether rollback was triggered.

### Integration Tester Trigger Cadence

The staging gate is a **milestone-level final gate**, not a continuous integration tool:

- Triggered once when **all** milestone PRs have merged and code review is complete
- NOT triggered per-merge, per-PR, or during active development
- Reserved for complicated or high-risk flows where staging confidence is worth the deployment cost
- If in doubt: ask the PO or provide the trigger command so they can run it explicitly

### Test Scope

MVP smoke tests for the staging gate:
1. `GET /health` → 200 response
2. One basic create-read flow representative of the milestone's primary user journey

Full BDD scenario execution (as in standard Integration Tester operation) is not required for the staging gate — smoke + contract is sufficient. Full BDD runs post-PROMOTE.

## Consequences

- Every GoKit service milestone now has a defined staging gate checkpoint before PROMOTE
- Integration Tester gains a second spawn context (staging gate, in addition to post-merge BDD execution)
- Rollback is always safe — staging gate never blocks rollback
- Sonic runtime services are explicitly deferred; this ADR does not cover them
- Harness skill (`SKILL-staging-deploy.md`) and role update (`ROLE-INTEGRATION-TESTER.md`) are required alongside this ADR
