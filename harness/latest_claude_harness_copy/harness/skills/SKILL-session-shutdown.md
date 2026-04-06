# Skill: Session Shutdown

Load this skill when: session is ending, or Lead initiates shutdown sequence.

## Shutdown Sequence
Builders first → Architect → Reviewer last.
NEVER close or merge PRs while agents are still running.

## 8 Mandatory Shutdown Deliverables

**ORDER IS MANDATORY. Do not proceed to the next step until the current one is complete.**

### 1. Write Build Journal Entry (docs/BUILD-JOURNAL.md) — BLOCKING GATE
Write this FIRST, before any commits. Do NOT commit shutdown deliverables until this entry is written.
Append — NEVER overwrite.

> **Append-only:** Never read `docs/BUILD-JOURNAL.md` before appending. Write the new session block directly — the file is write-only at shutdown. Reading the full file costs ~10,000 tokens for no benefit (621 lines / ~40K chars and growing).
```
## Session YYYY-MM-DD
PRs merged: [N] | Bugs fixed: [N] | Coverage delta: [+/-N%] | Agent spawns: [N]

### What happened
[3-5 sentences: what was accomplished, what milestone work moved]

### What went wrong
[specific failures, blocked PRs, agent misbehaviors]

### Key decisions
[architectural choices, product decisions, tradeoffs made]

### What was NOT done
[deferred work, blocked items, scope cuts]
```

**Gate check**: Do not proceed to step 2 until docs/BUILD-JOURNAL.md has been updated with a new session entry. PR/issue state is authoritative in GitHub — run `gh pr list` and `gh issue list` rather than duplicating state here.

### 2. Verify All L: Events Written (`harness/lessons.md`) — BLOCKING GATE

Every L: event from this session must have a corresponding entry in `harness/lessons.md`.
If any are missing, write them NOW before proceeding. Verbal corrections do not count.
Verify: `git diff HEAD harness/lessons.md` — must show new entries for this session.
Do not proceed to Step 3 until this gate is clear.

> **Append-only:** Never read `harness/lessons.md` before appending. Write new session entries
> directly — the file is write-only at shutdown. Reading the full file costs ~15K tokens for no benefit.

Append new entries — NEVER edit existing entries.

> **Supersession check:** Before appending new lessons, check if any new lesson contradicts or replaces an existing entry. If so, append a `SUPERSEDED:` notice for the old entry first, then append the new lesson with a `SUPERSEDES:` line. See SKILL-live-learning.md § Marking Superseded Lessons for format.
Format:
```
## Session YYYY-MM-DD
### WHAT_I_DID
[1-2 sentences: what was accomplished]
### WHAT_WAS_WRONG
[specific failure or near-miss — be concrete]
### CORRECTION
[what was done differently or added to harness]
### PATTERN
[one-line rule for future sessions]
```

### 3. Create Harness Recommendations Issue
Create a GitHub issue with specific files + specific changes needed.
Write the body to a temp file first (avoids security prompts for `#`-prefixed lines):
```
Write ./issue-body.md:
## Harness updates from session YYYY-MM-DD

### ROLE-BUILDER-CORE.md
- Add: [specific rule] to NON-NEGOTIABLE block

### CLAUDE.md
- Update BUILD + VERIFY with actual commands: [commands]

### harness/SYSTEM-KNOWLEDGE.md
- Update module status for M[N]: [module] is now [status]
```
```bash
gh issue create \
  --title "harness: post-session updates [YYYY-MM-DD]" \
  --body-file ./issue-body.md && rm -f ./issue-body.md
```
This becomes the first task of the next session.

### 4. Scan for Submodule PRs Before Writing Launch Script
Run this command and surface any PRs on submodule repos that need manual close — corey-latislaw cannot close these:
```bash
gh pr list --state open --json number,title,headRefName,body
```
List any Web/consumer-web or iOS/JustEat PRs explicitly for PO action in the Launch Script.

