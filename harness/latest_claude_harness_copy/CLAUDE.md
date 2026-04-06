## PROJECT
Name: TBD — PM discovers in M0
Repo: https://github.je-labs.com/grocery-and-retail-growth/testharness
Targets: TBD | Stack: .NET (ASP.NET Core) | Cloudinary (PDF storage) | DI: TBD | Tests: TBD
Specs: tasks/PRODUCT-BRIEF.md | ADRs: tasks/adr/

## BUILD + VERIFY
[lint]      # auto-fix formatting — fill in after M0 defines stack
[quality]   # static analysis — CI runs this
[test]      # zero failures required
[coverage]  # run at session start too

## SESSION START
0. **Runtime flags** — read `~/.claude/session-flags.env` (create with defaults if missing).
   Detect keywords in PO's opening message and update flags accordingly:
   - `🍯` or `swarm` → `HARNESS_MODE=swarm`
   - `🐝` or `worker` → `HARNESS_MODE=worker`
   - `🌻` or `release` → `HARNESS_UPSTREAM=release`
   - `🏠` or `hive` → `HARNESS_UPSTREAM=hive`
   - `debug` → `HARNESS_DEBUG=1`
   - `builder-model` → `EXPERIMENTAL_HARNESS_BUILDER_CHOOSE_MODEL=true`
   Write resolved values to `~/.claude/session-flags.env`. Emit startup line:
   `⚙️  session-flags: mode=<value>  upstream=<value>  debug=<on|off>  builder-model=<on|off>`
   Default file content (create if absent):
   ```
   HARNESS_MODE=worker
   HARNESS_UPSTREAM=hive
   HARNESS_DEBUG=0
   EXPERIMENTAL_HARNESS_BUILDER_CHOOSE_MODEL=false
   ```
   **Debug mode** (`HARNESS_DEBUG=1`): use verbose narration (explain each step as it runs, surface intermediate state), emit token counts at each stage, run stop-hook cost report at session end.
0b. **OTEL stack** — ensure local observability stack is running:
   ```bash
   # Use start script if present; fall back to docker compose directly
   if [[ -f harness/otel/otel-start.sh ]]; then
     bash harness/otel/otel-start.sh
   else
     (cd harness/otel && docker compose up -d --quiet-pull 2>/dev/null) \
       && echo "📊 OTEL stack running — Grafana: http://localhost:4000"
   fi
   ```
   Include in startup line: `📊 Grafana: http://localhost:4000`
   If Colima/Docker is not running, note it and continue (non-blocking).
1. Read LAUNCH-SCRIPT.md — previous session handoff
2. `git fetch origin`
   `git pull origin main`
3. `git log --oneline -20` — recent changes
4. Read `tasks/state.json` — live execution state (issue status, active worktrees, open PRs, blocked items)
   Read `tasks/MILESTONES.md` — milestone planning context (task list, issue mapping, dependencies)
5. If tasks/PRODUCT-BRIEF.md missing → spawn PM before feature work; M0 scaffold may proceed in parallel
6. Check active/blocked GitHub issues
7. Read harness/SYSTEM-KNOWLEDGE.md for relevant modules
8. Read relevant tasks/adr/ entries
8b. Read `harness/PO-DECISIONS.md` — active PO decisions that constrain implementation choices
9. Read harness/SKILLS-INDEX.md (load skills lazily)
   NOTE: Do NOT load harness/lessons.md at startup — it is append-only correction history (880+ lines), not reference material. Load SKILL-live-learning.md only when an L: event fires.
10. Read your role file from harness/roles/

## SESSION END
1. Queue or merge all session PRs — use `gh pr merge --merge --auto` for merge queue
2. Verify all open PRs are either merged, queued, or explicitly deferred (with reason)
3. Remove worktree directories then prune:
   `git worktree list | grep -E '/tmp|/private/tmp' | awk '{print $1}' | xargs -I{} git worktree remove --force {}`
   `git worktree prune`
