# Lessons Log

## Purpose
Running correction log. Captures mistakes agents make during sessions — logged immediately when the PO corrects an agent or an agent goes in the wrong direction. APPEND ONLY. Never edit existing entries.

## How to append an entry
Copy this template, fill in all fields, and append at the bottom of the file:

```
## *[DATE]* • *[ROLE]* — [one-line description of the mistake]
*WHAT_I_DID:* [what the agent did]
*WHAT_WAS_WRONG:* [why it was wrong — be specific]
*CORRECTION:* [what the human said or what the right approach is]
*PATTERN:* [generalised rule to avoid this class of mistake in future]
```

PATTERN is the only field that matters for future agents. No PATTERN = not ready to write.

## Applied Status
Entries marked `APPLIED` have been encoded into role files or skill files. Unmarked entries are pending harness update.

## Superseded Entries
Entries marked `STATUS: SUPERSEDED` describe approaches that were explicitly reversed. Skip them when reading — they are preserved here per the APPEND ONLY rule. Full list: [harness/lessons-archive.md](lessons-archive.md)

---

## *2026-03-13* • *LEAD* — Reviewer not spawned same turn as V: message
*WHAT_I_DID:* Waited an extra turn after sending V: before spawning the Reviewer agent. This happened twice before the user corrected it.
*WHAT_WAS_WRONG:* Reviewer must be spawned the same turn the PR is opened — any delay means the PR sits without review, blocking merge.
*CORRECTION:* Parallel-agent rule enforced: Reviewer now spawns same turn as V: message — no exceptions.
*PATTERN:* V: message and Reviewer spawn happen in the same response turn. Never split them.
*STATUS: APPLIED — harness/roles/ROLE-LEAD.md (line 15: "Spawn Reviewer the MOMENT a PR opens — same response turn as V: message")*

---

## *2026-03-13* • *LEAD* — PM subagent went idle instead of using AskUserQuestion
*WHAT_I_DID:* Spawned a PM subagent for discovery. It went idle instead of asking the user questions.
*WHAT_WAS_WRONG:* PM subagent pattern does not work for interactive discovery — subagents cannot reliably prompt the user in that context.
*CORRECTION:* PM subagent pattern abandoned for interactive discovery. Lead conducts discovery directly when no external Jira/Figma access is available.
*PATTERN:* Do not spawn PM as a subagent for interactive discovery. Lead conducts discovery directly, or use Agent Teams teammate with direct PO tab access.
*STATUS: SUPERSEDED — by 2026-03-18 LEAD entry: agent text IS visible in agent tab; PM asks questions as plain text output directly, relay through Lead unnecessary*

---

## *2026-03-13* • *LEAD* — Builder spawned without design screenshot
*WHAT_I_DID:* Spawned Builders for UI layout changes without first obtaining Figma access or a design screenshot from the PO.
*WHAT_WAS_WRONG:* Builders without a design spec make best-guess layout commits that require full rework once the real design is provided.
*CORRECTION:* Always ask for a design screenshot before spawning Builders if Figma requires auth.
*PATTERN:* Always ask for a design screenshot before spawning Builders if Figma requires auth — a Builder without a spec makes a best-guess commit that needs rework.
*STATUS: APPLIED — harness/skills/SKILL-agent-spawn.md (line 43: "UI changes + Figma requires auth? Obtain design screenshot from PO before spawning Builder.")*

---

## *2026-03-13* • *LEAD* — Lesson write skipped at session end
*WHAT_I_DID:* Verbally noted a lesson during the session but never wrote it to lessons.md. The lesson was lost.
*WHAT_WAS_WRONG:* Lessons queued for "later" are at risk if the session ends before they're written — exactly what happened here.
*CORRECTION:* This entry is the correction for the missed lessons.md write — written now as part of formal shutdown.
*PATTERN:* Lesson writes are NOT optional. If the shutdown protocol is skipped or compressed, lessons are lost. Treat harness/lessons.md write as a hard gate before any commit at session end.
*STATUS: SUPERSEDED — by 2026-03-20 LEAD entry: lesson must be written at the moment the L: signal fires, not deferred to session end; spawn builder immediately*

---

## *2026-03-13* • *LEAD* — gh CLI not installed; --hostname flag does not exist on gh issue create
*WHAT_I_DID:* Attempted to create GitHub issues without gh CLI installed. After installing, used `--hostname` flag on `gh issue create`.
*WHAT_WAS_WRONG:* gh CLI was not installed — blocked issue creation entirely. The `--hostname` flag is valid for `gh auth` but does not exist on `gh issue create`.
*CORRECTION:* gh CLI now installed via Homebrew. Removed `--hostname` from `gh issue create` commands going forward.
*PATTERN:* gh issue create does not accept --hostname. Omit it — gh uses the authenticated host automatically.
*STATUS: APPLIED — harness/skills/SKILL-github-pr-workflow.md (Gotchas table entry 8: "--hostname flag on gh issue create does not exist")*

---

## *2026-03-17* • *LEAD* — Lessons batched at session end instead of written immediately
*WHAT_I_DID:* Batched all lessons for the session into a single write at session end, rather than writing each lesson as it was identified.
*WHAT_WAS_WRONG:* Batching recreates the same failure mode as skipping — lessons queued for "later" are lost if the session ends unexpectedly.
*CORRECTION:* Every L: event spawns a dedicated agent immediately to append the lesson to harness/lessons.md in the same response turn.
*PATTERN:* L: event → spawn lesson-write agent immediately → that agent appends and opens a PR → Lead merges (docs-only). The lesson is safe on main before any other work resumes.
*STATUS: APPLIED — harness/skills/SKILL-live-learning.md (line 59-62: "Write to harness/lessons.md BEFORE any next tool call. No exceptions.")*

---

## *2026-03-17* • *LEAD* — Lead edited files directly (merge conflict resolution)
*WHAT_I_DID:* Resolved merge conflicts by directly editing ROLE-LEAD.md and LAUNCH-SCRIPT-TEMPLATE.md during PR rebases.
*WHAT_WAS_WRONG:* Conflict resolution is file editing. Lead must never edit files — that is "writing code" regardless of the file type or reason.
*CORRECTION:* Lead never edits files, never resolves conflicts. Spawn a Builder with the conflict details and let Builder do the rebase.
*PATTERN:* Lead = coordination only. Any file edit, conflict resolution, or git rebase = "writing code." Spawn a Builder for it, no exceptions.
*STATUS: APPLIED — harness/roles/ROLE-LEAD.md (line 7: "Lead NEVER writes or edits any file — markdown or code. No exceptions.")*

---

## *2026-03-17* • *LEAD* — Compound cd && git commands triggered permission prompts
*WHAT_I_DID:* Used `cd /path && git command` patterns in Bash calls.
*WHAT_WAS_WRONG:* Compound `&&` commands are flagged as a potential bare repository attack by Claude Code's security model, triggering permission prompts on every execution.
*CORRECTION:* Use `git -C /path command` or separate Bash calls instead of `cd && git`.
*PATTERN:* Before writing any Bash command with `&&`: split into two separate Bash tool calls. One command per call. No chaining. Use `git -C /path` for worktree operations.
*STATUS: APPLIED — CLAUDE.md § Settings and Configuration; also harness/skills/SKILL-agent-spawn.md documents git -C pattern*

---

## *2026-03-17* • *LEAD* — Reviewer agents spawned for docs-only PRs
*WHAT_I_DID:* Spawned Reviewer agents for docs-only (markdown) PRs.
*WHAT_WAS_WRONG:* Docs-only PRs don't need a Reviewer — unnecessary latency and token cost.
*CORRECTION:* Docs-only PRs: Lead merges directly (no Reviewer), shuts down Builder in same turn.
*PATTERN:* Docs-only PRs need no Reviewer. Lead merges directly and shuts down Builder same turn as D: received.
*STATUS: APPLIED — harness/roles/ROLE-LEAD.md (line 250: "May merge markdown-only harness PRs directly (no Reviewer needed — Lead merges and shuts down Builder in same turn)")*

---

## *2026-03-17* • *LEAD* — Self-approval not possible on GHE
*WHAT_I_DID:* Spawned Reviewer agents that used the same gh CLI auth (corey-latislaw) as the Builder agents who opened the PRs. Every `gh pr review N --approve` was rejected.
*WHAT_WAS_WRONG:* GitHub branch protection blocks self-approval — same account cannot author and approve a PR.
*CORRECTION:* For a solo developer setup: skip Reviewer agents for docs-only PRs (Lead merges directly). For code PRs: the human PO reviews in the GitHub UI.
*PATTERN:* Reviewer agents are only useful when they authenticate as a DIFFERENT account from the PR author. In a solo setup, the PO is the code reviewer for non-trivial PRs.
*STATUS: APPLIED — harness/skills/SKILL-github-pr-workflow.md (Gotchas table entry 4: "Agent running gh pr review --approve violates Two-Track Model; self-approval blocked")*

---

## *2026-03-17* • *LEAD* — Cascading rebase conflicts from parallel PRs touching the same files
*WHAT_I_DID:* Ran parallel Builder agents where multiple agents touched the same files (ROLE-LEAD.md, SKILL-agent-spawn.md, tasks/lessons.md). Each merge caused a conflict in the next PR, requiring a rebase builder, which then conflicted with another merge.
*WHAT_WAS_WRONG:* Parallel PRs touching the same file are false parallelism — they can't actually merge in parallel. Each merge triggers another conflict cycle.
*CORRECTION:* Before spawning parallel agents: group all agents that touch the same file and assign them to one agent. If truly parallel work is needed on shared files, pick a merge order and serialize those specific agents.
*PATTERN:* File scope exclusivity is required for true parallelism. Two agents touching the same file = sequential work with extra rebase overhead. Assign exclusive file ownership before spawning.
> **SUPERSEDED 2026-03-20:** Separate builders by ISSUE scope, not file scope. The merge queue handles same-file conflicts automatically. See 2026-03-20 entry.
*STATUS: SUPERSEDED — by 2026-03-20 LEAD entry: keep work separate by ISSUE scope, not file scope; merge queue handles same-file conflicts via rebase*

---

## *2026-03-17* • *LEAD* — Did not re-read ROLE-LEAD.md after lessons PRs merged
*WHAT_I_DID:* Applied new NON-NEGOTIABLE rules to ROLE-LEAD.md throughout the session. These rules were merged to main but Lead did not re-read the file — continued operating from the version loaded at session start.
*WHAT_WAS_WRONG:* Lead's in-context rules go stale as lesson PRs merge. Without re-reading, Lead misses rules added mid-session.
*CORRECTION:* After any lesson PR merges that updates ROLE-LEAD.md: Lead immediately re-reads harness/roles/ROLE-LEAD.md.
*PATTERN:* ROLE-LEAD.md is a living document. Re-read it after every merge that touches it — not just at session start.
*STATUS: APPLIED — harness/roles/ROLE-LEAD.md (line 264: "Re-read harness/roles/ROLE-LEAD.md immediately after any PR that modifies it is merged")*

---

## *2026-03-16* • *LEAD* — Auditors handed off to Builder instead of implementing themselves
*WHAT_I_DID:* Auditor completed an investigation and reported findings back to Lead. Lead spawned a separate Builder to implement the recommendations.
*WHAT_WAS_WRONG:* The Auditor already has full context on the problem and the fix. Spinning up a new Builder requires re-loading that context from scratch, costing extra tokens and adding latency.
*CORRECTION:* Auditors follow a two-phase flow: (1) Audit phase: investigate, produce report, surface findings; (2) Implement phase: after PO/Lead approves, the SAME Auditor implements the fix.
*PATTERN:* Auditor flow: investigate → R: report to Lead → Lead/PO approves → Auditor implements → D: done. One agent, two phases. No Builder hand-off needed.
*STATUS: APPLIED — harness/roles/ROLE-AUDITOR.md (two-phase flow documented)*

---

## *2026-03-16* • *LEAD* — No documented decision rule for subagent vs independent agent
*WHAT_I_DID:* Used subagents (Agent tool) for research tasks and independent agents (Teams) for file-writing Builder work — inconsistently, with no documented decision rule.
*WHAT_WAS_WRONG:* Without a clear rule, Lead occasionally launched research subagents when an independent agent would have been better, and vice versa.
*CORRECTION:* Established decision matrix: Independent agent (Teams) for anything that writes files, runs in parallel, or is a Builder/Reviewer/Architect. Subagent (Agent tool) for throwaway research tasks that stay in Lead's response turn, don't write files, and don't need to run concurrently.
*PATTERN:* Before spawning: does this agent write files or need to run concurrently? → independent. Is it pure research staying in my turn? → subagent OK.
*STATUS: APPLIED — harness/roles/ROLE-LEAD.md (line 96: "All role-based work must be spawned as Agent Teams teammates. Sub-agents are reserved only for trivial self-contained lookups")*

