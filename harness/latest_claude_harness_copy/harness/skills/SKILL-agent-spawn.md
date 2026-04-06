# Skill: Agent Spawn Protocol — Claude Code Agent Teams

Load this skill when: about to spawn an agent.

## Overview

All agents are spawned as **Claude Code Agent Teams teammates** — full independent Claude Code sessions that the PO can interact with directly (paste images, text, transcripts into agent tabs). This replaces the previous Agent SDK background-agent pattern.

**Prerequisite:** `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` must be `"1"` in `~/.claude/settings.json` (already configured).

## Display Modes

| Mode | How it works | Setup |
|------|-------------|-------|
| **In-process** (default) | Shift+Down cycles through teammate tabs. Type to message directly. | No setup needed |
| **Split panes** | Each teammate gets its own pane. Click to interact. | Requires tmux or iTerm2 |

Set in `~/.claude/settings.json`:
```json
{ "teammateMode": "tmux" }
```
Or per-session: `claude --teammate-mode in-process`

## CRITICAL: TeamCreate is Required for Teammates

**The Agent tool alone creates sub-agents, NOT teammates.** Sub-agents are ephemeral background workers scoped to Lead's context — they cannot receive PO input, do not appear as tabs, and vanish when Lead's turn ends.

To spawn a **real teammate** (independent session, own tab, PO can interact):
1. Use **TeamCreate** to create the teammate
2. Use **SendMessage** to send the prompt to the teammate

**Never use `run_in_background: true` for teammate Bash commands.** Background execution causes 401 authentication failures in Claude Code Agent Teams. All teammate Bash calls must run in the foreground (default).

## Pre-Spawn Checklist
- [ ] **GitHub issue exists** for this work (feature or harness). Note the issue number — include it in this builder's spawn prompt and in the PR body.
- [ ] **One issue = one builder = one PR.** Each GitHub issue gets exactly one dedicated Builder with its own worktree and branch. Never group multiple issues into a single builder — even if the issues are related or touch the same file. Group only when issues are trivially related AND the total diff is small (≤20 lines). When in doubt, separate.
- [ ] **Work is grouped by logical concern**, not by file. If two changes serve different purposes, they are separate builders/PRs even if they touch the same file.
- [ ] **TeamCreate used (NOT Agent tool)** — Agent tool creates sub-agents, not teammates; see A9
- [ ] **Model set in Agent tool `model` parameter** — not in prompt text; inherits Opus if omitted; see A1
- [ ] **Branch name specified** as `[type]/[short-description]-[issue-number]` — issue number required for uniqueness
- [ ] **Upstream param declared** — `🏠` (hold in hive, default) or `🌻` (release to sunflower) included in spawn prompt
- [ ] **File scope defined, no overlap** with other active agents; see A3
- [ ] **Worktree OUTSIDE repo tree** (file-writing agents); spawn prompt includes absolute worktree path; see A4
- [ ] **UI changes + Figma requires auth?** Obtain design screenshot from PO before spawning Builder. A Builder without a spec makes a best-guess commit that needs rework.
- [ ] **Spawn prompt complete:** role file, platform (`ios|android|web|backend|none`), task, push-before-DONE, merge ownership rules, plan approval if risky

**Troubleshooting permission prompts:** Four root causes, in order of likelihood:
1. **Relative file paths in spawn prompts** — `Read(**)` in the allow list is anchored to the main project root. When a builder in a worktree reads `harness/foo.md` (relative), Claude Code cannot match it against `Read(/private/tmp/**)` and prompts. Fix: all file paths in spawn prompts must be absolute (e.g. `/private/tmp/wt-name/harness/foo.md`). Add a rule to the spawn prompt: "All file reads and writes must use absolute paths."
2. **Project `.claude/settings.json` has a `permissions.allow` block** — it replaces (not merges with) the global allow list. Remove the block entirely; keep env vars only. See CLAUDE.md "Settings and Configuration".
3. **Global allow list missing `/private/tmp/**` entries** — macOS resolves `/tmp` to `/private/tmp`. `Glob(/private/tmp/**)` and `Grep(/private/tmp/**)` must be present alongside `Glob(**)` and `Grep(**)`. Read/Write/Edit similarly need `/private/tmp/**`. Any tool path entry without a matching `/private/tmp/**` entry will prompt on macOS.
4. **Category B (security-check) prompts** — heredoc or command substitution with `#`-prefixed lines always prompt regardless of the allow list. Fix: write body/commit-message files with the Write tool, use `--body-file` and `git commit -F`. See SKILL-github-pr-workflow.md.

