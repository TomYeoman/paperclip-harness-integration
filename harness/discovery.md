# Harness Discovery: Codex + Paperclip-First Adaptation

Date: 2026-04-04
Owner: discovery pass

## TL;DR

Your instinct is right: role contracts are highly transferable, but the orchestration mechanics must shift from Claude-native team tools to Paperclip primitives.

- Keep: role design, quality gates, spec-first/TDD rules, PR workflow discipline, session rituals.
- Replace: TeamCreate/SendMessage/TaskCreate style orchestration with Paperclip agents, issues, comments, checkout, approvals, routines, and wakeups.
- Adapt for Codex: use `AGENTS.md` as the runtime-facing dense contract (Codex discovers repo-local `AGENTS.md`), then map role files and skills into Paperclip agent instructions and company skills.

Conclusion: we can bring over about 75-85% of the harness intent, but only about 35-45% of its original control mechanics verbatim.

## Scope Lock (Confirmed)

Per latest direction, target runtime compatibility is:

- `codex_local`
- `claude_local`

## What Changes Because We Are Codex + Paperclip

### 1) Claude team-tool assumptions do not transfer directly

The provided harness assumes Claude-specific intra-session orchestration tools (`TeamCreate`, `SendMessage`, task-spawn semantics, permission bypass flow). Codex runtime in Paperclip does not expose those same primitives in the same way.

Implication: orchestration must be externalized into Paperclip's control plane objects (agents/issues/comments/routines), not kept inside one interactive model session.

### 2) Paperclip is heartbeat-based and asynchronous by design

Agents do not run continuously; they wake, do bounded work, and exit. Coordination patterns must tolerate async handoffs and eventual consistency.

Implication: "same turn" reflexes (like immediate reviewer spawn in a single LLM conversation) become event-driven patterns (assignment, mention wakeup, routine tick).

### 3) Task ownership is single-assignee with atomic checkout

Paperclip enforces single-task ownership through checkout semantics.

Implication: this is stronger than many ad hoc harnesses and should replace manual "do not overlap file scopes" rules as the primary concurrency guard.

### 4) Codex runtime has specific operational constraints

- Must run in trusted repo context (or explicit bypass flag).
- Uses `OPENAI_API_KEY` or native `codex login` auth.
- In Docker, ownership mismatches can break run-log/state writes.

Implication: we should codify adapter/environment diagnostics as first-class startup checks in the harness.

## Transferability Matrix

| Harness Element                                               | Keep/Replace        | Paperclip-First Mapping                                         | Notes                     |
| ------------------------------------------------------------- | ------------------- | --------------------------------------------------------------- | ------------------------- |
| Lead/Architect/Builder/Reviewer/Tester/Auditor roles          | Keep                | Separate Paperclip agents with role-specific instructions       | Strong fit                |
| PM discovery flow                                             | Keep                | PM agent + issue document (`plan`) + board comments             | Strong fit                |
| Discovery gate template                                       | Keep                | Required comment/document block before checkout                 | Strong fit                |
| Spec chain + TDD rules                                        | Keep                | Shared skill + reviewer checks + CI gates                       | Strong fit                |
| Session start/end ritual                                      | Keep                | Routine-triggered lead heartbeat + shutdown checklist issue/doc | Strong fit                |
| TeamCreate/SendMessage orchestration                          | Replace             | Issue assignment + comments + @mentions + wakeups               | Core adaptation           |
| Claude permission pre-approval file (`.claude/settings.json`) | Replace             | Paperclip governance + adapter config + runtime limits          | Claude-specific           |
| Worktree isolation manual protocol                            | Adapt               | Paperclip execution workspaces/worktree model                   | Prefer platform primitive |
| GitHub Issues as mandatory source of truth                    | Adapt               | Paperclip Issues as canonical, GitHub PRs for code lifecycle    | Recommended               |
| Reviewer reflex on PR open                                    | Keep (event-driven) | PR comment/status triggers reviewer issue assignment            | Async equivalent          |

## Paperclip Primitives We Should Lean On

1. **Agents** (`/api/companies/:companyId/agents`)
   - Represents persistent team roles and reporting tree.

2. **Issues + checkout** (`/api/companies/:companyId/issues`, `/api/issues/:id/checkout`)
   - Canonical work queue with atomic ownership and explicit statuses.

3. **Comments + mentions** (`/api/issues/:id/comments`)
   - Lightweight inter-agent communication and targeted wakeups.

4. **Issue documents** (`/api/issues/:id/documents/:key`)
   - Durable plan/spec/retro artifacts without overloading issue description.

5. **Approvals** (`/api/approvals/*`)
   - Governance for hires/strategy decisions.

6. **Routines** (`/api/companies/:companyId/routines`)
   - Recurring orchestration pulses (lead check-ins, periodic audits, etc.).

7. **Agent instructions path** (`PATCH /api/agents/{agentId}/instructions-path`)
   - Clean way to bind role contracts to each agent.

8. **Company skills + agent skill sync**
   - Reusable protocol modules distributed by platform, not only repo-local docs.

## Recommended Architecture (Codex-Compatible)

### Control Plane (Paperclip-native)

