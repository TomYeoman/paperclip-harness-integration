# Task Spec: Staging Deployment Quality Gate

**Issue**: #493
**Status**: Harness docs delivered
**ADR**: tasks/adr/STAGING-QUALITY-GATE.md
**BDD**: tasks/bdd/STAGING-DEPLOYMENT.feature

## What This Is

A documented, agent-friendly protocol for triggering a staging deployment, running smoke and contract tests via Integration Tester, then rolling back. Applies to GoKit services only.

This is a **milestone-level final gate** — it runs once when all milestone PRs have merged and code review is complete, before Lead sends `PROMOTE:`. It is not a developer iteration tool.

## When to Use

**Use the staging gate:**
- All milestone PRs are merged
- Code review is complete
- You are about to send `PROMOTE:` for a GoKit service
- The milestone involves complicated or high-risk flows

**Do not use:**
- During development iteration (use `make start` / `make tail-logs` locally)
- Per-PR or per-merge (too expensive, wrong cadence)
- For Sonic runtime services (out of scope — separate ticket required)

**If unsure:** Provide the trigger command to the user and let them decide whether to run the gate.

## Scope

GoKit services only — identified by `service.json` at the repository root. Verify before triggering.

## Implementation Guide

### Step 1: Verify scope

```bash
ls <service-repo-root>/service.json
```

If absent: not a GoKit service, do not trigger. Ask Lead or PO for guidance.

### Step 2: Trigger deployment

```bash
GH_HOST=github.je-labs.com gh workflow run deploy-staging.yml \
  --repo <org>/<service-repo> \
  --field service=<service-name> \
  --field ref=<branch-or-sha>
```

Record the run ID:

```bash
GH_HOST=github.je-labs.com gh run list \
  --repo <org>/<service-repo> \
  --workflow deploy-staging.yml \
  --limit 1 \
  --json databaseId,status,createdAt
```

### Step 3: Spawn Integration Tester

Immediately after triggering (do not wait for deploy to complete):

```
G: it-staging [milestone-id] — staging gate
Workflow run ID: <run-id>
Staging endpoint: https://staging.<service-name>.je-internal.com
Deploy timestamp: <ISO-8601>
Estimated rollback: T+5:00 from deploy timestamp
Scope: health check + smoke + contract (not full BDD)
Service repo: <org>/<service-repo>
```

See `harness/context/CLAUDE-INTEGRATION-TESTER.md` for full spawn language.

### Step 4: Wait for V:

Integration Tester sends `V: STAGING [milestone-id]` with:
- `Overall: PASS | FAIL | PARTIAL`
- Health, Smoke, Contract results with evidence
- Tests completed timestamp

### Step 5: Rollback at T+5:00

Unconditional. Do not wait for Integration Tester if V: has not arrived.

```bash
GH_HOST=github.je-labs.com gh workflow run rollback-staging.yml \
  --repo <org>/<service-repo> \
  --field service=<service-name> \
  --field run_id=<deploy-run-id>
```

### Step 6: Record gate result

| V: Overall | Action |
|-----------|--------|
| PASS | Proceed to PROMOTE |
| FAIL | Route to Builder with evidence; re-gate after fix |
| PARTIAL | Lead judgment — escalate to PO if unsure |

## Test Scope

MVP smoke tests only (not full BDD):
1. `GET /health` → 200 + valid response body
2. One basic create-read flow (milestone's primary user journey)
3. Contract verification: key endpoints respond per contract spec

Full BDD execution runs after PROMOTE, per standard Integration Tester protocol.

## Rollback Semantics

- Rollback is unconditional at T+5:00 — no test result extends the window
- Rollback is a safety mechanism, not a failure signal
- If IT tests are still running at T+4:30: IT delays 30s (max 2 retries), sends V: PARTIAL, Lead rolls back
- IT does NOT block rollback

## Harness Files Delivered

| File | Purpose |
|------|---------|
| `tasks/adr/STAGING-QUALITY-GATE.md` | ADR: gate model, rollback semantics, scope |
| `harness/skills/SKILL-staging-deploy.md` | Agent-friendly trigger + rollback commands |
| `harness/roles/ROLE-INTEGRATION-TESTER.md` | Added Pre-Release Staging Gate section |
| `harness/context/CLAUDE-INTEGRATION-TESTER.md` | Spawn language for Lead |
| `tasks/bdd/STAGING-DEPLOYMENT.feature` | BDD scenarios (5 scenarios) |
| `tasks/STAGING-DEPLOYMENT-QUALITY-GATE.md` | This file |