**`bypassPermissions` is permanently disabled** (`disableBypassPermissionsMode: "disable"` in `~/.claude/settings.json`). Spawning with `mode: "bypassPermissions"` is a no-op — it does NOT skip the allow list. The allow list is the only security model. Every tool an agent uses must be explicitly allowed.

## Step 1: Create Worktree (for file-writing agents)

### Single builder
```bash
# OUTSIDE the repo tree — use /private/tmp/wt-[name]
git worktree add /private/tmp/wt-[feature-name] -b feature/[feature-name] main
```
Path must be OUTSIDE repo tree. Example:
- Repo: /Users/you/testharness
- Worktree: /private/tmp/wt-user-auth (correct — outside, macOS standard)
- Worktree: /Users/you/testharness/worktrees/b-user-auth (WRONG — inside repo)

### Parallel builders — Lead MUST pre-create all worktrees before spawning

`isolation: "worktree"` alone is insufficient for parallel builders. Lead must pre-create each worktree manually and hardcode the absolute path in each spawn prompt:

```bash
git worktree add /private/tmp/wt-[slug-a] -b [branch-a] origin/main
git worktree add /private/tmp/wt-[slug-b] -b [branch-b] origin/main
git worktree add /private/tmp/wt-[slug-c] -b [branch-c] origin/main
```

Run all pre-creation commands before spawning any builder. Each builder receives its own hardcoded path (e.g. `/private/tmp/wt-[slug-a]`) — never a computed or dynamic path.

**Why pre-creation is required:** The Bash tool CWD does NOT persist between calls inside a builder. A builder that runs plain `git` (without `-C /path`) operates on whatever directory the shell resets to — often the main repo. This contaminates the main repo branch and other builders' worktrees.

**Every git command in a spawn prompt must use `git -C /private/tmp/wt-[slug]`** — never plain `git`, never `cd /path && git`.

**Required warning in every spawn prompt for parallel builders:**
> ⚠️ CRITICAL: The Bash tool CWD does NOT persist between calls. NEVER run plain `git` — always use `git -C /private/tmp/wt-[slug]` for every single git command.

## Step 2: Spawn Teammate

Tell Lead in natural language to spawn a teammate. Lead describes the role, model, task, and working directory. Claude Code creates the teammate as a full independent session.

Example Lead prompt to Claude Code:
```
Spawn a teammate named "b-user-auth" using Sonnet to implement user
authentication. Working directory: /c/b-user-auth. Branch: feature/user-auth.
Require plan approval before implementation.

Prompt: You are Builder agent b-user-auth working on user authentication.
Working directory: /c/b-user-auth
Branch: feature/user-auth
GitHub issue: #42
Platform: ios

Read first: harness/roles/ROLE-BUILDER-CORE.md, harness/roles/ROLE-BUILDER-IOS.md, harness/skills/SKILL-coding-standards-ios.md

Task: [description]

Rules:
- [rule1]
- [rule2]

When complete:
1. Run quality checks
2. Run tests — zero failures
3. Follow PR workflow in harness/roles/ROLE-BUILDER-CORE.md (Two-Track Model)
```

## PO Direct Interaction

Agent Teams teammates have full input surfaces. The PO can:
- **Paste images** directly into any agent's tab (design screenshots, error captures)
- **Paste text** (transcripts, requirements, Jira ticket content)
- **Type messages** to redirect, ask questions, or give additional context
- **Navigate** with Shift+Down (in-process) or click (split panes)

This eliminates the need for relay patterns. PM, Auditor, and other interactive roles talk to PO directly in their tab.

## Naming

Always use a descriptive slug for the `name` parameter — not just the issue number:
- **Good:** `b-prune-launch-script`, `b-ios-gates`, `r-review-auth`, `au-token-audit`
- **Bad:** `b-284`, `b-286`

Issue number as suffix is fine: `b-prune-launch-script-284`. The PO reads agent names live in the team pane.

## Name Prefix Conventions
| Prefix | Role |
|--------|------|
| b- | Builder |
| a- | Architect |
| r- | Reviewer |
| t- | Tester |
| pm- | PM |
| au- | Auditor |

