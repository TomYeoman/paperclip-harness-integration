# Token Efficiency Audit
**Date:** 2026-03-21
**Auditor:** Claude Sonnet 4.6 (Phase 1 — Report Only)

---

## Executive Summary

- **Biggest waste:** ROLE-PM.md contains two complete duplicate sections (M-number Discipline, Ticket Sizing Standard each appear 3× for ~500 wasted tokens per load). Fix in <30 min.
- **Biggest structural waste:** Every agent loads CLAUDE.md (≈900 tokens) unconditionally — but 40% of it is only relevant to Lead (dashboard format, session start protocol, dispatch rules). Agent-specific CLAUDE slices would save 350+ tokens per spawn.
- **Highest-impact quick win:** The launch script (LAUNCH-SCRIPT.md ≈700 tokens) is loaded every session start but duplicates role rules already in ROLE-LEAD.md and CLAUDE.md. It can be cut to ≈200 tokens by removing standing-rules boilerplate.
- **DSL is effective** but the Communication DSL is documented in four places (CLAUDE.md, AGENT-COMMUNICATION-PROTOCOL.md, ROLE-LEAD.md, docs/architecture/COMMUNICATION-DSL.md) — consolidate to one canonical source with references.
- **SKILLS-INDEX.md lazy-load works** and is the best existing pattern — should be expanded to role-file content.

---

## 1. Context Load Analysis

### Files Always Loaded Into Every Agent Context

| File | Est. Tokens | Always Loaded? | Role-Specific? | Notes |
|------|------------|----------------|----------------|-------|
| CLAUDE.md (project) | ~900 | Yes — auto | Partially | §DISPATCH, §SESSION START, §AGENT TEAM are Lead-only |
| ~/.claude/CLAUDE.md (global) | ~250 | Yes — auto | No | Subagent routing, context mgmt, bash output rules |
| Role file (ROLE-*.md) | 700–1,900 | Yes — in spawn prompt | Yes | PM is largest at ~1,900 due to duplication |
| SKILL-agent-spawn.md | ~1,000 | Lead only, lazy | Lead-only | Correct — loaded on demand |
| AGENT-COMMUNICATION-PROTOCOL.md | ~600 | Via spawn prompt typically | Partial | DSL reference duplicated elsewhere |
| SYSTEM-KNOWLEDGE.md | ~400 | Recommended in SESSION START | Partial | Only module status rows are relevant per-agent |
| SKILLS-INDEX.md | ~200 | Via SESSION START step 9 | No | Good — just the index, skills loaded lazily |
| TDD-STANDARDS.md | ~600 | Not loaded by default | Builder/Tester | Correctly not in default load path |
| LAUNCH-SCRIPT.md | ~700 | Yes — SESSION START step 1 | Lead-only | Contains standing rules duplicating CLAUDE.md |
| tasks/MILESTONES.md | ~600 | Yes — SESSION START step 4 | Lead-only | Full milestone history loaded every session |

### Token Cost Estimates by Role at Spawn

| Role | Estimated Spawn Context Tokens | Primary Sources |
|------|-------------------------------|-----------------|
| Lead | ~3,400 | CLAUDE.md + ROLE-LEAD.md + LAUNCH-SCRIPT.md + AGENT-COMMUNICATION-PROTOCOL.md |
| Builder | ~2,400 | CLAUDE.md + ROLE-BUILDER.md + SKILL-agent-spawn.md in prompt context |
| Reviewer | ~1,800 | CLAUDE.md + ROLE-REVIEWER.md |
| Architect | ~1,600 | CLAUDE.md + ROLE-ARCHITECT.md |
| PM | ~2,800 | CLAUDE.md + ROLE-PM.md (inflated by duplication) |
| Auditor | ~1,200 | CLAUDE.md + ROLE-AUDITOR.md |
| Tester | ~1,000 | CLAUDE.md + ROLE-TESTER.md |

### What Could Be Lazy-Loaded

