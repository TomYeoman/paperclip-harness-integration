# Harness: An AI Agent Orchestration System

> Internal overview for Anthropic reviewer. Written March 2026.
> 22+ sessions · 350+ commits · 240+ PRs

---

## What This Is

This repository is an agent orchestration harness for coordinating multi-agent Claude Code teams on real software projects. The core problem it solves: when you scale beyond a single Claude Code session — running multiple agents in parallel on different tasks — you need structure that survives context compaction, cross-session handoffs, agent crashes, and the entropy that accumulates when many independent actors share a codebase.

The harness is not a framework in the traditional sense. It is a set of rules, roles, communication protocols, and workflows encoded into files that Claude Code loads automatically (`CLAUDE.md`, role files, skill files). The "infrastructure" is conventions: how agents identify themselves, how they signal state changes, how lessons are encoded, how sessions start and end. A human (the Product Owner) interacts with the Lead agent in plain English using a compact DSL; the Lead orchestrates a team of specialist agents that never require direct PO interaction except when the PO chooses to engage them in their own tabs.

The harness was originally scaffolded to support a specific product (a loyalty pricing feature for a grocery/retail multi-platform app), but its orchestration layer is product-agnostic. Every rule in it traces back to a real failure that happened during development.

---

## Architecture

### Agent Team Structure

```
                        ┌─────────┐
                        │   PO    │  (human)
                        └────┬────┘
                             │ LEAD DSL commands
                             ▼
                        ┌─────────┐
                        │  Lead   │  Opus · coordination only · never writes code
                        └────┬────┘
          ┌──────────────────┼──────────────────────┐
          ▼                  ▼                       ▼
    ┌──────────┐      ┌────────────┐         ┌──────────────┐
    │   PM     │      │  Architect │         │   Auditor    │
    │ Haiku/   │      │   Opus     │         │  Haiku/Opus  │
    │  Opus    │      │ 2 milestones│        │ audit+impl   │
    └──────────┘      │   ahead    │         └──────────────┘
                      └────────────┘
          ┌─────────────────┬──────────────────┐
          ▼                 ▼                  ▼
    ┌──────────┐     ┌──────────┐       ┌──────────┐
    │ Builder  │     │ Builder  │       │ Reviewer │
    │ Sonnet   │     │ Sonnet   │       │ Sonnet   │
    │ worktree │     │ worktree │       │          │
    └──────────┘     └──────────┘       └──────────┘
          │                 │
          ▼                 ▼
    feature/auth      feature/cart
    (git worktree)    (git worktree)
```

Each Builder works in an isolated **git worktree** outside the main repo directory. All worktrees are sibling directories (`../b-feature-auth`, `../b-feature-cart`), never inside the repo tree. This prevents one agent's git operations from affecting another's working state.

### File Layout

```
testharness/
├── CLAUDE.md                    # Dense agent reference — auto-loaded every session
├── CLAUDE-HUMAN.md              # Human-readable version of the same content
├── LAUNCH-SCRIPT.md             # Session handoff — Lead reads on startup
├── harness/
│   ├── roles/                   # ROLE-LEAD.md, ROLE-BUILDER.md, etc.
│   ├── skills/                  # Lazy-loaded skill files (session shutdown, PR workflow, etc.)
│   ├── context/                 # Per-role CLAUDE.md slices (loaded only in that role's context)
│   ├── rules/                   # MERGE-OWNERSHIP.md, etc.
│   ├── lessons.md               # Append-only correction log
│   └── SYSTEM-KNOWLEDGE.md      # Live module status, known gotchas
├── docs/
│   ├── architecture/            # Human-reference architecture docs (not loaded into agents)
│   └── BUILD-JOURNAL.md         # Session-by-session narrative log
└── tasks/
    ├── MILESTONES.md            # Source of truth for project progress
    └── PRODUCT-BRIEF.md         # Product vision and scope
```

### Session Lifecycle

```
Session Start
  1. Lead reads LAUNCH-SCRIPT.md (previous handoff)
  2. git pull, git log
  3. Read MILESTONES.md, check GitHub issues
  4. Model audit gate (verify every active agent is on correct model)
  5. Spawn agents

Active Work
  Lead ──G:──► Builder (in worktree)
  Builder ──R:──► Lead (discovery done, plan ready)
  Lead ──G:──► Builder (proceed)
  Builder implements, pushes branch
  Builder ──V:──► Lead (PR opened)
  Lead (same turn) ──G:──► Reviewer (adversarial review)
  Reviewer ──feedback──► Builder (via SendMessage)
  Builder fixes, pushes
  Builder ──D:──► Lead (complete)
  Lead displays dashboard, PO merges in GitHub UI

Session End
  1. Build Journal entry
  2. Lessons written (harness/lessons.md)
  3. Harness improvement issue filed
  4. Launch Script written (overwrites — not appended)
  5. Commit all deliverables, push, open PR
  6. Clear session overrides in role files
  7. Worktree cleanup
```

### Communication DSL