## Model Selection Quick Reference
| Role | Model | Model ID |
|------|-------|----------|
| Lead | Opus | claude-opus-4-6 |
| Architect | Opus | claude-opus-4-6 |
| Builder (production code) | Sonnet | claude-sonnet-4-6 |
| Builder (docs-only / harness) | Haiku | claude-haiku-4-5-20251001 |
| Reviewer | Sonnet | claude-sonnet-4-6 |
| PM (large discovery) | Opus | claude-opus-4-6 |
| PM (checklist/intake) | Haiku | claude-haiku-4-5-20251001 |
| Tester (complex scenarios) | Sonnet | claude-sonnet-4-6 |
| Tester (default) | Haiku | claude-haiku-4-5-20251001 |
| Auditor (complex research/security) | Opus | claude-opus-4-6 |
| Auditor (small harness changes) | Haiku | claude-haiku-4-5-20251001 |

**Builder model selection rule:** Use Haiku if the builder's entire diff will be markdown files in the harness (ROLE-*.md, SKILL-*.md, CLAUDE.md, docs/, etc.). Use Sonnet if any production code is touched (iOS, Android, web, backend submodules).

**⚠️ CRITICAL: `model` must be set as the Agent tool's `model` parameter.** Writing `"Model: claude-sonnet-4-6"` anywhere in the prompt text is a no-op. If not specified, teammate inherits Lead's model (Opus) — wasteful for Sonnet/Haiku roles. Only the tool's `model` parameter sets the agent model.

## Spawn Prompt Template
```
You are [role] agent [name] working on [task-description].

Working directory: [/absolute/path/to/worktree]
Branch: [branch-name]
GitHub issue: #[N]
Platform: [ios|android|web|backend|none]

Files to read first (use absolute paths — relative paths trigger permission prompts in worktrees):
- [/absolute/path/to/worktree]/harness/roles/ROLE-BUILDER-CORE.md  ← all builders (replaces ROLE-BUILDER.md)
- [/absolute/path/to/worktree]/harness/roles/ROLE-BUILDER-[PLATFORM].md  ← platform extension: ios|android|web|backend (omit if platform: none)
- [/absolute/path/to/worktree]/harness/context/CLAUDE-[ROLE].md  ← role-specific CLAUDE.md slice (replaces full CLAUDE.md)
- [/absolute/path/to/worktree]/harness/skills/SKILL-coding-standards-[platform].md  ← required for Builder and Reviewer
- [/absolute/path/to/file1]
- [/absolute/path/to/file2]

Task: [clear description]

Rules:
- [rule1]
- [rule2]
- All file reads and writes MUST use absolute paths (e.g. /private/tmp/wt-[name]/src/...). Relative paths trigger permission prompts.
- Before staging: run `git branch --show-current` and confirm it matches the intended branch. If wrong, run `git checkout -b <correct-branch-name>` before any `git add`.
- Stage only specific files by absolute path (`git add /abs/path/file`). NEVER use `git add -A` or `git add .` — shared git object store means untracked files from other builders can contaminate your commit.

PO can paste images, text, and transcripts directly into your tab. If PO provides context this way, use it immediately.

When complete (Builder):
1. Run [quality check command]
2. Run [test command] — must be zero failures
3. **Verify branch name before staging:**
   ```bash
   git branch --show-current
   # Must match intended branch name. If wrong, abort: git checkout -b <correct-branch-name>
   ```
4. **Stage only specific files — never git add -A or git add .:**
   ```bash
   git add /absolute/path/to/file1 /absolute/path/to/file2
   # NEVER: git add -A or git add .
   # Reason: shared git object store — untracked files from other builders can contaminate
   ```
5. **Rebase against main immediately before push — every time:**
   ```bash
   git rebase origin/main
   # Do this immediately before git push — not earlier in the workflow
   # Catches conflicts before merge-queue ejection, not after
   # Required even if you think your branch is up to date
   ```
6. Follow PR workflow in [/absolute/path/to/worktree]/harness/roles/ROLE-BUILDER-CORE.md (Two-Track Model)
```

**Model selection note:** When spawning a Builder for docs-only/harness changes (markdown files in harness, ROLE-*.md, SKILL-*.md, CLAUDE.md, etc.), specify `claude-haiku-4-5-20251001` to reduce cost. For any production code changes, use `claude-sonnet-4-6`. Greenfield builders doing spike/exploratory work may use Haiku regardless of scope.

## Hold in Hive (🏠) — Local Development

Use this flow for work that should stay local until Lead explicitly authorizes upstream PR:

```
You are Builder agent [name] working on [task-description].

Upstream: 🏠 hold in hive

Working directory: [/absolute/path/to/worktree]
Branch: feature/[slug]
GitHub issue: #[N]
Platform: [ios|android|web|backend|none]

Files to read first (use absolute paths):
- [/absolute/path/to/worktree]/harness/roles/ROLE-BUILDER-CORE.md
- [/absolute/path/to/worktree]/harness/rules/MERGE-OWNERSHIP.md

Task: [clear description]

Rules:
- Work locally — do NOT open a PR until Lead sends 👑 to authorize upstream
- Branch follows standard feature/[slug] naming
- On authorization (👑 received from Lead): push branch, open PR, follow standard Two-Track lifecycle
- All file reads and writes MUST use absolute paths
- After Reviewer all-clear: Lead queues PR
- Builder polls merge queue → sends CONFIRMED-D: on merge
- Do NOT shut down until Lead sends CLOSE: following CONFIRMED-D:
- Use SendMessage to report all stage transitions to [lead-name]
```

**Builder queue gate — Reviewer all-clear required before merge:**
After Builder sends V: (PR opened), Lead spawns Reviewer same turn. Builder must NOT be instructed to queue its own PR — that is Lead's responsibility, and only after Reviewer all-clear. The correct sequence is:
1. Builder sends V: → Lead spawns Reviewer immediately (same turn)
2. Reviewer sends all-clear → Lead queues PR
3. Builder polls merge queue → sends CONFIRMED-D: on merge
4. Lead sends CLOSE:

Spawn prompts must never tell a builder to queue its own PR. Merge queue is Lead's action, gated on Reviewer all-clear.

**Merge ownership — Two-Track Model (encode in every Builder and Reviewer prompt):**
> Full rules: see [harness/rules/MERGE-OWNERSHIP.md](../rules/MERGE-OWNERSHIP.md). Spawn prompts must NEVER include instructions to merge or approve. If a spawn prompt contradicts a role file's NON-NEGOTIABLE rules, the role file wins.

## Post-Spawn Verification
Within 2 messages of spawning, confirm teammate ran `pwd` and `git rev-parse --show-toplevel` as separate Bash calls.
If teammate is in wrong directory, message them directly to correct before any work proceeds.

## 10 Anti-Patterns

**A1: Omit model or write model in prompt text instead of Agent tool parameter**
What goes wrong: Teammate inherits Lead's Opus model — 5x cost for Sonnet-appropriate tasks. Writing `"Model: claude-sonnet-4-6"` in the prompt text body is also a no-op — only the Agent tool's `model` parameter sets the model.
Rule: Always specify model in the Agent tool's `model` parameter, not in the prompt text.

**A2: Spawn from inside another agent's worktree**
What goes wrong: Nested worktree paths cause git to look up the tree and find the wrong repo root.
Rule: Lead spawns teammates from main repo directory.

**A3: Two agents with overlapping file scope**
What goes wrong: Both agents modify same files — merge conflicts on PR.
Rule: Define file scope per agent before spawning. No overlaps.
**Exception:** Same-file changes for separate issues are acceptable — the merge queue serialises them automatically. Pre-assign file ownership only for append-heavy shared files (`harness/lessons.md`, `docs/BUILD-JOURNAL.md`) where rebase queue overhead is disproportionate. Never blend issue scope to avoid file conflicts.

**A4: Worktree inside repo tree**
What goes wrong: `git status` in main repo shows worktree files as untracked. `git clean` deletes agent's work.
Rule: Always place worktrees OUTSIDE repo tree (parent directory or sibling directory).

**A5: 3+ redirect messages to misbehaving teammate**
What goes wrong: Tokens wasted on corrections that don't stick. Teammate context is corrupted.
Rule: After 1 retry, shut down teammate and respawn with corrected prompt.

**A6: Spawn without push-before-DONE instruction**
What goes wrong: Teammate commits locally but crashes before pushing — commits vanish.
Rule: Every spawn prompt must include "push branch before sending D:".

**A7: Skip plan approval for risky tasks**
What goes wrong: Teammate implements the wrong approach, wasting tokens and time.
Rule: Use plan approval for complex tasks, refactors, or any work touching shared interfaces.

**A8: Relay PO questions through Lead for interactive roles**
What goes wrong: Unnecessary latency and cognitive overhead. PO can talk to teammates directly.
Rule: PM, Auditor, and other interactive roles talk to PO directly in their tab. Lead relay is only needed for coordination signals (G:, B:, D:, V:).