- **TDD-STANDARDS.md** — already not in default path. Good.
- **SKILL-pr-review.md** — only relevant when Reviewer receives V:. Currently lazy. Good.
- **SKILL-session-shutdown.md** — only relevant at session end. Currently lazy. Good.
- **SYSTEM-KNOWLEDGE.md module table** — only the relevant rows are needed per-agent. A section-per-module would allow targeted reads.
- **MILESTONES.md full history** — Lead only needs active/paused milestones. Completed/dropped milestones consume tokens with no value.

---

## 2. What We're Doing Right

### 2.1 SKILLS-INDEX.md Lazy-Load Pattern
**Works as intended.** The index (~200 tokens) contains load triggers that prevent skill files (500–1,000 tokens each) from being loaded unconditionally. Eight skill files × average 700 tokens = 5,600 tokens that are correctly deferred. This is the best pattern in the harness.

**Evidence:** `harness/SKILLS-INDEX.md:1` — "Do NOT load all skills at once. Read the skill file only when the trigger condition is true."

### 2.2 Communication DSL
**Token-efficient by design.** The 10-prefix DSL (`I:` `R:` `G:` `H:` `B:` `D:` `A:` `V:` `E:` `L:`) reduces coordination overhead from multi-sentence prose to single-line signals. A `D:` message with SELF-AUDIT block conveys in ~80 tokens what prose would take ~300 tokens to express.

**Evidence:** `harness/AGENT-COMMUNICATION-PROTOCOL.md:69-84` — "Token Economy Rules: No filler, No preamble, No restatement, No hedging."

### 2.3 Discovery Gate Pattern
**Saves tokens vs ad-hoc exploration.** The structured DISCOVERY gate format forces agents to articulate what they've read and what they plan before getting Lead approval. This prevents agents from burning tokens on wrong-direction implementation. The SELF-GO exception for trivial tasks is correctly calibrated.

**Evidence:** `CLAUDE.md:120-130` — Discovery gate with R:/SELF-GO pattern.

### 2.4 NON-NEGOTIABLE Blocks
**High-signal primacy placement.** Placing NON-NEGOTIABLE rules at the end of role files takes advantage of the recency bias for context loaded at spawn time. More importantly, SKILL-live-learning.md explicitly documents the top-5-rules-at-primacy pattern for spawn prompts, which is the most reliable enforcement position.

**Evidence:** `harness/skills/SKILL-live-learning.md:21-52` — NON-NEGOTIABLE block pattern with the U-shaped retention curve rationale.

### 2.5 Session Overrides Section
**Low-cost state carrier.** The `## Session Overrides` section in each role file allows session-specific rule additions without polluting the permanent rule set. The cleared-at-session-end discipline prevents accumulation. Costs ~15 tokens per role file but avoids per-session role file proliferation.

### 2.6 Model Routing
**Haiku for mechanical tasks is correct.** Routing PM intake, Tester defaults, and Auditor small tasks to Haiku is a ~15× cost reduction vs Opus for the same token volume. The escalation criteria are clearly defined.

---

## 3. Waste Findings

### Finding 1: ROLE-PM.md Has Triple Duplication of Two Major Sections
**Severity:** High
**Location:** `harness/roles/ROLE-PM.md:241-306` and `:253-261` and `:297-306`

The `## M-number Discipline` section appears 3 times (lines 241–251, 253–261, 297–306). The `## Ticket Sizing Standard` section appears twice with full content duplication (lines 207–239 and 263–295). This inflates ROLE-PM.md to ~1,900 tokens vs an expected ~1,200. Every PM spawn carries ~700 tokens of dead weight.

### Finding 2: Two-Track Merge Model Documented in 4+ Places
**Severity:** High
**Locations:**
- `CLAUDE.md:74-86` (§ BRANCHES + PR MERGE)
- `harness/roles/ROLE-LEAD.md:74-86` (§ Merge Ownership)
- `harness/roles/ROLE-BUILDER.md:82-101` (§ PR Workflow)
- `harness/roles/ROLE-REVIEWER.md:7-11`
- `harness/skills/SKILL-agent-spawn.md:170-173`
- `harness/skills/SKILL-github-pr-workflow.md:80-120`

