> **Role context slice** — Contains only the CLAUDE.md sections relevant to this role. Full CLAUDE.md is at the repo root. This file is loaded in place of CLAUDE.md for non-Lead agents.

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

## COMMIT
`type(scope): description`
Types: feat | fix | test | refactor | docs | chore | harness
For Co-Authored-By trailers:
1. Use Write tool to write commit message to ./commit-msg.txt (inside worktree)
2. `git commit -F ./commit-msg.txt && rm -f ./commit-msg.txt`
Never use `git commit -m "$(cat <<'EOF'...)"` — triggers security prompt regardless of allowlist.
Never use printf to write the file — use the Write tool instead.

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
| L: | Pattern identified | Capture in harness ≤5 min |

No filler. No preamble. No restatement. Diffs not prose for code changes.

## LOOP DETECTION
- Same function modified 3+ times → stop and reassess
- 10+ tool calls without DONE/BLOCK → pause and assess

## ESCALATE TO PO WHEN
- Product judgment not in spec
- Spec contradiction
- Blocker after 3 attempts
- Builder + Reviewer disagree