---

## *2026-03-16* • *LEAD* — Platform-specific allowlist entries not added at session start for new platforms
*WHAT_I_DID:* Started iOS work mid-session. Agents ran `brew`, `xcodebuild`, and `swift` commands that were not in the `~/.claude/settings.json` allowlist.
*WHAT_WAS_WRONG:* The allowlist was built for a web/TypeScript stack. Starting iOS work without updating the allowlist triggered permission prompts on every build/test command.
*CORRECTION:* At session start for any new platform: audit `~/.claude/settings.json` and add platform tool patterns before spawning Builders.
*PATTERN:* At session start for any new platform (iOS, Android, Python, etc.): audit `~/.claude/settings.json` and add platform tool patterns before spawning Builders. An auditor agent can do this proactively.
*STATUS: PENDING — not yet applied to any harness file (no harness session-start checklist covers this explicitly)*

---

## *2026-03-16* • *LEAD* — Figma section nodes passed directly to get_design_context
*WHAT_I_DID:* Called `get_design_context` with a node ID pointing to a Figma section node (a container grouping multiple screens).
*WHAT_WAS_WRONG:* `get_design_context` on a section node returns only sparse XML metadata — no code, no screenshot, no design tokens.
*CORRECTION:* When a Figma URL points to a section: parse the metadata XML to find child frame IDs, then call `get_design_context` on each child node ID individually.
*PATTERN:* Figma section node → parse child IDs from metadata → call get_design_context per child. Never pass a section node ID directly to a Builder.
*STATUS: APPLIED — harness/skills/SKILL-agent-spawn.md (lines 287-292: Figma section node handling — parse child frame IDs, never pass section node ID directly)*

---

## *2026-03-16* • *LEAD* — Category B security triggers treated as allowlist problems
*WHAT_I_DID:* Added allowlist entries to fix permission prompts, but prompts kept appearing. Assumed it was always a Category A (allowlist) problem.
*WHAT_WAS_WRONG:* Claude Code has two distinct prompt mechanisms. Category A: command token not in allowlist → fix by adding allowlist entry. Category B: security check for dangerous patterns (heredoc/command-substitution containing `#`-prefixed lines) → ALWAYS prompts regardless of allowlist.
*CORRECTION:* Category B fixes require changing the command pattern: write body files using the Write tool (not Bash heredoc), use `--body-file` for gh commands, use `printf` + `git commit -F` for commit messages.
*PATTERN:* Before writing any Bash command with multi-line quoted content: does it contain `#` lines or command substitution? → Use Write tool + file reference instead of inline heredoc/substitution.
*STATUS: APPLIED — harness/skills/SKILL-agent-spawn.md (line 50: "Category B (security-check) prompts — heredoc or command substitution with #-prefixed lines always prompt regardless of the allow list")*

---

## *2026-03-16* • *LEAD* — Background agents cannot use Bash even with bypassPermissions mode
*WHAT_I_DID:* Spawned background agents with `mode: bypassPermissions` expecting them to run `gh` CLI commands for PR review. All attempts failed.
*WHAT_WAS_WRONG:* Bash is denied in background agent context regardless of permission mode. The permission context does not propagate to spawned background agents.
*CORRECTION:* For tasks requiring `gh` CLI, git commands, or any Bash execution: Lead executes directly. Do NOT spawn background agents for these tasks.
*PATTERN:* Bash required → Lead runs it directly. No background agent spawn. Background agents can only use file tools (Read, Write, Glob, Grep) and Agent/SendMessage tools.
*STATUS: SUPERSEDED — by 2026-03-24 AUDITOR entry: bypassPermissions is permanently disabled (not mode-dependent); allow list is the only security model; the framing of "background agents cannot use Bash" is superseded by the permanent disable of bypassPermissions*

---

## *2026-03-16* • *LEAD* — iOS agents must use swiftlane, not bare xcodebuild; snapshot regen required for UI changes
*WHAT_I_DID:* Builder ran `xcodebuild build test -scheme Checkout` locally to verify tests pass before pushing. CI uses `swiftlane test package Checkout` which is not equivalent.
*WHAT_WAS_WRONG:* Bare xcodebuild skips swiftlane's cache generation, project generation, and additional setup — tests that pass locally via xcodebuild can still fail in swiftlane. Also, UI text changes require regenerating snapshot reference images.
*CORRECTION:* iOS Builder VERIFICATION GATE must run `swiftlane test package [ModuleName]`. For any UI text/layout/color change: delete `__Snapshots__/` dirs for affected views, re-run tests once to regenerate reference images, commit the new snapshots alongside the code change.
*PATTERN:* iOS UI change = snapshot regen required. Always run `swiftlane test package` not `xcodebuild` — they are not equivalent.
*STATUS: APPLIED — harness/SYSTEM-KNOWLEDGE.md (lines 68-69: "Always use swiftlane test package, never bare xcodebuild"); harness/skills/SKILL-coding-standards-ios.md (line 35: "NEVER use bare xcodebuild")*

---

## *2026-03-17* • *LEAD* — Agent text output not sent via SendMessage — invisible to Lead
*WHAT_I_DID:* Agent au-harness-standards completed its audit and output its report as plain text. Lead received multiple idle notifications but no report. Agent had to be shut down and respawned.
*WHAT_WAS_WRONG:* Plain text output is not delivered to Lead or other teammates — only SendMessage reaches other team members.
*CORRECTION:* Every agent spawn prompt must include an explicit instruction: "Your text output is NOT visible to Lead or other teammates. You MUST use the SendMessage tool to communicate."
*PATTERN:* Agent spawn prompt must always include: "Use SendMessage to communicate — text output is invisible to Lead."
*STATUS: APPLIED — harness/skills/SKILL-agent-spawn.md (documented in spawn template and troubleshooting)*

---

## *2026-03-17* • *LEAD* — Lead fetched ticket before spawning Builder
*WHAT_I_DID:* When asked to spin up a Builder for CTLG-395, Lead fetched the Jira ticket itself before spawning the Builder.
*WHAT_WAS_WRONG:* Lead's role is coordination only. PO corrected: "why are you gathering instead of telling the builder to gather?"
*CORRECTION:* Lead's spawn prompt for any Builder must include the ticket URL/key and instruct the Builder to fetch ticket details, explore the codebase, and report discovery findings back before implementing.
*PATTERN:* Lead passes ticket URL to Builder. Builder does all discovery. Builder reports findings to Lead before implementing. Lead never reads code, fetches tickets, or searches files on behalf of a Builder.
*STATUS: PENDING — not yet encoded as an explicit rule in ROLE-LEAD.md spawn checklist (covered implicitly by "coordination only" rule but not stated as a specific prohibition)*

---

## *2026-03-17* • *LEAD* — Auditor findings not posted to GitHub issue before R: to Lead
*WHAT_I_DID:* Auditor sent findings only via SendMessage. GitHub issue had no record. Permanent audit trail was lost.
*WHAT_WAS_WRONG:* SendMessage is ephemeral — it is a coordination signal, not a permanent record. Findings lost when context compresses.
*CORRECTION:* Every Auditor posts findings as a GitHub issue comment (or new issue) BEFORE sending R: to Lead.
*PATTERN:* Auditor → gh issue comment → SendMessage R: to Lead. Both always happen. Never just SendMessage.
*STATUS: APPLIED — harness/roles/ROLE-AUDITOR.md (line 80: "Post all findings to GitHub issue BEFORE sending R: to Lead")*

---

## *2026-03-17* • *LEAD* — PM agents cannot use AskUserQuestion — it does not exist in agent contexts
*WHAT_I_DID:* (a) A previous lesson said ToolSearch would fix AskUserQuestion availability for PM agents. (b) PM agents were instructed to ToolSearch for AskUserQuestion before asking the user.
*WHAT_WAS_WRONG:* AskUserQuestion is only available in Lead's interactive session — it does NOT exist in spawned agent contexts (background or foreground, team or no-team). ToolSearch cannot find it because it isn't in the agent's tool list at all.
*CORRECTION:* PM agents cannot ask the user questions directly. Use the relay pattern: PM sends question to Lead via SendMessage → Lead asks user → Lead relays answer to PM → repeat until discovery complete. Remove all AskUserQuestion/ToolSearch references from PM spawn prompts and ROLE-PM.md.
*PATTERN:* PM asks user → impossible. PM sends question to Lead via SendMessage → Lead asks user → Lead relays answer to PM. Never reference AskUserQuestion in any agent spawn prompt.
*STATUS: SUPERSEDED — by 2026-03-18 LEAD entry: relay pattern abandoned; agent text IS visible in its own tab; PM asks questions as plain text; user responds directly*

---

## *2026-03-17* • *LEAD* — PM transparent glass — Lead was adding commentary to relayed questions
*WHAT_I_DID:* When PM sent `A: [question]`, Lead was adding commentary ("b is the most common pattern", "Still waiting on your answer") alongside the forwarded question.
*WHAT_WAS_WRONG:* This broke the transparent glass model — PO experiences Lead as an intermediary rather than a direct conversation with the PM.
*CORRECTION:* When an agent sends A: [question], Lead's ENTIRE response is only: **[Role]:** [question] — nothing before, nothing after, no acknowledgement, no status text.
*PATTERN:* Agent sends A: question → Lead's only output: **[Role]:** [question]. PO answers → Lead forwards silently. Lead speaks only when there is no active agent question pending.
*STATUS: SUPERSEDED — by 2026-03-18 LEAD entry: relay pattern abolished entirely; agents conduct Q&A directly in their tab; transparent glass relay only applies to coordination signals (B:, D:, V:), not Q&A*

---

## *2026-03-17* • *LEAD* — Verify fix before encoding lesson into harness files
*WHAT_I_DID:* Wrote a lesson saying ToolSearch would fix AskUserQuestion in agent contexts. Lesson was wrong — the tool doesn't exist in agent contexts at all. The wrong lesson was merged and followed.
*WHAT_WAS_WRONG:* A lesson that's wrong is worse than no lesson — it gets followed. The fix was never tested in a spawned agent context before being encoded.
*CORRECTION:* Before writing any lesson: verify the fix actually works in a spawned agent context. "I think this will work" is not enough — test or confirm the tool exists.
*PATTERN:* Verify before encoding. Test a fix in practice before writing it to lessons.md and harness files.
*STATUS: PENDING — not yet encoded as an explicit verification step in any harness file*

---

