# Harness Scaling Report: Multi-Team, Cross-Organisation Readiness

**Date**: 2026-03-26
**Author**: Auditor agent (a-scale-audit)
**Scope**: Full harness audit for multi-team scaling readiness
**Files reviewed**: CLAUDE.md, README.md, harness/SYSTEM-KNOWLEDGE.md, harness/PO-DECISIONS.md,
harness/roles/ (all 15 role files), harness/rules/ (all 4 rule files),
tasks/MILESTONES.md, tasks/adr/ (all 5 ADRs), harness/SKILLS-INDEX.md

---

## Executive Summary

The harness is a mature, battle-tested single-team orchestration system (22+ sessions,
350+ commits, 240+ PRs) that encodes genuine operational learning. Its rules are precise,
its communication DSL is coherent, and its quality gates are well-enforced. It is not,
however, designed for multi-team use. Every layer — identity, governance, tooling,
configuration, and knowledge — assumes a single PO, a single Lead, a single GitHub
Enterprise host, and a single working directory on a single developer's machine.

Five specific structural problems make naive multi-team adoption high-risk:

1. **The PO identity is singular and hardcoded** — `corey-latislaw` appears in
   merge permissions, worktree paths, and shutdown constraints. A second team would
   need to either share this identity (a security problem) or fork and manually
   re-thread every reference.

2. **The harness is a shared mutable singleton** — all teams would write to the same
   `harness/lessons.md`, `harness/SYSTEM-KNOWLEDGE.md`, and `docs/BUILD-JOURNAL.md`.
   There is no namespace, no team prefix, no ownership model for harness content.

3. **There is no governance model** — no process exists to ratify a rule change across
   teams. Today the PO owns harness evolution unilaterally. With five teams, a rule
   change by one team's Lead silently applies to all others on next session start
   (because CLAUDE.md is auto-loaded).

4. **Infrastructure is machine-local** — hooks, allow lists, and secrets live in
   `~/.claude/settings.json` on one developer's machine. Another team on another machine
   has no way to discover or replicate the exact configuration.

5. **The skills layer is partially external and unversioned** — community skills are
   pulled from `git@github.je-labs.com:ai-platform/skills.git` on demand with no
   version pinning. Different teams pulling the same skill at different times may get
   different behaviour.

The sections below detail each of these areas with specific file references and
concrete recommendations. A prioritised action table appears at the end.

---

## 1. Current Limitations: What Is Implicitly Single-Team

### 1.1 PO identity embedded in rules

The GitHub username `corey-latislaw` is not merely contextual — it is a named constraint
in operational rules:

- `harness/rules/MERGE-OWNERSHIP.md` lines 111–114 and 163: submodule path
  `/Users/corey.latislaw/Documents/Code/Claude/testharness/[platform]` is the canonical
  worktree root for Track 3 operations. Every builder on every team using this harness
  would be given a path that resolves to one person's laptop.
- `harness/roles/ROLE-LEAD.md` line 231: "corey-latislaw cannot close PRs on
  Web/consumer-web or iOS/JustEat" — a GitHub permission constraint that is person-specific.
- `harness/roles/ROLE-LEAD.md` line 304: "GitHub self-approval: corey-latislaw cannot
  approve own PRs" — same person-scoped constraint.
- `CLAUDE.md` line 36, 128: `GH_HOST=github.je-labs.com` is embedded in session-end
  commands and spawn protocol references. This is a single enterprise instance; a team
  at a different org would need a different host.

A second team inheriting this harness verbatim would spawn builders that try to
create worktrees at `/Users/corey.latislaw/...` — a path that does not exist on their
machine. This would silently fail or produce misleading errors.

### 1.2 Working directory is absolute and machine-local

`CLAUDE.md` and `harness/rules/PERMISSIONS-MODEL.md` encode the repo root as
`/Users/corey.latislaw/Documents/Code/Claude/testharness`. This appears in:

- `harness/roles/ROLE-LEAD.md` line 128: manual worktree creation command uses this
  absolute path as the `-C` argument.