- Canonical orchestration state lives in Paperclip (agents/issues/comments/approvals/routines).
- "Lead" is a manager agent, not a local chat coordinator.
- All multi-agent coordination is issue-centric and auditable.

### Runtime Plane (Codex-local)

- All role agents use `codex_local` initially.
- Each agent has a distinct `instructionsFilePath` mapped to its role contract.
- Use conservative `timeoutSec`/`graceSec` and explicit `cwd` per project/workspace.

### Artifact Plane (Repo + GitHub)

- Keep harness docs in repo for version control and review.
- Use GitHub for PR lifecycle, not necessarily as the primary task queue.
- Link PR URLs back into Paperclip issue comments for traceability.

## Concrete Adaptations to the Provided Harness Spec

1. **Replace `CLAUDE.md` as runtime anchor with `AGENTS.md` for Codex**
   - Keep `CLAUDE.md` only as optional compatibility doc for human readers/tools.
   - Dense "always-loaded" contract should be in `AGENTS.md` for Codex behavior.

2. **Role files remain valid conceptually**
   - `ROLE-LEAD.md`, `ROLE-BUILDER.md`, etc. are still useful.
   - But enforce behavior via Paperclip assignment/workflow, not only local prompt discipline.

3. **Communication DSL remains useful, but transport changes**
   - Prefixes (`I:`, `B:`, `D:`, etc.) become structured issue comments.
   - Lead reacts via assignment changes/wakeup events, not in-memory chat routing.

4. **Worktree policy should defer to Paperclip execution workspace model**
   - Keep safety guidance, but do not duplicate orchestration that Paperclip already performs.

5. **Verification should include platform/runtime checks**
   - Add Codex auth/trust/cwd diagnostics and run-log write test to preflight checklist.

## Proposed Implementation Plan

### Phase 0 - Foundation Decisions (short)

Decide and lock:

- Canonical task system: Paperclip issues (recommended) vs dual-tracking with GitHub issues.
- Canonical dense runtime doc: `AGENTS.md` (recommended).
- Role deployment mode: repo files only vs company skills + repo source-of-truth (recommended hybrid).

### Phase 1 - Harness Skeleton in Repo

Create codex-adapted harness files (minimal, opinionated):

- `harness/AGENTS.md` (dense runtime contract)
- `harness/roles/*.md`
- `harness/skills/*.md`
- `harness/protocol.md`
- `harness/tdd-standards.md`
- `harness/spec-driven.md`

Acceptance:

- No Claude-only primitives in required runtime path.
- All references resolve to real files.

### Phase 2 - Paperclip Role Wiring

In Paperclip company setup:

- Create role agents (Lead, Architect, Builder, Reviewer, Tester, Auditor, optional PM).
- Set each agent `instructionsFilePath` to corresponding role doc.
- Assign baseline skills (`paperclip`, plus harness skills once imported).

Acceptance:

- Environment tests pass for every role agent.
- Manual wakeup of each role produces expected "identity + assignment" behavior.

### Phase 3 - Workflow Automation

- Define routine(s) for lead cadence.
- Add issue templates/doc keys (`plan`, `retro`, `launch-script`).
- Implement reviewer trigger rule as assignment/status transition pattern.

Acceptance:

- End-to-end flow: Builder issue -> PR opened -> Reviewer issue -> feedback -> merge -> done.

### Phase 4 - Hardening and Metrics

- Add audit checks (blocked-loop detection, stale issue detection, review SLA).
- Add budget and failure handling playbooks.
- Add dashboard views/queries for orchestration health.

Acceptance:

- One milestone delivered entirely through the adapted harness with no manual side channels.

## Risks and Mitigations

1. **Risk: trying to mimic Claude team semantics too literally**
   - Mitigation: model orchestration as workflow state transitions in Paperclip, not chat choreography.

2. **Risk: dual source of truth (Paperclip issues vs GitHub issues)**
   - Mitigation: make Paperclip canonical for execution; GitHub for code review artifacts.

3. **Risk: role drift over time**
   - Mitigation: source-of-truth in repo, then sync into Paperclip via instructions path and skills.

4. **Risk: Codex environment friction (auth, trust dir, permissions)**
   - Mitigation: codify a startup preflight checklist and fail fast before first real run.

## Recommended First Slice to Implement Next

1. Build the codex-native dense contract (`AGENTS.md`) and 6 role files.
2. Stand up one company with 3 agents first: Lead, Builder, Reviewer.
3. Run one real feature from TODO -> PR -> review -> merge using only Paperclip issues/comments + GitHub PRs.
4. Capture deltas, then expand to Architect/Tester/Auditor and full harness set.

This gives us quick proof that the adaptation works before we generate the full, heavier harness corpus.

## Self-Hosting Priority (Now)

To make harness development self-improving inside Paperclip, prioritize issue-native execution before broad file generation:

1. Seed harness backlog as Paperclip issues (parent + child structure).
2. Track all harness work in Paperclip issue states/comments.
3. Require PR links in issue comments for every merged step.
4. Capture lessons back into harness docs after each child issue closes.
5. Keep harness issues under a dedicated Paperclip project (`Harness Scaffolding`) with workspace cwd `/workspace`.

Reference implementation artifacts:

- `harness/paperclip-issues-plan.md`
- `harness/scripts/seed-harness-issues.sh`