Six partial copies of the same Track 1 / Track 2 rules. Total estimated duplicated tokens: ~800. Each update to the merge model requires editing 6+ files.

### Finding 3: Spawn Sequence Warning Documented in 4 Places
**Severity:** Medium
**Locations:**
- `CLAUDE.md:39-45` (§ DISPATCH)
- `harness/roles/ROLE-LEAD.md:94-124` (§ Spawn Sequence)
- `harness/skills/SKILL-agent-spawn.md:24-32` (§ CRITICAL)
- `harness/skills/SKILL-agent-spawn.md:179-218` (§ Anti-Patterns)

The TeamCreate vs Agent tool distinction and the 10 anti-patterns (A1–A10) are the authoritative source in SKILL-agent-spawn.md. The other locations contain abbreviated re-statements that add ~400 tokens of redundancy.

### Finding 4: LAUNCH-SCRIPT.md Contains Standing Rules Duplicating CLAUDE.md
**Severity:** Medium
**Location:** `LAUNCH-SCRIPT.md:54-66` (§ Standing Rules)

The "Standing Rules" block in the launch script (~300 tokens) repeats rules that are already canonical in CLAUDE.md and ROLE-LEAD.md. Specifically: spawn sequence, model selection, PR body format, submodule merge rules, Reviewer spawn timing. These rules don't need to be in the launch script — the launch script should point to those files, not repeat their content. The launch script's actual value is session state (open PRs, worktrees, blockers), not standing rules.

### Finding 5: MILESTONES.md Loads Full Dropped/Done History Every Session
**Severity:** Medium
**Location:** `tasks/MILESTONES.md:18-54` (M0, M1 — both DROPPED)

M0 and M1 are DROPPED. They consume ~200 tokens per session start read with zero operational value. The Milestone States section and state machine (~100 tokens) is reference material that doesn't need to be in the active working file.

### Finding 6: AGENT-COMMUNICATION-PROTOCOL.md Duplicates DSL Already in CLAUDE.md
**Severity:** Medium
**Location:** `harness/AGENT-COMMUNICATION-PROTOCOL.md:55-84` vs `CLAUDE.md:104-118`

Both files contain the full DSL prefix table. The protocol file also contains the token economy rules (lines 69–84) which partially duplicate COMMUNICATION-DSL.md in docs/architecture/. Three partial copies of the communication DSL with slightly different formats.

### Finding 7: docs/architecture/ Is Prose Documentation of Things Already in Role Files
**Severity:** Low
**Location:** `docs/architecture/` (6 files)

These architecture docs (~4,000 tokens total) exist for human onboarding but are not loaded into agent contexts. They document the same rules as CLAUDE.md and role files in narrative form. This is not a runtime cost — but it creates a maintenance burden: when rules change, there are now 3 documents to update (role file + CLAUDE.md + architecture doc). They should be explicitly marked as human-readable documentation that is NOT authoritative for agent behavior.

### Finding 8: SKILL-agent-spawn.md Pre-Spawn Checklist Is 11 Items
**Severity:** Low
**Location:** `harness/skills/SKILL-agent-spawn.md:34-46`

11-item checklists are harder to internalize than 5-6 item lists. Items 5–11 (GitHub issue active, platform identified, plan approval, prompt includes role file, worktree path, push-before-DONE, merge ownership) could be collapsed into a spawn prompt template requirement rather than a separate checklist — the template already encodes them.

### Finding 9: ROLE-BUILDER.md Has iOS-Specific Sections Even Though Stack Is TBD
**Severity:** Low
**Location:** `harness/roles/ROLE-BUILDER.md:24-42` (§ iOS VERIFICATION GATE)