### 5. Write Launch Script (LAUNCH-SCRIPT.md)

<!-- canonical source for launch script template -->

OVERWRITE this file — do not append. Startup commands regenerate live state (PRs, issues, worktrees) at session start — do not pre-populate those sections here. Only write what cannot be recovered from CLI: decisions, context, blockers, and priority judgment.

```
# Launch Script
# Date: next session after YYYY-MM-DD
# Starting state: [brief state summary — e.g. "Main clean, [N] PRs merged in session YYYY-MM-DD"]

## Previous Session Summary (YYYY-MM-DD)
— Max 7 bullets. Decisions made, context not recoverable from git log, what was NOT done and why.
— No ticket tables. No PR lists. Those are in GitHub.
- [Key decision or non-obvious context]
- [What was deferred and why]

## Role

You are an engineering manager orchestrating a Claude agent team. You coordinate, unblock, and make decisions.

**Your #1 rule: you NEVER write, edit, or commit code.** You spawn builder agents who work in worktrees.

Detailed instructions:
- Team protocol: harness/AGENT-COMMUNICATION-PROTOCOL.md
- Your role: harness/roles/ROLE-LEAD.md
- Spawn sequence: CLAUDE.md § AGENT TEAM

## Startup

Run these commands at session start:

```bash
git fetch origin
git pull origin main --ff-only
git worktree list
git worktree prune
gh issue list --state open --json number,title,labels
gh pr list --json number,title,state
```

## Standing Rules
Rules: See CLAUDE.md and harness/roles/ROLE-LEAD.md — do not duplicate here.

## Priority Order for Next Session
— Lead's judgment. Not derived from CLI — this is the reasoning that would be lost otherwise.
1. [Highest priority — e.g. merge queued PRs, then most urgent issue]
2. [Next priority]
3. [Continue milestone tasks]

## Known Blockers
- [Specific blocker with reason — or "None" if clean]

## Submodule PRs Needing Manual Close (PO action required)
(corey-latislaw cannot close PRs on Web/consumer-web or iOS/JustEat)
- [PR #N — repo — title] or "None"

## Setup / Prerequisites

On a new machine, complete CLI setup before any git or `gh` operations:
- See [harness/setup/GITHUB-ENTERPRISE-SETUP.md](../../harness/setup/GITHUB-ENTERPRISE-SETUP.md) for `gh` CLI auth, token scopes, SSO, and connection testing.
- Verify with: `gh auth status --hostname github.je-labs.com`

## Known Constraints
- Bug fixes: use harness/skills/WORKFLOW-BUG-FIX.md (lean workflow — skips PM/Architect). Check triage gate before spawning Builder.
- New features: use harness/skills/SKILL-new-feature-checklist.md (full workflow with PM discovery and Architect phases).

## Startup Checklist
1. Read CLAUDE.md — your dense agent reference
2. Read harness/SYSTEM-KNOWLEDGE.md — module status (Architect populates this)
3. Read tasks/PRODUCT-BRIEF.md — product direction
4. Read tasks/MILESTONES.md — find current milestone tasks
5. Read harness/SKILLS-INDEX.md — know what skills exist (don't load them yet)
6. Read your role file from harness/roles/
7. Apply pending harness updates (if any) before feature work
8. Begin M[N]
```

### Lessons.md Pre-Commit Check
Before committing, verify:
- [ ] harness/lessons.md has been updated this session (check git diff — new entries appended)
- [ ] Every L: pattern broadcast during the session has a corresponding entry in harness/lessons.md
- [ ] No lesson was "noted verbally" without a write — verbal corrections do not count

If any check fails: write the missing entries NOW before proceeding.