4. Delete all merged remote branches:
   `git branch -r --merged origin/main | grep -v 'origin/main\|HEAD' | sed 's/.*origin\///' | xargs -r git push origin --delete`
   Skip any branch with an open PR — check `GH_HOST=github.je-labs.com gh pr list --state open --json headRefName` first.
4b. Review unmerged remote branches for stale/abandoned work:
   `git branch -r --no-merged origin/main | grep -v 'HEAD\|origin/main'`
   For each branch with no open PR and no recent activity: `git push origin --delete <branch>`.
   WARNING: squash-merged branches appear as unmerged — cross-reference against `gh pr list --state merged` before deleting.
5. `git checkout main && git pull origin main` — end every session on main, up to date
6. Commit or delete all untracked files
7. `git stash clear` — discard all stashes; stale WIP from closed branches accumulates quickly
8. Push all branches that have open PRs
9. Write build journal (docs/BUILD-JOURNAL.md), session record (docs/sessions/YYYY-MM-DD[letter].json per schema at docs/sessions/schema.md), and launch script (LAUNCH-SCRIPT.md)
   Build journal entry must include a `### Session metrics` table with: PRs merged/queued/deferred, issues created/closed, agent spawns (builders/auditors/other), L: count, S: count, spawn-to-D: ratio, B: rate, avg PR cycle time, coord overhead.
9b. Reset `~/.claude/session-flags.env` to defaults:
   ```
   HARNESS_MODE=worker
   HARNESS_UPSTREAM=hive
   HARNESS_DEBUG=0
   EXPERIMENTAL_HARNESS_BUILDER_CHOOSE_MODEL=false
   ```
10. Output session-end dashboard using this exact template:

```
╔══════════════════════════════════════════════════════════════════════╗
║  📋 SESSION-END DASHBOARD — YYYY-MM-DD                               ║
╠══════════════════════════════════════════════════════════════════════╣
║  Session health:  ████████░░  80%  │  Duration: ~Nh                  ║
╠══════════════════════╦═══════════════════════════════════════════════╣
║  🔀 PRs THIS SESSION ║                                               ║
╠══════════════════════╣                                               ║
║  ✅ #N  title        ║  merged                                       ║
║  🔄 #N  title        ║  in merge queue                               ║
║  🟡 #N  title        ║  open — awaiting review                       ║
║  ❌ #N  title        ║  closed without merge — reason                ║
╠══════════════════════╬═══════════════════════════════════════════════╣
║  🎫 ISSUES THIS SESSION                                              ║
╠══════════════════════╣                                               ║
║  ✅ #N  title        ║  closed                                       ║
║  🔄 #N  title        ║  PR in queue                                  ║
║  🟡 #N  title        ║  open                                         ║
║  ❌ #N  title        ║  deferred — reason                            ║
╠══════════════════════╩═══════════════════════════════════════════════╣
║  📊 SESSION STATS                                                    ║
╠══════════════════════════════════════════════════════════════════════╣
║  ✅ PRs merged          │  N                                         ║
║  🔄 PRs in queue        │  N                                         ║
║  🟡 PRs still open      │  N                                         ║
║  🎫 Issues created      │  N                                         ║
║  ✅ Issues closed       │  N                                         ║
║  🤖 Agent spawns        │  N  (builders: N, reviewers: N, other: N)  ║
║  📚 Lessons encoded     │  N                                         ║
║  🤖 Spawn-to-D: ratio   │  N/N (N%)                                  ║
║  🚫 B: rate             │  N/N (N%)                                  ║
║  ⏱️  Avg PR cycle time    │  Nh Nm                                     ║
║  🔄 Avg loops/PR          │  N.N                                       ║
║  📊 Coord overhead      │  ~N%  (target <15%)                        ║
║  💪 vFTE hours            │  N.N h  (efficiency: N.Nx)                 ║
╠══════════════════════════════════════════════════════════════════════╣
║  ⚠️  ITEMS NEEDING PO ACTION                                         ║
╠══════════════════════════════════════════════════════════════════════╣
║  • [Submodule PRs needing manual close — or "None"]                  ║
║  • [Deferred items with explicit reasons — or "None"]                ║
║  • [Any open issues that require product decision]                   ║
╠══════════════════════════════════════════════════════════════════════╣
║  🚀 NEXT SESSION PRIORITY                                            ║
╠══════════════════════════════════════════════════════════════════════╣
║  1. [Highest priority — merge queued PRs, then urgent issues]        ║
║  2. [Next priority]                                                  ║
║  3. [Continue milestone work]                                        ║
╚══════════════════════════════════════════════════════════════════════╝
```

