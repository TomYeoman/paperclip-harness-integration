# Workflow: Bug Fix

Use this workflow for simple, well-understood bugs. Skips PM discovery and Architect phases.

## Triage Gate — Bug Fix vs Full Workflow

Use this workflow ONLY when ALL of the following are true:

| Criterion | Threshold |
|-----------|-----------|
| Change size | < 50 lines |
| Scope | Single component or file |
| Interfaces | No new interfaces required |
| Spec | No spec change required |
| Root cause | Known and understood before starting |

If ANY criterion fails → use the full workflow (SKILL-new-feature-checklist.md) and spawn PM.

## Phases Skipped

- PM discovery
- Architect interface design
- ADR creation

Code review is NEVER skipped.

---

## Phase 1 — Triage and Understanding

Run this gate before touching any code. Self-GO is allowed (no Lead approval needed) if all triage criteria pass.

```
BUG-FIX: [ISSUE-ID]
READ: [files read]
UNDERSTAND: [1-2 sentences: what is broken and why]
ROOT CAUSE: [specific line/condition causing the bug]
UNKNOWNS: [list or NONE]
PLAN:
  - [ ] Write regression test: [test name]
  - [ ] Fix: [function/file]
  - [ ] Verify no other call sites affected
TRIAGE: all criteria met | failed:[which criterion]
SELF-GO: yes
```

If TRIAGE fails, stop. Send B: to Lead with reason.

## Phase 2 — Fix (TDD order mandatory)

- [ ] Create branch: `git checkout -b fix/[desc]`
- [ ] Write regression test FIRST — must fail before the fix
- [ ] Commit the failing test
- [ ] Apply the fix — make the test pass
- [ ] Verify no existing tests regressed

## Phase 3 — Verification Gate

Before opening a PR:

- [ ] Run tests — zero failures
- [ ] Run lint/format
- [ ] Run static analysis — zero new violations
- [ ] `git diff main` — self-review: no unintended changes
- [ ] "Would a staff engineer approve?" — if no, fix first

## Phase 4 — PR and Merge

- [ ] Push branch: `git push -u origin fix/[desc]`
- [ ] Create PR: `gh pr create --title "fix(scope): description" --body "Closes #N\n\n[what was broken and how it was fixed]"`
- [ ] Send V: message to Reviewer with PR number
- [ ] Fix ALL reviewer feedback on branch (no follow-up issues)
- [ ] After Reviewer approves: # Human (PO) merges via GitHub UI — agents never run gh pr merge

## Common Bug Fix Blockers

1. Regression test written AFTER fix (wrong TDD order)
2. Fix touches more than the minimal change needed
3. Root cause was wrong — symptom treated, not cause
4. Triage criteria not actually met — should have used full workflow
5. No `Closes #N` in PR body

## "Where Am I?" Recovery Table

| I have... | I'm in... | Next step |
|-----------|-----------|-----------|
| Issue assigned, no branch | Phase 1 | Run triage gate |
| Triage fails any criterion | — | Stop, send B: to Lead |
| Branch, no test | Phase 2 | Write regression test FIRST |
| Failing test, no fix | Phase 2 | Apply fix |
| Fix done, tests passing | Phase 3 | Run verification gate |
| Verification passes, no PR | Phase 4 | Push and create PR |
| Reviewer left feedback | Phase 4 | Fix ALL feedback on branch |
| Reviewer approved | Phase 4 | Notify PO — human merges via GitHub UI |
