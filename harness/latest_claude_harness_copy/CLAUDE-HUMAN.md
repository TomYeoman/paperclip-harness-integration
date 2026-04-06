# CLAUDE-HUMAN.md — Human-Readable Harness Reference

> This file contains the same information as CLAUDE.md but with full explanations, examples, and context. **Sync rule**: any change to CLAUDE.md must be reflected here in the same PR.

---

## PROJECT

This section identifies the project and where to find its key documents. The stack, DI framework, test framework, and target platforms are defined during M0 (the scaffold milestone) by the PM and Architect. Until then, these fields are TBD placeholders.

- **Name**: TBD — PM discovers in M0
- **Repo**: https://github.je-labs.com/grocery-and-retail-growth/testharness
- **Targets**: TBD
- **Stack / DI / Tests**: TBD — Architect defines in M0
- **Specs**: tasks/PRODUCT-BRIEF.md
- **Design decisions**: tasks/adr/

---

## BUILD + VERIFY

These are the four commands every agent runs before creating a PR. They are TBD until M0 defines the project stack, at which point Architect updates both CLAUDE.md and this file.

| Command | Purpose | Failure means |
|---------|---------|--------------|
| `[lint]` | Auto-fix formatting | Don't commit — formatter fixes it |
| `[quality]` | Static analysis | Fix violations before PR |
| `[test]` | Run all tests | Zero failures required |
| `[coverage]` | Coverage report | No regression from baseline |

**Why**: CI runs these commands. If they fail in CI, the PR is blocked. Running locally first prevents wasted review cycles.

---

## SESSION START

This is an ordered checklist that the Lead agent follows at the start of every session. The order matters — reading the launch script first gives context for everything else.

1. **Read LAUNCH-SCRIPT.md** — contains handoff from previous session: open PRs, active issues, remaining tasks
2. **Pull latest** — `git fetch origin && git pull origin main` — ensures Lead is working from current state
3. **Review recent history** — `git log --oneline -20` — understand what changed since last session
4. **Read milestones** — `tasks/MILESTONES.md` — confirm current milestone and task status
5. **Product discovery check** — if `tasks/PRODUCT-BRIEF.md` doesn't exist, spawn PM agent before feature work (M0 scaffold may proceed in parallel)
6. **Check active issues** — identify blocked or stale issues on GitHub
7. **Read system knowledge** — `harness/SYSTEM-KNOWLEDGE.md` for modules relevant to today's work
8. **Read ADRs** — `tasks/adr/` for architectural decisions relevant to today's work
9. **Load skills index** — `harness/SKILLS-INDEX.md` — know what skills exist (load specific skills lazily)
10. **Read role file** — `harness/roles/ROLE-LEAD.md`

---

## SESSION END

At session end, every agent must:
- Commit or delete all untracked files (no uncommitted work left behind)
- Push all working branches
- Remove dead worktrees

The Lead runs the full shutdown protocol in `harness/skills/SKILL-session-shutdown.md`, which produces 6 deliverables including the next session's launch script.

---

## ARCH RULES

These rules define the allowed dependency directions between layers. Violating layer direction is the most common architectural mistake and is difficult to fix after the fact.

