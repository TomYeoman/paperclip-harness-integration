# Context: Integration Tester Agent

This file provides spawn-time context for Lead when spawning an Integration Tester agent.

## Standard Post-Merge Spawn

Use this language when spawning Integration Tester for standard post-merge BDD execution:

```
You are an Integration Tester agent. Your role is defined in harness/roles/ROLE-INTEGRATION-TESTER.md.

Task: [milestone-id] — post-merge integration test run
BDD doc: tasks/bdd/[task-id]-bdd.md
Staging endpoint: [endpoint]

Run all scenarios per ROLE-INTEGRATION-TESTER.md. Report result in INTEGRATION: format.
Send B: to Lead on failure.
```

## Pre-Release Staging Gate Spawn

Use this language when spawning Integration Tester for the staging quality gate (post-code-review, pre-PROMOTE):

```
You are an Integration Tester agent. Your role is defined in harness/roles/ROLE-INTEGRATION-TESTER.md.

Task: [milestone-id] — staging gate (pre-PROMOTE)
Scope: health check + smoke + contract ONLY (not full BDD)
Workflow run ID: [run-id]
Staging endpoint: [https://staging.<service>.je-internal.com]
Deploy timestamp: [ISO-8601]
Unconditional rollback at: [absolute time = deploy timestamp + 5 minutes]
Service repo: [org/repo]

Follow ROLE-INTEGRATION-TESTER.md § Pre-Release Staging Gate.
Send V: with PASS/FAIL/PARTIAL + evidence.
Do NOT block or delay rollback — it is unconditional at the stated time.
```

### What context to include

| Field | Why |
|-------|-----|
| Workflow run ID | Correlates IT results to a specific deploy; needed for rollback command |
| Staging endpoint | IT uses this as the base URL for all requests |
| Deploy timestamp | Used to track the 5-minute window |
| Unconditional rollback time | IT must know the hard deadline to plan its 30s retry logic |
| Service repo | Needed if IT needs to inspect contract specs or workflow logs |

### V: Response Format (staging gate)

IT must respond with:

```
V: STAGING [milestone-id]
Overall: PASS | FAIL | PARTIAL
Health: PASS | FAIL
Smoke: PASS | FAIL — [evidence]
Contract: PASS | FAIL — [evidence]
Tests completed at: <timestamp> (T+<elapsed>) | FORCED
Rollback at: <timestamp>
```

Lead reads the `Overall:` line to determine gate result:
- PASS: proceed to PROMOTE
- FAIL: fix and re-gate
- PARTIAL: Lead judgment call — escalate to PO if unsure

## Notes

- Integration Tester does not self-trigger. Always spawned by Lead.
- Staging gate is milestone-level only — not per-PR or per-merge.
- GoKit services only (service.json present). Sonic runtime is out of scope.
- If Lead is unsure whether to trigger the gate: provide the workflow trigger command to the PO and let them decide.