The iOS verification gate, snapshot regeneration instructions, and iOS pre-PR checklist add ~250 tokens to every Builder spawn even for Android, Web, and Backend builders. Platform-specific content should be in SKILL-coding-standards-ios.md (already loaded lazily), not in the base role file.

### Finding 10: WORKFLOW-BUG-FIX.md:73 Uses `gh pr merge` Directly
**Severity:** Low
**Location:** `harness/workflows/WORKFLOW-BUG-FIX.md:73`

Line 73 instructs: `gh pr merge --squash --delete-branch`. This contradicts the NON-NEGOTIABLE rule in ROLE-BUILDER.md and CLAUDE.md that agents NEVER merge. The workflow was likely written before the no-merge rule was established. This inconsistency forces every Reviewer reading this workflow to reconcile the contradiction, burning reasoning tokens unnecessarily.

---

## 4. Agent DSL Analysis

### Current DSL Effectiveness

The 10-prefix DSL is genuinely token-efficient. Evidence of effectiveness:
- A `D: TASK-042 complete. PR #15 opened.` message plus a SELF-AUDIT block achieves in ~100 tokens what a prose status update would take 300–400 tokens.
- The `V:` prefix creates an unambiguous trigger for Lead to spawn a Reviewer immediately — no reasoning required about whether a Reviewer is needed.
- `B:` with file:line reference encodes enough context for any agent to unblock without back-and-forth.

### Consistency Across Role Files

**Inconsistencies found:**

1. `A:` prefix semantics differ: CLAUDE.md defines it as "Decision needed / Respond" for any agent. AGENT-COMMUNICATION-PROTOCOL.md restricts `A:` to PM only. ROLE-PM.md says agents send `A:` via SendMessage to Lead. ROLE-LEAD.md says "If Lead receives an A: message from an agent via SendMessage, it is a bug." This is a genuine contradiction creating decision overhead.

2. `E:` prefix is defined in CLAUDE.md and AGENT-COMMUNICATION-PROTOCOL.md but does not appear in any role file's NON-NEGOTIABLE section or spawn prompt guidance. It appears to be under-used.

3. The COMMUNICATION-DSL.md in docs/architecture/ shows Lead as the sender of `E:` while AGENT-COMMUNICATION-PROTOCOL.md shows `A:` as the "decision needed" prefix. The two documents define slightly different semantics for escalation.

### Gaps in the DSL

**Missing message types:**

1. **No spawn acknowledgment prefix.** When Lead spawns a teammate and sends the prompt, there is no structured signal back confirming the teammate is live and in the correct directory. Currently handled by Lead checking `pwd` / `git rev-parse` output — this is prose verification, not a DSL signal.

2. **No re-review signal.** After Builder pushes fixes, Builder notifies Reviewer via "SendMessage that fixes are pushed" (plain text). There is no structured prefix for this — it is the only coordination step in the PR lifecycle without a DSL prefix. A `F:` (Fixes pushed, please re-review) signal would close this gap.

3. **No handoff signal.** Session shutdown requires Lead to explicitly instruct each agent to shut down, but there is no `X:` or `S:` prefix for "session end, shut down now." Shutdown messages are currently prose.

### What a Lead-Specific DSL Would Add

The existing Communication DSL is inter-agent. A Lead-specific DSL would encode the _orchestration_ layer — decisions Lead makes that are not covered by the current prefixes:

1. **`ASSIGN: [agent] [task-id]`** — explicit task assignment signal (currently embedded in G:)
2. **`SCALE: [role] [count] [reason]`** — signal to spawn N additional agents of a role (e.g., 3 Builders for 3 parallel issues)
3. **`AUDIT: [scope]`** — trigger for a model audit of all active agents before any G: messages
4. **`MERGE: [PR-N]`** — Lead's merge action, currently undeclared in DSL despite being a key Lead action
5. **`CLOSE: [agent-name]`** — explicit agent shutdown signal, creates a permanent record of agent lifecycle
6. **A structured dashboard template** rather than free-form text — the dashboard in ROLE-LEAD.md is a format spec but Lead constructs it from scratch each time. A DSL token for "render dashboard" would standardize output and allow RTK-style post-processing.