### 6. Commit All Deliverables + Create Harness PR
Write the PR body to a temp file first (avoids security prompts for `#`-prefixed lines):
```
Write ./shutdown-pr-body.md:
Session shutdown deliverables. Closes #[harness-issue]
```
```bash
git add harness/lessons.md docs/BUILD-JOURNAL.md LAUNCH-SCRIPT.md harness/SYSTEM-KNOWLEDGE.md
git add harness/roles/ harness/skills/  # if harness files were updated
git commit -m "harness(session): shutdown deliverables YYYY-MM-DD"
git push -u origin harness/shutdown-YYYY-MM-DD
gh pr create --title "harness: session shutdown YYYY-MM-DD" --body-file ./shutdown-pr-body.md && rm -f ./shutdown-pr-body.md
```

### 7. Clear Session Overrides
Reset ALL ROLE-*.md Session Overrides sections to:
```
## Session Overrides
_None — cleared at session end._
```
Do not leave session-specific rules in role files — they become noise in future sessions.

### 7b. Collect Session Metrics (Step 9b)

Before outputting the dashboard, collect and record session KPIs:

1. **Count agents spawned** — count distinct TeamCreate + Agent tool calls this session
2. **Count D: received** — count D: messages received from agents
3. **Count B: received** — count B: messages received from agents
4. **Compute spawn-to-D: ratio** = D: count / spawned count
5. **Compute B: rate** = B: count / spawned count
6. **Compute PR cycle time** — for each PR merged this session:
   ```bash
   gh pr view <N> --json mergedAt,createdAt --hostname github.je-labs.com
   ```
   Cycle time = `mergedAt` − `createdAt`. Average across all session PRs.
   > Cycle time starts at issue creation, not PR open. Use `gh issue view <N> --json createdAt` for the issue-open timestamp when issue number is known.
7. **Compute average loop count** — count reviewer F: signals per PR (manual tally from session messages). Average across session PRs.
   > Loop count = number of times a builder received reviewer feedback and pushed fixes before merge.
8. **Compute coordination overhead** = Lead message word count ÷ total session word count (Lead + all agents). Thresholds: < 15% healthy | 15–25% watch | > 25% flag to PO immediately before ending session.
9. **Compute vFTE hours and efficiency** — see `docs/investigations/VFTE-FORMULA-2026-03-24.md` for full formula.
   - For each merged PR, get T-shirt size label: `gh issue view <N> --json labels --hostname github.je-labs.com | jq '.labels[] | select(.name | startswith("size:")) | .name'`. Default to M if missing.
   - Map size to hours: XS=1h, S=2h, M=4h, L=8h, XL=16h
   - Get revision count per PR: `gh pr view <N> --json reviews --hostname github.je-labs.com | jq '[.reviews[] | select(.state=="CHANGES_REQUESTED")] | length'`
   - Compute: `rework_rate = total_revision_count / total_prs_merged`
   - Compute: `vfte_hours = Σ(pr_hours × (1 − rework_rate))`
   - Compute: `vfte_efficiency = vfte_hours / session_wall_clock_hours`
   - Flag any PR missing a size label in the dashboard PO ACTION section
10. **Record in docs/sessions/YYYY-MM-DD[letter].json** — **BLOCKING GATE** (same level as LAUNCH-SCRIPT.md). Use canonical schema from `docs/sessions/schema.md`. Include all computable fields; set unknown fields to `null`. Do NOT omit fields — schema must be complete for tooling consistency. Commit alongside shutdown deliverables PR. Include fields: `coordination_overhead_pct`, `vfte_hours_estimate`, `vfte_efficiency`
11. **Add all KPI rows to session-end dashboard** (SESSION STATS section): spawn-to-D: ratio, B: rate, avg PR cycle time, avg loops/PR, coordination overhead, vFTE hours, vFTE efficiency

### 8. Return to Main (MANDATORY FINAL GATE)

```bash
git checkout main && git pull origin main --ff-only
```

Session is not closed until Lead is on an up-to-date main branch.

## Worktree Cleanup
```bash
git worktree list  # see all active worktrees
git worktree prune  # remove stale refs
# For each completed worktree:
git worktree remove ../b-[name]  # if clean
git worktree remove --force ../b-[name]  # if dirty (work is on branch, safe to force)
```
