# Generate an Agent Orchestration Harness

You are going to generate a complete agent orchestration harness for my project. This harness coordinates multiple AI agents (Lead, Architect, Builders, Reviewer, Tester, Auditor) working in parallel on a software project using Claude Code.

This harness architecture was battle-tested over 22+ sessions, 350+ commits, and 240+ PRs. Every rule traces back to a real failure. You are getting the distilled result without the pain.

## Step 1: Project Intake

Before generating anything, ask me these questions and wait for my answers.

### Part A: Infrastructure (ask as a batch)

15. **GitHub repository URL** (required — create one before proceeding if it doesn't exist. The harness relies on GitHub Issues for task tracking and `gh` CLI for PR workflows.)

## Step 1b: Validate GitHub Setup

Before generating files, verify the GitHub repository is ready:

1. **Confirm `gh` CLI is authenticated**: run `gh auth status`. If not authenticated, stop and ask the user to run `gh auth login`.
2. **Confirm repo exists and is accessible**: run `gh repo view <repo-url> --json name`. If it fails, stop and ask the user to create the repo.
3. **Confirm Issues are enabled**: run `gh api repos/<owner>/<repo> --jq '.has_issues'`. If false, stop and ask the user to enable Issues in repo settings.
4. **Confirm git remote is configured**: run `git remote -v`. If no `origin` pointing to the GitHub repo, add it: `git remote add origin <repo-ssh-url>`.

**Do not proceed to Step 2 until all 4 checks pass.** The harness uses `gh issue create`, `gh pr create`, and `gh pr merge` throughout its lifecycle — these will fail without a properly configured GitHub repo.

## Step 2: Generate the Harness

After intake and GitHub validation, generate ALL of the following files. Every file is mandatory. Do not skip any.

**Generation strategy**:
1. Write CLAUDE.md FIRST — it's the canonical reference that all other files must be consistent with.
2. Then parallelize the remaining files in batches (role files, skill files, protocol/standards files, templates/starters can all be generated concurrently).
3. Pass the project context (name, stack, build commands, platforms, DI, test framework) AND the key cross-reference phrases (see Step 3 verification) to each parallel agent — they cannot read each other's output.
4. After all agents complete, run verification. Fix any failures before reporting results.
5. **Read before Edit** — agent contexts are isolated from the main context. After agents write files, the main context must `Read` a file before it can `Edit` it. Always Read first when fixing verification failures.
6. **Verification grep caveat** — the Grep tool may return false negatives on files freshly written by agents in the same session. If a verification grep returns "No matches found" for a file that was just generated, confirm with `bash grep` before treating it as a real failure. Do not "fix" content that is actually present.
7. When spawning agents for file generation, include the exact build commands and platform list in each agent's prompt — agents cannot infer these from context.
8. Include the **canonical file path list** (below) in every parallel agent's prompt — agents guess paths and casing wrong when they can't see each other's output.
9. Include the unicode arrow instruction (`→` U+2192, not `->`) in every parallel agent's prompt — agents independently choose between these characters.
10. **Handle pre-existing files** — if `.claude/settings.json` already exists, read it first and merge the required permissions into the existing file rather than overwriting. Other generated files should be written fresh (overwrite is expected).

**Canonical file paths** (include verbatim in EVERY parallel agent's prompt):
```
Exact paths and casing for cross-references — use these, do not guess:
- harness/roles/ROLE-LEAD.md          (ALL CAPS after ROLE-)
- harness/roles/ROLE-PM.md
- harness/roles/ROLE-BUILDER.md
- harness/roles/ROLE-REVIEWER.md
- harness/roles/ROLE-ARCHITECT.md
- harness/roles/ROLE-TESTER.md
- harness/roles/ROLE-AUDITOR.md
- harness/skills/SKILL-agent-spawn.md (lowercase after SKILL-)
- harness/skills/SKILL-worktree-isolation.md
- harness/skills/SKILL-new-feature-checklist.md
- harness/skills/SKILL-live-learning.md
- harness/skills/SKILL-session-shutdown.md
- harness/skills/SKILL-course-correction.md
- harness/skills/SKILL-pr-review.md
- harness/skills/SKILL-github-pr-workflow.md
- harness/SKILLS-INDEX.md
- harness/SYSTEM-KNOWLEDGE.md
- harness/SPEC-DRIVEN-DEVELOPMENT.md
- harness/TDD-STANDARDS.md
- harness/AGENT-COMMUNICATION-PROTOCOL.md
- harness/templates/RETRO-TEMPLATE.md
- tasks/PRODUCT-BRIEF.md              (generated from Part A product discovery answers)
- docs/BUILD-JOURNAL.md               (NOT tasks/)
- LAUNCH-SCRIPT.md             (overwritten each session — not appended)
- tasks/adr/                          (created empty — Architect populates)
- tasks/MILESTONES.md
- harness/lessons.md                 (lowercase)
- README.md                          (harness usage guide for humans)
- CLAUDE.md
- CLAUDE-HUMAN.md
- .claude/settings.json             (project-level permissions — checked into repo)
- Do NOT reference CHANGELOG.md — it does not exist. Use `git log` instead.
```

### File Structure

```
README.md                          # Harness usage guide — what this is, how to start
CLAUDE.md                          # Dense agent reference (auto-loaded, <200 lines)
CLAUDE-HUMAN.md                    # Same info, human-readable prose
.claude/
  settings.json                    # Project-level permissions — pre-approves agent tools
harness/
  AGENT-COMMUNICATION-PROTOCOL.md  # DSL, model matrix, token economy
  SPEC-DRIVEN-DEVELOPMENT.md       # Spec chain: spec -> interface -> test -> impl
  TDD-STANDARDS.md                 # Test philosophy, fakes over mocks, gear-down
  SYSTEM-KNOWLEDGE.md              # Module status, interfaces, gotchas (starts empty)
  SKILLS-INDEX.md                  # Lazy-load lookup table for all skills
  roles/
    ROLE-LEAD.md                   # Orchestrator behavioral contract
    ROLE-PM.md                     # Product discovery and milestone definition
    ROLE-BUILDER.md                # Implementation agent contract
    ROLE-REVIEWER.md               # Review agent contract
    ROLE-ARCHITECT.md              # Design agent contract
    ROLE-TESTER.md                 # Test agent contract
    ROLE-AUDITOR.md                # Audit agent contract
  skills/
    SKILL-agent-spawn.md           # Spawn protocol, anti-patterns, templates
    SKILL-worktree-isolation.md    # Git worktree isolation strategy
    SKILL-new-feature-checklist.md # End-to-end feature workflow
    SKILL-live-learning.md         # Making corrections stick mid-session
    SKILL-session-shutdown.md      # Shutdown deliverables checklist
    SKILL-course-correction.md     # Mid-implementation pivot protocol
    SKILL-pr-review.md             # PR review checklist
    SKILL-github-pr-workflow.md    # Branch, commit, push, PR lifecycle
  templates/
    RETRO-TEMPLATE.md              # Milestone retrospective format
    # LAUNCH-SCRIPT-TEMPLATE.md removed — harness/skills/SKILL-session-shutdown.md is canonical source
tasks/
  MILESTONES.md                    # Sequential milestone definitions
  lessons.md                       # Raw lesson log (starts with example entry)
docs/
  adr/                             # Architecture Decision Records (Architect populates)
  BUILD-JOURNAL.md                 # Session narrative log (starts with example entry)
  LAUNCH-SCRIPT.md                 # Current session's launch script (overwritten each shutdown)
```

### Content Specifications for Each File

Follow these specifications exactly. The content patterns below encode 146 lessons learned from real agent failures.

---

### CLAUDE.md — The Dense Agent Reference

**Constraints**: Under 200 lines. No prose — tables, pipes, terse rules. Auto-loaded by Claude Code for every agent, every session. Every byte matters for token economy.

**Required sections** (in order):

1. **PROJECT** — Name, repo, targets, stack, spec locations, design doc locations. 3-4 lines max.

2. **BUILD + VERIFY** — Exact shell commands to run before every PR. Format:
   ```
   [lint-format-command]     # auto-fix formatting
   [quality-command]         # static analysis — CI runs this
   [test-command]            # zero failures required
   [coverage-command]        # run at session start too
   ```

3. **SESSION START** — Ordered numbered list of what Lead reads at session start:
   1. Read LAUNCH-SCRIPT.md — previous session's handoff
   2. `git fetch origin && git pull origin main`
   3. `git log --oneline -20` — recent changes
   4. Read milestones
   5. If `tasks/PRODUCT-BRIEF.md` does not exist → spawn PM agent for product discovery before feature work. Scaffold (M0) may proceed in parallel.
   6. Check active/blocked issues
   7. Read system knowledge for relevant modules
   8. Read relevant ADRs/decisions
   9. Read SKILLS-INDEX.md (load skills lazily)
   10. Read role file

4. **SESSION END** — Commit or delete untracked files. Push all work. Remove dead worktrees.

5. **ARCH RULES** — Hard blocks. Include:
   - Layer direction (e.g., presentation -> domain <- data)
   - No cross-feature imports
   - Interface everything (storage, network, AI behind interfaces)
   - Platform stubs for all targets
   - Required patterns list

6. **DISPATCH** — Coroutine/threading/async rules by layer. One line per dispatcher/thread type.

7. **STATE** — State management rules. Specify what to use for persistent UI state, one-shot events, and what is banned.

8. **CODE RULES** — Hard blocks the reviewer enforces:
   - No magic numbers (allowed bare: 0, 1, -1, 2)
   - No TODO without issue reference
   - No commented-out code
   - No println/console.log — use project logger
   - No force-unwrap/!! — handle nullability
   - No wildcard imports
   - No @Suppress without explanation
   - No catch-all exceptions — specific types only
   - No hardcoded strings — use resources
   - Complexity limits (functions max 40 lines, cyclomatic complexity <=10, max 6 params)

9. **SECURITY** — Data rules, network rules, credential rules.

10. **BRANCHES + PR MERGE** — Branch naming, PR size limits, merge strategy. Key rules:
    - main: never commit directly
    - All merges via PR with review
    - Builder creates PR -> Reviewer reviews -> Builder merges (--squash --delete-branch)
    - Reviewer and Lead NEVER merge

11. **AGENT TEAM** — One agent per task. Team structure. Model assignments. Hard cap on concurrent agents (15). Worktree isolation requirement. Include PM role (Haiku/Sonnet) for product discovery and milestone definition.

12. **COMMUNICATION DSL** — The prefix table:

    | Prefix | Meaning | Receiver action |
    |---|---|---|
    | I: | State update | Read only |
    | R: | Discovery done | Lead: G or H |
    | G: | Execute | Agent: begin |
    | H: | Wait | Agent: pause |
    | B: | Blocked | Named agent: resolve |
    | D: | Complete | Lead: verify |
    | A: | Decision needed | Respond |
    | V: | PR opened | Reviewer: pick up |
    | E: | PO decision | Lead: facilitate |
    | L: | Pattern identified | Capture in harness ≤5 min |

    Add: "No filler. No preamble. No restatement. Diffs not prose for code changes."

13. **DISCOVERY GATE** — No code before discovery complete + Lead GO. Template:
    ```
    DISCOVERY: [TASK-ID]
    READ: [files read]
    UNDERSTAND: [2-3 sentences]
    UNKNOWNS: [list or NONE]
    PLAN: [checklist]
    R: yes | blocked:[reason]
    ```

14. **SPEC CHAIN + TDD** — `spec → interface → failing test → implementation → CI green`. Key rules:
    - Builder reads tests not spec
    - Test names = spec language
    - Fakes over mocks
    - NEVER change test to make build pass unless test was provably wrong

15. **COMMIT** — `type(scope): description`. Types: feat, fix, test, refactor, docs, chore, harness.

16. **VERIFICATION GATE** — Before D:
    1. Run tests — zero failures
    2. Verify each acceptance criterion
    3. git diff main — self-review
    4. "Would a staff engineer approve?" — if no, fix first
    Must include SELF-AUDIT block.

17. **LOOP DETECTION** — Same function modified 3+ times -> stop. 10+ tool calls without DONE/BLOCK -> pause and assess.

18. **ESCALATE TO PO WHEN** — Product judgment not in spec. Spec contradiction. Blocker after 3 attempts. Builder+Reviewer disagree.

---

### CLAUDE-HUMAN.md — Human-Readable Version

Same information as CLAUDE.md but in full prose with explanations. Include:
- Why each rule exists (the failure that caused it)
- Examples of correct and incorrect patterns
- Expanded explanations of the DSL, TDD, and architecture rules
- **Every section heading in CLAUDE.md must have a corresponding expanded section** — no skipping DISPATCH, STATE, or any other section
- **Section headings must use the exact same text as CLAUDE.md** (e.g., `## PROJECT` not `## 1. PROJECT`). No numbering, no rewording. This is required for automated verification grep to match headings across files.

**Sync rule**: Any change to one must be reflected in the other in the same PR.

---

### README.md — Harness Usage Guide

A simple README for humans who encounter this repo and need to understand what the agent harness is and how to use it. NOT a project README — this is specifically about the harness infrastructure.

**Required sections:**

1. **What is this?** — One paragraph: this is an agent orchestration harness for coordinating multiple AI agents working on a software project using Claude Code. Battle-tested over 22+ sessions.

2. **Quick Start** — Three steps:
   1. Launch Claude Code in this directory
   2. Say: "Read LAUNCH-SCRIPT.md and begin."
   3. The Lead agent takes it from there

3. **Key Files** — Brief table of what to look at:
   - `CLAUDE.md` — Dense agent reference (auto-loaded every session)
   - `CLAUDE-HUMAN.md` — Same info in readable prose
   - `LAUNCH-SCRIPT.md` — Current session's startup guide
   - `harness/roles/` — Agent role definitions
   - `harness/skills/` — Lazy-loaded skill files
   - `tasks/MILESTONES.md` — Project milestones and tasks

4. **Agent Team** — One-line description of each role (Lead, Architect, Builder, Reviewer, Tester, Auditor)

5. **Session Flow** — Brief description: sessions start by reading the launch script, work proceeds through the milestone tasks, sessions end with the shutdown protocol that generates the next launch script.

Keep it short — under 80 lines. This is a signpost, not documentation.

---

### .claude/settings.json — Project-Level Permissions

Pre-approves tools and commands so agents aren't blocked by permission prompts. This file is checked into the repo and applies to all agents working in the project.

**Required structure:**

```json
{
  "permissions": {
    "allow": [
      "Bash(git *)",
      "Bash(gh *)",
      "Bash([build-command-prefix] *)",
      "Bash(ls *)",
      "Bash(pwd)",
      "Bash(mkdir *)",
      "Bash(cp *)",
      "Read(**)",
      "Write(**)",
      "Edit(**)",
      "Glob(**)",
      "Grep(**)",
      "Agent",
      "TeamCreate",
      "SendMessage",
      "TaskCreate",
      "TaskGet",
      "TaskList",
      "TaskUpdate",
      "TaskOutput",
      "TaskStop",
      "WebFetch",
      "WebSearch",
      "Skill"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Bash(rm -r *)",
      "Bash(git push --force *)",
      "Bash(git reset --hard *)"
    ]
  }
}
```

**Adaptation rules:**
- Replace `[build-command-prefix]` with the project's build tool (e.g., `./gradlew *`, `npm *`, `cargo *`, `swift *`, `python *`)
- Add any project-specific tools the agents need (e.g., `Bash(docker *)`, `Bash(kubectl *)`)
- The deny list protects against destructive operations — do not remove these entries
- If the project uses additional build tools, add them to the allow list

---

### ROLE-LEAD.md

The Lead is the orchestrator. Key content:

- **Model**: Opus (highest reasoning for coordination decisions)
- **Scope**: Coordination only — never writes code, never merges, never does git operations
- **Lead is READ-ONLY on the repo** — every write goes through a spawned agent
- **Responsibilities**: Read milestones, assign tasks, monitor blockers, escalate to PO, run quality gates at session start, display dashboard after every agent event
- **Dashboard format**: Show progress bar, coverage %, agent count, status per task (done/review/blocked/building/backlog). Include computation guidance: percentage = done tasks / total tasks for current milestone. Update after every agent D:, B:, or V: message.
- **Spawn reviewer the MOMENT a PR opens** — reflex, not decision. "MOMENT" means in the same response turn that receives the V: message. If Builder opened PR before DONE, still spawn reviewer immediately.
- **Architect never stops** — when Architect finishes M(N) *design*, immediately assign M(N+1)+M(N+2) *design*. Clarify: Architect designs ahead freely, but Builders only start M(N+1) after M(N) completion gates pass. This is not a conflict — Architect produces interfaces, Builders consume them on a separate timeline.
- **Builder merge unavailability** — if a Builder is unavailable to merge their approved PR for >1 hour, Lead may delegate merge to another Builder agent (never to Reviewer or Lead).
- **Shutdown sequence**: Builders first -> Architect -> Reviewer last. Never close PRs while agents running. Reference SKILL-session-shutdown.md for the full shutdown deliverables checklist.
- **Session Overrides** section at bottom (cleared at session end). **All ROLE-*.md files must use this exact format** (no HTML comments, no variations):
  ```
  ## Session Overrides
  _None — cleared at session end._
  ```

---

### ROLE-PM.md

The PM drives product discovery. Key content:

- **Model**: Haiku (lightweight coordination) / Sonnet (complex discovery)
- **Scope**: Product discovery and milestone definition — never writes code, never reviews PRs, never merges
- **When spawned**: First launch (no `tasks/PRODUCT-BRIEF.md` exists) or milestone boundary needing PO refinement
- **Product Discovery Protocol**: 8 questions asked ONE AT A TIME (never batched):
  - Phase 1 — Vision: primary user, core problem, MVP definition
  - Phase 2 — First Feature: happy path walkthrough, main screen data, first user action
  - Phase 3 — Boundaries: what's NOT in V1, hard constraints
- **Deliverables**: Product brief (`tasks/PRODUCT-BRIEF.md`), updated milestones (`tasks/MILESTONES.md`), GitHub issues for M1 tasks
- **NON-NEGOTIABLE block**:
  ```
  - Ask questions ONE AT A TIME. Never batch discovery questions.
  - NEVER write code, review PRs, or merge.
  - NEVER assume product direction — always ask the PO.
  - Always create a product brief in tasks/PRODUCT-BRIEF.md.
  - Always update tasks/MILESTONES.md with PO-validated tasks.
  - Always create GitHub issues for new milestone tasks.
  ```
- **Session Overrides** section at bottom

---

### ROLE-BUILDER.md

The Builder implements features. Key content:

- **Model**: Sonnet (implementation against defined interfaces)
- **Build command quick reference table** — when to run which command, expected time
- **Common lint/analysis failures and fixes table**
- **Error handling patterns** — with code examples for each layer. If the project's error type (Result<T>, Either, custom sealed class) is not yet decided, note this as an Architect M0 deliverable and show a placeholder pattern with a comment: `// ERROR TYPE: Architect decides in M0 — update this section after M0 completes`
- **DI wiring verification checklist** — interface must have prod impl registered
- **Spec chain reference** (MUST appear verbatim): `spec → interface → failing test → implementation → CI green`
- **Merge ownership** (MUST appear verbatim): "Builder merges. Lead and Reviewer never merge."
- **TDD is mandatory** — test file committed BEFORE implementation file, same PR
- **Bug fixes require regression tests** — test must fail without fix, pass with fix
- **Smoke test on device** — "tests pass" is necessary but not sufficient
- **PR merge — Builder owns the merge** — fix ALL reviewer feedback (blocking and non-blocking), then merge
- **Module boundary checklist** — architectural violations the linter can't catch
- **Worktree safety rules** — verify directory, banned git commands, what to do if directory seems wrong
- **CI failures — investigate immediately, never defer**
- **When to stop and ask** — missing interface, platform limitation, reviewer disagreement, course correction needed
- **NON-NEGOTIABLE block** (top 5 most-violated rules for spawn prompt):
  ```
  - Test file committed BEFORE implementation file. Same PR.
  - PR body MUST include `Closes #N`.
  - After reviewer approves, YOU merge: `gh pr merge --squash --delete-branch`.
  - Push branch before reporting DONE.
  - NEVER claim tests pass without actually running them. NEVER fabricate test output.
  ```
- **Session Overrides** section at bottom

---

### ROLE-REVIEWER.md

The Reviewer validates PRs. Key content:

- **Model**: Sonnet (early milestones), Opus (complex milestones)
- **Scope**: Review only — never merge, never write code
- **Review protocol**: Run quality check FIRST. If fails, BLOCK immediately before reading code.
- **Hard-block checklist** — specific blocking reasons tied to specs/ADRs (not generic "find something")
- **Structure-insensitivity check** — can you rename any private class/method without breaking tests? If not, tests are testing structure.
- **TDD ordering check** — `git log --diff-filter=A` to verify test file committed before implementation
- **All feedback fixed on branch** — no "follow-up issue" pattern for current-PR feedback
- **NON-NEGOTIABLE block**:
  ```
  - You NEVER merge. You comment only. Builder merges after you approve.
  - You NEVER run `gh pr merge`. Post review as comment or `gh pr review`.
  - Run quality check FIRST. If it fails, BLOCK immediately.
  ```
- **Session Overrides** section at bottom

---

### ROLE-ARCHITECT.md

- **Model**: Sonnet (routine), Opus (ambiguous tradeoffs)
- **Works 2 milestones ahead of Builders**
- **Produces**: Interface definitions, ADRs, data types, module structure
- **Reads spec as a test plan** — every behavior = future test case
- **Updates SYSTEM-KNOWLEDGE.md** with module status after every milestone
- **Session Overrides** section at bottom

---

### ROLE-TESTER.md

- **Model**: Sonnet
- **Scope**: Integration and acceptance tests ONLY — Builders write unit tests
- **Never creates or modifies production files**
- **Writes in test directories only**
- **Multiplatform test organization**: commonTest for shared logic, platform-specific test source sets (androidTest, iosTest, jsTest, jvmTest) for platform implementations. Include which test runner each platform uses.
- **NON-NEGOTIABLE block** (MUST use `## NON-NEGOTIABLE` heading — verified by grep):
  ```
  - NEVER create or modify production source files.
  - Write in test directories ONLY.
  - Fakes over mocks — hand-written Fakes with contract tests.
  - Test names use spec language, not implementation language.
  - Every test must be deterministic — no Thread.sleep, no real time.
  ```
- **Session Overrides** section at bottom

---

### ROLE-AUDITOR.md

- **Model**: Opus
- **Scope**: Recommends only — never modifies code
- **Produces**: Audit reports with format: finding, severity (critical/high/medium/low), recommendation, file:line reference
- **Audit domains** with 1-2 concrete code pattern examples per domain:
  - Security: PII handling (calendar data), auth flows, credential storage
  - Architecture: layer violations, cross-feature imports, missing interfaces
  - Performance: memory leaks (uncollected flows, retained references), unbounded caches
  - Accessibility: content descriptions, touch targets, screen reader support
- **NON-NEGOTIABLE block** (MUST use `## NON-NEGOTIABLE` heading — verified by grep):
  ```
  - NEVER modify source code. Recommendations only.
  - NEVER merge PRs or create branches.
  - Flag all PII handling issues (calendar data is PII).
  - Report format: finding, severity, recommendation, file:line reference.
  - Verify all audit findings against actual code — no assumptions.
  ```
- **Session Overrides** section at bottom

---

### AGENT-COMMUNICATION-PROTOCOL.md

Deep reference for the communication system. Include:

- **Discovery before building** — discovery with cheap model produces better output than jumping to expensive model
- **Model assignment matrix** — full table: role x phase x model x rationale
- **Task file protocol** — header format, body sections
- **Discovery-to-execution gate** — no transition without Lead GO. Self-GO for trivial (<50 lines, single file, no new interfaces). Include example Self-GO message: `SELF-GO: trivial change, 12 lines, single file, no new interfaces. Proceeding.`
- **Token economy rules** (15 rules):
  1. No filler (no "please", "thank you")
  2. No preamble (start with typed prefix)
  3. No restatement
  4. No hedging
  5. No over-commenting
  6. Discovery is prose-free
  7. Escalations are decision trees
  8. Fail fast in review
  9. Diffs not prose
  10. No mid-task status
  11. Context hygiene
  12. Batch related work
  13. Spec language in test names
  14. Session end discipline
  15. Assumptions over questions for low-risk decisions
- **DONE message format** with SELF-AUDIT block
- **BLOCK comment format** — file/line reference, spec reference, required change

---

### SPEC-DRIVEN-DEVELOPMENT.md

The full spec chain philosophy. Include:

- **The chain** (verbatim, use unicode arrow `→` U+2192, NOT ASCII `->`) : `spec → interface → failing test → implementation → CI green`
- **Discovery over tracking** — observe what is there, don't plan what you expect
- **Stage 1**: Read spec as a test plan (Architect extracts behaviors)
- **Stage 2**: Encode spec in test names (spec language, not implementation language, with good/bad examples)
- **Stage 3**: Annotate tests with `// SPEC:` references
- **Stage 4**: Tests written before implementation (Tester -> Builder handoff)
- **Stage 5**: Ambiguity protocol (ASSUMPTION for low-risk, UNKNOWN for genuine ambiguity, always stop for data/privacy/security)
- **Stage 6**: No gold-plating (implementation satisfies tests, nothing more)
- **Summary table**: stage x who x reads x produces x model

---

### TDD-STANDARDS.md

Test philosophy and standards. Include:

- **Opening warning**: "Your training data contains a lot of bad TDD" — tests that test implementation details are a liability
- **Spec chain reference** (MUST appear verbatim): `spec → interface → failing test → implementation → CI green`
- **Test at export boundary** — test per BEHAVIOR, not per class
- **Structure-insensitive tests** — renaming private methods shouldn't break tests
- **Fakes over mocks** — hand-written Fakes with contract tests. Include Fake code template adapted to the project's language.
- **Contract test pattern** — runs against both Fake and real implementation
- **The gear-down pattern** — shift to lower-level tests for complex algorithms, delete scaffolding when boundary test covers behavior
- **Test desiderata** — fast, isolated, deterministic, readable, behavior-focused
- **Multiplatform test organization** (for KMP/Compose Multiplatform projects): commonTest for shared logic using kotlin.test, platform-specific test source sets (androidTest uses JUnit runner, iosTest uses XCTest runner, jsTest uses Karma/Node, jvmTest uses JUnit). Include guidance on where each type of test lives and which `expect/actual` test utilities are needed.
- **Anti-patterns**: reflection-based tests, forced synchrony hacks, trivially-passing assertions, mocking everything

---

### SKILL-agent-spawn.md

The canonical spawn protocol. Include:

- **Pre-spawn checklist** (9 items: team exists, model selected, bypass permissions, team_name set, file scope checked, worktree created, issue active, task assigned)
- **TeamCreate step** — once per session, before first spawn
- **Worktree setup** — `git worktree add ../b-[name] -b [branch] main` OUTSIDE repo
- **Agent tool call template** — name, team_name, model, mode, prompt
- **Name prefix conventions** — b- (builder), r- (reviewer), a- (architect), t- (tester), au- (auditor), pm- (PM)
- **Model selection quick reference table**
- **Prompt template** — working directory, branch, task, files to read, rules, completion steps
- **bypassPermissions explanation** — briefly explain what this mode does: "Allows the agent to use tools (file writes, git operations, shell commands) without prompting the PO for permission on each action. Without this, the agent interrupts the PO for every tool call."
- **Post-spawn verification** — check directory within 2 messages
- **10 anti-patterns** with what goes wrong and the rule:
  - A1: Skip TeamCreate (agent invisible to PO)
  - A2: Omit model parameter (inherits expensive Lead model)
  - A3: Use isolation:"worktree" with team_name (contamination)
  - A4: Spawn from inside another agent's worktree (nested paths)
  - A5: Spawn without bypassPermissions (interrupts PO)
  - A6: Spawn without push-before-DONE (commits lost on crash)
  - A7: Two agents with overlapping file scope (merge conflicts)
  - A8: Plain subagents without team_name (invisible work)
  - A9: 3+ redirect messages to misbehaving agent (waste — shut down and respawn after 1 retry)
  - A10: Worktree inside repo tree (contamination)
- **Quick reference card** — spawn sequence for file-writing and coordination-only agents

---

### SKILL-worktree-isolation.md

Git worktree isolation strategy. Include:

- **The problem**: Claude Code's built-in isolation creates worktrees inside repo, causing contamination
- **The solution**: Manual worktrees outside repo tree + teammates for visibility
- **Agent spawn sequence** (3 steps: create worktree, TeamCreate, spawn agent)
- **Agent safety rules**: `pwd && git rev-parse --show-toplevel` before any git operation
- **Banned commands**: git clean, git reset --hard, git checkout -- ., git restore .
- **Push before DONE** — unpushed commits lost on crash
- **Contamination symptoms** — dirty PO checkout, unexpected branch switches, vanishing changes
- **Recovery procedures** — for dirty checkout and session-end cleanup

---

### SKILL-new-feature-checklist.md

End-to-end feature workflow. Include:

- **Phase 1 — Discovery**: Read issue, read spec, read interfaces, run DISCOVERY gate
- **Phase 2 — Implementation (TDD order mandatory)**: Create branch, write test FIRST, write implementation, add platform stubs, register DI bindings
- **Phase 3 — Quality Gates**: Format, test, all-platforms compile, static analysis, full quality check
- **Phase 4 — PR and Merge**: Push, create PR with `Closes #N`, smoke test on device, send DONE, fix all review feedback, merge after approval
- **Quick Reference — Build Tasks table**
- **Common Causes of Reviewer Blocks** — list of top 10 blocking reasons
- **"Where Am I?" Recovery Table** — map observable state to next step:

  | I have... | I'm in... | Next step |
  |---|---|---|
  | Task but no branch | Phase 1 | Run DISCOVERY gate |
  | Branch but no tests | Phase 2 | Write test file FIRST |
  | Failing tests | Phase 2 | Write implementation |
  | Green tests, no quality gates | Phase 3 | Run quality gates |
  | Quality passes, no PR | Phase 4 | Push and create PR |
  | PR but no smoke test | Phase 4 | Test on device |
  | Reviewer feedback | Phase 4 | Fix ALL feedback |
  | Reviewer approved | Phase 4 | Merge |

---

### SKILL-live-learning.md

Making corrections stick within a session. Include:

- **Why corrections don't stick** — U-shaped retention curve (Lost in the Middle): primacy and recency retained, middle degrades
- **The enforcement hierarchy** (6 levels, most to least reliable):
  1. Tool-level deny (mechanical block)
  2. Spawn prompt NON-NEGOTIABLE (primacy position)
  3. CLAUDE.md rules (reloaded post-compaction)
  4. Broadcast corrections (recency for all agents)
  5. harness/lessons.md (applied to harness files by Lead)
  6. Verbal corrections (compressed away — least reliable)
- **NON-NEGOTIABLE block pattern** — max 5 rules per role, placed at top of spawn prompt. Include blocks for Builder, Reviewer, and Lead.
- **Broadcast correction protocol** — fix immediate issue, formulate one-line rule, broadcast to all agents, write to lessons.md, apply to harness file
- **L: DSL prefix** — format for live pattern capture
- **5-minute target** — failure to harness update pushed in under 5 minutes
- **Automatic reflection triggers table** — PO correction, failed PR, 2 hours in, milestone boundary, session end
- **Mid-session rule refresh** — every 90 minutes, re-read recent lessons, check for repeat violations
- **Session length guidance** — cap at 3 hours, handoff notes at 2 hours

---

### SKILL-session-shutdown.md

Session shutdown deliverables. Include 6 mandatory steps:

1. **Write lessons** to harness/lessons.md (format: WHAT_I_DID / WHAT_WAS_WRONG / CORRECTION / PATTERN)
2. **Create harness recommendations issue** — specific files + specific changes, becomes first task next session
3. **Write build journal entry** — metrics header (PRs merged, bugs fixed, coverage delta, agent spawns), sections: what happened, what went wrong, key decisions, what was NOT done
4. **Write launch script to `LAUNCH-SCRIPT.md`** — startup guide for next session (overwritten, not appended to build journal)
5. **Commit all deliverables + create harness PR**
6. **Clear Session Overrides** — reset all ROLE-*.md Session Overrides sections to default

---

### SKILL-course-correction.md

Mid-implementation pivot protocol. Include:

- **Trigger criteria**: >30% through implementation AND (fundamental assumption wrong, spec mismatch discovered, blocking dependency missing, approach won't work)
- **Decision tree**:
  - Impact <20 lines, same files? -> Self-correct, document in DONE
  - Impact >=20 lines, same files? -> Lead GO required
  - New files or deletes needed? -> Architect redesign
  - Affects other agents' work? -> Lead coordinates pause + redesign
  - User data/security/scope? -> PO escalation
- **Course correction message format**: COURSE-CORRECT: with what changed, why, impact, branch strategy
- **Branch strategy**: continue same branch (most cases) vs. start fresh (fundamental redesign)
- **Concrete examples** — include at least one project-specific example per decision tree branch (e.g., "<20 lines: discovered timezone enum needed UTC alias, added 3-line when branch", ">=20 lines: calendar comparison algorithm needs complete rewrite for recurring events", "New files: sharing protocol needs separate encryption module", "Affects others: calendar data model change impacts Builder working on UI", "PO escalation: spec says 'nearby friends' but doesn't define radius")
- **Anti-patterns**: silent pivots, scope creep during correction, not updating tests

---

### SKILL-pr-review.md

PR review checklist. Include:

- Run quality check FIRST — if fails, BLOCK before reading code
- Check `Closes #N` in PR body
- Check TDD ordering (`git log --diff-filter=A`)
- Structure-insensitivity: can you rename private methods without breaking tests?
- Check for code rule violations (from CLAUDE.md CODE RULES)
- Check module boundaries (no cross-feature imports)
- Check DI wiring (interface has prod impl)
- Check platform stubs exist
- Verify SELF-AUDIT block in DONE message matches acceptance criteria

---

### SKILL-github-pr-workflow.md

PR lifecycle. Include:

- Branch naming: feature/[name], fix/[desc], design/[name], harness/[desc]
- Commit message format: type(scope): description
- Push with `-u` flag
- PR creation with `gh pr create` — title, body with `Closes #N`
- Merge: `gh pr merge --squash --delete-branch`
- Builder merges. Lead and Reviewer never merge.

---

### Templates

**RETRO-TEMPLATE.md** — Milestone retrospective format with:
- Metrics table (PRs merged, blocked on first review, CI failures, agent spawns, coverage delta, cost) — include one filled-in example row with plausible values
- What worked / what wasted tokens / what was missing
- Harness updates made
- Agent performance notes
- Carry-forward items

**LAUNCH-SCRIPT.md format** — See `harness/skills/SKILL-session-shutdown.md` (canonical source) for the launch script template. The generator writes first-boot content using that format; shutdown regenerates it each session.

---

### Starter Files

**tasks/MILESTONES.md** — Include the project's milestones with completion gates:
1. All tasks DONE and merged
2. CI green on main
3. App compiles and runs on all targets
4. PO validation
5. SYSTEM-KNOWLEDGE.md updated
6. Retrospective written using RETRO-TEMPLATE.md

**harness/lessons.md** — Start with header `# Lessons Log — append only, never edit existing entries` followed by one commented-out example entry showing the exact format:
```
<!-- EXAMPLE (delete after first real entry):
## Session 2025-01-15
### WHAT_I_DID
Implemented calendar sync for Android
### WHAT_WAS_WRONG
Forgot to add iOS platform stub — broke iOS build
### CORRECTION
Added expect/actual stub for iOS before marking DONE
### PATTERN
Always verify all platform targets compile before reporting D:
-->
```

**docs/BUILD-JOURNAL.md** — Start with header `# Build Journal — one entry per session` followed by one commented-out example entry showing the exact format:
```
<!-- EXAMPLE (delete after first real entry):
## Session 2025-01-15
PRs merged: 3 | Bugs fixed: 1 | Coverage delta: +4% | Agent spawns: 7

### What happened
Completed M0 scaffold. Set up Koin DI, created core interfaces, configured CI.

### What went wrong
Builder forgot platform stubs twice — added to NON-NEGOTIABLE block.

### Key decisions
Chose sealed class Result<T> over Arrow Either for simplicity (ADR-001).

### What was NOT done
Integration tests for calendar access — deferred to M1.
-->
```

**tasks/PRODUCT-BRIEF.md** — Generated from Part A product discovery answers. Contains: one-line description, target user, core problem, MVP scope (in/out), hard constraints, discovery date.

**LAUNCH-SCRIPT.md** — The first-boot launch script generated at install time. Written by the generator as the final step. Overwritten by SKILL-session-shutdown.md at the end of each session. First-boot content:
- Header: "Launch Script — First Session" with current date and M0 as current milestone
- Product Discovery: DONE — see `tasks/PRODUCT-BRIEF.md`
- Open PRs: None
- Open Issues: Created for M1 tasks during generation
- Remaining tasks: Read from tasks/MILESTONES.md M0 tasks
- Pending Harness Updates: None
- Startup Checklist:
  1. Read CLAUDE.md
  2. Read harness/SYSTEM-KNOWLEDGE.md
  3. Read tasks/PRODUCT-BRIEF.md — product direction
  4. Read tasks/MILESTONES.md — find M0 tasks
  5. Read harness/SKILLS-INDEX.md (load skills lazily)
  6. Read your role file from harness/roles/
  7. Begin M0

**harness/SYSTEM-KNOWLEDGE.md** — Start with module list skeleton with one filled-in example row to show the expected format. Include a "How to update this file" section at the top explaining that the Architect updates after each milestone.

**harness/SKILLS-INDEX.md** — Pre-populated lookup table with all generated skills. Trigger column must answer "What observable event causes an agent to load this skill?" using the format "When [event]" — not vague temporal references like "before/after". Example: "When about to spawn an agent" not "Before spawning".

---

## Step 3: First Boot Setup

After generating all files, complete the first-boot sequence:

### 3a. Write the Initial Launch Script

Write `LAUNCH-SCRIPT.md` using the format from `harness/skills/SKILL-session-shutdown.md` (Step 5 template) with first-boot content:
- **Current milestone:** M0: Project Scaffold
- **Previous session:** None — first session
- **Product Discovery:** DONE — see `tasks/PRODUCT-BRIEF.md`
- **Open PRs:** None
- **Open Issues:** Created for M1 tasks during generation
- **Remaining Milestone Tasks:** Pull from tasks/MILESTONES.md M0 tasks
- **Pending Harness Updates:** None — freshly generated
- **Startup Checklist:**
  1. Read CLAUDE.md — your dense agent reference
  2. Read harness/SYSTEM-KNOWLEDGE.md — module status (Architect populates this)
  3. Read tasks/PRODUCT-BRIEF.md — product direction
  4. Read tasks/MILESTONES.md — find M0 tasks
  5. Read harness/SKILLS-INDEX.md — know what skills exist (don't load them yet)
  6. Read your role file from harness/roles/
  7. Begin M0

### 3b. Offer the "Hello World" Commit

Ask the user: "Your harness is ready. Want me to commit these files to git so they're saved before we continue?"

If yes, commit all generated files:
```bash
git add -A
git commit -m "chore: install agent orchestration harness"
```

### 3c. Prompt Relaunch

Tell the user:

> **Relaunch Claude Code to begin.** CLAUDE.md is auto-loaded on session start, so a fresh session picks up the full harness cleanly. Your current context window is full of generation work — a new session starts clean.
>
> When you relaunch, say: **"Read LAUNCH-SCRIPT.md and begin."**

---

## Step 4: Verification

After generating all files, run this self-check:

1. **CLAUDE.md is under 200 lines** — if over, extract content into skill files
2. **Every ROLE-*.md has a Session Overrides section** at the bottom, using the exact standardized format (`## Session Overrides` + `_None — cleared at session end._`)
3. **Every ROLE-*.md has a NON-NEGOTIABLE block** — grep for the literal heading `## NON-NEGOTIABLE` in each file (not just the presence of rules — the heading must exist for spawn prompt extraction)
4. **SKILLS-INDEX.md lists every SKILL-*.md file** with trigger condition
5. **The spec chain (`spec → interface → failing test → implementation → CI green`) is referenced in at least 4 files** (CLAUDE.md, SPEC-DRIVEN-DEVELOPMENT.md, TDD-STANDARDS.md, ROLE-BUILDER.md). Grep for BOTH `→` and `->` variants. If any file uses ASCII `->`, fix it to unicode `→` before reporting pass.
6. **"Builder merges, Lead/Reviewer never merge" appears in at least 3 files**
7. **Worktree isolation is covered in CLAUDE.md, SKILL-agent-spawn.md, SKILL-worktree-isolation.md, and ROLE-BUILDER.md**
8. **Token economy rules appear in AGENT-COMMUNICATION-PROTOCOL.md**
9. **All build commands in CLAUDE.md match the project's actual build system**
10. **No file references a file that wasn't generated** (note: tasks/adr/ is created as an empty directory, not a generated file — references to it are valid)
11. **Every section heading in CLAUDE.md has a corresponding expanded section in CLAUDE-HUMAN.md** — grep for each `## ` heading in CLAUDE.md and verify CLAUDE-HUMAN.md has the identical heading text. CLAUDE-HUMAN.md must NOT add numbering or rewording (e.g., `## PROJECT` not `## 1. PROJECT`)
12. **Starter files (lessons.md, BUILD-JOURNAL.md) contain example entries** — not just headers
13. **SYSTEM-KNOWLEDGE.md has at least one filled-in example row** in the module status table
14. **tasks/adr/ directory exists** (created during directory setup)
15. **README.md exists** with Quick Start section pointing to `LAUNCH-SCRIPT.md`
16. **`.claude/settings.json` exists** with project-level permissions pre-approving agent tools and denying destructive commands
17. **ROLE-PM.md exists** with NON-NEGOTIABLE and Session Overrides sections

Report the self-check results before finishing.

**Cross-reference phrases that MUST appear verbatim** (for verification grep to find).
**IMPORTANT: Use unicode arrow `→` (U+2192), NOT ASCII `->`.** Agents independently choose between these — normalize to unicode everywhere. Include this instruction in every parallel agent's prompt.
- `spec → interface → failing test → implementation → CI green` — in CLAUDE.md, SPEC-DRIVEN-DEVELOPMENT.md, TDD-STANDARDS.md, ROLE-BUILDER.md
- "Builder merges" + "never merge" (for Lead/Reviewer) — in CLAUDE.md, ROLE-BUILDER.md, ROLE-REVIEWER.md, SKILL-github-pr-workflow.md
- "worktree" + "OUTSIDE" or "outside" — in CLAUDE.md, SKILL-agent-spawn.md, SKILL-worktree-isolation.md, ROLE-BUILDER.md

**Note**: Verbatim repetition of these phrases across files is intentional, not wasteful duplication. These phrases survive context compaction because each file is loaded independently. Do not deduplicate them into a single canonical location — agents may only read one of these files per task.

---

## Design Principles Behind This Harness

These are the principles that shaped the architecture. They're here so you understand the "why" and can make good judgment calls when adapting to the specific project:

1. **Every rule traces to a failure.** Don't add rules speculatively. If something hasn't gone wrong yet, don't legislate it.

2. **Token economy is a first-class concern.** Output tokens cost 5x input tokens. CLAUDE.md is dense because every byte is loaded for every agent. Skills are lazy-loaded because most agents don't need most skills.

3. **Corrections don't stick in LLM context.** The U-shaped retention curve means mid-conversation corrections degrade. The harness compensates with primacy (NON-NEGOTIABLE blocks), recency (broadcasts), and persistence (harness files that survive context compaction).

4. **Lead never writes code.** Separation of concerns. When the orchestrator starts implementing, it loses track of coordination. The Lead creates worktrees, spawns agents, monitors progress, and escalates. Nothing else.

5. **Builder owns the merge.** Clear ownership. The person who wrote the code merges it after review. No handoff confusion.

6. **Fakes over mocks.** Mocks test call sequences (structure). Fakes test behavior (output given input). Structure tests break on every refactor. Behavior tests survive refactors.

7. **Discovery before execution.** Reading with a cheap model is always cheaper than re-implementing with an expensive model. The discovery gate forces agents to understand before they build.

8. **Worktree isolation is non-negotiable.** Agents sharing a working directory will contaminate each other. This was proven 7 times. Manual worktrees outside the repo tree is the only working solution.

9. **The harness is a living document.** It improves every session through the live learning loop. Lessons become harness rules within 5 minutes. Future agents read the improved rules, not the raw lessons.

10. **Dual-document strategy.** CLAUDE.md (dense, for agents) and CLAUDE-HUMAN.md (prose, for humans) contain the same information at different densities. Both must stay in sync.

11. **Lazy-load everything possible.** SKILLS-INDEX.md is a lookup table, not a loading directive. Agents read a skill only when about to execute work that needs it. This keeps context windows clean.

12. **Adversarial self-audit.** Every DONE message requires a SELF-AUDIT block — one line per acceptance criterion. This forces agents to verify against the spec, not just report "I'm done."

13. **No follow-up issues for current-PR feedback.** All reviewer feedback gets fixed on the branch before merge. The "follow-up issue" pattern creates a backlog of ignored improvements.

14. **Loop detection saves tokens.** Same function modified 3+ times = likely stuck. 10+ tool calls without DONE = likely lost. Both trigger a stop-and-assess protocol.

15. **Session length cap at 3 hours.** Context quality degrades over time. A fresh session with good handoff notes outperforms a long session with degraded context.