**A9: Use Agent tool instead of TeamCreate to spawn teammates**
What goes wrong: Agent tool creates a sub-agent (ephemeral, no PO interaction, no tab, scoped to Lead's turn). The "teammate" never appears in the tab list and cannot receive images, text, or messages from PO.
Rule: Always use TeamCreate + SendMessage. Agent tool is ONLY for trivial self-contained lookups within Lead's own response.

**A10: Use `run_in_background: true` for teammate Bash commands**
What goes wrong: Background Bash execution triggers 401 authentication failures in Agent Teams. Commands silently fail or return auth errors.
Rule: All teammate Bash calls must use foreground execution (the default). Never set `run_in_background: true`.

**A11: Sequential grouping without hard dependency** — Creating Group A → Group B → Group C when all tasks are independent. Always prefer spawning all builders in parallel in one turn. Sequence only when task B's input literally depends on task A's output.

## Gotchas

| # | Trap | What breaks | Fix |
|---|------|------------|-----|
| 1 | Agent tool instead of TeamCreate | Sub-agent only — no tab, no PO access, vanishes after Lead's turn | Always TeamCreate first, then Agent(team_name=...) |
| 2 | `model` written in prompt text | No-op — teammate inherits Lead's Opus model (5× cost) | Set model in Agent tool's `model` parameter only |
| 3 | `run_in_background: true` in teammate Bash | Silent 401 auth failures | Always use foreground Bash (the default) |
| 4 | Worktree inside repo tree | Main `git status` polluted; `git clean` destroys agent work | Place worktree outside repo tree (parent or sibling dir) |
| 5 | Two agents with overlapping file scope | Merge conflicts on PR | Assign file scope per agent before spawning — no overlaps |
| 6 | Missing push-before-DONE instruction | Commits lost on agent crash | Every spawn prompt must include "push branch before D:" |
| 7 | Spawning agents sequentially when tasks are independent | Wasted wall time | Spawn all independent builders in parallel in one turn |
| 8 | `git add -A` or `git add .` before commit | Untracked files from other builders pollute the commit (shared git object store) | Always `git add /abs/path/file1 /abs/path/file2` — stage named files only |
| 9 | Committing without verifying branch name | Work lands on wrong branch (e.g. main, another builder's branch) | Run `git branch --show-current` before staging; if wrong, `git checkout -b <correct-branch>` |
| 10 | Large SendMessage body (~2000+ chars) | Message silently not delivered — no error returned, recipient gets nothing | Write content to `./msg-to-lead.md` with Write tool; send short SendMessage: `"Full report at /abs/path/msg-to-lead.md — please read"`. Lead reads file directly. Use for Auditor Phase 1 reports, discovery summaries, multi-section findings. |

### Figma Section Nodes

When a Figma URL points to a section node:
1. Call `get_metadata` first to get the section's metadata
2. Parse child frame IDs from the metadata
3. Call `get_design_context` on each child individually

**Never pass a section node ID directly to a Builder** — it returns sparse metadata only, not design context. Builders will produce best-guess UI.

## Quick Reference Card

**File-writing agent (Builder, Tester) — single builder:**
1. `git worktree add /private/tmp/wt-[name] -b [branch] main`
2. Identify platform: `ios|android|web|backend|none`
3. Spawn teammate with worktree path, model, platform, and plan approval if needed

**Parallel builders — pre-create ALL worktrees first:**
1. `git worktree add /private/tmp/wt-[slug-a] -b [branch-a] origin/main`
2. `git worktree add /private/tmp/wt-[slug-b] -b [branch-b] origin/main`
3. (repeat for each builder)
4. Spawn all builders simultaneously — each with its own hardcoded absolute path
5. Every spawn prompt must include: `git -C /private/tmp/wt-[slug]` for ALL git commands
6. Every spawn prompt must include the CWD warning: "⚠️ CRITICAL: The Bash tool CWD does NOT persist between calls. NEVER run plain `git` — always use `git -C /path/to/worktree` for every single git command."

**Coordination-only agent (PM, Auditor reading code):**
1. Spawn teammate with main repo path and model
2. No worktree needed — no file writes to repo
3. PO interacts directly in teammate tab

**Agent working in a different repo (multi-repo pattern):**
1. Clone target repo outside harness tree (once per machine): `git clone git@github.je-labs.com:Org/repo.git /c/repo`
2. `git -C /c/repo worktree add /c/b-[agent-name] -b feature/[branch] main`
3. Spawn teammate with absolute worktree path `/c/b-[agent-name]`
See docs/investigations/MULTI-REPO-STRATEGY.md for full evaluation and rationale.
