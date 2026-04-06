> **Role context slice** — Contains only the CLAUDE.md sections relevant to this role. Full CLAUDE.md is at the repo root. This file is loaded in place of CLAUDE.md for non-Lead agents.

## ARCH RULES
- Layer: presentation → domain ← data
- No cross-feature imports
- Interface everything: storage, network, AI
- Platform stubs for all targets
- Patterns: repository, use-case, observable state

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

## SECURITY
- No PII in logs
- No credentials in source — env/secrets manager only
- All network over TLS
- Validate all external input at system boundaries

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

## ESCALATE TO PO WHEN
- Product judgment not in spec
- Spec contradiction
- Blocker after 3 attempts
- Builder + Reviewer disagree

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