- `harness/rules/MERGE-OWNERSHIP.md` lines 111–114: Track 3 submodule paths use
  this root.
- `harness/rules/PERMISSIONS-MODEL.md` line 64: "Builders run in worktrees under
  `/private/tmp/wt-[name]/`. File tool patterns like `Read(**)` are anchored to the
  project root (`/Users/.../testharness`)."

### 1.3 Single Lead, single session model

The harness assumes exactly one active Lead per session:
- `CLAUDE.md` line 119: "One team per session. Lead can only manage one team at a time."
- `harness/roles/ROLE-LEAD.md` line 7: "Lead NEVER writes or edits any file — markdown
  or code. No exceptions."

This is a correct constraint for a single team but becomes ambiguous at scale. If Team A
and Team B each have a Lead, and both are running sessions simultaneously against the
same harness repo, they would be making concurrent writes to shared files (lessons.md,
BUILD-JOURNAL.md, SYSTEM-KNOWLEDGE.md) with no coordination mechanism.

### 1.4 Merge queue is tied to a single ruleset

`CLAUDE.md` line 180 and `harness/rules/MERGE-OWNERSHIP.md` line 7 reference merge
queue ruleset ID 831. This is a GitHub repository-scoped setting. A forked harness for
a different team would need to create its own ruleset and update the reference. If teams
share a single testharness repo, the merge queue already handles concurrent PRs — but
the agent polling logic (2-minute cap, 12 × 10s polls) was calibrated for a single team's
throughput. With 5 teams merging PRs concurrently, queue wait times would increase and
the polling cap would trigger `B:` signals more frequently.

### 1.5 Agent cap calibrated for one team

`CLAUDE.md` line 207: "Max 6 concurrent (evidence-based; escalate to PO for exceptions)."
`harness/roles/ROLE-LEAD.md` line 178: "Max 6 concurrent agent limit is an
evidence-based coordination guideline."

This cap was established by operational evidence from one team's sessions. Five teams
sharing a Claude Code account would collectively exceed this in a single session window,
but the current model has no concept of account-level resource budgeting — only
session-level.

---

## 2. Tension: Individual vs. Shared Harness

### The fork-per-team model

If each team forks the harness, they gain:
- Full customisation autonomy — team-specific roles, rules, agent caps
- No cross-team file conflicts during sessions
- Independent lessons.md and PO-DECISIONS.md

They lose:
- Any improvements one team makes stay local. Propagating a lesson from Team A's
  `harness/lessons.md` to Team B requires a manual PR across repos.
- Community skills (`ai-platform/skills`) are already shared via the JET-wide layer —
  the harness fork would duplicate the team-specific layer on top, but the two-layer
  model (SKILLS-INDEX.md lines 52–60) would become a three-layer model without a
  documented sync protocol.
- The `remember:` command (`CLAUDE.md` line 307) requires a 4-step lifecycle: Claude
  memory + lessons.md + harness file + builder PR. With forks, step 4 PRs land in
  different repos. There is no harness-level changelog or cross-repo diff to track drift.

### The shared-harness model

If all teams share one harness repo, they gain:
- Automatic propagation of lessons and rule improvements
- A single source of truth for protocol

They lose:
- Namespace isolation: `harness/SYSTEM-KNOWLEDGE.md` has one Module Status table
  with no team prefix. Team A's modules and Team B's modules would collide in the same
  table, with no way to distinguish ownership.
- `harness/PO-DECISIONS.md` has one flat log keyed only by date. Multiple POs making
  decisions on the same day would produce ambiguous entries.
- `docs/BUILD-JOURNAL.md` is a narrative log — with five teams running sessions
  concurrently, the journal would become a merge-conflict battleground.
- Session-end cleanup steps (`git stash clear`, worktree prune, branch deletion) are
  destructive and scoped to the repo as a whole. Team A's session-end could delete
  Team B's in-flight branches.

### What this tells us

