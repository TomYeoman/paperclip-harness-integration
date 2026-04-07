Work so far:

- Harness project setup with all setup work logged as issues. Paperclip is then essentially self updating / building itself - all changes which utilise the paperclip API (I.E will change DB state - but are not a code change) are enforced as scriptable events via the scripts directory (see scripts/README.md) with the AGENT.md enforcing the policy. This means that future harness users can easily use the same scripts to setup their own harness.

Cool features / points of interest:

- Cross provider / model support per agent - we can define codex as the CEO / planner, whilst using claude as the builder / reviewer / tester / etc (or maybe we want to introduce image gen, audio, video etc models), gives us a lot of flexibility and allows us to use the best model for the job.
- Everything has a well documented rest API, and is scriptable - this means that we can easily extend the harness to do more complex things, and automate tests and setup.

Features

- Reviewer must post an approve/block summary in the issue thread based on the PR checklist template.

TODO

- Think about issue sync - right now we have Jira, and GH issues - I like paperclips agent first issue design, but we should probably have a way to sync issues from other systems, do adapters exist for this?
- On the same note - we want all issues to be shared across team members - do we need a shared hosted database, or just an issue sync (with then still running the control plane locally) - needs further thought / discussion.
- On this note - I've tried to put process in place that all updates to the harness which involve data changes should be scriptable - needs testing E2E / some love.
- E2E / regression tests - we should have a way to run e2e tests against the harness.
- Remote hosting.. right now everyone is running their own instance of paperclip.. we should we should perhaps have a hosted version?

- Provision a merge-queue-enabled test repository and token with branch-protection read + PR write permissions.
  - Run the real queue lifecycle scenario end-to-end (`QUEUE` hold in `in_review` + `CONFIRMED-D` before `done`).
  - Capture evidence (issue id, PR url, queue state, merge commit) and update `harness/testing/HARA-12-assertion-matrix.md` + `harness/adr/HARA-12-parity-runbook.md`.

Research notes (2026-04-07)

Issue sync (Jira/GH/other systems)

- I could not find a first-party Jira/GitHub issue sync adapter already shipped in this repo.
- The plugin direction is very aligned though:
  - `doc/plugins/PLUGIN_SPEC.md` calls out issue tracker sync as a target plugin category.
  - `doc/plugins/ideas-from-opencode.md` explicitly lists Linear/GitHub issue sync as strong connector-plugin candidates.
- There are related discussion threads in upstream issues, but no implemented and closed "issue sync adapter" thread that I could find yet.
- Related adjacent idea: instance-to-instance ticket exchange via federation is proposed in issue #1084 (OPEN).

Thoughts / ideas

- Start with one-way external -> Paperclip sync first (import tickets), then add two-way status/comment sync once conflict semantics are clear.
- Treat Paperclip issues as the action/execution plane, even when source tickets live in Jira/GH.
- Build sync as a connector plugin using jobs + webhooks + secret refs (fits the plugin architecture direction).

Questions

- What is the source of truth when fields conflict (Jira/GH vs Paperclip)?
- Which fields are in scope for v1 sync (status/title/comments only, or assignee/labels/priority too)?
- Is near-real-time sync required, or is scheduled polling good enough initially?

Shared team state: shared hosted DB vs local control planes + sync

- The docs already support team/shared operation in authenticated deployments (`doc/DEPLOYMENT-MODES.md`), so a shared instance is a first-class direction.
- If each teammate runs local control planes, sync/federation complexity appears quickly (identity mapping, conflict handling, stale locks, replay/idempotency concerns).
- My current leaning: one shared authenticated/private instance (plus external Postgres) for team execution, local instances only for experimentation.

Questions

- Do we want one canonical company/instance as source of truth?
- If yes, should all harness participants authenticate into that shared instance?
- If no, how much eventual consistency and conflict resolution complexity are we willing to own?

Scriptable data changes and E2E/regression confidence

- The scriptability policy is well-defined in `harness/scripts/README.md` and looks solid.
- Harness parity evidence is mostly green; merge-queue scenario is still pending (scenario #3) due missing queue-enabled test repo.
- The main repo does already have meaningful e2e/regression rails:
  - Playwright onboarding e2e (`tests/e2e/onboarding.spec.ts`)
  - release smoke browser flow (`tests/release-smoke/*`)
  - CI workflows that run e2e (`.github/workflows/e2e.yml`, `.github/workflows/pr.yml`)
- Gap: harness-specific script-driven E2E is still largely manual and should be automated.

Ideas

- Add a harness smoke runner that executes setup scripts against an ephemeral company and validates expected resources via API.
- Add a regression pack for the script contract (idempotent reruns, expected no-op behavior, failure mode assertions).
- Add CI/nightly harness validation job against a dedicated disposable test company.

Remote hosting status

- This is actively discussed upstream but not solved end-to-end yet.
- Relevant OPEN issues:
  - #966 Managed hosting hooks for SaaS multi-tenant deployment
  - #742 zero-config remote access relay/tunnel
  - #2579 first-admin bootstrap UX for appliance/hosted installs
- So: hosted direction is present, but still maturing operationally.

Novel / interesting future work to consider

1. Instance federation protocol (#1084): secure cross-instance ticket exchange (Paperclip <-> Paperclip) without centralizing all teams into one server.
2. Connector plugin for external issue systems: start with GitHub/Jira import + status mirror, then expand to bi-directional sync.
3. Managed hosting hooks (#966): core hooks for real SaaS operation (tenant identity, usage reporting, external secrets).
4. Sandboxed remote execution (#248): provider-agnostic secure runtime for untrusted inputs and safer automations.
5. External execution manager adapter (#2840): delegate execution to self-hosted/remote runtimes via standard `/runs` contract.
6. Resilience routing: automatic fallback chain (#2743) plus complexity-aware model routing (#2668).
7. Operator notifications outside UI (#2897, #597): webhooks/web push for approvals, blocked states, completions.
8. Agent self-scheduler skill (#2708): let agents create/manage recurring routines proactively.