The most valuable addition would be `CLOSE:` and `F:` — these address the two most common unstructured coordination moments in the current harness.

---

## 5. Novel / Non-Obvious Solutions

### 5.1 Role Manifest Files (Agent-Specific CLAUDE Slices)
Instead of every agent loading the full CLAUDE.md, produce role-specific `CLAUDE-[ROLE].md` files during session init. Each file contains only the sections relevant to that role:
- Builder slice: CODE RULES + SECURITY + COMMIT + SPEC CHAIN (omit DISPATCH, SESSION START, AGENT TEAM, BRANCHES, dashboard)
- Reviewer slice: BRANCHES + CODE RULES (omit almost everything else)
- This would reduce per-agent CLAUDE load by 40–60%.

### 5.2 Structured JSON Contracts Between Agents
Currently agents exchange DSL signals and prose. For the V: → Reviewer handoff, a lightweight JSON contract would eliminate ambiguity:
```json
{"event": "V", "task_id": "TASK-042", "pr": 15, "branch": "feature/jwt-validation", "platform": "ios", "diff_lines": 180}
```
The diff_lines field alone allows Lead to decide whether to escalate Reviewer model (Sonnet vs Opus) before spawning, without the Reviewer needing to measure the PR first.

### 5.3 File-Based State Machine for Milestone Progress
Currently milestone state lives in tasks/MILESTONES.md as prose tables. A machine-readable `tasks/state.json` file (updated by builders on D:, read by Lead on session start) would allow Lead to reconstruct the dashboard without reading 600 tokens of MILESTONES.md. MILESTONES.md becomes a human-readable view, not the operational source of truth.

### 5.4 Checkpoint/Resume Context Frames
At the 2-hour mark (per SKILL-live-learning.md), insert a structured context checkpoint:
```
CHECKPOINT: Session 2026-03-21T14:30Z
COMPLETED: TASK-042, TASK-043
IN-PROGRESS: TASK-044 (b-cart, 60% done, PR not yet open)
BLOCKED: TASK-045 (awaiting Architect ADR-003)
NEXT: TASK-046 when TASK-044 merges
```
This 100-token checkpoint, placed at context recency, compensates for middle-context degradation better than repeating full milestone state.

### 5.5 .claudeignore Patterns for Agent Worktrees
A `.claudeignore` in each worktree could exclude node_modules, build artifacts, and generated files that inflate context when agents do directory exploration. Currently this is instructed in prose ("Do not load lock files, build artefacts"). A `.claudeignore` makes it structural:
```
node_modules/
build/
dist/
.gradle/
*.lock
*.generated.*
```

### 5.6 Tiered Role File Loading
Current: spawn prompt says "read ROLE-BUILDER.md". Every Builder loads the full role file at the start.
Alternative: Role files split into a CORE (permanent, always load) and EXTENDED (load when trigger matches):
- `ROLE-BUILDER-CORE.md` (~300 tokens): fundamental constraints, NON-NEGOTIABLE block
- `ROLE-BUILDER-IOS.md` (~250 tokens): iOS-specific gates
- `ROLE-BUILDER-ANDROID.md` (~200 tokens): Android-specific gates
- `ROLE-BUILDER-WEB.md` (~200 tokens): Web-specific gates
Platform-specific sections loaded only when `Platform: ios|android|web|backend` in spawn prompt.

### 5.7 Prompt Compression via Shared Reference Files
Instructions like the full Two-Track Merge Model (currently in 6 files) could exist once as `harness/rules/MERGE-OWNERSHIP.md` and all other files reference it: `@merge-ownership`. Claude Code's file reading supports this pattern. Each reference site saves ~150 tokens.

