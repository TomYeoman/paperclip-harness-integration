# Skill: PR Review Checklist

Load this skill when: received a V: message and about to review a PR.

## Step 1: Load Semantic Context

> **Requires code-review-graph MCP plugin** (see issue #385). If not installed, skip this step.

Call `get_review_context` (code-review-graph MCP tool) with the PR number to load semantically relevant context before reading files. This surfaces the files most relevant to the changed code paths, reducing token cost.

If the tool is unavailable, skip to Step 2.

## Step 2: Run Quality Check FIRST
```bash
[quality command]
```
If this fails → BLOCK immediately. Do not read any code. Post to PR:
```
gh pr review [PR] --comment --body "BLOCKED: Quality check failed. Fix before re-review.
[paste quality check output]"
```

## Step 3: Check PR Body
- [ ] PR body contains `Closes #N` (exact format)
- [ ] Description explains what changed and why
If missing `Closes #N` → BLOCK: "PR body must contain `Closes #N` to auto-close issue on merge."

## Step 4: TDD Ordering Check
```bash
git log --diff-filter=A --name-only --pretty=format:"%H %s" origin/main..HEAD
```
Test file(s) must appear in an EARLIER commit than implementation file(s).
If same commit — ask Builder: "Was test written before implementation?"
If implementation committed before test → BLOCK: "TDD ordering violated: test must be committed before implementation."

## Step 4b: Regression Test Check (Bug-Fix PRs Only)
If the PR branch starts with `fix/`:
- [ ] A new test exists that reproduces the original bug
- [ ] That test fails on `main` (or Builder confirms it would fail without the fix)
If missing → BLOCK: "Bug-fix PR must include a regression test that reproduces the original bug."

## Step 5: Structure-Insensitivity Check
For each test file:
- Pick a private class or method in the implementation
- Ask: "Would renaming this break any test?"
- If yes → BLOCK: "Test [TestName.testMethod] tests structure, not behavior. It references [private thing]. Tests must survive renaming private internals."

## Step 6: CODE RULES Check
Apply CLAUDE.md § CODE RULES — do not restate here. Every rule in that section is a hard block if violated.

**Platform standards (mandatory):** Load `harness/skills/SKILL-coding-standards-[platform].md` for the platform provided in your spawn prompt and apply its checklist in addition to the base CODE RULES. Platform violations are hard blocks — treat them identically to CODE RULES violations. The platform identifier must be provided in your Reviewer spawn prompt (`Platform: ios|android|web|backend`).

## Step 7: Module Boundary Check
- [ ] No imports from other feature modules
- [ ] No presentation layer importing data layer directly
- [ ] All new dependencies behind interfaces

## Step 8: DI Wiring Check
For each new interface:
- [ ] Production implementation exists
- [ ] Production impl registered in DI module
- [ ] Test fake exists (or Tester has been assigned to create one)

## Step 9: Platform Stubs Check
If multiplatform project:
- [ ] New `expect` declarations have `actual` implementations for ALL target platforms
- [ ] No target platform left with a stub that crashes at runtime

## Step 10: SELF-AUDIT Verification
Check Builder's DONE message for SELF-AUDIT block.
- [ ] SELF-AUDIT block exists
- [ ] Each acceptance criterion listed as pass/fail
- [ ] No criterion marked "pass" without visible evidence in the diff

## Feedback Format
All feedback must be actionable and file:line referenced:
```
**BLOCKED**: [reason]
File: path/to/file.kt:42
Required change: [specific fix]
Spec reference: [if applicable]
```

Non-blocking feedback:
```
**SUGGESTION**: [reason]
File: path/to/file.kt:15
Consider: [specific alternative]
```
Builder must fix ALL feedback (blocking and non-blocking) before review is marked complete.

## Completion (NOT approval — Reviewer never approves)
When all issues are addressed and re-review passes, write the completion comment to a file with a **checklist evidence block** showing every step was executed:

```
Write ./review-complete.md:
Adversarial review complete. All issues addressed. Ready for human review.

Evidence:
- Step 1 (Semantic context): [get_review_context called — pass / tool unavailable — skipped]
- Step 2 (Quality check): [ran command X — passed/failed]
- Step 3 (PR body): [Closes #N present — pass]
- Step 4 (TDD ordering): [test committed before impl — pass / N/A reason]
- Step 4b (Regression test): [N/A — not a bug fix / test exists — pass]
- Step 5 (Structure-insensitivity): [checked renaming X — tests survive — pass]
- Step 6 (CODE RULES): [reviewed N files — no violations / found X — addressed]
- Step 6b (Platform standards): [loaded SKILL-coding-standards-[platform].md — no violations / found X — addressed]
- Step 7 (Module boundaries): [no cross-feature imports — pass / N/A]
- Step 8 (DI wiring): [no new interfaces — N/A / checked X — pass]
- Step 9 (Platform stubs): [N/A — single platform / checked X — pass]
- Step 10 (SELF-AUDIT): [all criteria present and evidenced — pass]
```

```bash
gh pr review [PR-number] --comment --body-file ./review-complete.md && rm -f ./review-complete.md
```

A review that says "looks good, no blockers" without the evidence block is an incomplete review. Lead must reject it and ask the Reviewer to re-run with evidence.

Then send Builder via SendMessage: "Adversarial review complete. Send D: to Lead."
Then send Lead via SendMessage: "Adversarial review complete for PR #[N]. Ready for human review."

**NEVER run `gh pr review --approve`. NEVER run `gh pr merge`. Human (PO) performs the final review and merge in GitHub UI.**

## Gotchas

- `get_review_context` is only available after the code-review-graph plugin is installed (see issue #385 / `.claude/settings.json` mcpServers). If the tool is unavailable, skip it and proceed with full file reads.
