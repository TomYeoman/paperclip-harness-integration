# Lessons Archive — Superseded Entries

> Entries moved here from harness/lessons.md when their STATUS was confirmed SUPERSEDED.
> These entries describe approaches that were explicitly reversed or replaced by later sessions.
> Do NOT follow these — they are archived for historical context only.
> Active lessons: harness/lessons.md

---

## *2026-03-13* • *LEAD* — PM subagent went idle instead of using AskUserQuestion
*WHAT_I_DID:* Spawned a PM subagent for discovery. It went idle instead of asking the user questions.
*WHAT_WAS_WRONG:* PM subagent pattern does not work for interactive discovery — subagents cannot reliably prompt the user in that context.
*CORRECTION:* PM subagent pattern abandoned for interactive discovery. Lead conducts discovery directly when no external Jira/Figma access is available.
*PATTERN:* Do not spawn PM as a subagent for interactive discovery. Lead conducts discovery directly, or use Agent Teams teammate with direct PO tab access.
*STATUS: SUPERSEDED — by 2026-03-18 LEAD entry: agent text IS visible in agent tab; PM asks questions as plain text output directly, relay through Lead unnecessary*

---

## *2026-03-13* • *LEAD* — Lesson write skipped at session end
*WHAT_I_DID:* Verbally noted a lesson during the session but never wrote it to lessons.md. The lesson was lost.
*WHAT_WAS_WRONG:* Lessons queued for "later" are at risk if the session ends before they're written — exactly what happened here.
*CORRECTION:* This entry is the correction for the missed lessons.md write — written now as part of formal shutdown.
*PATTERN:* Lesson writes are NOT optional. If the shutdown protocol is skipped or compressed, lessons are lost. Treat harness/lessons.md write as a hard gate before any commit at session end.
*STATUS: SUPERSEDED — by 2026-03-20 LEAD entry: lesson must be written at the moment the L: signal fires, not deferred to session end; spawn builder immediately*

---

## *2026-03-17* • *LEAD* — Cascading rebase conflicts from parallel PRs touching the same files
*WHAT_I_DID:* Ran parallel Builder agents where multiple agents touched the same files (ROLE-LEAD.md, SKILL-agent-spawn.md, tasks/lessons.md). Each merge caused a conflict in the next PR, requiring a rebase builder, which then conflicted with another merge.
*WHAT_WAS_WRONG:* Parallel PRs touching the same file are false parallelism — they can't actually merge in parallel. Each merge triggers another conflict cycle.
*CORRECTION:* Before spawning parallel agents: group all agents that touch the same file and assign them to one agent. If truly parallel work is needed on shared files, pick a merge order and serialize those specific agents.
*PATTERN:* File scope exclusivity is required for true parallelism. Two agents touching the same file = sequential work with extra rebase overhead. Assign exclusive file ownership before spawning.
*STATUS: SUPERSEDED 2026-03-20 — Separate builders by ISSUE scope, not file scope. The merge queue handles same-file conflicts automatically.*

---

## *2026-03-17* • *LEAD* — Lessons batched at session end instead of written immediately
*WHAT_I_DID:* Batched all lessons for the session into a single write at session end, rather than writing each lesson as it was identified.
*WHAT_WAS_WRONG:* Batching recreates the same failure mode as skipping — lessons queued for "later" are lost if the session ends unexpectedly.
*CORRECTION:* Every L: event spawns a dedicated agent immediately to append the lesson to harness/lessons.md in the same response turn.
*PATTERN:* L: event → spawn lesson-write agent immediately → that agent appends and opens a PR → Lead merges (docs-only). The lesson is safe on main before any other work resumes.
*STATUS: SUPERSEDED — by 2026-03-20 LEAD entry: lesson must be written at the moment the L: signal fires, not deferred to session end; spawn builder immediately*

---

## *2026-03-16* • *LEAD* — Background agents cannot use Bash even with bypassPermissions mode
*WHAT_I_DID:* Spawned background agents with `mode: bypassPermissions` expecting them to run `gh` CLI commands for PR review. All attempts failed.
*WHAT_WAS_WRONG:* Bash is denied in background agent context regardless of permission mode. The permission context does not propagate to spawned background agents.
*CORRECTION:* For tasks requiring `gh` CLI, git commands, or any Bash execution: Lead executes directly. Do NOT spawn background agents for these tasks.
*PATTERN:* Bash required → Lead runs it directly. No background agent spawn. Background agents can only use file tools (Read, Write, Glob, Grep) and Agent/SendMessage tools.
*STATUS: SUPERSEDED — by 2026-03-24 AUDITOR entry: bypassPermissions is permanently disabled (not mode-dependent); allow list is the only security model; the framing of "background agents cannot use Bash" is superseded by the permanent disable of bypassPermissions*

---

