# Skill: Staging Deployment Quality Gate

Load this skill when: Lead or Reviewer needs to trigger a staging deployment and run smoke/contract tests before a PROMOTE decision.

## When to Use

**Use this gate:**
- After all milestone PRs have merged and code review is complete
- Before Lead sends `PROMOTE:` for a GoKit service
- For complicated or high-risk flows where staging confidence is worth the deployment cost

**Do NOT use this gate:**
- During developer iteration — use `make start` / `make tail-logs` locally instead
- Per-PR or per-merge — too expensive; not the right cadence
- For Sonic runtime services — out of scope (separate ticket required)

**If unsure:** Ask the user whether to run the gate, or provide the trigger command below so they can run it explicitly.

## Scope Guard

This skill applies to **GoKit services only**.

A service is in scope if `service.json` exists at the repository root. Verify before triggering:

```bash
ls <service-repo-root>/service.json
```

If `service.json` is absent: the service is not a GoKit service. Do not trigger this gate. Surface to Lead and ask for guidance.

## Trigger

```bash
GH_HOST=github.je-labs.com gh workflow run deploy-staging.yml \
  --repo <org>/<service-repo> \
  --field service=<service-name> \
  --field ref=<branch-or-sha>
```

Get the resulting run ID for Integration Tester:

```bash
GH_HOST=github.je-labs.com gh run list \
  --repo <org>/<service-repo> \
  --workflow deploy-staging.yml \
  --limit 1 \
  --json databaseId,status,createdAt
```

## Integration Tester Spawn

Immediately after triggering the workflow, Lead spawns an Integration Tester with:

```
G: it-staging [milestone-id] — staging gate
Workflow run ID: <run-id>
Staging endpoint: https://staging.<service-name>.je-internal.com
Deploy timestamp: <ISO-8601>
Estimated rollback: T+5:00 from deploy timestamp
Scope: health check + smoke + contract (not full BDD)
Service repo: <org>/<service-repo>
```

Integration Tester runs in parallel with the 5-minute countdown. See `ROLE-INTEGRATION-TESTER.md § Pre-Release Staging Gate` for full IT protocol.

## Rollback

Rollback is **unconditional at T+5:00**. No test result extends the window.

```bash
GH_HOST=github.je-labs.com gh workflow run rollback-staging.yml \
  --repo <org>/<service-repo> \
  --field service=<service-name> \
  --field run_id=<deploy-run-id>
```

Lead triggers rollback at T+5:00 regardless of Integration Tester test state. The gate result is determined by the Integration Tester `V:` output.

## Gate Result

| IT result | Rollback | Outcome |
|-----------|----------|---------|
| V: PASS (before T+5:00) | Triggered at T+5:00 | Gate PASS — proceed to PROMOTE |
| V: FAIL (before T+5:00) | Triggered at T+5:00 | Gate FAIL — fix and re-gate before PROMOTE |
| V: partial (T+5:00 forced) | Triggered at T+5:00 | Gate INCONCLUSIVE — Lead decision |

## Developer Iteration Alternative

For local development and iteration, do NOT use the staging gate. Use:

```bash
make start       # bring up the service locally
make tail-logs   # stream logs
make test        # run unit/integration tests
```

The staging gate is a milestone-level checkpoint, not a development loop tool.
