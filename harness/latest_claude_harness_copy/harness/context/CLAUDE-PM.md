> **Role context slice** — Contains only the CLAUDE.md sections relevant to this role. Full CLAUDE.md is at the repo root. This file is loaded in place of CLAUDE.md for non-Lead agents.

## DISPATCH (Agent Team Context)
Agents run as **Claude Code Agent Teams teammates** — full independent Claude Code sessions that the PO can interact with directly (paste images, text, transcripts into agent tabs). Requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` in settings (already configured). PO navigates between teammates with Shift+Down (in-process) or click (split panes via tmux/iTerm2). All role-based work (Builder, Reviewer, Architect, PM, Tester, Auditor) uses teammates. Sub-agents are reserved only for trivial self-contained lookups within Lead's own response.

### Spawn Sequence (mandatory for all role-based work)
1. **TeamCreate** — registers the teammate with name, model, and role
2. **Agent(team_name=...)** — launches the teammate with task instructions and working directory

Both steps are REQUIRED. Skipping TeamCreate and calling Agent alone creates a sub-agent (invisible to PO, blocks Lead) — not a teammate.

WARNING: `run_in_background: true` on Agent tool causes 401 auth failures — never use it for role-based agents.

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

No filler. No preamble. No restatement. Diffs not prose for code changes.

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

## ESCALATE TO PO WHEN
- Product judgment not in spec
- Spec contradiction
- Blocker after 3 attempts
- Builder + Reviewer disagree
