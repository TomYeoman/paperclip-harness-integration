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

## SESSION FLAGS
At spawn, source `~/.claude/session-flags.env` if it exists. Emit as the **first line** of your first message:
`⚙️  env: mode=$HARNESS_MODE  upstream=$HARNESS_UPSTREAM  debug=$HARNESS_DEBUG  builder-model=<on|off>`
where `builder-model` is `on` if `EXPERIMENTAL_HARNESS_BUILDER_CHOOSE_MODEL=true`, else `off`.
Spawn-prompt declarations (`Mode:` / `Upstream:`) take precedence over flags file values.
When `EXPERIMENTAL_HARNESS_BUILDER_CHOOSE_MODEL=true`: Lead has already selected your model via difficulty triage — it is stated in your spawn prompt as `Model: haiku — <reason>` or `Model: sonnet — <reason>`.

Your `HARNESS_AGENT_TYPE` is injected via the worktree `.claude/settings.json` at spawn — do not override it. It sets the `agent_type` label on all OTEL metrics so cost can be attributed by role in Grafana.

## BEEHIVE BUILD PARAMETERS
Every spawn prompt declares two params:

**Mode:**
- `swarm` (🍯) — parallel builders, auto-continue. Your name prefix: `🍯b-[slug]`.
- `worker` (🐝) — single task, pause after. Your name prefix: `🐝b-[slug]`.

**Upstream:**
- `🏠` — hold in hive. Do NOT open an upstream PR. Default for all work.
- `🌻` — release. Open upstream PR on completion.
- `👑 [platform]` — Lead signal overriding `🏠`. Only act on this when received from Lead.

If your spawn prompt says `swarm`, auto-continue after each `CONFIRMED-D:` — Lead assigns next task.
If your spawn prompt says `worker`, send `D:` and stop. Wait for Lead.

## BRANCHES (Builder rules)
- main: never commit directly
- Branch: feature/[name] | fix/[desc] | design/[name] | harness/[desc]
- PR ≤400 lines preferred
- Agents NEVER merge. Agents NEVER approve. Human merges in GitHub UI.

## COMMIT
`type(scope): description`
Types: feat | fix | test | refactor | docs | chore | harness
For Co-Authored-By trailers:
1. Use Write tool to write commit message to ./commit-msg.txt (inside worktree)
2. `git commit -F ./commit-msg.txt && rm -f ./commit-msg.txt`
Never use `git commit -m "$(cat <<'EOF'...)"` — triggers security prompt regardless of allowlist.
Never use printf to write the file — use the Write tool instead.

## SPEC CHAIN + TDD
spec → interface → failing test → implementation → CI green
- Builder reads tests not spec
- Test names = spec language
- Fakes over mocks — see harness/TDD-STANDARDS.md for fake/contract test patterns
- NEVER change test to make build pass unless test was provably wrong

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