Agents communicate using a single-letter prefix protocol that tells the receiver what action to take. The full set:

| Prefix | Meaning | Receiver action |
|--------|---------|----------------|
| `I:` | State update | Read only |
| `R:` | Discovery done | Lead: G or H |
| `G:` | Execute | Agent: begin |
| `H:` | Wait | Agent: pause |
| `B:` | Blocked | Named agent: resolve |
| `D:` | Complete | Lead: verify + dashboard |
| `A:` | Decision needed | Lead: respond or escalate to PO |
| `V:` | PR opened | Lead: spawn Reviewer immediately (same turn) |
| `L:` | Pattern identified | Lead: encode in harness ≤5 min |

Plain text output from an agent is **not** delivered to Lead or other teammates — only `SendMessage` reaches them. This was a painful discovery made on session 3 (see Lessons).

### Two-Track Merge Model

- **Track 1 (harness/docs):** Lead merges directly using `gh pr merge --merge --auto`. No Reviewer needed. Builder shuts down same turn.
- **Track 2 (production code):** Human (PO) merges in GitHub UI. No agent merges or approves. Self-approval is blocked on the GitHub Enterprise setup used here.

A GitHub merge queue (enabled on `main`) serialises all PRs through the queue, auto-rebasing each against the updated main before merging. Parallel builders do not need to coordinate rebases manually — the queue handles ordering.

### Skills System

Skills are lazy-loaded Markdown files (`harness/skills/`) covering reusable workflows: session shutdown, PR review, agent spawn, worktree isolation, external doc ingestion, course correction, etc. `SKILLS-INDEX.md` is the lookup table; agents load only the skill relevant to their current task. This keeps agent context windows small.

---

## Key Design Decisions

### 1. CLAUDE.md as the config file

Every Claude Code session loads `CLAUDE.md` automatically. Making it the harness configuration file means agents bootstrap with full context without any explicit loading step. There are two versions: `CLAUDE.md` (dense reference, ~200 lines, auto-loaded) and `CLAUDE-HUMAN.md` (prose explanations for humans). Any change to one must be reflected in the other.

The tension: CLAUDE.md competes with the project codebase for context window. The harness went through a dedicated token efficiency audit (session 2026-03-18, 14 issues) that eliminated ~2,600 tokens/session of redundancy — deduplicating role files, archiving completed milestones, splitting per-platform builder content into separate files loaded only when the relevant platform is active.

### 2. Agent Teams, not sub-agents

Early sessions spawned role-based agents as background sub-agents. This was wrong for several reasons: they shared Lead's context window (consuming Lead's tokens), ran serially (blocking Lead), had no user input surface (PO could not paste images or answer questions directly), and lost auth context (causing `401` errors on GitHub API calls).

The correct pattern — using Claude Code Agent Teams (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`) — gives each agent its own full Claude Code session with its own terminal, its own token budget, and a tab the PO can interact with directly. The spawn sequence requires two steps: `TeamCreate` (registers the teammate) then `Agent(team_name=...)` (starts it). Skipping `TeamCreate` silently creates a sub-agent instead of a teammate — a bug that was hit multiple times before being encoded.

### 3. Worktrees outside the repo tree

Claude Code's built-in `isolation: "worktree"` places worktrees inside the repo directory (`.worktrees/`). This causes contamination: `git status` in the main repo shows every agent's uncommitted work, `git clean` deletes another agent's files, branch switches affect everyone. The harness creates worktrees manually as sibling directories outside the repo. Every agent verifies `pwd` and `git rev-parse --show-toplevel` before any git operation — if either output is wrong, the agent stops and notifies Lead.

### 4. The merge queue solves parallel conflicts

Parallel builders inevitably touch the same files. The initial approach was to pre-assign exclusive file ownership before spawning — this was rejected by the PO as over-engineering that blurred issue boundaries. The merge queue is the right solution: it serialises all PRs through a rebase against updated main before merging. Builders work on separate branches with full issue scope; the queue handles ordering.

### 5. The enforcement hierarchy

LLM context has a "Lost in the Middle" problem: corrections made mid-session are forgotten after 20+ more messages. The harness uses a layered enforcement hierarchy, from most to least reliable:

1. Tool-level deny (settings.json allowlist) — mechanical block, 100% reliable
2. NON-NEGOTIABLE block at top of spawn prompt — primacy position, seen fresh by each new agent
3. `CLAUDE.md` rules — reloaded after context compaction, persistent across sessions
4. `harness/lessons.md` — encoded corrections that carry across session boundaries
5. Verbal corrections — compressed away; least reliable

When a pattern is identified (an `L:` event), it must be encoded at levels 3 and 4 within 5 minutes — verbal acknowledgement alone is not sufficient.

### 6. Lead never writes code

Lead is coordination-only. This means no file edits, no merge conflict resolution, no codebase reading on behalf of builders. The constraint is hard because violations are tempting when "it would be faster for Lead to just fix it." The rule exists because: (a) it enforces proper context isolation — Builders have their own discovery process, (b) it prevents Lead from consuming context window reading implementation details, and (c) it creates a paper trail (every file change has a Builder's worktree and PR behind it).

This rule was violated twice in early sessions (merge conflict resolution). Both violations were immediately corrected and encoded.

### 7. Settings.json layering — project vs global

Project-level `.claude/settings.json` with a `permissions.allow` block **replaces** (does not merge with) the global `~/.claude/settings.json`. A narrow project-level allowlist silently shadows the global `Bash(*)` wildcard, causing permission prompts on every command in every agent worktree. The fix: project settings contain env vars only (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`); permission management lives in global settings. This was discovered after causing a session-wide permission prompt storm.