Use this EXACT template. Do not invent a different format.
Data sources: `gh pr list`, `gh issue list`, `git log --oneline -10`, `harness/lessons.md` (last session block).
Progress bar: 10% per PR merged (██ filled, ░░ empty, 10 segments). Box-drawing characters required — ASCII dashes are wrong.

## ARCH RULES
- Layer: presentation → domain ← data
- No cross-feature imports
- Interface everything: storage, network, AI
- Platform stubs for all targets
- Patterns: repository, use-case, observable state
- New backend services: scaffold via Sonic (`https://sonic.production.jet-internal.com/scaffold`) before building.

## DISPATCH
Agents run as **Claude Code Agent Teams teammates** — full independent Claude Code sessions that the PO can interact with directly (paste images, text, transcripts into agent tabs). Requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` in settings (already configured). PO navigates between teammates with Shift+Down (in-process) or click (split panes via tmux/iTerm2). All role-based work (Builder, Reviewer, Architect, PM, Tester, Auditor) uses teammates. Sub-agents are reserved only for trivial self-contained lookups within Lead's own response. One coroutine/async scope per layer, never shared across layers.

### Spawn Sequence (mandatory for all role-based work)
1. **TeamCreate** — registers the teammate with name, model, and role
2. **Agent(team_name=...)** — launches the teammate with task instructions and working directory

Both steps are REQUIRED. Skipping TeamCreate and calling Agent alone creates a sub-agent (invisible to PO, blocks Lead) — not a teammate.

**One team per session.** Lead can only manage one team at a time. All concurrent builders (and all other role-based agents) must be spawned as named teammates within that single team. Never call TeamCreate more than once per session — subsequent calls will fail with "A leader can only manage one team at a time."

WARNING: `run_in_background: true` on Agent tool causes 401 auth failures — never use it for role-based agents.

**Builder lifecycle — CONFIRMED-D: required before CLOSE::** Lead does NOT send CLOSE: on D: alone. Wait for CONFIRMED-D: (merge queue confirmed). Queue merge on D:, then wait for CONFIRMED-D:, then send CLOSE:. Builder shuts down only after receiving CLOSE:.

**Worktree isolation (CC v2.1.49+):** `isolation: "worktree"` now works natively — each builder gets its own worktree automatically. Manual `/private/tmp/` pre-creation remains valid for cases requiring explicit branch control. Native isolation is the preferred default. `.claude/worktrees/` is gitignored for CC-managed worktrees.

**Stack check (mandatory pre-spawn):** confirm target stack is documented before spawning any implementation builder. If undocumented, ask the PO.

**Model triage (mandatory pre-spawn when EXPERIMENTAL_HARNESS_BUILDER_CHOOSE_MODEL=true):** Lead selects the model before every builder spawn. Include `Model: <model> — <reason>` in the spawn prompt. Default to Haiku; escalate to Sonnet only when one of these applies:
- Task requires defining new interfaces or ADRs
- Cross-cutting change affecting 3+ features or layers
- Security-sensitive (auth, secrets, input validation)
- Spec is ambiguous — builder must resolve it, not just implement
- Previous builder sent `B:` on this task
- Issue labeled `complexity:high`, `architecture`, or `security`
All other tasks (implement-to-spec, tests, lint, config, docs, harness scripts) → Haiku.

**HARNESS_AGENT_TYPE injection (mandatory):** Before spawning any agent, write a `.claude/settings.json` to the worktree root with the agent's role so hooks report the correct label:
```bash
# builder
echo '{"env":{"HARNESS_AGENT_TYPE":"builder","OTEL_RESOURCE_ATTRIBUTES":"agent.role=builder"}}' \
  > /private/tmp/<worktree>/.claude/settings.json
