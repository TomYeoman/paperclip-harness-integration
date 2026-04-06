# Skill: New Feature Checklist

Load this skill when: starting implementation of a new feature task.

## Phase 1 — Discovery
- [ ] Read GitHub issue — understand acceptance criteria
- [ ] **Large repo scoping (iOS, 30GB+):** Before exploring files, read `docs/architecture/CODEBASE-MAP.md` and any `AGENTS.md` in the repo root to identify the relevant module/package. Do NOT traverse the full repo — scope all file reads to the identified module(s) only. See `docs/architecture/ios-codebase-map.md` for the iOS module map.
- [ ] Read relevant spec section in tasks/PRODUCT-BRIEF.md
- [ ] Read interface definitions from Architect (tasks/adr/ or shared module)
- [ ] Read harness/SYSTEM-KNOWLEDGE.md for relevant module status
- [ ] **iOS only:** Read `.swiftlint.yml` from the iOS repo root before writing any code
- [ ] **Large repo (iOS, 30GB+):** Read `docs/architecture/CODEBASE-MAP.md` and `docs/architecture/ios-codebase-map.md` first — identify the 1–2 relevant modules before exploring any files. Do NOT traverse the full repo.
- [ ] Run DISCOVERY gate and send R: to Lead

```
DISCOVERY: [TASK-ID]
READ: [list of files read]
UNDERSTAND: [2-3 sentences: what this task does, what interfaces it uses]
UNKNOWNS: [list anything unclear, or NONE]
PLAN:
  - [ ] Write test: [test name]
  - [ ] Implement: [class/function name]
  - [ ] Add platform stub: [if needed]
  - [ ] Register DI: [module name]
  - [ ] Create PR closing #[N]
R: yes | blocked:[reason]
```

Wait for Lead G: before proceeding to Phase 2.

## Phase 2 — Implementation (TDD order mandatory)
- [ ] Create branch: `git checkout -b feature/[name]`
- [ ] Write test file FIRST — commit it before any implementation
- [ ] Write implementation to make tests pass
- [ ] Add platform stubs for all target platforms (if needed)
- [ ] Register DI bindings (interface → production impl)
- [ ] Verify DI wiring: interface has prod impl registered

## Phase 3 — Quality Gates
- [ ] Run lint/format: `[lint command]` — auto-fix
- [ ] Run tests: `[test command]` — zero failures
- [ ] Run static analysis: `[quality command]` — zero violations
- [ ] Verify all platforms compile (if multiplatform)
- [ ] Run full quality check: `[coverage command]` — no regression
- [ ] **iOS only:** Run SwiftLint — zero warnings (`swiftlint lint`)
- [ ] **iOS only:** Assess SonarQube coverage impact — note in PR body if coverage will drop

## Phase 4 — PR and Merge
- [ ] Push branch: `git push -u origin feature/[name]`
- [ ] Create PR: `gh pr create --title "feat(scope): description" --body "Closes #N\n\n[description]"`
- [ ] Smoke test on device/target (tests passing is necessary but NOT sufficient)
- [ ] Send V: message to Lead with PR number
- [ ] Fix ALL reviewer feedback on branch (no follow-up issues)
- [ ] After Reviewer approves: Human (PO) merges in GitHub UI. Agents NEVER run `gh pr merge`.

## Quick Reference — Build Tasks
| Task | Command | When |
|------|---------|------|
| Format | `[lint]` | Before every commit |
| Test | `[test]` | After every change |
| Analyze | `[quality]` | Before PR |
| Coverage | `[coverage]` | At PR creation |

_Fill in actual commands after M0 defines stack._

## Common Causes of Reviewer Blocks
1. Quality check fails
2. PR body missing `Closes #N`
3. Test committed AFTER implementation (wrong TDD order)
4. Tests are structure-sensitive (test private method names)
5. Magic number without constant
6. TODO without issue reference
7. Commented-out code left in
8. println/console.log left in
9. Missing platform stub for one target
10. DI interface not registered in production module

## "Where Am I?" Recovery Table
| I have... | I'm in... | Next step |
|-----------|-----------|-----------|
| Task assigned, no branch | Phase 1 | Run DISCOVERY gate |
| Branch, no test file | Phase 2 | Write test file FIRST |
| Test file, no implementation | Phase 2 | Write implementation |
| Implementation, tests failing | Phase 2 | Fix implementation (not tests) |
| Green tests, no quality gates run | Phase 3 | Run quality gates |
| Quality passes, no PR | Phase 4 | Push and create PR |
| PR open, no smoke test | Phase 4 | Test on device |
| Reviewer left feedback | Phase 4 | Fix ALL feedback on branch |
| Reviewer approved | Phase 4 | Human (PO) merges in GitHub UI |