### 5.8 Discovery Report Template File
The DISCOVERY gate format is defined inline in CLAUDE.md and reproduced in some spawn prompts. A canonical `/tmp/discovery-template.md` written at session start and referenced in all spawn prompts would standardize format without repeating it. The template itself can be minimal (~50 tokens) while the instructions on what to fill in stay in CLAUDE.md.

---

## 6. Straightforward Wins (Quick, <1 hour each)

Ranked by token impact (highest first):

1. **Fix ROLE-PM.md triple duplication** — Remove 2 duplicate copies of M-number Discipline section and 1 duplicate copy of Ticket Sizing Standard. Saves ~700 tokens per PM spawn. File: `harness/roles/ROLE-PM.md`.

2. **Prune LAUNCH-SCRIPT.md standing rules** — Replace the §Standing Rules block (lines 54–66, ~300 tokens) with a single pointer: "Rules: See CLAUDE.md and harness/roles/ROLE-LEAD.md — do not duplicate here." Saves ~300 tokens per session start. File: `LAUNCH-SCRIPT.md`.

3. **Add DROPPED milestone archive** — Move M0 and M1 entries from MILESTONES.md to `tasks/MILESTONES-ARCHIVE.md`. Active file references the archive. Saves ~200 tokens per session start read. File: `tasks/MILESTONES.md`.

4. **Remove iOS-specific section from ROLE-BUILDER.md** — Move iOS VERIFICATION GATE (lines 24–42) and iOS Quality Gates (lines 103–124) to `harness/skills/SKILL-coding-standards-ios.md` where they belong. Saves ~250 tokens for all non-iOS Builder spawns. File: `harness/roles/ROLE-BUILDER.md`.

5. **Fix `A:` prefix contradiction** — Reconcile the conflicting definitions across CLAUDE.md, AGENT-COMMUNICATION-PROTOCOL.md, and ROLE-LEAD.md. ROLE-LEAD.md says A: from an agent is a bug; CLAUDE.md says any agent can send A:. Pick one canonical definition, update all three files. Eliminates reasoning overhead for every agent reading the conflict. Files: `CLAUDE.md:112`, `harness/AGENT-COMMUNICATION-PROTOCOL.md:60`, `harness/roles/ROLE-LEAD.md:170`.

6. **Fix WORKFLOW-BUG-FIX.md:73** — Replace `gh pr merge --squash --delete-branch` with a note that human (PO) merges. Saves future Reviewers from having to reconcile this contradiction. File: `harness/workflows/WORKFLOW-BUG-FIX.md:73`.

7. **Mark docs/architecture/ as human-only docs** — Add a header to each file: "HUMAN REFERENCE ONLY — Not loaded into agent contexts. CLAUDE.md and role files are authoritative." Prevents confusion about which is canonical. Files: `docs/architecture/` (6 files, trivial edit each).

8. **Add `F:` prefix to the DSL** — Define F: (Fixes pushed, ready for re-review) in CLAUDE.md's DSL table and AGENT-COMMUNICATION-PROTOCOL.md. Closes the unstructured coordination gap in the Builder → Reviewer re-review loop. Files: `CLAUDE.md`, `harness/AGENT-COMMUNICATION-PROTOCOL.md`.

---

## 7. Structural Recommendations (Higher Effort, Higher Impact)

Ranked by impact:

1. **Agent-Specific CLAUDE Slices** — Produce role-targeted CLAUDE summaries (400–500 tokens each vs 900 for full CLAUDE.md). Lead generates these at session start once and injects into spawn prompts. Each non-Lead role gets only its relevant sections. Estimated saving: 300–500 tokens per non-Lead agent spawn across 15 possible concurrent agents = 4,500–7,500 tokens for a full team. **Implementation:** New skill SKILL-session-init.md + one-time template generation per role. Effort: 2–3 hours.

2. **Machine-Readable State File** — Introduce `tasks/state.json` as the canonical source of truth for milestone/task progress. Lead reads this file (100–200 tokens) instead of MILESTONES.md (600 tokens) to reconstruct the dashboard. Milestones.md becomes human-readable view only. Builders update state.json atomically on D:. **Implementation:** Requires Architect ADR defining schema. Effort: 3–4 hours.

