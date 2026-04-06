# Agent Communication Protocol

## Communication DSL Reference
| Prefix | Full meaning | Format |
|--------|-------------|--------|
| I: | Informational state update | `I: [agent] [status]` |
| R: | Discovery complete, ready for GO | `R: [task-id] ready \| blocked:[reason]` |
| G: | Execute — Lead authorizes work | `G: [agent] [task-id]` |
| H: | Hold — wait for condition | `H: [agent] wait for [condition]` |
| B: | Blocked — named agent resolve | `B: [task-id] blocked on [agent/issue]: [description]` |
| D: | Done — Lead verify | `D: [task-id] complete. PR #[N]. SELF-AUDIT: [criteria]` |
| A: | Decision needed — any agent sends to Lead; Lead forwards to PO if needed | `A: [decision needed] [options]` |
| V: | PR opened | `V: [task-id] PR #[N] opened. [branch]` |
| F: | Fixes pushed, ready for re-review | `F: [task-id] PR #[N] fixes pushed` |
| E: | PO product decision | `E: [question] [context] [options]` |
| L: | Pattern identified | `L: [what went wrong] — [rule] — updating [file]` |
| CHECKPOINT: | Session context re-anchor at 2-hour mark | All agents: read and re-orient |

## Lead-Only Signals
Reserved for Lead orchestration. Agents receive these, never send them.

| Prefix | Full meaning | Format |
|--------|-------------|--------|
| `ASSIGN:` | Explicit task assignment | `ASSIGN: [agent] [task-id]` |
| `SCALE:` | Spawn N additional agents | `SCALE: [role] [N] ([issue list])` |
| `AUDIT:` | Trigger audit | `AUDIT: [agent] scope:[scope]` |
| `MERGE:` | Lead merging Track 1 PR | `MERGE: PR-[N]` |
| `CLOSE:` | Agent shutdown | `CLOSE: [agent] reason:[reason]` |

## Lead DSL — PO → Lead Commands
Short commands for immediate execution. See `CLAUDE.md#LEAD-DSL` for the full table.

| Category | Examples |
|----------|---------|
| Spawn | `build:`, `arch:`, `review`, `test:`, `pm:`, `audit:`, `security:` |
| Workflow | `merge #N`, `validate [milestone]` |
| Status | `dashboard`, `prs`, `issues`, `status` |
| Control | `go`, `no`, `skip`, `defer [issue]`, `shut down` |
| Memory | `remember:`, `never:`, `always:` |

## DONE Message Format
```
D: [TASK-ID] complete. PR #[N] opened.

SELF-AUDIT:
- [criterion 1]: PASS — [evidence]
- [criterion 2]: PASS — [evidence]

Tests: [N] passed, 0 failed
Quality: PASS
Coverage: [N]% ([+/-N]% from baseline)
```

## BLOCK Message Format
```
B: [TASK-ID] blocked on [agent/issue/person].

File: path/to/file.kt:42
Spec reference: [spec section or NONE]
Required: [what needs to happen to unblock]
Attempted: [what was tried, N times]
```

## Builder Fallback: PO Unreachable
If you cannot reach the PO directly, send B: to Lead and wait — never self-authorize scope expansion.

Builder cannot reach PO → `B:` to Lead → wait for Lead to relay PO decision → proceed only after `G:`.

## Reviewer → Builder Change-Request Flow
1. Reviewer posts feedback via `gh pr review [PR] --comment --body "[feedback]"`
2. Reviewer sends to Lead: `B: [TASK-ID] PR #[N] changes requested: [summary]`
3. Lead routes to Builder: `G: [builder] fix PR #[N] feedback: [summary]`
4. Builder fixes on branch, pushes, sends `F: [TASK-ID] PR #[N] fixes pushed` to Reviewer
5. Reviewer re-reviews immediately on receiving F:

## Verbatim Relay — Lead Responsibility
When any agent sends findings or an `A:` question to Lead, surface them **verbatim** to the PO:
```
**[Auditor]:** [exact findings text]
```
No paraphrasing. No summarizing. No framing. The PO reads what the agent wrote, not Lead's interpretation.

## Investigation Standard
All agents investigate before concluding. Read relevant files, check actual state, find real root cause. Surface assumptions without evidence are a failure.

## Token Economy
No filler, no preamble, no restatement, no hedging. DSL prefix starts every message. Diffs not prose for code changes. Only R:, D:, B: at state transitions — no mid-task status.
See `harness/skills/SKILL-agent-spawn.md` for full token discipline rules.

## Trigger Design
Default to **scheduled** or **milestone-based** triggers. Per-event triggers (per-merge, per-PR) require explicit cost justification. Infrastructure cost is a named design constraint.

## Canonical References
- **Spawn sequence, worktree isolation, model matrix, anti-patterns:** `harness/skills/SKILL-agent-spawn.md`
- **Worktree isolation detail, contamination recovery:** `harness/skills/SKILL-worktree-isolation.md`
- **Commit and PR workflow:** `harness/skills/SKILL-github-pr-workflow.md`
- **DISCOVERY gate, VERIFICATION gate, Self-GO format:** `harness/roles/ROLE-BUILDER-CORE.md`
- **Trio Workflow (PM ↔ QE ↔ Arch):** `harness/TRIO-WORKFLOW.md`
- **Merge ownership rules:** `harness/rules/MERGE-OWNERSHIP.md`
- **Permissions model:** `harness/rules/PERMISSIONS-MODEL.md`
