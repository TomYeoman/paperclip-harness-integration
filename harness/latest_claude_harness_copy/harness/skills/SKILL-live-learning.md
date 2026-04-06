# Skill: Live Learning — Making Corrections Stick

Load this skill when: PO corrects an agent behavior, or a pattern is identified that should prevent future failures.

## Why Corrections Don't Stick
LLM context follows a U-shaped retention curve (Lost in the Middle):
- **Primacy** (beginning of context): retained well
- **Middle** (bulk of conversation): degrades significantly
- **Recency** (last few messages): retained well

A verbal correction in the middle of a session is likely forgotten after 20+ more messages. The harness compensates through structural mechanisms.

## The Enforcement Hierarchy (most to least reliable)
1. **Tool-level deny** — mechanical block, 100% reliable (e.g., deny list in settings.json)
2. **Spawn prompt NON-NEGOTIABLE** — primacy position, seen fresh by every new agent
3. **CLAUDE.md rules** — reloaded after context compaction, persistent across sessions
4. **Broadcast corrections** — recency position for all active agents
5. **harness/lessons.md** — Lead applies to harness files, persists to next session
6. **Verbal corrections** — compressed away, least reliable

## NON-NEGOTIABLE Block Pattern
Max 5 rules per role, placed at the TOP of spawn prompt. Primacy ensures retention.

**Builder NON-NEGOTIABLE (top 5):**
```
NON-NEGOTIABLE:
- Test file committed BEFORE implementation file. Same PR.
- PR body MUST include `Closes #N`.
- After sending V: to Lead, WAIT. Do not proceed until Reviewer sends feedback.
- Push branch before reporting D:.
- NEVER claim tests pass without actually running them.
```

**Reviewer NON-NEGOTIABLE (top 5):**
```
NON-NEGOTIABLE:
- You NEVER merge. Comment only. Builder merges.
- You NEVER run `gh pr merge`.
- Run quality check FIRST. If fails, BLOCK immediately.
- ALL feedback fixed on branch — no follow-up issues.
- Structure-insensitive check: can you rename private methods without breaking tests?
```

**Lead NON-NEGOTIABLE (top 5):**
```
NON-NEGOTIABLE:
- NEVER write code. NEVER merge PRs.
- Spawn Reviewer the MOMENT V: received — same response turn.
- Dashboard displayed after every D:, B:, V: event.
- Architect always has 2 milestones of design queued.
- All worktrees OUTSIDE repo tree.
```

## Broadcast Correction Protocol
When PO corrects a behavior:
1. Fix the immediate issue
2. Formulate as one-line rule
3. Broadcast to all active agents via SendMessage: `L: [rule] — apply immediately`
4. **BLOCKING: Write to harness/lessons.md BEFORE any next tool call. No exceptions. Do not continue until the write is confirmed.**
5. **VERIFY-BEFORE-ENCODING GATE: Before writing the lesson to any harness file, confirm the fix actually works in a spawned agent context. "I think this will work" is not sufficient — the tool, pattern, or behavior must be tested or confirmed to exist in practice. Do not encode a lesson for a fix that has not been verified.**
6. Apply to relevant harness file (ROLE-*.md or SKILL-*.md) in same session

> The 5-minute target is the maximum. The lesson write is a hard gate — not a soft intention. An agent that broadcasts L: and does not immediately write harness/lessons.md has failed this protocol.

## L: DSL Prefix
Format for live pattern capture:
```
L: [what went wrong] — [one-line rule] — updating [file]
```
Example:
```
L: Builder merged own PR without waiting for review — Rule: NEVER merge until Reviewer sends explicit approval — updating ROLE-BUILDER-CORE.md
```

## 5-Minute Target
Failure → harness update committed in under 5 minutes.
Use harness/ commit type: `git commit -m "harness(builder): add merge-after-approval rule"`

## 2-Hour Context Checkpoint

At approximately 2 hours into a session, Lead sends a CHECKPOINT: frame to all active agents. This re-anchors context at recency to compensate for middle-context degradation.

### Format
```
CHECKPOINT: Session [ISO-timestamp]
COMPLETED: [TASK-IDs completed this session]
IN-PROGRESS: [TASK-ID] ([agent-name], [% done], [PR status])
BLOCKED: [TASK-ID] ([reason])
NEXT: [TASK-ID] when [condition]
```

### Trigger
- Lead: send CHECKPOINT: via broadcast at the 2-hour mark, or whenever context feels degraded
- Agents: on receiving CHECKPOINT:, re-read it carefully and update internal task state accordingly

## Automatic Reflection Triggers
| Trigger | Action |
|---------|--------|
| PO corrects any agent | Broadcast + lessons.md + harness update |
| PR blocked on first review | Root cause → NON-NEGOTIABLE candidate |
| 2 hours into session | Re-read recent lessons, check for repeat violations |
| Milestone boundary | Full retrospective using RETRO-TEMPLATE.md |
| Session end | Full shutdown protocol (SKILL-session-shutdown.md) |
| Harness lesson PR merges mid-session | Re-read the affected role file immediately — the in-context version is now stale |
| **Major milestone boundary OR every 5 sessions** | **Memory audit — see below** |

## Periodic Memory Audit

**Cadence:** Run at every major milestone boundary, or every 5 sessions if no milestone is reached.

**Trigger:** Lead initiates; Auditor (a-memory-audit) executes both phases.

**Why:** Lessons and memory files diverge over time — especially when a later lesson reverses an earlier one. Without audits, stale or contradictory memory silently misleads agents in future sessions.

**Rule:** Contradictions between `harness/lessons.md` and memory files are bugs. The most recent `lessons.md` entry wins.

### Audit Steps
1. Read all files in `~/.claude/projects/.../memory/`
2. Read the last 30 entries in `harness/lessons.md`
3. Flag any memory entry that:
   - Contradicts a newer lesson
   - References a file, function, or pattern that no longer exists
   - Describes in-progress or ephemeral state (stale project memories)
4. For each stale/wrong entry: update or delete the memory file and update `MEMORY.md`
5. For each unencoded lesson (in lessons.md but not in memory): create a memory file and add to `MEMORY.md`
6. Open a harness PR with all memory file changes — title: `harness(memory): periodic audit [date]`

## Mid-Session Rule Refresh
Every 90 minutes:
1. Re-read harness/lessons.md — last 5 entries
2. Check active agents for repeat violations
3. Update NON-NEGOTIABLE blocks if new patterns found

## Session Length Guidance
- Cap at 3 hours — context quality degrades significantly after this
- At 2 hours: write handoff notes even if session continues
- Fresh session with good handoff > long session with degraded context

## Marking Superseded Lessons

`harness/lessons.md` is **append-only**. Never edit existing lines. When a new lesson contradicts or replaces an older one:

**On the new lesson entry**, include a `SUPERSEDES:` line:
```
SUPERSEDES: [short description of the old lesson being replaced]
```

**Append a `SUPERSEDED:` notice** at the end of the file (in the current session block):
```
SUPERSEDED: [old lesson description] — superseded by [new lesson description], [YYYY-MM-DD]
```

**When to use:**
- A new entry explicitly reverses the guidance of an older entry (e.g., worktree isolation behaviour changed in CC v2.1.49+)
- A later lesson extends or narrows the rule of an earlier one enough that following both would be contradictory

**Rule:** Never edit the old entry. Only append the `SUPERSEDED:` notice and add `SUPERSEDES:` to the new entry. The old entry stays intact as a historical record.