3. **Tiered Role Files by Platform** — Split ROLE-BUILDER.md into ROLE-BUILDER-CORE.md + platform extension files. Spawn prompts include CORE + relevant platform file only. Saves ~250 tokens per non-iOS Builder spawn. **Implementation:** Refactor ROLE-BUILDER.md, update SKILLS-INDEX.md, update spawn prompt template in SKILL-agent-spawn.md. Effort: 2 hours.

4. **Single Canonical Merge-Ownership Reference** — Create `harness/rules/MERGE-OWNERSHIP.md` as the one authoritative source. Replace the 6 copies with a pointer: "See harness/rules/MERGE-OWNERSHIP.md". This is both a token saving and a maintenance win — one place to update when the rule changes. Effort: 1–2 hours.

5. **Milestone Archive Pattern** — Implement a formal archive pattern: completed/dropped milestones move to `tasks/MILESTONES-ARCHIVE.md`, active file stays lean. Extend the SESSION START checklist to skip reading the archive unless specifically requested. Over time, as milestones accumulate, this becomes more valuable. Effort: 1 hour to implement, ongoing maintenance discipline.

6. **Checkpoint Context Frame Pattern** — Encode the checkpoint format into SKILL-live-learning.md as a mandatory 2-hour trigger. Define the CHECKPOINT: DSL prefix. This improves context quality for long sessions without adding tokens upfront — the checkpoint replaces prior context that has degraded. Effort: 1 hour (update SKILL-live-learning.md + add CHECKPOINT to DSL).

7. **RTK Rewrite Rules for Common Patterns** — Since RTK is installed, create RTK rewrite rules that compress known verbose patterns at input time. For example, "NON-NEGOTIABLE:" blocks that repeat full DSL definitions could be collapsed to pointers. This requires careful RTK configuration to avoid breaking context that legitimately needs the full text. Effort: 2–4 hours to configure safely.

---

## 8. Proposed GitHub Issues

| Issue Title | Category | Estimated Token Impact |
|-------------|----------|----------------------|
| Fix ROLE-PM.md triple duplication of M-number Discipline and Ticket Sizing | Quick | ~700 tokens/PM spawn |
| Prune LAUNCH-SCRIPT.md standing rules boilerplate | Quick | ~300 tokens/session |
| Archive DROPPED milestones (M0, M1) out of active MILESTONES.md | Quick | ~200 tokens/session |
| Move iOS-specific Builder gates to SKILL-coding-standards-ios.md | Quick | ~250 tokens/non-iOS Builder spawn |
| Reconcile `A:` prefix contradiction across CLAUDE.md, ACP, ROLE-LEAD.md | Quick | Reasoning overhead |
| Fix WORKFLOW-BUG-FIX.md:73 — remove `gh pr merge` instruction | Quick | Consistency/confusion |
| Mark docs/architecture/ files as human-reference-only | Quick | Maintenance clarity |
| Add `F:` (fixes pushed) prefix to Communication DSL | Quick | Structure + clarity |
| Implement agent-specific CLAUDE.md slices for non-Lead roles | Structural | 300–500 tokens/agent spawn |
| Introduce machine-readable tasks/state.json for milestone tracking | Structural | ~400 tokens/session |
| Refactor ROLE-BUILDER.md into CORE + platform extension files | Structural | ~250 tokens/non-iOS Builder |
| Create canonical harness/rules/MERGE-OWNERSHIP.md reference | Structural | ~800 tokens (6 file dedup) |
| Implement 2-hour CHECKPOINT: context frame pattern | Structural | Context quality for long sessions |
| Design LEAD DSL extension: ASSIGN:, SCALE:, AUDIT:, MERGE:, CLOSE: | Structural | Orchestration clarity |

**Total issues proposed:** 14 (8 Quick, 6 Structural)