## *2026-03-17* • *LEAD* — PM agents cannot use AskUserQuestion — it does not exist in agent contexts
*WHAT_I_DID:* (a) A previous lesson said ToolSearch would fix AskUserQuestion availability for PM agents. (b) PM agents were instructed to ToolSearch for AskUserQuestion before asking the user.
*WHAT_WAS_WRONG:* AskUserQuestion is only available in Lead's interactive session — it does NOT exist in spawned agent contexts (background or foreground, team or no-team). ToolSearch cannot find it because it isn't in the agent's tool list at all.
*CORRECTION:* PM agents cannot ask the user questions directly. Use the relay pattern: PM sends question to Lead via SendMessage → Lead asks user → Lead relays answer to PM → repeat until discovery complete. Remove all AskUserQuestion/ToolSearch references from PM spawn prompts and ROLE-PM.md.
*PATTERN:* PM asks user → impossible. PM sends question to Lead via SendMessage → Lead asks user → Lead relays answer to PM. Never reference AskUserQuestion in any agent spawn prompt.
*STATUS: SUPERSEDED — by 2026-03-18 LEAD entry: relay pattern abandoned; agent text IS visible in its own tab; PM asks questions as plain text; user responds directly*

---

## *2026-03-17* • *LEAD* — PM transparent glass — Lead was adding commentary to relayed questions
*WHAT_I_DID:* When PM sent `A: [question]`, Lead was adding commentary alongside the forwarded question.
*WHAT_WAS_WRONG:* This broke the transparent glass model — PO experiences Lead as an intermediary rather than a direct conversation with the PM.
*CORRECTION:* When an agent sends A: [question], Lead's ENTIRE response is only: **[Role]:** [question] — nothing before, nothing after, no acknowledgement, no status text.
*PATTERN:* Agent sends A: question → Lead's only output: **[Role]:** [question]. PO answers → Lead forwards silently. Lead speaks only when there is no active agent question pending.
*STATUS: SUPERSEDED — by 2026-03-18 LEAD entry: relay pattern abolished entirely; agents conduct Q&A directly in their tab; transparent glass relay only applies to coordination signals (B:, D:, V:), not Q&A*

---

## *2026-03-18* • *LEAD* — Architect relay questions had commentary — breaking transparent glass model
*WHAT_I_DID:* Lead was adding commentary alongside Architect questions.
*WHAT_WAS_WRONG:* This broke the transparent glass model — PO experienced Lead as an intermediary rather than a direct conversation with the Architect.
*CORRECTION:* Architect questions relay identically to PM questions: Architect sends `A: [question]` → Lead shows `**Architect:** [question]` verbatim — no commentary.
*PATTERN:* Any agent that needs PO input uses the same relay protocol: `A: [question]` → Lead shows `**[Role]:** [question]` → PO answers → Lead forwards silently.
*STATUS: SUPERSEDED — by 2026-03-18 LEAD (same date, later entry): agent text IS visible in agent tab; relay through Lead is unnecessary; agents do Q&A directly*

---

## *2026-03-18* • *LEAD* — Spawned all agents via Agent SDK background agents instead of Agent Teams teammates
*WHAT_I_DID:* Spawned all role-based agents via the Agent SDK tool with `team_name` + `run_in_background: true`. PO could not paste images, text, or transcripts to them.
*WHAT_WAS_WRONG:* Background agents have no user input surface — PO cannot interact with them directly. They also cannot use Bash/CLI tools.
*CORRECTION:* Migrated to Claude Code Agent Teams. All role-based agents are now spawned as Agent Teams teammates — full independent Claude Code sessions.
*PATTERN:* Agent Teams teammates = full Claude Code sessions with user input. Agent SDK background agents = no user input, no Bash. Always use Agent Teams for role-based work.
*STATUS: APPLIED/SUPERSEDED — CLAUDE.md § DISPATCH (spawn sequence documented); by later entries, bypassPermissions is also permanently disabled*

---

## *2026-03-20* • *LEAD* — Attempted to create multiple teams for parallel builders
*WHAT_I_DID:* Called TeamCreate four times to create separate teams for four parallel builders.
*WHAT_WAS_WRONG:* TeamCreate fails with "A leader can only manage one team at a time."
*CORRECTION:* One team, multiple teammates within it using Agent(team_name=...).
*PATTERN:* Create ONE team at session start. Spawn all builders as teammates within that team.
*STATUS: SUPERSEDED — duplicate of 2026-03-19 LEAD — One TeamCreate per Lead session (canonical version with fuller context)*

---

## *2026-03-20* • *LEAD* — Specified model in prompt text instead of Agent tool parameter
*WHAT_I_DID:* Wrote "Model: claude-sonnet-4-6" in the spawn prompt text but did not set the model parameter on the Agent tool call.
*WHAT_WAS_WRONG:* Prompt text is ignored for model selection. The agent inherited Lead's Opus model instead of Sonnet.
*CORRECTION:* The model must be set via the Agent tool's model parameter.
*PATTERN:* Always set model via the `model` parameter on the Agent tool call.
*STATUS: SUPERSEDED — duplicate of 2026-03-19 LEAD — Model param must be on Agent tool call (canonical version)*

---