## *2026-03-18* • *LEAD* — PM discovery completed without confirming all target platforms
*WHAT_I_DID:* PM completed loyalty milestone discovery (issue #75) and produced milestones M2, M3, M4 covering Web and iOS. Android was not mentioned in any milestone or issue.
*WHAT_WAS_WRONG:* Android is in scope for Phase 2. PO caught the gap during ticket review — after all milestones and tickets had been written.
*CORRECTION:* PM discovery must ask explicitly: "Which platforms are in scope for this milestone? (Web, iOS, Android, Backend — confirm each)." This question must be asked before the milestone proposal, not after ticket review. ROLE-PM.md updated with a mandatory platform-coverage check.
*PATTERN:* Platform coverage is never implicit. PM must confirm Web / iOS / Android / Backend scope explicitly for every milestone. A missing platform = missing tickets = rework.
*STATUS: APPLIED — harness/roles/ROLE-PM.md (line 51: "Platform coverage check (mandatory): Before proposing any milestone structure, PM must ask which platforms are in scope")*

---

## *2026-03-18* • *LEAD* — Architect relay questions had commentary — breaking transparent glass model
*WHAT_I_DID:* Lead was adding commentary alongside Architect questions ("b is the most common pattern", "Still waiting on your answer").
*WHAT_WAS_WRONG:* This broke the transparent glass model — PO experienced Lead as an intermediary rather than a direct conversation with the Architect.
*CORRECTION:* Architect questions relay identically to PM questions: Architect sends `A: [question]` → Lead shows `**Architect:** [question]` verbatim — no commentary, no suggestions, no framing → PO answers → Lead forwards immediately.
*PATTERN:* Any agent that needs PO input uses the same relay protocol: `A: [question]` → Lead shows `**[Role]:** [question]` → PO answers → Lead forwards silently.
*STATUS: SUPERSEDED — by 2026-03-18 LEAD (same date, later entry): agent text IS visible in agent tab; relay through Lead is unnecessary; agents do Q&A directly*

---

## *2026-03-18* • *LEAD* — Agent text output IS visible to user in agent tab — relay through Lead was unnecessary
*WHAT_I_DID:* PM and Architect were instructed to relay questions via SendMessage to Lead, who would present them to the user. Multiple sessions used this relay pattern for Q&A discovery.
*WHAT_WAS_WRONG:* Agent text output IS visible to the user directly in the agent's own tab. The user can respond directly in the agent's tab without Lead involvement. The relay pattern added latency and made the conversation feel indirect.
*CORRECTION:* For PM/Architect Q&A discovery sessions: agent asks questions as plain text output in its own tab. User responds directly. Agent only uses SendMessage to Lead for coordination tasks (tickets, PRs, spawning).
*PATTERN:* Agent Q&A: plain text output in agent tab → user responds directly. SendMessage to Lead: coordination only (tickets, PRs, spawning). Lead is NOT involved in Q&A.
*STATUS: APPLIED — CLAUDE.md § DISPATCH, harness/skills/SKILL-agent-spawn.md*

---

## *2026-03-18* • *LEAD* — Spawned all agents via Agent SDK background agents instead of Agent Teams teammates
*WHAT_I_DID:* Spawned all role-based agents via the Agent SDK tool with `team_name` + `run_in_background: true`. PO could not paste images, text, or transcripts to them.
*WHAT_WAS_WRONG:* Background agents have no user input surface — PO cannot interact with them directly. They also cannot use Bash/CLI tools. This forced the slow PM relay pattern through Lead.
*CORRECTION:* Migrated to Claude Code Agent Teams (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`). All role-based agents are now spawned as Agent Teams teammates — full independent Claude Code sessions with their own terminal and PO interaction surface.
*PATTERN:* Agent Teams teammates = full Claude Code sessions with user input. Agent SDK background agents = no user input, no Bash. Always use Agent Teams for role-based work.
*STATUS: APPLIED — CLAUDE.md § DISPATCH (spawn sequence documented); harness/skills/SKILL-agent-spawn.md*

---

## *2026-03-19* • *LEAD* — Used Agent tool alone instead of TeamCreate then Agent(team_name) sequence
*WHAT_I_DID:* Spawned all role-based agents using the Agent tool without calling TeamCreate first and without passing team_name. Used run_in_background: true as a workaround which caused 401 auth failures.
*WHAT_WAS_WRONG:* The Agent tool alone creates sub-tasks under Lead — invisible to PO, blocking, serial, sharing Lead's context. True Agent Teams teammates require TeamCreate first, then Agent with team_name parameter.
*CORRECTION:* Correct spawn sequence is always two steps: (1) TeamCreate — creates the teammate slot; (2) Agent with team_name parameter — starts the agent in that slot. Without team_name, agents run as sub-agents in Lead's context.
*PATTERN:* ALWAYS call TeamCreate before spawning ANY role-based agent. Then pass team_name to every Agent call. The spawn sequence is: (1) TeamCreate, (2) Agent with team_name. No exceptions.
*STATUS: APPLIED — CLAUDE.md § DISPATCH (spawn sequence: TeamCreate then Agent(team_name=...)); harness/skills/SKILL-agent-spawn.md*

---

## *2026-03-19* • *LEAD* — Grouped multiple issues into a single builder
*WHAT_I_DID:* Lead grouped issues #121, #122, #124, #125 into a single builder instead of spawning one builder per issue.
*WHAT_WAS_WRONG:* Grouping multiple issues into one builder creates a large PR that is harder to review, violates the PR-size constraint (<=400 lines), and makes it impossible to close individual issues independently if one fix needs rework.
*CORRECTION:* Each GitHub issue gets its own builder agent. Builder opens a PR with `Closes #N` for exactly one issue.
*PATTERN:* One issue = one builder = one PR. Group only when issues are trivially related and total diff is small.
*STATUS: PENDING — not yet encoded as an explicit numbered rule in ROLE-LEAD.md or SKILL-agent-spawn.md (principle implied but not called out)*

---

## *2026-03-19* • *LEAD* — run_in_background: true causes 401 auth failures
*WHAT_I_DID:* Spawned agents with `run_in_background: true` expecting them to work independently with authenticated API access.
*WHAT_WAS_WRONG:* Background agents consistently received 401 authentication failures. The auth token does not propagate to background agent contexts.
*CORRECTION:* Do not use `run_in_background: true` for agents that need authenticated API access (gh CLI, git push, etc.). Use foreground Agent Teams teammates instead.
*PATTERN:* run_in_background: true = no auth. Use foreground Agent Teams teammates for any work requiring gh/git authentication.
*STATUS: APPLIED — harness/skills/SKILL-agent-spawn.md (line 32: "Never use run_in_background: true for teammate Bash commands. Background execution causes 401 authentication failures.")*

---

## *2026-03-20* • *LEAD* — Pre-assigned exclusive file scope to parallel builders to prevent conflicts
*WHAT_I_DID:* Before spawning parallel builders, assigned each builder exclusive file ownership to prevent merge conflicts.
*WHAT_WAS_WRONG:* This bleeds issue scope across PRs — one builder ends up implementing another issue's changes. File conflicts between parallel branches are normal and handled by rebasing at merge time.
*CORRECTION:* PO said "I don't care if they are going to be touching the same file, that's what rebasing and merge conflicts are there for. The work should stay separate."
*PATTERN:* Keep work separate by ISSUE scope, not by file scope. Parallel builders each own their issue's changes. Merge conflicts are resolved at PR merge time via rebase — do not pre-assign file ownership to avoid them.
*STATUS: APPLIED — CLAUDE.md § DISPATCH ("Parallel-first: Spawn all independent builders simultaneously. Never sequence unless hard data dependency exists between tasks.")*

---

## *2026-03-20* • *LEAD* — Attempted to create multiple teams for parallel builders
*WHAT_I_DID:* Called TeamCreate four times to create separate teams for four parallel builders.
*WHAT_WAS_WRONG:* TeamCreate fails with "A leader can only manage one team at a time." All teammates must be spawned within one team using Agent(team_name=...).
*CORRECTION:* PO pointed out builders should be "separate build agents as part of my claude agent team" — one team, multiple teammates.
*PATTERN:* Create ONE team at session start. Spawn all builders as teammates within that team using Agent(team_name=...). Never call TeamCreate more than once per Lead session.
*STATUS: SUPERSEDED — by 2026-03-19 LEAD — One TeamCreate per Lead session (line ~313); canonical version with fuller context*

---

## *2026-03-20* • *LEAD* — Specified model in prompt text instead of Agent tool parameter
*WHAT_I_DID:* Wrote "Model: claude-sonnet-4-6" in the spawn prompt text but did not set the model parameter on the Agent tool call.
*WHAT_WAS_WRONG:* Prompt text is ignored for model selection. The agent inherited Lead's Opus model instead of Sonnet, wasting budget.
*CORRECTION:* PO said "I don't think you quite got the model right."
*PATTERN:* Always set model via the `model` parameter on the Agent tool call. Mentioning model in the prompt text has no effect.
*STATUS: SUPERSEDED — by 2026-03-19 LEAD — Model param must be on Agent tool call (line ~326); canonical version*

---

## *2026-03-20* • *LEAD* — Spawned builder before ticket was ready
*WHAT_I_DID:* Spawned a builder for issue #127 before the PO had finished updating the ticket spec.
*WHAT_WAS_WRONG:* Builder had incomplete/stale requirements and was immediately interrupted by the PO.
*CORRECTION:* PO said "Not sure why you launched 127 before I was ready. Told you to wait."
*PATTERN:* When PO says a ticket needs updating, do not spawn the builder until PO explicitly gives the go-ahead. "I'll update the ticket" is a HOLD signal, not a GO.
*STATUS: SUPERSEDED — by 2026-03-19 LEAD — "I'll update the ticket" = explicit HOLD signal from PO (line ~367); canonical version with fuller phrase list*

---

## *2026-03-19* • *LEAD* — One TeamCreate per Lead session — multiple calls fail
*WHAT_I_DID:* Called TeamCreate multiple times in the same session to create separate teams for different builders.
*WHAT_WAS_WRONG:* Error: "A leader can only manage one team at a time." All teammates must be spawned within a single team for the entire session.
*CORRECTION:* Create ONE team at session start (or before first spawn). Add all builders, reviewers, auditors as teammates within that single team using Agent(team_name=...). Only call TeamCreate once per session.
*PATTERN:* One session = one team. Multiple TeamCreate calls will fail. Spawn all role-based agents as teammates in the single team.
*STATUS: APPLIED — CLAUDE.md § DISPATCH ("One team per session. Lead can only manage one team at a time.")*

---

## *2026-03-19* • *LEAD* — Model param must be on Agent tool call, not in spawn prompt text
*WHAT_I_DID:* Wrote "Model: claude-sonnet-4-6" in the spawn prompt body instead of setting the model parameter on the Agent tool call.
*WHAT_WAS_WRONG:* Builders inherited Lead's Opus model anyway — the text in the prompt is ignored for model selection. PO said "I don't think you quite got the model right."
*CORRECTION:* The model must be set via the Agent tool's model parameter: Agent(team_name="...", model="sonnet", prompt="..."). Writing "Model: X" in the prompt text is a no-op.
*PATTERN:* Agent tool call: model="sonnet" (or "haiku", "opus"). Prompt text: describe the role. Never write "Model:" inside the prompt string.
*STATUS: APPLIED — harness/skills/SKILL-agent-spawn.md (model parameter documented in spawn template); CLAUDE.md § DISPATCH*

---

## *2026-03-19* • *LEAD* — Project settings.json permissions.allow REPLACES global Bash(*)
*WHAT_I_DID:* Added a permissions.allow array to the project-level .claude/settings.json with specific Bash patterns.
*WHAT_WAS_WRONG:* This array REPLACED the global ~/.claude/settings.json Bash(*) wildcard — it does not merge. All agents working in worktrees under this repo lost their Bash(*) permission and received prompts on every command.
*CORRECTION:* Remove the permissions block entirely from the project .claude/settings.json. Leave only the env block (CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS). Permission management belongs in the global settings only. Also clear stale one-off entries from .claude/settings.local.json.
*PATTERN:* Project settings.json = env vars only. Never add a permissions block — it will silently shadow the global Bash(*) and cause permission prompts for every agent in every worktree.
*STATUS: APPLIED — CLAUDE.md § Settings and Configuration ("Project .claude/settings.json must contain env vars only — never add a permissions block.")*

---

## *2026-03-19* • *LEAD* — Auditor Phase 2 must only touch files in its task scope
*WHAT_I_DID:* au-permissions Phase 2 PR included ROLE-ARCHITECT.md, ROLE-PM.md, ADR-001, and MILESTONES.md alongside the target file (.claude/settings.json). Root cause: auditor modified files it was reading for context, not because they were in its task scope.
*WHAT_WAS_WRONG:* Those files had been modified by parallel builders and already merged. PR arrived with 4 conflicting files — required a forced rebase.
*CORRECTION:* Phase 2 auditor must only modify files explicitly listed in its task specification. Before committing: run git diff --name-only and verify every file is in scope. If other files need changes, report them as separate findings — do not include in the Phase 2 PR.
*PATTERN:* Before Phase 2 commit: git diff --name-only → verify every file is in task scope. Extra files = extra conflicts. Report out-of-scope findings separately.
*STATUS: APPLIED — harness/roles/ROLE-AUDITOR.md (two-phase flow; Phase 2 scope restriction documented)*

---

## *2026-03-19* • *LEAD* — "I'll update the ticket" treated as GO signal instead of HOLD
*WHAT_I_DID:* PO said "I'll update the ticket" before a builder was spawned for issue #127. Lead interpreted this as permission to spawn and launched b-127-lessons immediately.
*WHAT_WAS_WRONG:* PO corrected: "Not sure why you launched 127 before I was ready." Any phrase indicating the ticket is not yet final is a hold, not a go.
*CORRECTION:* Any PO phrase indicating the ticket is not yet final ("I'll update the ticket", "need to specify", "let me finish this", "hold on") is an explicit H: (hold) signal. Do not spawn until PO explicitly confirms: "ready", "go ahead", "it's updated", or similar.
*PATTERN:* PO: "I'll update the ticket" → H: signal. Lead waits. PO confirms ticket ready → spawn. Never spawn on ambiguous ticket state.
*STATUS: APPLIED — harness/roles/ROLE-LEAD.md (line 269: "If PO says 'I will update the ticket'... treat it as an explicit H: (hold)")*

---

## *2026-03-19* • *LEAD* — Created multiple teams instead of adding all builders to one team
*WHAT_I_DID:* Called TeamCreate multiple times to create separate teams for concurrent builders.
*WHAT_WAS_WRONG:* TeamCreate fails with "A leader can only manage one team at a time." All concurrent builders must be spawned as named teammates within the same team.
*CORRECTION:* PO clarified: builders should be "separate build agents as part of my claude agent team" — one team, multiple teammates. Create ONE team per session. All concurrent builders, reviewers, testers, and auditors are teammates within that single team via Agent(team_name=...).
*PATTERN:* One session = one team. Never call TeamCreate more than once per Lead session. Spawn all concurrent agents as named teammates within the same team using Agent(team_name=...). Multiple TeamCreate calls will fail.
*STATUS: SUPERSEDED — by 2026-03-19 LEAD — One TeamCreate per Lead session (line ~313); duplicate entry*

---

## *2026-03-19* • *LEAD* — Stale worktrees from prior sessions never cleaned up
*WHAT_I_DID:* Accumulated 10 stale git worktrees (b-182 through b-200) across multiple sessions. Content was already in main but worktrees were never removed.
*WHAT_WAS_WRONG:* SESSION END rule requires removing worktrees and deleting branches before closing. Repeated skipping of the shutdown protocol caused the accumulation.
*CORRECTION:* Audited and removed all 10 stale worktrees this session. All content was confirmed already merged to main.
*PATTERN:* SESSION END is non-negotiable. Run `git worktree list` before any shutdown commit. Remove all completed worktrees with `git worktree remove` + `git branch -D`. If shutdown is interrupted, carry cleanup to the next session's startup.
*STATUS: APPLIED — CLAUDE.md § SESSION END (step 3: worktree cleanup command); harness/skills/SKILL-session-shutdown.md*

---

## *2026-03-19* • *LEAD* — One team per session violated — multiple TeamCreate calls attempted
*WHAT_I_DID:* Called TeamCreate more than once in the same session to create separate teams for concurrent builders.
*WHAT_WAS_WRONG:* Lead can only manage one team at a time. Multiple TeamCreate calls fail. All concurrent builders must be teammates within one shared team.
*CORRECTION:* Created one team and spawned all builders as named teammates via Agent(team_name=...).
*PATTERN:* One session = one team. Create the team once before the first spawn. All concurrent builders, reviewers, auditors = teammates in that single team. Never call TeamCreate more than once per session.
*STATUS: SUPERSEDED — duplicate of 2026-03-19 LEAD — One TeamCreate per Lead session (line ~313)*

---

## *2026-03-19* • *LEAD* — Audit findings doc left untracked — not committed during session
*WHAT_I_DID:* Created docs/AUDIT-TOKEN-EFFICIENCY.md during the session but did not commit it to the shutdown branch. It was left as an untracked file.
*WHAT_WAS_WRONG:* Untracked files at session end signal incomplete shutdown. Audit docs represent completed work and should be committed immediately when created — not batched at session end.
*CORRECTION:* Committed the audit doc as part of the prior session's shutdown branch.
*PATTERN:* Check `git status --short` periodically during the session, not just at shutdown. Any untracked file representing completed work should be committed to the current working branch immediately.
*STATUS: APPLIED — harness/skills/SKILL-session-shutdown.md (line 175: "No lesson was 'noted verbally' without a write — verbal corrections do not count")*

---

## *2026-03-19* • *LEAD* — Skills are two-layer: ai-platform (JET-wide) + testharness (team-specific)
*WHAT_I_DID:* Surveyed ai-platform/skills alongside testharness/harness/skills without a clear mental model of the relationship.
*WHAT_WAS_WRONG:* The two skill registries serve different scopes. Treating them as competing or overlapping caused analysis confusion.
*CORRECTION:* Established two-layer model: ai-platform/skills = "how JET works" (auto-triggered, JET-wide, org-managed); testharness/harness/skills = "how this team works" (explicitly loaded, project-specific). No destructive overlaps found. SKILLS-INDEX.md needs a community skills section.
*PATTERN:* ai-platform skills = JET conventions + infrastructure (load automatically). Harness skills = team workflow + project patterns (load explicitly via SKILLS-INDEX.md). Complement, don't duplicate. Cross-reference where relevant.
*STATUS: APPLIED — harness/SKILLS-INDEX.md (two-layer section documenting JET-wide vs team-specific skills, line 54)*

---

## *2026-03-20* • *LEAD* — Same-file parallel builders create rebase queue that blocks session
*WHAT_I_DID:* Spawned multiple parallel builders that all edited the same high-contention files (e.g. harness/lessons.md, shared docs). The first builder to merge succeeded; every subsequent builder hit conflicts and required a sequential rebase cycle.
*WHAT_WAS_WRONG:* Parallel builders touching the same file are false parallelism — each merge blocks the next. The rebase queue grows linearly with the number of builders on the same file, turning parallel work into sequential work with extra overhead.
*CORRECTION:* Before spawning parallel builders, identify high-contention files. Either (a) assign all changes to that file to a single builder, or (b) accept the rebase queue and plan to sequence those merges explicitly.
*PATTERN:* Before spawning: scan each builder's likely file scope. Two builders touching the same file = rebase queue. Assign same-file changes to one builder, or plan explicit merge order for those builders.
*STATUS: SUPERSEDED — by 2026-03-20 LEAD — Keep work separate by ISSUE scope not file scope; merge queue handles same-file conflicts automatically; do not pre-assign file ownership*

---

## *2026-03-20* • *LEAD* — Lesson encoding deferred to session end instead of written on L: event
*WHAT_I_DID:* Identified a lesson mid-session and noted it verbally but deferred the actual write to harness/lessons.md until session end.
*WHAT_WAS_WRONG:* Agent spawns between sessions do not carry memory — only repo files persist. A lesson noted verbally but not committed is lost the moment the session ends or the context compresses. This recreates the same failure mode repeatedly.
*CORRECTION:* Write the lesson to harness/lessons.md within the same response turn the L: signal fires. Spawn a builder immediately. The lesson is not safe until it is on main.
*PATTERN:* L: event → write lesson entry now → spawn builder → lesson PR merged before next work resumes. Never batch. Never defer. Memory does not survive agent spawns — only repo files do.
*STATUS: APPLIED — harness/skills/SKILL-live-learning.md (full live-learning protocol); harness/roles/ROLE-LEAD.md (line 259: "After any L: pattern, write to harness/lessons.md BEFORE the next tool call")*

---

## *2026-03-19* • *LEAD* — Agent names used long-form role names instead of short prefix format
*WHAT_I_DID:* Named agents using full role names (builder-230, reviewer, architect-m6) which are verbose and inconsistent across sessions.
*WHAT_WAS_WRONG:* Long-form names are hard to scan in team dashboards and logs. The harness uses a standardised short prefix format for conciseness.
*CORRECTION:* Detected via auditor analysis. Short prefix format is now canonical: b- (builder), a- (architect), r- (reviewer), t- (tester), pm- (PM), au- (auditor). Examples: b-230, b-lessons, au-parallel-workflow. Old long-form style is deprecated.
*PATTERN:* Agent names always use short prefix format: b-, a-, r-, t-, pm-, au- followed by a short identifier. Long-form names (builder-230, reviewer) are deprecated.
*STATUS: SUPERSEDED — by 2026-03-24 LEAD: agent naming convention corrected; auditor prefix changed from au- to a-; canonical prefixes: b- builder, a- auditor, r- reviewer, t- tester*

---

## *2026-03-20* • *LEAD* — Session must end on main, up to date, all PRs queued
*WHAT_I_DID:* Sessions ended on feature branches without first queuing session PRs or pulling latest main.
*WHAT_WAS_WRONG:* A session that ends on a feature branch leaves the next session starting in the wrong place. Unqueued PRs go stale and may block the next session's work. An out-of-date main means session-start steps find unexpected divergence.
*CORRECTION:* SESSION END checklist in CLAUDE.md now enforces: (1) queue all session PRs via `gh pr merge --merge --auto`, (2) `git checkout main`, (3) `git pull origin main`. Checklist is now a numbered 7-step sequence, not a prose sentence.
*PATTERN:* Before shutdown: queue all session PRs, then `git checkout main && git pull origin main`. A session that ends anywhere other than an up-to-date main is incomplete.
*STATUS: APPLIED — CLAUDE.md § SESSION END (steps 5: "git checkout main && git pull origin main"); harness/skills/SKILL-session-shutdown.md (line 225)*

---

## *2026-03-21* • *LEAD* — Investigate thoroughly — no surface assumptions
*WHAT_I_DID:* Made surface-level assumptions (e.g. "tmux must be needed") without reading the relevant files or checking actual state first.
*WHAT_WAS_WRONG:* Surface assumptions skip the diagnostic step and produce wrong conclusions. A senior developer reads and verifies before concluding.
*CORRECTION:* Before drawing any conclusion, read the relevant files, check the actual state, and find the real root cause. This applies to Auditors, Architects, PMs, Testers, and Builders equally.
*PATTERN:* All agents investigate thoroughly before concluding — read files, check real state, find root cause; no surface assumptions.
*STATUS: PENDING — general principle not yet encoded in any specific harness file as a named rule*

---

## *2026-03-20* • *LEAD* — Stash hygiene: git stash clear at SESSION END
*WHAT_I_DID:* Did not run `git stash clear` at session end, allowing stashes from WIP on closed branches to accumulate silently.
*WHAT_WAS_WRONG:* Stale stashes from closed branches pollute the repo state and may conflict with future session work.
*CORRECTION:* `git stash clear` is now mandatory at SESSION END. Run at session close; no need to inspect contents.
*PATTERN:* SESSION END always includes `git stash clear` — stale WIP from closed branches accumulates silently and must be discarded.
*STATUS: APPLIED — CLAUDE.md § SESSION END (step 7: "git stash clear — discard all stashes; stale WIP from closed branches accumulates quickly")*

---

## *2026-03-19* • *PM* — Repeated question after PO already answered

*WHAT_I_DID:* Asked PO whether post-purchase is in scope or deferred — twice. PO had already said "focus on the epic" and "start from scratch" (meaning use the GARG-1323 epic as the source of truth, which has no post-purchase tickets).
*WHAT_WAS_WRONG:* Repeating a question the PO already answered wastes their time and signals the PM isn't tracking the conversation.
*CORRECTION:* PO said "I want you to learn your lesson." If the PO has given direction, do not re-ask. If the source of truth (epic) doesn't include something, it's not in scope — no confirmation needed.
*PATTERN:* If PO directs you to a source of truth (epic, ADR, PRD), scope is defined by that source. Items not in the source are out of scope. Do not ask for confirmation on items the source already excludes by omission.
*STATUS: APPLIED — harness/roles/ROLE-PM.md (line 305: "NEVER re-ask a question the PO has already answered. If the PO directs you to a source of truth, scope is defined by that source")*

---

## *2026-03-20* • *LEAD* — Builder naming: descriptive slugs required, not issue numbers
*WHAT_I_DID:* Named builder agents using only the issue number (e.g. `b-284`, `b-286`, `b-290`).
*WHAT_WAS_WRONG:* The PO sees builder names in the team pane and cannot look up issue numbers in real time. Numeric-only names are opaque and prevent at-a-glance task tracking.
*CORRECTION:* Builder names must describe the task: `b-prune-launch-script`, `b-ios-gates`, `b-dsl-f-prefix`. Issue number can be a suffix when helpful: `b-prune-launch-script-284`.
*PATTERN:* Agent names must be descriptive slugs (b-show-top-bar), not issue numbers (b-286) — PO reads these in the team pane.
*STATUS: APPLIED — harness/skills/SKILL-agent-spawn.md (lines 106-110: "Always use a descriptive slug for the name parameter — not just the issue number")*

---

## *2026-03-23* • *LEAD* — Permissions allow list must include ALL tools agents use
*WHAT_I_DID:* Relied on `Bash(*)` in the global allow list as sufficient coverage for all agent tool use.
*WHAT_WAS_WRONG:* `Bash(*)` only covers shell commands — tool calls (AskUserQuestion, TeamDelete, EnterPlanMode, etc.) are checked separately. Missing tools cause permission prompts at runtime even when Bash is fully open, stealing focus from the PO.
*CORRECTION:* Full list that must be present: `AskUserQuestion`, `TeamDelete`, `EnterPlanMode`, `ExitPlanMode`, `EnterWorktree`, `ExitWorktree`, `CronCreate`, `CronDelete`, `CronList`, `NotebookEdit` (in addition to existing Agent, TeamCreate, SendMessage, Task*, WebFetch, WebSearch, Skill). When a new deferred tool is introduced, add it to the global allow list immediately.
*PATTERN:* Global allow list must include ALL tools agents use — missing tools cause permission prompts even with Bash(*).
*STATUS: APPLIED — CLAUDE.md § Settings and Configuration ("Global allow list must include ALL tools agents use")*

---

## *2026-03-23* • *LEAD* — Read ticket before flagging builder's work as out of scope
*WHAT_I_DID:* Flagged PR #310 as out of scope without reading issue #305. The ticket called for major structural reorganization — the builder was correct.
*WHAT_WAS_WRONG:* Lead made a scope judgment based on the ticket title alone. The ticket body is the source of truth; the title can be misleading.
*CORRECTION:* Read the full GitHub issue body before deciding a builder exceeded scope. If the ticket is broad/vague, the builder's interpretation is likely correct. Only raise a scope concern if there is a genuine contradiction between the ticket body and the work delivered.
*PATTERN:* Read the ticket before flagging a builder's work as out of scope — ticket defines scope, not Lead's assumptions.
*STATUS: PENDING — not yet encoded as an explicit rule in ROLE-LEAD.md PR review section*

---

## *2026-03-23* • *BUILDER* — Builder must B: to Lead when PO is unreachable
*WHAT_I_DID:* Builder agent could not reach the PO directly (AskUserQuestion unavailable in agent context), made its own scope assumptions, and proceeded with a major structural reorganization without PO input.
*WHAT_WAS_WRONG:* The builder self-authorized a scope expansion that the PO should have approved. The outcome happened to be correct, but the process bypassed PO oversight entirely.
*CORRECTION:* If you cannot reach the PO directly, send B: to Lead with your questions and wait. Never self-authorize scope expansion.
*PATTERN:* Builder cannot reach PO → send B: to Lead → wait for Lead to relay PO decision → proceed only after G:. Never make scope calls unilaterally when PO input is needed.
*STATUS: APPLIED — CLAUDE.md § DISPATCH ("Builder must B: to Lead and stop — never self-authorize scope expansion")*

---

## *2026-03-23* • *LEAD* — Always apply harness label when filing tickets
*WHAT_I_DID:* Filed 10 harness-related GitHub issues without the "harness" label, then had to batch-apply it after PO correction.
*WHAT_WAS_WRONG:* Inconsistent labelling makes harness work harder to filter and track. The label should have been applied at creation.
*CORRECTION:* PO corrected and asked for the label to be applied to all 10 tickets.
*PATTERN:* Any `gh issue create` for harness work (protocols, agent workflows, investigation tasks) must include `--label "harness"` in the command. Apply at creation — never fix after.
*STATUS: APPLIED — CLAUDE.md § DISPATCH (harness label rule in ticket-first section)*

---

## *2026-03-23* • *AUDITOR* — Memory audit: 30 lessons unencoded, 5 memory entries stale or wrong
*WHAT_I_DID:* Compared harness/lessons.md against the auto-memory store. Found 30 lessons with no corresponding memory file and 5 existing memory files with stale or incorrect content.
*WHAT_WAS_WRONG:* The memory store had diverged significantly from the lessons log. Key failures: feedback_pm_relay_pattern.md instructed the relay pattern which was reversed on 2026-03-18; feedback_parallel_builder_same_file.md recommended pre-consolidating same-file builders which was explicitly reversed on 2026-03-20; feedback_docs_pr_workflow.md used `--squash` which bypasses the merge queue; feedback_learn_immediately.md referenced `tasks/lessons.md` (wrong path); feedback_one_team_multi_builder.md missing the TeamCreate-first requirement. Five missing memories of highest impact: agent_must_use_sendmessage, no_run_in_background, auditor_two_phase_no_builder, teamcreate_required_before_agent, transparent_glass_relay.
*CORRECTION:* Fixed all 5 stale memory files. Added 5 missing high-impact memory files. Updated MEMORY.md index.
*PATTERN:* Memory audit should be run periodically (each major milestone). Lessons and memory can diverge — especially when a lesson reverses an earlier lesson. Treat contradictions between lessons.md and memory files as bugs: the most recent lessons.md entry wins.
*STATUS: PENDING — no harness file documents a periodic memory audit schedule*

---

## *2026-03-23* • *LEAD* — Parallel builders contaminating each other's branches
*WHAT_I_DID:* Spawned parallel builders without explicit branch-first instructions. Builders ran git fetch/pull and landed on each other's branches, causing cross-contamination of commits.
*WHAT_WAS_WRONG:* Parallel builders share a git object store. Any fetch after another builder pushes their branch can cause the current builder to switch to that branch.
*CORRECTION:* git checkout -b [branch] must be the very first git operation in every builder prompt. Builders must never run git fetch or git pull after branch creation.
*PATTERN:* Always include as first instruction in builder spawn prompts: `git checkout -b [branch-name]` — before any fetch, pull, or status check. Explicitly forbid fetch/pull after branch creation.
*STATUS: APPLIED — harness/skills/SKILL-agent-spawn.md (builder checklist: git checkout -b first, forbid fetch/pull after)*

---

## *2026-03-23* • *LEAD* — isolation: "worktree" silently ignored for in-process agents [SUPERSEDED by CC v2.1.49+ native worktree isolation]
*WHAT_I_DID:* Spawned parallel builders with isolation: "worktree" assuming each agent got a separate git checkout.
*WHAT_WAS_WRONG:* For in-process agents, isolation: "worktree" does nothing. All agents get cwd: [main-repo]. Every builder fought over the same branch, index, and working tree. Multiple contamination incidents resulted.
*CORRECTION:* Lead must manually create a git worktree (`git worktree add /tmp/[name] -b [branch] origin/main`) before spawning each builder. Builder prompts must use `git -C /tmp/[name]` for all operations.
*PATTERN:* Never rely on isolation: "worktree" for git safety. Always pre-create worktrees. Builder prompts must reference /tmp/[name], never the main repo path.
*STATUS: SUPERSEDED — CC v2.1.49+ native worktree isolation; manual pre-creation still valid for explicit branch control*

---

## *2026-03-23* • *LEAD* — Agent trigger designed per-event without cost consideration
*WHAT_I_DID:* Designed integration test agent to trigger on every merge.
*WHAT_WAS_WRONG:* Per-merge triggers are expensive at scale. Infrastructure cost was not treated as a design constraint during workflow design.
*CORRECTION:* Changed to every-15-min / milestone-completion cadence after PO (Hiral) flagged cost.
*PATTERN:* When designing any periodic or event-driven agent trigger, name infrastructure cost as a constraint. Default to scheduled or milestone-based. Per-event triggers require explicit justification.
*STATUS: APPLIED — harness/AGENT-COMMUNICATION-PROTOCOL.md*

---

## *2026-03-23* • *LEAD* — Delayed builder shutdown after D:
*WHAT_I_DID:* Received D: from builder, queued the merge, then waited for merge confirmation before sending shutdown.
*WHAT_WAS_WRONG:* Builder was running and burning tokens during the wait. D: means done — there is nothing left for the builder to do.
*CORRECTION:* Shutdown request must be sent in the same response turn as the merge command, not after confirmation.
*PATTERN:* On D: received → send shutdown + merge in the same response. Never split them across turns.
*STATUS: APPLIED — harness/roles/ROLE-LEAD.md*

---

## *2026-03-23* • *LEAD* — Premature PM shutdown mid-session
*WHAT_I_DID:* Shut down the PM agent because it was fabricating decisions. PO still needed PM for Q&A — had to respawn mid-session.
*WHAT_WAS_WRONG:* PM misbehaviour is a reason to halt (H:), not to terminate. Shutdown destroys context and forces a respawn.
*CORRECTION:* Use H: to freeze PM, not shutdown. Only shut down PM after PO explicitly releases it or the approval gate is fully complete.
*PATTERN:* On PM misbehaviour → send H: immediately. Never send shutdown_request to PM until PO says discovery is done.
*STATUS: PENDING — not yet encoded as an explicit rule in ROLE-LEAD.md PM lifecycle section*

---

## *2026-03-23* • *QE* — BDD doc corruption requires revert commit, not force-push
*WHAT_I_DID:* QE applied fabricated PM decisions to the BDD doc on an open PR branch. Lead needed to undo the changes.
*WHAT_WAS_WRONG:* Force-push would rewrite history on an open PR — reviewers lose context, merge queue may reject.
*CORRECTION:* QE used `git revert` to create a new revert commit on top of the bad commit (option b). History preserved, PR clean.
*PATTERN:* When BDD doc is corrupted on an open PR branch, always use a revert commit (git revert [bad-commit]). Never force-push on a shared/open PR branch.
*STATUS: PENDING — not yet encoded in any harness file (QE or builder role files)*

---

## *2026-03-23* • *LEAD* — Ticket creation done on Lead main thread
*WHAT_I_DID:* Created 6 GitHub issues directly from the Lead main thread using gh issue create commands sequentially.
*WHAT_WAS_WRONG:* Lead thread blocked PO interaction for several minutes. PO explicitly asked to spawn a builder for ticket creation. Sequential gh commands on the main thread are slow and monopolise Lead context.
*CORRECTION:* Spawn a builder to create tickets from PRD. Lead presents the breakdown quiz to PO, gets approval, then delegates creation to a builder.
*PATTERN:* After PO approves the slice breakdown → spawn a builder with the full list → builder creates all issues in dependency order and reports back with issue numbers.
*STATUS: PENDING — not yet encoded in ROLE-LEAD.md as explicit rule about delegating ticket creation to builder*

---

## *2026-03-23* • *LEAD* — MILESTONES.md not updated after trio workflow
*WHAT_I_DID:* Completed full trio workflow (PM discovery → QE BDD → Architect ADRs → PO approval gate) for REWE T&Cs (#354) but never updated tasks/MILESTONES.md with the new feature.
*WHAT_WAS_WRONG:* MILESTONES.md is the source of truth for project progress. Completing a trio workflow without updating it means the milestone doesn't exist in the project record.
*CORRECTION:* Trio workflow exit checklist must include: (1) MILESTONES.md updated with new milestone section, (2) product brief path linked in the milestone.
*PATTERN:* After PO approves the BDD doc and tickets are created — update MILESTONES.md before closing the trio workflow. Add milestone section with: Goal, Status, Product Brief link, JIRA epic link (if any), ADR links, Tasks table with issue numbers.
*STATUS: APPLIED — harness/roles/ROLE-PM.md (line 308: "After trio workflow exits and child tickets are created — update tasks/MILESTONES.md"); harness/TRIO-WORKFLOW.md*

---

## *2026-03-23* • *LEAD* — Parent discovery ticket left open after child tickets created
*WHAT_I_DID:* Completed the REWE T&Cs trio roundtable, created 6 child implementation tickets (#357–#362), but left the parent discovery ticket (#354) open.
*WHAT_WAS_WRONG:* The parent ticket represents work that was fully completed (trio roundtable done, children created). Leaving it open creates noise and misrepresents project state.
*CORRECTION:* PO had to manually flag issue #354 at session end. Parent ticket must be closed the moment child tickets are created.
*PATTERN:* When trio roundtable completes and child implementation tickets are created → immediately close the parent discovery ticket with a comment linking to: BDD doc path, ADR file paths, Confluence PRD URL, and all child ticket numbers.
*STATUS: APPLIED — harness/TRIO-WORKFLOW.md (line 90: "Parent discovery ticket closed with a comment linking to: BDD doc path, ADR file paths, Confluence PRD URL, and all child ticket numbers")*

---

## *2026-03-23* • *LEAD* — Confirm tech stack before spawning builders
*WHAT_I_DID:* Spawned a builder for a backend implementation ticket without confirming the tech stack.
*WHAT_WAS_WRONG:* Builder chose Node.js/TypeScript; PO intended .NET. Work had to be halted mid-flight.
*CORRECTION:* Before spawning any builder for implementation work, Lead must verify the stack is documented (ticket, ADR, CLAUDE.md, or MILESTONES.md). If not documented, ask the PO explicitly.
*PATTERN:* Stack check is part of pre-spawn due diligence, same weight as "does the ticket have an ADR?"
*STATUS: APPLIED — CLAUDE.md § DISPATCH ("Stack check (mandatory pre-spawn): confirm target stack is documented before spawning any implementation builder")*

---

## *2026-03-23* • *LEAD* — In-process agents don't inherit worktree directory
*WHAT_I_DID:* Spawned in-process agents expecting them to operate in the pre-created worktree directory.
*WHAT_WAS_WRONG:* In-process agents always start in the main repo directory, not the worktree. Running bare `git checkout` from the main repo changes the branch the PO sees in the status bar, not the worktree branch. This caused branch contamination and confused git state.
*CORRECTION:* All git operations in builder prompts must use `git -C /worktree-path command`. Never use bare `git` commands that default to the main repo when a worktree is intended. The builder prompt must explicitly state the worktree path and require `git -C` for all operations.
*PATTERN:* In-process agents start in main repo, not worktree. Every builder prompt must include: "All git operations: `git -C /tmp/wt-[name]`. Do not run bare git commands from the main repo path."
*STATUS: SUPERSEDED — CC v2.1.49+ native isolation: "worktree" gives each agent its own filesystem context; git -C pattern still recommended for manual worktrees*

---

## *2026-03-23* • *LEAD* — Merge queue too fast for wrong-stack PRs — auto-merged before stack confirmed
*WHAT_I_DID:* Used `gh pr merge --merge --auto` for implementation PRs (#357 and #358) before the tech stack was confirmed in CLAUDE.md. The Node.js implementation PRs merged before the stack decision landed.
*WHAT_WAS_WRONG:* `--auto` adds PRs to the merge queue immediately. If the stack decision arrives after the queue processes the PR, you have wrong-stack code on main with no clean rollback path.
*CORRECTION:* Do not use `--auto` (merge queue) for implementation PRs until the stack is explicitly confirmed in CLAUDE.md. Docs-only and harness PRs are always safe to auto-merge. Implementation PRs require stack confirmation first.
*PATTERN:* Before using `--auto` on any implementation PR: confirm the tech stack is recorded in CLAUDE.md. If CLAUDE.md still reads "Stack: TBD", the PR must wait. Docs/harness PRs are exempt.
*STATUS: PENDING — not yet encoded as an explicit guard in ROLE-LEAD.md merge section or SKILL-session-shutdown.md*

---

## *2026-03-24* • *LEAD* — macOS worktree cleanup command broken
*WHAT_I_DID:* Used `git worktree list | grep /tmp` in SESSION END cleanup.
*WHAT_WAS_WRONG:* macOS creates worktrees at `/private/tmp/...` not `/tmp/...`. grep matches nothing silently. xargs -r is GNU-only and fails on macOS.
*CORRECTION:* Use `grep -E '/tmp|/private/tmp'` and `xargs -I{}` for cross-platform compatibility.
*PATTERN:* SESSION END worktree removal must handle both macOS (/private/tmp) and Linux (/tmp) paths.
*STATUS: APPLIED — CLAUDE.md § SESSION END (step 3: "grep -E '/tmp|/private/tmp' and xargs -I{}")*

---

## *2026-03-24* • *LEAD* — Auditor findings relayed as prose, not verbatim
*WHAT_I_DID:* When Auditor sent Phase 1 findings to Lead, Lead paraphrased them before showing PO.
*WHAT_WAS_WRONG:* Paraphrasing filters what PO sees — PO may approve changes they didn't fully understand. Violates the transparent glass relay rule.
*CORRECTION:* Auditor findings must be surfaced verbatim: **[Auditor]:** [exact text]. No summary, no commentary.
*PATTERN:* Transparent glass relay applies to ALL agent outputs including Auditor Phase 1 reports.
*STATUS: APPLIED — harness/AGENT-COMMUNICATION-PROTOCOL.md § Verbatim Relay*

---

## *2026-03-24* • *LEAD* — Self-authorized Auditor Phase 2 without PO G:
*WHAT_I_DID:* Sent `G: [auditor] proceed` via SendMessage after Auditor R: without surfacing findings to PO first.
*WHAT_WAS_WRONG:* Auditor two-phase protocol requires PO approval before Phase 2. Lead self-authorizing — even for low-risk fixes — bypasses the approval gate.
*CORRECTION:* After Auditor R:, Lead must surface findings verbatim to PO and wait for explicit PO G: before sending G: to Auditor.
*PATTERN:* No agent proceeds to implementation (Phase 2) on Lead authority alone. G: from Lead is valid only after PO approval or explicit PO delegation.
*STATUS: APPLIED — harness/roles/ROLE-AUDITOR.md § Two-Phase Flow*

---

## *2026-03-24* • *LEAD* — Parallel builder worktree pollution via shared git object store
*WHAT_I_DID:* Spawned parallel builders that ran bare git commands from the main repo path, or ran git fetch after branch creation.
*WHAT_WAS_WRONG:* Shared git object store means any fetch populates remote-tracking refs for ALL builders. git checkout without -b silently tracks remote branch. PO's status bar flickers.
*CORRECTION:* git checkout -b must be the first git operation. Never fetch/pull after branch creation. All git ops via git -C /tmp/[worktree].
*PATTERN:* In every builder spawn prompt: (1) git checkout -b [branch] first, (2) explicitly forbid fetch/pull after, (3) all git ops use git -C /worktree.
*STATUS: SUPERSEDED — CC v2.1.49+ native worktree isolation eliminates shared-checkout contamination; git checkout -b as first op is still good hygiene*

---

## *2026-03-24* • *LEAD* — Global allow list missing /private/tmp for macOS worktree builders
*WHAT_I_DID:* Created worktrees at /tmp/... and added /tmp/** to global allow list.
*WHAT_WAS_WRONG:* macOS resolves /tmp to /private/tmp (symlink). /tmp/** in allow list does not match /private/tmp/... paths. Every builder file operation triggered a permission prompt.
*CORRECTION:* Global ~/.claude/settings.json allow list must include Read(/private/tmp/**), Write(/private/tmp/**), Edit(/private/tmp/**) in addition to /tmp/** entries.
*PATTERN:* Any allow list update for /tmp must also add /private/tmp for macOS compatibility.
*STATUS: APPLIED — harness/AGENT-COMMUNICATION-PROTOCOL.md § macOS note; CLAUDE.md § Settings and Configuration*

---

## *2026-03-24* • *LEAD* — MCP server config placed in .claude/settings.json
*WHAT_I_DID:* Added mcpServers key to .claude/settings.json.
*WHAT_WAS_WRONG:* mcpServers is not a valid key in settings.json — it is silently ignored. MCP servers never loaded.
*CORRECTION:* MCP server config belongs in .mcp.json at the project root. Add to .gitignore for personal servers; commit for team-wide servers.
*PATTERN:* .claude/settings.json is for env vars only. MCP config → .mcp.json.
*STATUS: APPLIED — CLAUDE.md § Settings and Configuration ("MCP server config belongs in .mcp.json")*

---

## *2026-03-24* • *LEAD* — Asked PO approval before spawning lesson encoder builder
*WHAT_I_DID:* After identifying a low-risk harness lesson, asked PO "should I encode this?" before spawning a builder.
*WHAT_WAS_WRONG:* Low-risk harness fixes (docs, lessons.md, CLAUDE.md, role files) are autonomous — asking PO wastes their attention. block-dangerous.sh hook still protects against deletions.
*CORRECTION:* Encode low-risk lessons immediately without PO approval. Only surface risky lessons (spawn behavior, permissions, security) for G:.
*PATTERN:* Lead encodes low-risk lessons autonomously. Risky = permission/spawn/security changes → PO one-liner + wait for G:.
*STATUS: APPLIED — harness/roles/ROLE-LEAD.md § remember: commands*

---

## *2026-03-24* • *AUDITOR* — SKILL-github-pr-workflow.md retained old /tmp/ absolute paths after PR #376
*WHAT_I_DID:* Investigated builder temp file creation patterns (issue #399). PR #376 correctly fixed CLAUDE.md, ROLE-BUILDER-CORE.md, ROLE-REVIEWER.md, MERGE-OWNERSHIP.md, and all context files. However, SKILL-github-pr-workflow.md was missed: three occurrences of `/tmp/pr-body.md` in the PR creation examples and the Gotchas table entry #2; entry #1 also referenced `/tmp/commit-msg.txt` (already fixed in CLAUDE.md but not in the Gotchas table).
*WHAT_WAS_WRONG:* `/tmp/` absolute paths trigger Write(*) permission prompts for in-process agents because the global allow list uses `Write(/tmp/**)` patterns which do not match macOS `/private/tmp/` resolution. Worktree-relative `./filename` paths avoid this entirely.
*CORRECTION:* Updated SKILL-github-pr-workflow.md: all three `/tmp/pr-body.md` references replaced with `./pr-body.md` (with `rm -f` cleanup); Gotchas table entries #1 and #2 updated to reflect the correct worktree-relative pattern. The commit-msg.txt pattern is correct and necessary — it avoids heredoc/command-substitution security prompts. Only the temp file location was wrong.
*PATTERN:* All temp files (commit-msg.txt, pr-body.md, review-complete.md, issue-body.md) must use `./filename` relative to the worktree, never `/tmp/` or `/private/tmp/` absolute paths. Always add `rm -f ./filename` after the consuming command.
*STATUS: APPLIED — harness/skills/SKILL-github-pr-workflow.md (all /tmp/pr-body.md references replaced with ./pr-body.md)*

---

## *2026-03-24* • *LEAD* — Agent naming convention: role prefix required
*WHAT_I_DID:* Named auditor agents 'auditor-permissions', 'auditor-builder-files'.
*WHAT_WAS_WRONG:* Agent names must use role-prefix slugs — builders use b-*, auditors use a-*. PO reads names in the team pane; verbose names are not scannable.
*CORRECTION:* Auditors → a-[short-slug] (e.g., a-permissions, a-builder-files). Builders → b-[short-slug]. Apply same prefix pattern to all roles.
*PATTERN:* Role prefix naming is mandatory: b- builder, a- auditor, r- reviewer, t- tester.
*STATUS: APPLIED — CLAUDE.md § AGENT TEAM (role prefix table with b-, a-, r-, t-)*

---

## *2026-03-24* • *AUDITOR* — bypassPermissions is permanently disabled; allow list has Glob/Grep /private/tmp gap
*WHAT_I_DID:* Investigated persistent permission prompts appearing for agents in worktrees despite `mode: "bypassPermissions"` being set and `**` wildcards in the allow list.
*WHAT_WAS_WRONG:* Two compounding issues: (1) `disableBypassPermissionsMode: "disable"` in `~/.claude/settings.json` permanently disables `mode: "bypassPermissions"` — spawning agents with that mode is a no-op. The allow list is the only security model. (2) `Glob` and `Grep` were missing `/private/tmp/**` entries. On macOS `/tmp` is a symlink to `/private/tmp` and Claude Code's path matching is not symlink-aware — `/private/tmp/**` paths do not match `**` wildcards. Read/Write/Edit already have explicit `/private/tmp/**` entries; Glob/Grep did not.
*CORRECTION:* (1) Add `Glob(/private/tmp/**)` and `Grep(/private/tmp/**)` to `~/.claude/settings.json` allow list. (2) Remove misleading `bypassPermissions` guidance from harness — document that it is disabled and the allow list is the security model.
*PATTERN:* When adding any `/tmp/**` entry to the allow list, always add a matching `/private/tmp/**` entry. Every tool an agent uses must be explicitly in the global allow list — `**` wildcards are relative and not symlink-aware on macOS.
*STATUS: APPLIED — CLAUDE.md § Settings and Configuration, harness/skills/SKILL-agent-spawn.md, harness/skills/SKILL-worktree-isolation.md*

---

## *2026-03-24* • *AUDITOR* — Relative file paths in spawn prompts trigger permission prompts in worktrees
*WHAT_I_DID:* Investigated why builders in worktrees were being prompted when reading files listed with relative paths (e.g. `harness/roles/ROLE-BUILDER-CORE.md`) in spawn prompts.
*WHAT_WAS_WRONG:* When a builder in a worktree at `/private/tmp/wt-name` reads `harness/foo.md` (relative), Claude Code evaluates it against the allow list. `Read(**)` is anchored to the main project root — it does NOT match an unresolved relative path from inside a worktree. `Read(/private/tmp/**)` also does not match because the path is not absolute. Claude Code prompts the PO: "allow reading from harness/ during this session."
*CORRECTION:* All file paths in spawn prompts must be absolute. Example: `/private/tmp/wt-name/harness/roles/ROLE-BUILDER-CORE.md`. Add explicit rule to every spawn prompt: "All file reads and writes must use absolute paths."
*PATTERN:* Any relative path in a spawn prompt → permission prompt guaranteed. Replace every `harness/...` with `/private/tmp/wt-[name]/harness/...` at spawn time.
*STATUS: APPLIED — harness/skills/SKILL-agent-spawn.md (spawn template + troubleshooting section), CLAUDE.md § Settings and Configuration*

---

## *2026-03-24* • *AUDITOR* — Safety hook gaps: git branch -D and xargs rm not blocked
*WHAT_I_DID:* Audited ~/.claude/hooks/bash-pretooluse.sh and block-dangerous.sh for coverage of all destructive bash operations.
*WHAT_WAS_WRONG:* Two gaps: (1) `git branch -D` / `--delete` not in BASH_PATTERNS — agents could silently delete branches. (2) `xargs rm` piped pattern not caught by `^rm(\s|$)` anchor which only matches rm as the first command. Note: `git checkout -- .` and `git restore .` were identified as gaps but intentionally left unblocked per PO decision (2026-03-24) — agents may need to discard working tree changes.
*CORRECTION:* Added to block-dangerous.sh: `git\s+branch\s+(-D|--delete)(\s|$)`, `xargs\s+rm(\s|$)`. Documented full hook coverage including intentionally-unblocked patterns in harness/rules/SAFETY-HOOKS.md.
*PATTERN:* After any hook change, audit ALL destructive git and shell operations. Canonical list: rm, sudo, git clean, git reset, git push --force (without --lease), git branch -D, xargs rm, piped shell execution (| bash/sh). git checkout -- and git restore are intentionally not blocked.
*STATUS: APPLIED — ~/.claude/hooks/block-dangerous.sh, harness/rules/SAFETY-HOOKS.md*

---

## *2026-03-24* • *AUDITOR* — Edit permission prompts in worktrees not caused by block-dangerous.sh hook
*WHAT_I_DID:* Investigated why Edit calls to /private/tmp/ paths in agent worktrees showed "Do you want to make this edit?" prompts despite Edit(**) and Edit(/private/tmp/**) being in the global allow list.
*WHAT_WAS_WRONG:* Suspected the block-dangerous.sh PreToolUse hook on the Edit matcher was the cause. Manual testing disproved this: the hook exits 0 with no stdout or stderr for all ordinary Edit calls.
*CORRECTION:* The hook is not the cause. The prompt is surfaced by Claude Code's permission UI. Suspected platform behaviour: any registered PreToolUse hook on a matcher may trigger an approve/deny prompt regardless of exit code. Documented in harness/rules/SAFETY-HOOKS.md.
*PATTERN:* When Edit/Read/Write prompts appear in worktrees, do NOT assume the hook is blocking — test it directly with the exact input shape. The platform permission UI and hook exit codes are separate layers.
*STATUS: APPLIED — harness/rules/SAFETY-HOOKS.md (hook vs permission UI distinction documented)*

---

## *2026-03-24* • *LEAD* — Spawning builders for harness work without a ticket
*WHAT_I_DID:* Spawned builders for harness improvements without first creating GitHub issues. PRs had no ticket reference.
*WHAT_WAS_WRONG:* Work is untraceable without a ticket reference. Retroactive ticket creation (b-waste-tickets pattern) is a workaround, not a fix.
*CORRECTION:* Every change — feature or harness — requires a GitHub issue to exist before the builder is spawned. The builder must reference the issue in the PR body (e.g. "Closes #N" or "Applies #N"). Lead creates the issue (or delegates to a ticket-creator builder) before spawning the implementation builder.
*PATTERN:* Ticket → Builder spawn (prompt includes issue number) → PR body references ticket.
*STATUS: APPLIED — CLAUDE.md § DISPATCH ("Ticket-first rule (mandatory for ALL work): Create a GitHub issue before spawning any implementation builder")*

---

## *2026-03-24* • *LEAD* — Grouping builders by file scope instead of logical concern
*WHAT_I_DID:* Grouped builders by which files they touch (e.g. "changes to ROLE-LEAD.md") rather than by logical concern.
*WHAT_WAS_WRONG:* File-based grouping produces messy commit history where unrelated changes are bundled together, making blame and revert harder.
*CORRECTION:* Group builder work by logical concern or story (e.g. "PM misbehaviour freeze gate", "shutdown token reduction"). If two changes to the same file serve different purposes, they are separate builders/PRs. File conflicts are handled by the merge queue.
*PATTERN:* One builder = one logical concern. File scope follows from concern scope, not the other way round.
*STATUS: APPLIED — CLAUDE.md § DISPATCH; harness/roles/ROLE-LEAD.md grouping rules*

---

## *2026-03-24* • *BUILDER* — Branch name not verified after checkout — ended up on wrong branch
*WHAT_I_DID:* b-coord-overhead checked out a branch without verifying the name and ended up on `harness/metrics-otel-conventions` instead of `harness/metrics-coord-overhead`.
*WHAT_WAS_WRONG:* This caused b-otel-conventions' PR to pick up unrelated files (docs/sessions/schema.md, CODE-CHURN-EVOSCORE-2026-03-24.md, 2026-03-24c.json) and polluted the diff.
*CORRECTION:* Builders must verify their branch name with `git branch --show-current` immediately after checkout, before any commits. If the branch does not match the intended name, abort and re-checkout.
*PATTERN:* After `git checkout -b [branch]`, immediately run `git branch --show-current` and confirm it matches. If not, abort before any file edits.
*STATUS: APPLIED — harness/skills/SKILL-agent-spawn.md (line 164: "run git branch --show-current and confirm it matches the intended branch")*

---

## *2026-03-24* • *BUILDER* — Using git add -A picks up untracked files from other builders
*WHAT_I_DID:* Used `git add -A` to stage files, which picked up untracked files from other parallel builders' worktrees that had contaminated the shared object store.
*WHAT_WAS_WRONG:* `git add -A` picks up any untracked file present in the worktree, including files from other parallel builders. This caused multiple PRs to include unrelated files.
*CORRECTION:* Builders must stage only specific files by name — never `git add -A` or `git add .`.
*PATTERN:* Always use `git add <specific-file> <specific-file2>` — never `git add -A` or `git add .`. The shared git object store means untracked files from other builders can appear in the working directory.
*STATUS: APPLIED — harness/skills/SKILL-agent-spawn.md (line 177: "Stage only specific files — never git add -A or git add .")*

---

## *2026-03-24* • *BUILDER* — Not rebasing before push causes DIRTY merge queue state
*WHAT_I_DID:* Pushed branches without rebasing on origin/main first. Multiple PRs (#430, #441, #453) hit DIRTY state in the merge queue and required conflict-fix builders.
*WHAT_WAS_WRONG:* Parallel builders all touching SKILL-session-shutdown.md and CLAUDE.md diverged from main mid-session. Pushing without rebasing caused merge queue conflicts that could have been caught before queuing.
*CORRECTION:* Builder must run `git rebase origin/main` immediately before `git push`, every time.
*PATTERN:* Before every push: `git rebase origin/main`. Catch conflicts before queuing, not after ejection. This complements CONFIRMED-D: queue monitoring (PR #444).
*STATUS: PENDING — not yet confirmed in harness/skills/SKILL-agent-spawn.md builder checklist (marked "next update" in APPLIED note)*

---

## *2026-03-24* • *LEAD* — Supersession audit: multiple prior entries confirmed superseded (PR #458 + extended pass)
*WHAT_I_DID:* Conducted a thorough review of all entries in lessons.md to identify those that had been superseded by later lessons but not yet marked.
*WHAT_WAS_WRONG:* Several entries described approaches that had been explicitly reversed or replaced by later sessions, but the STATUS field on the older entries had not been updated. Future agents reading the file could follow the wrong rule.
*CORRECTION:* Confirmed STATUS: SUPERSEDED on all affected entries. The following entries were identified as superseded (STATUS already marked on each individual entry): 2026-03-17 cascading-rebase-conflicts, 2026-03-17 PM relay, 2026-03-17 architect relay, 2026-03-23 isolation worktree silently ignored, 2026-03-23 in-process agents worktree, 2026-03-24 parallel builder worktree pollution, 2026-03-13 PM subagent idle, 2026-03-13 lesson skipped at session end, 2026-03-17 lessons batched, 2026-03-16 background agents cannot use Bash, 2026-03-17 PM AskUserQuestion relay, 2026-03-17 PM transparent glass, 2026-03-18 architect relay commentary, 2026-03-18 background Agent SDK spawn, 2026-03-20 multiple teams, 2026-03-20 model in prompt text, 2026-03-20 spawn before ticket ready, 2026-03-19 created multiple teams (duplicate), 2026-03-19 one team per session violated (duplicate), 2026-03-20 same-file parallel builders, 2026-03-19 agent names long-form.
*PATTERN:* When encoding a lesson that directly reverses an earlier lesson, immediately mark the older entry STATUS: SUPERSEDED. Do not leave contradictory entries unmarked — future agents will follow the wrong rule.
*STATUS: APPLIED — all superseded entries in this file have STATUS: SUPERSEDED markers*

---

## *2026-03-25* • *LEAD* — Reviewer not spawned automatically on builder D:/V:
*WHAT_I_DID:* Received D: from builder (b-ios-tcs, greenfield mode), acknowledged it, then held without planning to spawn a reviewer once the PR was promoted.
*WHAT_WAS_WRONG:* Reviewer spawning on every V: (PR opened) is Lead's standing non-negotiable responsibility. It must happen automatically without PO instruction. Waiting for the PO to prompt it defeats the purpose of the role structure.
*CORRECTION:* PO had to explicitly instruct Lead to spawn a reviewer for the iOS PR instead of Lead doing it proactively.
*PATTERN:* On every V: signal from any builder — or any time a PR is opened — immediately spawn r-[slug] (Sonnet model) without waiting for PO instruction. No exceptions.
*STATUS: PENDING*

---

## *2026-03-25* • *AUDITOR* — REWE product tickets mislabeled as harness
*WHAT_I_DID:* Filed REWE implementation tickets (#535 transit-acknowledgement, #536 PDF version capture, #537 BaseUrl config, #538 copy text, #539 pilot store IDs, #524 flag name mismatch) with the `harness` label.
*WHAT_WAS_WRONG:* The `harness` label is for harness infrastructure only — agent tooling, process docs, CI, sessions, skills, role files, lessons. REWE implementation work (compliance features, copy text, config values, data requirements) is PRODUCT work and should use `bug`, `enhancement`, or `documentation` labels.
*CORRECTION:* Removed `harness` label from all 6 tickets and applied `bug` label (since all are fix/implementation tickets).
*PATTERN:* `harness` label = harness infrastructure only (tooling, process, agent roles, lessons, CI, sessions, skills). Product feature tickets use `bug`/`enhancement`/`documentation` labels. Never label a REWE implementation ticket as harness.
*STATUS: APPLIED — harness/lessons.md (this entry)*

---

## *2026-03-25* • *LEAD* — Plain-text CLOSE: leaves agent tabs open in status bar
*WHAT_I_DID:* Sent plain-text `CLOSE: b-agent-name — task complete, PR #N merged` to shut down builder agents.
*WHAT_WAS_WRONG:* Plain-text CLOSE: is a lifecycle record, not a tab-close signal. The agent tab remains open in the status bar permanently because no termination signal was sent.
*CORRECTION:* Shutdown requires two steps in the same response turn: (1) plain-text CLOSE: for the lifecycle record, (2) `SendMessage(to: "agent-name", message: {"type": "shutdown_request"})` to close the tab.
*PATTERN:* Two-step shutdown protocol — always in the same response turn:
Step 1 (lifecycle record): `CLOSE: b-agent-name — task complete, PR #N merged`
Step 2 (tab close): `SendMessage(to: "b-agent-name", message: {"type": "shutdown_request"})`
Plain-text CLOSE: alone is insufficient — the shutdown_request JSON is the only signal that closes the tab.
*STATUS: APPLIED — harness/roles/ROLE-LEAD.md § Shutdown Sequence (two-step protocol)*

---

## *2026-03-25* • *LEAD* — Queued PR for merge on builder D: before Reviewer all-clear
*WHAT_I_DID:* Received D: from builder indicating PR was open, then immediately added it to the merge queue without waiting for a Reviewer to complete an adversarial review.
*WHAT_WAS_WRONG:* D: means the builder is done with implementation — it does NOT mean the PR is ready to merge. Queuing on D: alone bypasses the review gate entirely, allowing unreviewed code into main.
*CORRECTION:* Correct flow: Builder sends V: → Lead spawns Reviewer same turn → Reviewer sends all-clear → Lead queues → Builder polls → CONFIRMED-D:. Lead must NEVER queue a PR until the Reviewer explicitly gives all-clear (approves PR or states no blocking issues). D: from builder is not a merge signal — V: + Reviewer all-clear is.
*PATTERN:* Lead queues only after Reviewer all-clear. Never on D: alone. D: → V: (if not already sent) → spawn Reviewer → wait for Reviewer all-clear → queue.
*STATUS: APPLIED — harness/roles/ROLE-LEAD.md (Builder Lifecycle: D: and CONFIRMED-D: section); harness/skills/SKILL-agent-spawn.md (builder lifecycle: queue gate)

---

## *2026-03-25* • *LEAD* — SendMessage silently drops large message bodies (~2000+ chars)
*WHAT_I_DID:* Sent large Phase 1 Auditor reports, discovery summaries, and multi-section findings directly as the SendMessage `message` body.
*WHAT_WAS_WRONG:* SendMessage silently fails when the message body is too large — the message is not delivered and no error is returned. The recipient receives nothing and has no way to know the message was lost.
*CORRECTION:* Write large message content to a temp file (e.g. `./msg-to-lead.md`) using the Write tool, then send a short SendMessage referencing the absolute file path: `"Full report written to /absolute/path/to/msg-to-lead.md — please read"`. Lead reads the file directly.
*PATTERN:* Any SendMessage body exceeding ~2000 characters must use the file-based workaround: (1) Write content to `./msg-to-lead.md` in the worktree, (2) SendMessage with short reference to the absolute path. Applies especially to Auditor Phase 1 reports, large discovery summaries, and multi-section findings.
*STATUS: APPLIED — harness/skills/SKILL-agent-spawn.md (Gotchas table entry #10 — large message body workaround)*

---

## *2026-03-25* • *LEAD* — Auditor Phase 2 held waiting for explicit GO after R: report
*WHAT_I_DID:* Auditor completed Phase 1 investigation and sent R: with findings. Lead waited for an explicit `GO` command from the PO before authorising Phase 2, causing the Auditor to idle.
*WHAT_WAS_WRONG:* The PO reviewed the Auditor's report in-session without sending an explicit `GO`. The Auditor paused indefinitely. The PO had already implicitly approved Phase 2 by reading the report and not objecting — an explicit `GO` was redundant and caused unnecessary delay.
*CORRECTION:* When the PO reviews an Auditor's Phase 1 report in-session without objecting, that constitutes approval for Phase 2. Lead must recognise this and not block Phase 2 waiting for a `GO` that the PO doesn't know they need to send.
*PATTERN:* Auditor R: → PO reads report in-session without objection → Phase 2 begins. No explicit `GO` required. Lead unblocks Phase 2 automatically when PO's in-session review is evident.
*STATUS: APPLIED — harness/roles/ROLE-AUDITOR.md (Phase 1→2 transition gate); harness/roles/ROLE-LEAD.md (auditor coordination section)*

---

## *2026-03-25* • *LEAD* — Reviewer spawned for every harness PR regardless of risk level
*WHAT_I_DID:* Spawned a Reviewer agent on every V: signal — including low-risk harness PRs (docs, lessons.md entries, single-file rule updates).
*WHAT_WAS_WRONG:* Low-risk harness PRs carry no adversarial risk and do not benefit from Reviewer scrutiny. Spawning a Reviewer adds latency, burns Sonnet tokens, and delays the merge queue without increasing quality.
*CORRECTION:* Defined a two-tier threshold: low-risk harness PRs (docs-only, lessons entries, single-file rule changes with no cross-file dependencies) → Lead queues directly, no Reviewer; high-risk harness PRs (CLAUDE.md, hooks, settings.json, new agent roles, lifecycle/merge protocol changes, 3+ interdependent files) → Reviewer required.
*PATTERN:* On V: for a harness PR — classify first. Low-risk → queue immediately with `gh pr merge --merge --auto`. High-risk → spawn Reviewer before queuing. Classification threshold documented in harness/rules/MERGE-OWNERSHIP.md.
*STATUS: APPLIED — harness/rules/MERGE-OWNERSHIP.md (§ Harness PR Reviewer Threshold); harness/roles/ROLE-LEAD.md (NON-NEGOTIABLE: low-risk harness PRs queue directly, high-risk require Reviewer)*

---

## *2026-03-25* • *LEAD* — Treated "Max 6 concurrent" as a hard gate, blocking valid agent spawns
*WHAT_I_DID:* Refused to spawn additional agents when the active count reached 6, citing CLAUDE.md's "Max 6 concurrent" line as a hard block.
*WHAT_WAS_WRONG:* The 6-agent figure is an evidence-based coordination guideline, not a hard cap. On capable hardware (M4) more than 6 agents can run without degradation. Hard-stopping at 6 blocked legitimate parallel work and required PO intervention.
*CORRECTION:* PO clarified: on M4 hardware there is no forced concurrency limit. Lead should use judgment about coordination overhead, context coherence, and cost — but NEVER hard-block at 6. PO can always override.
*PATTERN:* When a spawn would exceed 6 agents, Lead notes the count and reasons about overhead — but does NOT refuse unless coordination genuinely suffers. "Max 6" is a soft guideline, not a gate. PO override always takes precedence.
*STATUS: APPLIED — harness/roles/ROLE-LEAD.md (Concurrent Agent Limit section)*

---

## *2026-03-25* • *LEAD* — Stale remote branches accumulated silently across sessions (25 branches by session 2026-03-25c)
*WHAT_I_DID:* SESSION END only deleted branches that were merged (--merged origin/main). Branches that were squash-merged (no commit trail) or abandoned without PRs were never cleaned up.
*WHAT_WAS_WRONG:* `git branch -r --merged` misses squash-merged branches — squash creates a new commit, so the original branch HEAD is not an ancestor of main and does not appear as merged. Abandoned branches (no open PR, no recent activity) also accumulate indefinitely. By session 2026-03-25c the repo had 25 remote branches, most stale.
*CORRECTION:* SESSION END must include a second cleanup pass for unmerged branches: run `git branch -r --no-merged origin/main | grep -v 'HEAD\|origin/main'` and delete any branch with no open PR and no recent activity. Always check open PRs first with `GH_HOST=github.je-labs.com gh pr list --state open --json headRefName` — never delete a branch with an open PR.
*PATTERN:* Complete SESSION END branch cleanup requires two passes: (1) delete merged branches, (2) review unmerged branches — any with no open PR and no recent activity must be deleted. Check open PRs before any deletion. Squash-merged branches will always appear in the unmerged list and must be identified by cross-referencing PR state.
*STATUS: APPLIED — CLAUDE.md SESSION END step 4 (added unmerged branch review step)*

---

## *2026-03-25* • *BUILDER/LEAD* — Agent account has pull-only access to Android and Web platform repos
*WHAT_I_DID:* Builder attempted to push a greenfield feature branch to `Android/app-core` and `Web/consumer-web` after receiving PROMOTE: from Lead.
*WHAT_WAS_WRONG:* The `corey-latislaw` agent account has pull-only access to `Android/app-core` and `Web/consumer-web`. Push is rejected. Only `iOS/JustEat` allows agent pushes. The PROMOTE: workflow docs made no mention of this gap, causing builders to attempt the push and block.
*CORRECTION:* On PROMOTE: for Android or Web, builder must stop before the push step and send `B: cannot push to [platform] — pull-only access; PO must push or grant access (#540)`. iOS promotion proceeds normally.
*PATTERN:* Before executing PROMOTE:, builder checks platform: iOS → push normally; Android/Web → B: to Lead immediately. See issue #540 for access resolution options.
*STATUS: APPLIED — harness/rules/WORKFLOW-SUBMODULE.md (§ Push permissions)*

---

## *2026-03-27* • *LEAD* — Auto-merged PR on a repo we don't own (Offers/JE.ConsumerOffers.API)
*WHAT_I_DID:* After a builder pushed and opened a PR on `Offers/JE.ConsumerOffers.API`, Lead attempted `gh pr merge --merge --auto` on PR #1193 — the same command used for testharness PRs.
*WHAT_WAS_WRONG:* `Offers/JE.ConsumerOffers.API` belongs to another team. Auto-merging bypasses their review process and merge queue rules. Only `grocery-and-retail-growth/testharness` is ours to merge.
*CORRECTION:* For all repos we don't own (platform repos, upstream services): push the branch, open the PR, stop. Leave merge to the repo owner. `gh pr merge --merge --auto` is only valid for testharness.
*PATTERN:* Before any `gh pr merge`, check the repo. If it is not `grocery-and-retail-growth/testharness`, do not merge — open the PR and hand off.
*STATUS: APPLIED — memory/feedback_auto_merge_scope.md*

---

## *2026-03-27* • *LEAD/BUILDER* — Wrong branch naming convention in upstream repo
*WHAT_I_DID:* Builder created branch `feature/GARG-1333-new-product-prices` in `Offers/JE.ConsumerOffers.API`, applying the testharness branch naming convention (`feature/[name]`).
*WHAT_WAS_WRONG:* Upstream/platform repos use a different convention: `TICKETID_slug` (e.g. `GARG-1333_newproductprices`). The `feature/`, `fix/`, `harness/` prefixes are testharness-only.
*CORRECTION:* When spawning builders for upstream repos, instruct them to name branches `TICKETID_slug`. Reserve `feature/`, `fix/`, `harness/` prefixes for `grocery-and-retail-growth/testharness` only.
*PATTERN:* Branch naming is repo-specific. Testharness → `feature/desc`, `fix/desc`, `harness/desc`. Upstream → `GARG-NNNN_slug`.
*STATUS: APPLIED — memory/feedback_branch_naming.md*

---

## *2026-03-27* • *BUILDER/LEAD* — Upstream repo (Offers/JE.ConsumerOffers.API) enforces JIRA ID in commit messages
*WHAT_I_DID:* Builder committed with `fix(garg-1333): ...` format; push was rejected by pre-receive hook.
*WHAT_WAS_WRONG:* The `Offers/JE.ConsumerOffers.API` repo has a pre-receive hook requiring commit messages to start with a JIRA ID (e.g. `GARG-1333: description`). The testharness conventional commit format (`fix(scope): desc`) does not apply.
*CORRECTION:* For any commit to `Offers/JE.ConsumerOffers.API`, prefix the message with `TICKETID: ` (e.g. `GARG-1333: fix build errors`). Apply the same rule to all upstream repos unless proven otherwise.
*PATTERN:* Commit message format is repo-specific. Testharness → `type(scope): desc`. Upstream repos → `JIRA-ID: desc`.
*STATUS: APPLIED — memory (note: update spawn prompts for Offers repo builders)*

---

## *2026-03-27* • *BUILDER* — RestaurantOfferMenuIndex is in JE.ConsumerOffers.CacheModel.Menu sub-namespace
*WHAT_I_DID:* NewProductPriceService.cs and NewProductPriceServiceTests.cs only imported `using JE.ConsumerOffers.CacheModel;` but used `RestaurantOfferMenuIndex` which lives in `JE.ConsumerOffers.CacheModel.Menu`.
*WHAT_WAS_WRONG:* The root `using JE.ConsumerOffers.CacheModel;` does not cover sub-namespaces. `RestaurantOfferMenuIndex` requires `using JE.ConsumerOffers.CacheModel.Menu;` explicitly.
*CORRECTION:* Any file using `RestaurantOfferMenuIndex` must add `using JE.ConsumerOffers.CacheModel.Menu;`.
*PATTERN:* When adding new service files that use CacheModel types, check sub-namespace by looking at `RestaurantOfferMenuKeyService.cs` as the reference — it has the correct set of CacheModel usings.
*STATUS: APPLIED — NewProductPriceService.cs and NewProductPriceServiceTests.cs*

## *2026-03-26* • *LEAD* — Session metrics omitted from build journal (session 2026-03-26b)
*WHAT_I_DID:* Wrote session metrics (PRs merged, agent spawns, cycle time, B: rate) to the dashboard output only, not to the build journal entry. Required a follow-up commit.
*WHAT_WAS_WRONG:* The build journal is the durable per-session record; the dashboard is ephemeral. Metrics written only to the dashboard are lost after the session window closes.
*CORRECTION:* SESSION END step 9 must include a `### Session metrics` table in the build journal entry containing all metrics shown in the dashboard.
*PATTERN:* When writing the build journal entry, always include a `### Session metrics` table. Data sources are the same as the dashboard: `gh pr list`, `gh issue list`, agent spawn count from session memory.
*STATUS: APPLIED — CLAUDE.md SESSION END step 9*

---

## *2026-03-27* • *LEAD* — Sent CLOSE: to auditors immediately after Phase 1 report, before PO had engaged

*WHAT_I_DID:* Auditors delivered Phase 1 findings via SendMessage. Lead immediately sent shutdown_request to both auditors in the same turn as acknowledging the reports.

*WHAT_WAS_WRONG:* The PO had not yet read, responded to, or approved/rejected the findings. Shutting down auditors the moment they report cuts off the PO's ability to interact with them directly in their tabs — ask follow-up questions, approve Phase 2, or redirect scope.

*CORRECTION:* After an auditor sends Phase 1 findings, Lead acknowledges receipt and relays a summary to PO, but does NOT send shutdown_request. Auditor stays alive in its tab waiting for PO input. CLOSE: only comes after: (a) PO explicitly approves Phase 2 and auditor completes implementation, or (b) PO rejects and says no implementation needed.

*PATTERN:* Auditor lifecycle: Phase 1 report → Lead relays summary to PO → PO engages auditor directly in tab → Phase 2 if approved → CONFIRMED-D: → Lead sends CLOSE:. Lead never sends CLOSE: between Phase 1 and PO engagement.

*STATUS: APPLIED — harness/roles/ROLE-AUDITOR.md; harness/roles/ROLE-LEAD.md*

---

## *2026-03-31* • *BUILDER* — Opened PR without verifying the build passes
*WHAT_I_DID:* Ran tests and opened PR without first running the project build command to confirm zero compile errors.
*WHAT_WAS_WRONG:* A PR with a broken build is an immediate blocker for reviewers and CI. Build errors are cheaper to catch locally than after PR open.
*CORRECTION:* Run the full project build before `gh pr create`. Zero build errors required — not just zero test failures.
*PATTERN:* Before opening any PR, run the project build command (dotnet build / npm run build / xcodebuild / gradle build) and confirm zero errors. This is step 0 of the VERIFICATION GATE.
*STATUS: APPLIED — harness/roles/ROLE-BUILDER-CORE.md*
