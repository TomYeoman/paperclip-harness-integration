> **HUMAN REFERENCE ONLY** — This document is not loaded into agent contexts and is not authoritative for agent behavior. CLAUDE.md and role files (harness/roles/) are the canonical sources. This file exists for human onboarding and reference.

---

# Learning System

The harness improves across sessions through a structured learning protocol. When something goes wrong or a pattern is identified, it is captured, encoded into harness files, and committed — so the same mistake is less likely to happen again.

## Why Verbal Corrections Don't Stick

LLM context follows a retention curve (Lost in the Middle):
- **Primacy** (beginning of context): retained well
- **Middle** (bulk of conversation): degrades significantly
- **Recency** (last few messages): retained well

A verbal correction mid-session is likely forgotten after 20+ more messages. The harness compensates through structural mechanisms that outlive any single session.

## Enforcement Hierarchy (most to least reliable)

1. **Tool-level deny** — mechanical block, 100% reliable (settings.json allowlist/deny-list)
2. **Spawn prompt NON-NEGOTIABLE** — primacy position, seen fresh by every new agent
3. **CLAUDE.md rules** — reloaded after context compaction, persistent across sessions
4. **Broadcast corrections** — recency position for all active agents
5. **harness/lessons.md** — Lead applies to harness files, persists to next session
6. **Verbal corrections** — compressed away, least reliable

## L: Events and the 4-Step Process

When a pattern is identified (by PO correction, blocked PR, or agent observation), an `L:` DSL message is broadcast:

```
L: Builder merged own PR without waiting for review — rule: NEVER merge until Reviewer sends explicit signal — updating ROLE-BUILDER.md
```

This triggers 4 mandatory steps — all required, none deferrable:

### Step 1: Write to harness/lessons.md immediately

This is a hard gate — not a soft intention. Write the lesson before the next tool call.

Format:
```markdown
## Session YYYY-MM-DD

### L: YYYY-MM-DD — [short title]

#### WHAT_WAS_WRONG
[concrete description of what happened]

#### CORRECTION
[what changed — specific rule, file, or process]

#### PATTERN
[one-line rule for future sessions]
```

### Step 2: Update the relevant harness file

Apply the lesson to the file that governs the behavior:
- Agent behavior → `harness/roles/ROLE-[ROLE].md`
- Spawn process → `harness/skills/SKILL-agent-spawn.md`
- Git/PR workflow → `harness/skills/SKILL-github-pr-workflow.md`
- Session workflow → `harness/skills/SKILL-session-shutdown.md`

For example, if a Builder merged without Reviewer approval, add the rule to `ROLE-BUILDER.md`'s NON-NEGOTIABLE block.

### Step 3: Commit on a harness/ branch and open a PR

```bash
git add harness/lessons.md harness/roles/ROLE-BUILDER.md
printf 'harness(builder): add merge ownership rule\n\nCo-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>\n' > /tmp/commit-msg.txt
git commit -F /tmp/commit-msg.txt
git push -u origin harness/merge-ownership-rule
```

Lead merges docs-only harness PRs directly — no Reviewer needed.

### Step 4: Do NOT batch lessons

Every L: event gets its own branch and PR. Do not queue lessons for session end — an unexpected session termination would lose them. The lesson is safe only when it is on main.

---

## harness/lessons.md

`harness/lessons.md` is the append-only learning log. It records every correction across all sessions. Rules:
- Append only — never edit existing entries
- Every session's corrections are grouped under a `## Session YYYY-MM-DD` heading
- Each L: event within a session gets its own subsection

The file is read at session start (scan the last 5 entries to surface recent patterns) and after any context compaction event.

---

## NON-NEGOTIABLE Block Pattern

The highest-reliability enforcement mechanism for agent behavior. Max 5 rules placed at the TOP of a spawn prompt — primacy position ensures the agent reads them first and retains them.

Example from ROLE-BUILDER.md:
```
NON-NEGOTIABLE:
- Test file committed BEFORE implementation file. Same PR.
- PR body MUST include Closes #N.
- After sending V: to Lead, WAIT. Do not proceed until Reviewer sends feedback.
- Push branch before reporting D:.
- NEVER claim tests pass without actually running them.
```

When a lesson is severe enough (e.g., Builder merged own PR, Reviewer approved a PR), it goes into the NON-NEGOTIABLE block — not just the narrative lesson body.

---

## Memory System (.claude/projects/memory/)

The `.claude/projects/memory/` directory stores cross-session memory indexed in `MEMORY.md`. Unlike `harness/lessons.md` (which is operational history), memory files capture persistent facts about:

- **user/** — who the user is, their role, preferences
- **feedback/** — corrections and behavioral guidance
- **project/** — ongoing project context, decisions, timelines
- **reference/** — where to find external resources

Memory is loaded at the start of each conversation. `MEMORY.md` is the index — it points to individual memory files with brief descriptions. The index is always loaded; individual files are loaded on demand.

---

## Automatic Reflection Triggers

| Trigger | Action | Timing |
|---------|--------|--------|
| PO corrects any agent behavior | L: broadcast + 4-step process | Immediately |
| PR blocked on first review | Root cause → NON-NEGOTIABLE candidate | After Builder addresses feedback |
| 90 minutes into session | Re-read last 5 lessons, check for repeat violations | Every 90 min |
| Milestone boundary | Full retrospective (RETRO-TEMPLATE.md) | Before starting next milestone |
| Session end | Full shutdown protocol (SKILL-session-shutdown.md) | End of every session |

---

## Verify Before Encoding

A lesson that is wrong is worse than no lesson — it gets followed.

Before writing any lesson to `harness/lessons.md` and harness files, verify the fix actually works:
- If the lesson describes a tool behavior: test it in a spawned agent context before encoding
- If the lesson describes a process: confirm it applies to the current harness setup
- "I think this will work" is not sufficient — test or confirm first

Example of a lesson that needed correction: a session wrote that PM agents should call `ToolSearch` to load `AskUserQuestion`. This was encoded and merged. The next session discovered that `AskUserQuestion` is unavailable in agent contexts entirely — `ToolSearch` cannot help. A correction lesson was written, but the wrong lesson remained in the log permanently above it, creating confusion.

The correct relay pattern (verified): PM → SendMessage to Lead → Lead asks PO → Lead relays answer to PM.