# reviewer → "reviewer" | tester → "tester" | architect → "architect"
```
For native-isolation worktrees (CC v2.1.49+), write to the auto-created worktree path before sending G:.

**Ticket-first rule (mandatory for ALL work):** Create a GitHub issue before spawning any implementation builder — feature or harness. The builder's spawn prompt must include the issue number. The PR body must reference the issue. No exceptions.

**Issue repo rule:** shippable issues (bugs, features, refactors, investigations with a defined output) must be created in the relevant submodule repo (iOS/JustEat, Android/app-core, consumer-web, etc.) — not in testharness. Harness issues are for harness infrastructure only (CLAUDE.md, skills, roles, tooling). See harness/SYSTEM-KNOWLEDGE.md#issue-ownership.

## FEATURE FLAGS (JetFM)

Every new user-facing feature must be gated behind a JetFM feature flag. No feature ships without a kill switch.

Protocol: create flag in JetFM → gate code at entry point → default off → enable via Sonic.

See `harness/skills/SKILL-jetfm-feature-flags.md` for the full Builder protocol and PR checklist.

## STATE
TBD — Architect defines in M0.
Banned: shared mutable state without synchronization; global singletons with side effects.

## CODE RULES
- No magic numbers (bare OK: 0, 1, -1, 2)
- No TODO without issue reference
- No commented-out code
- No println/console.log — use project logger
- No force-unwrap/!! — handle nullability explicitly
- No wildcard imports
- No @Suppress without explanation
- No catch-all exceptions — specific types only
- No hardcoded strings — use resource files
- Max 40 lines/fn | Cyclomatic complexity ≤10 | Max 6 params
- No speculative code — only implement what the current ticket explicitly requires (YAGNI)

## SECURITY
- No PII in logs
- No credentials in source — env/secrets manager only
- All network over TLS
- Validate all external input at system boundaries
- Secrets: see harness/setup/SECRETS-INJECTION.md — never add secrets to any tracked file

## BRANCHES + PR MERGE
- main: never commit directly
- Branch: feature/[name] | fix/[desc] | design/[name] | harness/[desc]
- PR ≤400 lines preferred

### Submodule pointer commits
When builders advance work on a submodule feature branch (iOS, Android, web), the testharness submodule pointer must be updated per milestone checkpoint and committed to testharness with:
```
chore(submodule): update ios to abc1234
chore(submodule): update android to def5678
chore(submodule): update consumer-web to ghi9012
```
Use the Write tool to write the commit message to `./commit-msg.txt`, then `git commit -F ./commit-msg.txt && rm -f ./commit-msg.txt`.
Full workflow: see [harness/rules/WORKFLOW-SUBMODULE.md](harness/rules/WORKFLOW-SUBMODULE.md)

### Merge Queue

`main` is protected by a GitHub merge queue (ruleset ID 831, enabled 2026-03-20). All PRs targeting `main` must go through the queue — direct merges are blocked.

**Builder workflow (Track 1 and Track 2):** push branch, open PR, then add to the merge queue via the GitHub UI ("Add to merge queue" button) or:
```bash
gh pr merge <PR-number> --hostname github.je-labs.com --merge --auto
```
The queue auto-rebases each PR against the updated main in order, then merges. No manual rebase needed for parallel builders working in separate worktrees.

**Lead Track 1 workflow:** Lead still merges Track 1 (docs-only) PRs directly via `--auto` flag — the queue handles ordering. Do NOT use `gh pr merge --squash` for Track 1; use `gh pr merge --merge --auto` instead so the queue processes it.

**Parallel builder conflicts:** when multiple builders touch the same file, the merge queue serialises their PRs automatically. Builders do not need to rebase manually — the queue will rebase each PR before merging. If a PR cannot be automatically rebased (genuine line-level conflict), the queue ejects the PR and the builder must resolve the conflict manually.

### Beehive Build Protocol

Every builder spawn prompt must declare a mode and an upstream param.

**`swarm` (🍯):** Full agent swarm — multiple builders in parallel, auto-continue after each `CONFIRMED-D:`. Always used for harness work. Optionally used for milestones. Builder names: `🍯b-[slug]`.

**`worker` (🐝):** Single issue, slow and steady. Builder completes one task, sends `D:`, and waits. Lead displays dashboard and waits for PO input before assigning the next task. Builder names: `🐝b-[slug]`.

**Upstream param (default: `🏠`):**
- `🏠` — hold in hive. No upstream PR opened. Work stays local until Lead sends `👑`. Default for all work.
- `🌻` — release to sunflower. Upstream PR opens on task completion.

**Harness work is always `swarm` + `🏠`.** No exceptions.

Poll cap rule (both modes): max 2 minutes (12 × 10s polls). If queue has not confirmed by then, send `B:` to Lead and stop.

### Two-Track Merge Model

> Merge ownership rules: see [harness/rules/MERGE-OWNERSHIP.md](harness/rules/MERGE-OWNERSHIP.md)

## AGENT TEAM
Max 6 concurrent (evidence-based; escalate to PO for exceptions). All worktrees OUTSIDE repo tree.
**Parallel-first:** Spawn all independent builders simultaneously. Never sequence unless hard data dependency exists between tasks.
**Agent name prefixes (mandatory):** `🍯b-[slug]` Swarm Builder | `🐝b-[slug]` Worker Builder | `a-[slug]` Auditor | `r-[slug]` Reviewer | `t-[slug]` Tester. PO reads names in the team pane — use short, scannable slugs.

| Role | Name prefix | Model | Scope |
|------|-------------|-------|-------|
| Lead | (none) | Opus | Coordination only — never writes code, never merges |
| PM | pm-[slug] | Haiku/Opus | Product discovery, milestone definition |
| Architect | arch-[slug] | Opus | Interfaces, ADRs — 2 milestones ahead of Builders |
| Builder (swarm) | 🍯b-[slug] | Sonnet | Parallel implementation — harness always, milestones optionally |
| Builder (worker) | 🐝b-[slug] | Sonnet | Single-issue implementation — one task, then pause |
| Reviewer | r-[slug] | Sonnet | Review only — never merge |
| Tester | t-[slug] | Haiku/Sonnet | Integration/acceptance tests only |
| Auditor | a-[slug] | Haiku/Opus | Audit + implement: Phase 1 reports findings, Phase 2 implements after PO approval |
| QE | qe-[slug] | Sonnet/Opus | Requirement challenges, BDD scenarios, observability spec — pre-builder gate |
| Contract Tester | ct-[slug] | Haiku/Sonnet | API contract verification per PR — triggered by Reviewer |
| Integration Tester | it-[slug] | Sonnet/Opus | Post-merge full-staging BDD + observability gate |
| Security Researcher | sec-[slug] | Opus | Pre-Builder on `security-sensitive` tickets; STRIDE threat model, blocks Builder until R: all-clear |
| Security Reviewer | sec-[slug] | Sonnet | Milestone completion gate + 👑 gate; reviews full milestone diff against threat models |

## Settings and Configuration

**Timestamp injection:** `~/.claude/hooks/inject-timestamp.sh` runs on `UserPromptSubmit` and injects `Current time: YYYY-MM-DD HH:MM:SS TZ (UTC equivalent)` as `additionalContext` into every agent prompt. No manual date input needed — every session has precise time-of-day context automatically. Registered in `~/.claude/settings.json` under `hooks.UserPromptSubmit`.

**Project `.claude/settings.json` must contain env vars only — never add a permissions block.** Project-level `permissions.allow` replaces (not merges with) the global `~/.claude/settings.json` allow array. A narrow project-level allowlist shadows the global `Bash(*)` wildcard, causing permission prompts for all commands in agent worktrees. Keep project settings minimal; rely on the global allowlist.

**MCP server config belongs in `.mcp.json`** (project root) — NOT `.claude/settings.json`. The `mcpServers` key is not valid in `settings.json` and is silently ignored. Add `.mcp.json` to `.gitignore` for personal/local servers; commit it for team-wide servers.

**`bypassPermissions` is permanently disabled.** `disableBypassPermissionsMode: "disable"` is set in `~/.claude/settings.json`. Spawning agents with `mode: "bypassPermissions"` is a no-op — it does NOT bypass the allow list. The global allow list is the only permission model. Every tool an agent uses must be explicitly listed. On macOS, `Glob` and `Grep` require `Glob(/private/tmp/**)` and `Grep(/private/tmp/**)` entries in addition to the `**` wildcards (macOS resolves `/tmp` → `/private/tmp`; path matching is not symlink-aware).

**Spawn prompts must use absolute file paths.** `Read(**)` in the allow list is anchored to the main project root. When a builder in a worktree reads a relative path like `harness/foo.md`, Claude Code cannot match it against `Read(/private/tmp/**)` and prompts the PO. All file paths in spawn prompts must be absolute: `/private/tmp/wt-[name]/harness/foo.md`. Include an explicit rule in every spawn prompt: "All file reads and writes must use absolute paths."

## COMMUNICATION DSL
| Prefix | Meaning | Receiver action |
|--------|---------|----------------|
| I: | State update | Read only |
| R: | Discovery done | Lead: G or H |
| G: | Execute | Agent: begin |
| H: | Wait | Agent: pause |
| B: | Blocked | Named agent: resolve |
| D: | Complete | Lead: verify |
| A: | Decision needed — any agent sends to Lead; Lead forwards to PO if needed | Lead: respond or escalate |
| V: | PR opened | Reviewer: pick up immediately |
| F: | Fixes pushed, ready for re-review | Reviewer: pick up immediately |
| E: | PO decision | Lead: facilitate |
| L: | Pattern identified | Capture in harness ≤5 min |
| `S:` | Coding standard identified (platform-specific) | Encode in `standards/[platform].md` |
| CHECKPOINT: | Session context re-anchor at 2-hour mark, AND cost circuit breaker alert when agent spawn thresholds are exceeded (see ROLE-LEAD.md#cost-circuit-breaker) | All agents: read and re-orient |
| CONFIRMED-D: | Builder sends after merge queue confirms PR merged | Lead: send CLOSE: in response |

### Lead-only signals
| Prefix | Meaning | Receiver action |
|--------|---------|-----------------|
| `ASSIGN:` | Explicit task assignment to named agent | Agent: begin assigned task |
| `SCALE:` | Spawn N additional agents of a role | Lead executes spawn |
| `AUDIT:` | Trigger audit of specified scope | Auditor: begin investigation |
| `MERGE:` | Lead merging a Track 1 PR (docs/harness) | Record only — Lead action |
| `CLOSE:` | Agent shutdown with lifecycle record | Named agent: acknowledge and shut down |
| `👑 [platform]` | Authorize upstream PR for the named platform — overrides `🏠` hold. Requires explicit PO instruction. Lead NEVER sends `👑` on own judgment. After `👑`, Track 2 rules apply (adversarial review, human merges, `gh pr merge --auto` unavailable on platform repos). | Builder: open upstream PR, Track 2 rules from this point |

No filler. No preamble. No restatement. Diffs not prose for code changes.

## LEAD DSL
Short commands for efficient PO → Lead communication. Lead executes immediately on receipt.

### Spawn
| Command | Action | Example |
|---------|--------|---------|
| `swarm: [task\|milestone]` | Spawn swarm builders (🍯) — parallel, auto-continue | `swarm: milestone M6`, `swarm: harness` |
| `worker: [task\|#N]` | Spawn worker builder (🐝) — single issue, pause after | `worker: fix login bug`, `worker: #593` |
| `arch: [task]` | Spawn architect | `arch: design M6 interfaces` |
| `review` | Spawn reviewer (auto-picks unreviewed PR) | `review` |
| `test: [scope]` | Spawn tester | `test: M5.5 acceptance` |
| `pm: [scope]` | Spawn PM agent | `pm: M6 hero timing` |
| `audit: [scope]` | Spawn auditor/builder to audit scope | `audit: skills`, `audit: coverage`, `audit: suppressions` |
| `security: [scope]` | Spawn Security Researcher for adversarial audit | `security: storage`, `security: full`, `security: android` |

### Workflow
| Command | Action | Example |
|---------|--------|---------|
| `merge #N` | Merge PR (builder does it, or Lead for harness-only) | `merge #606` |
| `validate [milestone]` | Spawn validation agent | `validate m5.5` |

### Status
| Command | Action | Example |
|---------|--------|---------|
| `dashboard` | Full status refresh | `dashboard` |
| `prs` | Open PRs with review status | `prs` |
| `issues` | Issue backlog | `github issues` |
| `status` | One-line summary | `status` |

### Control
| Command | Action | Example |
|---------|--------|---------|
| `go` | Approve / unlock | `go` |
| `no` | Reject | `no` |
| `skip` | Skip item | `skip` |
| `defer [issue]` | Defer work | `defer #602` |
| `shut down` | Session shutdown | `shut down` |

### Memory
| Command | Action | Example |
|---------|--------|---------|
| `remember: [rule]` | Full lifecycle: (1) Claude memory, (2) harness/lessons.md, (3) apply to relevant harness file, (4) spawn builder to commit+PR | `remember: always run kover at session start` |
| `never: [anti-pattern]` | Same full lifecycle as `remember:` | `never: let PRs idle >30min unreviewed` |
| `always: [pattern]` | Same full lifecycle as `remember:` | `always: spawn reviewer on DONE` |

**`remember:` is not complete until the harness file is updated and a PR is open.** Claude memory alone does not persist across agent spawns — only repo files do. All 4 steps are required.

## DISCOVERY GATE
No code before discovery complete + Lead GO.
```
DISCOVERY: [TASK-ID]
READ: [files read]
UNDERSTAND: [2-3 sentences]
UNKNOWNS: [list or NONE]
PLAN: [checklist]
R: yes | blocked:[reason]
```
Self-GO: trivial (<50 lines, single file, no new interfaces) — include `SELF-GO:` line.

## SPEC CHAIN + TDD
spec → interface → failing test → implementation → CI green
- Builder reads tests not spec
- Test names = spec language
- Fakes over mocks — see harness/TDD-STANDARDS.md for fake/contract test patterns
- NEVER change test to make build pass unless test was provably wrong

## WRITE vs EDIT
Use **Edit** for any file that already exists. Use **Write** only to create new files.
Never use Write to overwrite an existing file — it triggers an interactive confirmation prompt that blocks the session.

## COMMIT
`type(scope): description`
Types: feat | fix | test | refactor | docs | chore | harness
For Co-Authored-By trailers:
1. Use Write tool to write commit message to ./commit-msg.txt (inside worktree)
2. `git commit -F ./commit-msg.txt && rm -f ./commit-msg.txt`
Never use `git commit -m "$(cat <<'EOF'...)"` — triggers security prompt regardless of allowlist.
Never use printf to write the file — use the Write tool instead.

## VERIFICATION GATE
Before D:
1. Run tests — zero failures
2. Run coverage — must meet or exceed baseline
3. Verify each acceptance criterion
4. `git diff main` — self-review
5. "Would a staff engineer approve?" — if no, fix first
SELF-AUDIT block required in every D: message.

## LOOP DETECTION
- Same function modified 3+ times → stop and reassess
- 10+ tool calls without DONE/BLOCK → pause and assess

## ESCALATE TO PO WHEN
- Product judgment not in spec
- Spec contradiction
- Blocker after 3 attempts
- Builder + Reviewer disagree