**Layer direction**: `presentation → domain ← data`
- Presentation imports from domain only
- Data imports from domain only
- Domain imports from nothing (it's the center)
- This is the Clean Architecture pattern

**No cross-feature imports**: Features communicate through shared domain interfaces, never directly. If feature A needs data from feature B, there's an interface in the domain layer for it.

**Interface everything**: Any external dependency (storage, network, AI, platform APIs) sits behind an interface defined in the domain layer. This is what makes testing possible — Fakes implement the interface.

**Platform stubs**: For multiplatform projects, all platform-specific implementations must have stubs for all target platforms. A missing stub compiles on one platform and crashes on another.

---

## DISPATCH

Thread and coroutine/async management rules. Architect defines these specifically for the project's stack in M0. The universal rule: each layer has its own dispatcher/thread pool and they are never shared across layers.

_Architect updates this section in M0 with project-specific rules._

---

## STATE

State management rules. Architect defines these specifically for the project's stack in M0.

**Always banned** (regardless of stack):
- Shared mutable state without explicit synchronization
- Global singletons with side effects (they make tests non-deterministic)

_Architect updates this section in M0 with project-specific patterns._

---

## CODE RULES

These are mechanical rules enforced by the Reviewer. Every violation is a block reason. They exist because code that violates these rules has caused real bugs in production.

| Rule | Why it exists |
|------|--------------|
| No magic numbers | `if (items > 7)` is unreadable. `if (items > MAX_CART_SIZE)` is. |
| No TODO without issue ref | TODOs without tracking get lost forever. |
| No commented-out code | Use git history. Dead code creates confusion. |
| No println/console.log | Logs PII, pollutes output, never gets removed. |
| No force-unwrap/!! | Crashes in production on null values. Handle nullability. |
| No wildcard imports | Makes it impossible to know what's imported. |
| No @Suppress without explanation | Suppressing a warning without explanation hides real bugs. |
| No catch-all exceptions | Catches bugs silently. Always specify the exception type. |
| No hardcoded strings | Can't localize. Can't search. Use resource files. |
| Max 40 lines/function | Functions over 40 lines do too many things. Extract. |
| Cyclomatic complexity ≤10 | High complexity = hard to test, hard to understand. |
| Max 6 params | More than 6 params = introduce a parameter object. |

---

## SECURITY

Security rules that apply regardless of project stack:

- **No PII in logs**: User names, email addresses, purchase history, location data — none of it goes in logs. Log user IDs (non-identifying references) instead.
- **No credentials in source**: API keys, passwords, tokens — never committed to git. Use environment variables or a secrets manager.
- **All network over TLS**: No plain HTTP for any production traffic.
- **Validate at boundaries**: Validate all external input (user input, API responses) at the point it enters the system. Trust nothing from outside.

---

## BRANCHES + PR MERGE

Branch and merge rules that define the flow from idea to main:

- **main is protected**: Never commit directly. All changes via PR.
- **Branch naming**: `feature/[name]` for features, `fix/[desc]` for bugs, `design/[name]` for Architect work, `harness/[desc]` for harness improvements
- **The merge flow**: Builder creates PR → Reviewer reviews → Builder merges with `--squash --delete-branch`
- **Reviewer and Lead NEVER merge**: Builder owns the code and owns the merge. This prevents confusion about who is responsible.
- **PR size**: ≤400 lines changed is preferred. Large PRs are hard to review and slow everything down.

---

## AGENT TEAM

The team has 7 roles, each with a specific model and scope. The 15-agent limit prevents context window overload and token runaway.

**Key rules:**
- One agent per task — parallel agents on the same task cause merge conflicts
- All worktrees OUTSIDE repo tree — built-in isolation contaminates the main checkout
- Lead is coordination-only — when Lead starts writing code, coordination breaks down

See individual ROLE-*.md files for detailed behavioral contracts.

---

## COMMUNICATION DSL

The DSL exists to eliminate ambiguity and reduce token waste. Every message starts with a typed prefix so the receiver knows exactly what action to take.

**Why no filler**: "Thank you for that update, it's very helpful" costs tokens, adds zero information, and is read by every agent in the team. In a 15-agent session, filler multiplies. Lead sets the tone by modeling terse, prefix-first communication.

**Full DSL reference**: See `harness/AGENT-COMMUNICATION-PROTOCOL.md`.

---

## DISCOVERY GATE

The discovery gate is a hard stop before implementation. No agent writes code without completing the gate and receiving Lead GO.

**Why it exists**: The most common failure mode is an agent that starts implementing before fully understanding the task. The discovery gate forces the agent to read the relevant files, identify unknowns, and produce a plan. This takes 2-3 minutes and prevents hours of wrong-direction work.

**Self-GO exception**: For trivial work (<50 lines, single file, no new interfaces), agents may self-authorize. They must include a `SELF-GO:` line in their first message explaining why the work is trivial.

---

## SPEC CHAIN + TDD

The spec chain is the core workflow: `spec → interface → failing test → implementation → CI green`

Each step gates the next:
- No interface without spec behavior to implement
- No test without interface to test against
- No implementation without failing test to satisfy
- No PR without CI green

**Builder reads tests, not spec**: This forces Architect and Tester to encode all spec requirements in the tests. Builder's only job is to make the tests pass.

**Fakes over mocks**: See `harness/TDD-STANDARDS.md` for full explanation.

**NEVER change a test to make the build pass**: Unless the test was provably wrong (wrong spec, wrong interface). If the test is right and implementation is failing, fix the implementation.

---

## COMMIT

Commit messages follow [Conventional Commits](https://www.conventionalcommits.org/):
`type(scope): description`

Types:
- `feat` — new feature
- `fix` — bug fix
- `test` — test changes
- `refactor` — code restructuring without behavior change
- `docs` — documentation
- `chore` — tooling, dependencies, config
- `harness` — harness file improvements

---

## VERIFICATION GATE

Before any agent sends `D:` (done), they must complete this checklist:

1. **Run tests** — zero failures. Not "probably passes". Actually run them.
2. **Verify acceptance criteria** — check each criterion from the GitHub issue
3. **Self-review** — `git diff main` — would you approve this if you were the reviewer?
4. **Staff engineer test** — "Would a staff engineer approve this without changes?" If no, fix first.

The **SELF-AUDIT block** in the D: message makes this verifiable:
```
SELF-AUDIT:
- User can add item to cart: PASS — test `user can add item to cart` passes
- Error shown for out-of-stock: PASS — test `adding out-of-stock item shows error` passes
- Cart total updates: PASS — test `cart total updates when quantity changes` passes
```

---

## LOOP DETECTION

Two patterns indicate an agent is stuck:
1. **Same function modified 3+ times**: The agent is iterating without making progress. Stop, reassess the approach, consider course correction.
2. **10+ tool calls without DONE or BLOCK**: The agent has lost track of the goal. Pause and assess what's actually needed.

Both trigger a stop-and-assess before any more changes.

---

## ESCALATE TO PO WHEN

Lead escalates to the Product Owner (the human) for these situations — they are not engineering decisions:
- **Product judgment not in spec**: Should the button say "Add" or "Add to Cart"? PO decides.
- **Spec contradiction**: Two requirements that can't both be true. PO resolves.
- **Blocker after 3 attempts**: Engineering can't solve it alone. Time to involve a human.
- **Builder + Reviewer disagree**: After 2 rounds of back-and-forth, escalate rather than let it cycle.