---

## What We Learned

### Parallelism

**What didn't work first:** Sequential agent spawning. Early sessions spawned builders one at a time, waiting for each to finish before starting the next. A `parallel-first` rule was encoded after PO feedback: all independent builders spawn in a single response turn, no exceptions.

**What didn't work second:** Pre-assigning exclusive file ownership to prevent merge conflicts between parallel builders. This blurred issue scope (one builder ended up implementing another's changes) and was rejected. The right model: builders each own their issue's scope; the merge queue serialises conflicts at merge time.

**What works:** Spawning 4-6 builders simultaneously, each in their own worktree, all working on separate GitHub issues. The merge queue handles ordering. One builder per issue (never bundled) keeps PRs small and reviewable.

### Agent Communication

**Agent text output is not delivered to Lead.** This was discovered on session 3 when an Auditor completed its work and reported via plain text — Lead received idle notifications but no report and had to respawn the agent. Every spawn prompt now includes: "Your text output is NOT visible to Lead or other teammates. You MUST use the SendMessage tool to communicate."

**The relay anti-pattern.** Early sessions had PM and Architect relay all questions to PO through Lead. This made conversations feel indirect and slow. It turned out agent text output IS visible to the PO directly in the agent's tab — the relay was unnecessary. PM and Architect now conduct Q&A directly; Lead only handles coordination (tickets, PRs, spawning).

**One question at a time.** PM agents that batch multiple questions create cognitive overload. The protocol: one question per SendMessage, no batching.

### Session Continuity

**Verbal corrections don't stick.** A correction mid-session is forgotten after ~20 messages. Every correction must be encoded into `harness/lessons.md` and the relevant role/skill file within 5 minutes. Batching lessons for session end was tried — lessons were lost when sessions ended unexpectedly. The lesson about batching was itself lost this way.

**Launch Script as handoff artifact.** The most reliable continuity mechanism across sessions is the `LAUNCH-SCRIPT.md` file — overwritten (not appended) at every session end with a full state snapshot: open PRs, blocked issues, remaining milestone tasks. It is the first thing Lead reads at session start.

**Verify before encoding.** A wrong lesson is worse than no lesson because it gets followed. One session encoded a lesson saying `ToolSearch` would make `AskUserQuestion` available to PM agents — this was wrong (`AskUserQuestion` doesn't exist in agent contexts at all). The incorrect lesson was committed and followed for two sessions before a correction was written above it.

### Permissions and Security

**The `&&` command pattern triggers security prompts.** `cd /path && git command` is flagged as a potential bare repository attack by Claude Code's security model, causing permission prompts on every call. The fix: use `git -C /path command` or separate Bash calls.

**Heredoc with `#` lines triggers Category B security prompts.** Multi-line bash content containing `#`-prefixed lines inside command substitution (`$(cat <<'EOF'...))`) triggers a security pattern check regardless of allowlist entries. The fix: write body content to a file using the Write tool, then reference the file.

**`run_in_background: true` loses auth.** Background agents do not inherit the session's auth context — `gh` CLI calls return 401. Foreground Agent Teams teammates inherit auth correctly.

### Scope Discipline

**One builder per issue.** Early sessions grouped related issues into a single builder to "save spawns." This created large PRs that were hard to review, made it impossible to close issues independently, and violated the ≤400 line PR size guideline. The rule is now absolute: one GitHub issue = one builder = one PR.

**Auditor Phase 2 scope creep.** After an audit, Auditors were modifying files they had read for context, not just the files in their task scope. These extra modifications conflicted with parallel builders' work. The rule: before Phase 2 commit, `git diff --name-only` and verify every file is in task scope.

**Lead fetching tickets before passing to Builders.** Lead was fetching Jira ticket details itself before spawning builders. PO: "why are you gathering instead of telling the builder to gather?" Lead passes the ticket URL to the Builder. Builder does all discovery.

### Model Selection

**Model must be set on the Agent tool, not in the prompt.** Writing "Model: claude-sonnet-4-6" inside the spawn prompt text is a no-op — the agent inherits Lead's model. The `model` parameter must be set on the Agent tool call: `Agent(team_name="b-auth", model="sonnet", ...)`.

**Opus costs ~15× Haiku.** Running Tester, PM, or Auditor agents on Opus without justification is a budget-burn event. The session-start model audit catches this before work begins.

---

## What's Next

_To be filled in by another agent._