## *2026-03-20* • *LEAD* — Spawned builder before ticket was ready
*WHAT_I_DID:* Spawned a builder for issue #127 before the PO had finished updating the ticket spec.
*WHAT_WAS_WRONG:* Builder had incomplete/stale requirements.
*CORRECTION:* PO said "Not sure why you launched 127 before I was ready."
*PATTERN:* When PO says a ticket needs updating, do not spawn the builder until PO explicitly gives the go-ahead.
*STATUS: SUPERSEDED — duplicate of 2026-03-19 LEAD — "I'll update the ticket" = explicit HOLD signal (canonical version)*

---

## *2026-03-19* • *LEAD* — Created multiple teams instead of adding all builders to one team
*WHAT_I_DID:* Called TeamCreate multiple times to create separate teams for concurrent builders.
*WHAT_WAS_WRONG:* TeamCreate fails with "A leader can only manage one team at a time."
*CORRECTION:* One team, all builders as teammates within it.
*PATTERN:* One session = one team. Create the team once.
*STATUS: SUPERSEDED — duplicate of 2026-03-19 LEAD — One TeamCreate per Lead session (canonical)*

---

## *2026-03-19* • *LEAD* — One team per session violated — multiple TeamCreate calls attempted
*WHAT_I_DID:* Called TeamCreate more than once in the same session.
*WHAT_WAS_WRONG:* Lead can only manage one team at a time.
*CORRECTION:* Create one team at session start. All builders as teammates.
*PATTERN:* One session = one team. Multiple TeamCreate calls will fail.
*STATUS: SUPERSEDED — duplicate entry*

---

## *2026-03-20* • *LEAD* — Same-file parallel builders create rebase queue that blocks session
*WHAT_I_DID:* Spawned multiple parallel builders that all edited the same high-contention files.
*WHAT_WAS_WRONG:* Parallel builders touching the same file are false parallelism.
*CORRECTION:* Before spawning parallel builders, identify high-contention files and assign all changes to a single builder.
*PATTERN:* Before spawning: scan each builder's likely file scope. Two builders touching the same file = rebase queue.
*STATUS: SUPERSEDED — by 2026-03-20 LEAD — Keep work separate by ISSUE scope not file scope; merge queue handles same-file conflicts automatically; do not pre-assign file ownership*

---

## *2026-03-19* • *LEAD* — Agent names used long-form role names instead of short prefix format
*WHAT_I_DID:* Named agents using full role names (builder-230, reviewer, architect-m6).
*WHAT_WAS_WRONG:* Long-form names are hard to scan in team dashboards and logs.
*CORRECTION:* Short prefix format is canonical: b- builder, a- auditor, r- reviewer, t- tester.
*PATTERN:* Agent names always use short prefix format.
*STATUS: SUPERSEDED — by 2026-03-24 LEAD: auditor prefix changed from au- to a-; canonical prefixes: b- builder, a- auditor, r- reviewer, t- tester*

---

## *2026-03-23* • *LEAD* — isolation: "worktree" silently ignored for in-process agents
*WHAT_I_DID:* Spawned parallel builders with isolation: "worktree" assuming each agent got a separate git checkout.
*WHAT_WAS_WRONG:* For in-process agents, isolation: "worktree" does nothing.
*CORRECTION:* Lead must manually create a git worktree before spawning each builder.
*PATTERN:* Never rely on isolation: "worktree" for git safety. Always pre-create worktrees.
*STATUS: SUPERSEDED — CC v2.1.49+ native worktree isolation; manual pre-creation still valid for explicit branch control*

---

## *2026-03-23* • *LEAD* — In-process agents don't inherit worktree directory
*WHAT_I_DID:* Spawned in-process agents expecting them to operate in the pre-created worktree directory.
*WHAT_WAS_WRONG:* In-process agents always start in the main repo directory, not the worktree.
*CORRECTION:* All git operations in builder prompts must use `git -C /worktree-path command`.
*PATTERN:* In-process agents start in main repo, not worktree. Every builder prompt must include: "All git operations: `git -C /tmp/wt-[name]`."
*STATUS: SUPERSEDED — CC v2.1.49+ native isolation: "worktree" gives each agent its own filesystem context; git -C pattern still recommended for manual worktrees*

---

## *2026-03-24* • *LEAD* — Parallel builder worktree pollution via shared git object store
*WHAT_I_DID:* Spawned parallel builders that ran bare git commands from the main repo path, or ran git fetch after branch creation.
*WHAT_WAS_WRONG:* Shared git object store means any fetch populates remote-tracking refs for ALL builders.
*CORRECTION:* git checkout -b must be the first git operation. Never fetch/pull after branch creation. All git ops via git -C /tmp/[worktree].
*PATTERN:* In every builder spawn prompt: (1) git checkout -b [branch] first, (2) explicitly forbid fetch/pull after, (3) all git ops use git -C /worktree.
*STATUS: SUPERSEDED — CC v2.1.49+ native worktree isolation eliminates shared-checkout contamination; git checkout -b as first op is still good hygiene*