Neither pure model works. The harness needs a **federation model**: a canonical upstream
harness (rules, roles, skills) that teams adopt as a read-only dependency, plus a
per-team configuration layer (PO identity, project-specific knowledge, lessons,
decisions) that lives in each team's own repo. This is architecturally analogous to the
existing two-layer skill model (SKILLS-INDEX.md lines 52–60) — it just needs to be
applied to the entire harness, not just skills.

---

## 3. Governance Gaps

### 3.1 Who owns the harness?

Today: the PO (`corey-latislaw`) owns harness evolution. The `remember:` DSL
(`CLAUDE.md` line 307) gives the PO a single-command workflow to encode a lesson and
ship it as a PR. There is no review board, no ratification process, no other stakeholder.

At scale with five teams: if Team A's Lead encodes a lesson that changes how builders
commit (e.g., a new commit message format), that rule propagates to all teams on next
session start — because CLAUDE.md is auto-loaded. Teams B through E have no
notification, no veto, and no changelog to understand what changed.

### 3.2 The lessons.md accumulation problem

`harness/lessons.md` is documented as "880+ lines, append-only correction history"
(CLAUDE.md line 25). The file is intentionally excluded from startup reads ("Do NOT
load harness/lessons.md at startup"). This append-only pattern works for one team
because the Lead knows the operational context. For a new team onboarding, the 880+
lines of lessons would be archaeological — they'd need to read hundreds of lines of
correction history with no index, no severity ranking, and no indication of which lessons
are still active vs. superseded.

There is no mechanism to:
- Mark a lesson as superseded by a later rule change
- Categorise lessons by platform or role
- Promote a lesson from team-specific to harness-canonical

### 3.3 PO-DECISIONS.md has no team scope

`harness/PO-DECISIONS.md` contains decisions from "Hiral" (identified by name, not
team). With multiple POs from multiple teams, decisions would accumulate with no
namespace. A builder reading PO-DECISIONS.md cannot tell which decisions apply to their
team's project.

### 3.4 No ratification process for CLAUDE.md changes

CLAUDE.md is the auto-loaded context for every session on every agent. Changes to it
affect all concurrent sessions immediately. The current review threshold
(`harness/rules/MERGE-OWNERSHIP.md` "High-risk" section) requires a Reviewer for
CLAUDE.md changes — but that Reviewer is from the same team. There is no cross-team
review gate, no RFC process, and no announcement channel.

### 3.5 Session overrides are not scoped

Every role file ends with "## Session Overrides — None — cleared at session end."
This works for one team because overrides are applied and cleared within a single
session. With multiple teams running concurrent sessions, a per-team override applied
by Team A's Lead during a session has no way to be scoped to Team A — it would appear
in the shared harness file and be visible to Team B.

---

## 4. Tooling and Permissions: What Is Hardcoded

### 4.1 GH_HOST

`GH_HOST=github.je-labs.com` appears in:
- `CLAUDE.md` line 36 (session-end branch deletion command)
- `harness/rules/MERGE-OWNERSHIP.md` line 164 (merge queue poll command)
- Multiple skill files (not fully audited in this pass)

This is the GitHub Enterprise hostname for JET. Another organisation or business unit
with its own GHE instance would need to find and replace every occurrence. There is no
single `HARNESS_GH_HOST` variable — it is scattered inline.

### 4.2 Machine-local paths

- `/Users/corey.latislaw/Documents/Code/Claude/testharness` (repo root)
- `/private/tmp/wt-[name]` (worktree convention — correct macOS path, but assumes a
  Mac developer; Linux would use `/tmp/wt-[name]`)

The worktree convention is partially parameterised by name but the root path is not.
`harness/rules/PERMISSIONS-MODEL.md` line 64 notes that `Read(**)` is "anchored to
the project root" — meaning the allow list entries (`Read(**)`, `Glob(**)`, etc.) are
implicitly tied to whichever directory Claude Code was launched from. This works on one
machine because there is only one project root. On another machine, the project root
would be different, but the PERMISSIONS-MODEL.md documentation would still reference
the original path.

### 4.3 Agent cap (6 concurrent) is uncalibrated for shared accounts

The 6-agent cap references "M4 hardware" (`ROLE-LEAD.md` line 178: "On capable hardware
(M4+)"). Hardware-based guidance is inherently machine-specific. A team running on
cloud-based compute or a different Mac model would have different thresholds, with no
guidance on how to calibrate.

### 4.4 Hooks and settings are user-local

`~/.claude/settings.json` and `~/.claude/hooks/` are not checked into the repo. A new
team member or new machine would have no way to discover the required hook configuration
except by reading `harness/rules/SAFETY-HOOKS.md` and `harness/rules/PERMISSIONS-MODEL.md`
manually. There is no setup script, no validation command, and no CI gate that confirms
the hooks are correctly installed.

The known issue documented in `harness/rules/SAFETY-HOOKS.md` lines 75–91 — that
PreToolUse hook registration causes "Do you want to make this edit?" prompts in
worktrees — is a friction point that new teams would hit with no documented resolution
path (the current workaround is "PO approves prompts as they appear").

### 4.5 Merge queue ruleset ID 831

This is hardcoded in `CLAUDE.md` line 180. It is a numeric ID assigned by GitHub to a
specific ruleset in a specific repository. If the harness is adopted by another team
in a different repo, this ID would be meaningless. Even within the same org, a forked
harness repo would have a different ruleset ID.

### 4.6 Sonic scaffold URL

`CLAUDE.md` line 108: `https://sonic.production.jet-internal.com/scaffold` is the
scaffolding service for JET backend services. This is JET-internal infrastructure.
A non-JET organisation using this harness would hit a 404 or auth failure when builders
try to scaffold new services.

### 4.7 Community skills repo

`harness/SKILLS-INDEX.md` line 65: `git@github.je-labs.com:ai-platform/skills.git`
is the JET-internal skills registry. External teams cannot access this. Even within
JET, the `npx skills add` installation command (`SKILLS-INDEX.md` line 64) is
undocumented in terms of the `npx` binary version required and whether it works on
non-Mac environments.

---

## 5. Recommendations

### Priority table

| # | Priority | Area | Recommendation | Effort |
|---|----------|------|----------------|--------|
| 1 | **P0 — Blocker** | Identity | Parameterise `GH_HOST`, repo root path, and PO username via a single `harness/config/HARNESS-CONFIG.md` file. All hardcoded references in roles, rules, and CLAUDE.md become `{HARNESS_GH_HOST}`, `{HARNESS_REPO_ROOT}`, `{HARNESS_PO_USERNAME}` with resolution instructions. | M |
| 2 | **P0 — Blocker** | Governance | Define a harness ownership model. Options: (a) Harness Steward role — one named person per org who owns CLAUDE.md changes; (b) RFC process — CLAUDE.md changes require a PR reviewed by all Lead agents from all active teams. Document the chosen model in a new `harness/GOVERNANCE.md` file. | S |
| 3 | **P1 — High** | Fork vs. share | Adopt the **federation model**: extract team-invariant content (roles, DSL, quality gates, lifecycle rules) into a canonical upstream harness. Each team maintains a thin per-team layer (PO identity, project knowledge, lessons, decisions). Define what belongs at each layer in `harness/FEDERATION.md`. | L |
| 4 | **P1 — High** | Knowledge namespace | Add a `team:` prefix to all entries in `harness/SYSTEM-KNOWLEDGE.md`, `harness/PO-DECISIONS.md`, and `docs/BUILD-JOURNAL.md`. Example: `## [Team: REWE] Module Status`. Without namespacing, shared-harness use becomes unmanageable above 2 teams. | S |
| 5 | **P1 — High** | Tooling | Replace machine-local paths with environment variables resolved at session start. Add a `SESSION-START-ENV-CHECK` step (before step 1 of session start in CLAUDE.md) that validates `HARNESS_REPO_ROOT`, `HARNESS_GH_HOST`, and `HARNESS_PO_USERNAME` are set, and fails loudly if not. | S |
| 6 | **P1 — High** | Setup reproducibility | Create `harness/setup/LOCAL-SETUP.md` with a validated setup script that installs hooks, configures `~/.claude/settings.json`, and verifies the allow list. Include a `harness-doctor` verification command that a new team member can run to confirm their setup is correct. | M |
| 7 | **P2 — Medium** | Lessons.md | Add an index to `harness/lessons.md` (or replace the append-only model with a structured `harness/lessons/` directory, one file per lesson, with a status field: active | superseded | team-specific). This makes lessons discoverable for new teams onboarding without reading 880+ lines linearly. | M |
| 8 | **P2 — Medium** | Skills versioning | Pin community skills to a tagged version: `npx skills add --skill reviewer --tag v1.2.0`. Document the pinned version in SKILLS-INDEX.md alongside the install command. Add a session-start check that confirms installed skills match pinned versions. | S |
| 9 | **P2 — Medium** | Agent cap | Replace the hardware-based "M4+" cap guidance with a calibration protocol: `harness/setup/AGENT-CAP-CALIBRATION.md` describes a 3-session calibration run that a new team performs to establish their hardware baseline. The result becomes their local cap setting. | S |
| 10 | **P3 — Low** | Merge queue | Extract ruleset ID 831 to the per-team config layer (from recommendation 1). Harness canonical content should reference `{HARNESS_MERGE_RULESET_ID}`. | XS |
| 11 | **P3 — Low** | External dependencies | Document JET-internal dependencies (Sonic, JetFM, GHE, community skills repo) in a `harness/setup/JET-DEPENDENCIES.md` file with substitution guidance for non-JET teams. This makes the harness portable to other organisations with known adaptation effort. | S |
| 12 | **P3 — Low** | Session overrides | Scope session overrides by team. Add a team identifier to the "## Session Overrides" section in role files, or move overrides to a per-team config directory. This prevents one team's session state from leaking into another team's reads. | S |

---

## 5.1 Recommended first steps (immediate)

The highest-leverage immediate action is **recommendation 1** (parameterise identities
and paths). It unblocks all subsequent multi-team work and has no breaking changes —
it only adds a config resolution step without changing any harness logic.

Coupled with **recommendation 2** (governance model), these two changes define who
owns the harness and how changes propagate. Without them, any subsequent federation
work would be contested: teams would disagree about whether a rule change from one
team should apply to others, with no process to resolve it.

**Recommendation 3** (federation model) should be scoped as an Architect task, not a
Builder task — it requires deciding what is truly invariant across teams versus what is
project-specific, and that decision requires product and architectural judgment.

---

## 5.2 What the harness does well (preserve at scale)

The following are genuine strengths that a multi-team design should preserve, not
abstract away:

- **The DISCOVERY gate** — the mandatory `DISCOVERY: / READ: / UNDERSTAND: / UNKNOWNS: / PLAN:` block prevents agents from starting work they don't understand. This is valuable at any scale.
- **The `remember:` 4-step lifecycle** — Claude memory + lessons file + harness file + PR. This ensures no lesson exists only in one agent's context. At scale, steps 3 and 4 need to target the correct team layer, but the structure is correct.
- **The Communication DSL** (I:, R:, G:, D:, B:, V:, F:, L:, CONFIRMED-D:) — this signal vocabulary is concise, unambiguous, and role-neutral. It would survive federation without modification.
- **The two-track merge model** — Track 1 (harness, markdown) vs. Track 2 (production code) cleanly separates what agents can merge from what humans must merge. This boundary is correct and should be preserved.
- **Parallel-first spawning** — the explicit rule against sequencing independent builders is a genuine performance gain. At scale, this principle becomes more important, not less.
- **The VERIFICATION GATE** — the 5-step pre-D: checklist is platform-agnostic and correct. It should be canonical across all teams without modification.

---

*Report complete. All findings based on direct file reads — no assumptions.*
