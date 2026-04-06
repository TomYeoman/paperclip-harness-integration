# Skill: GitHub PR Workflow

Load this skill when: creating a branch, committing work, or managing a PR.

## Branch Naming
| Type | Pattern | Example |
|------|---------|---------|
| Feature | `feature/[name]` | `feature/user-auth` |
| Bug fix | `fix/[desc]` | `fix/cart-total-rounding` |
| Architecture | `design/[name]` | `design/repository-interfaces` |
| Harness update | `harness/[desc]` | `harness/add-builder-rules` |

Never commit directly to main.

## Commit Message Format
```
type(scope): description
```
Types: `feat` | `fix` | `test` | `refactor` | `docs` | `chore` | `harness`

Examples:
- `feat(auth): add JWT token validation`
- `test(auth): add failing test for expired token`
- `fix(cart): correct rounding in total calculation`
- `harness(builder): add merge ownership rule`

## Full Workflow

### Create Branch
```bash
git checkout main
git pull origin main
git checkout -b feature/[name]
```

### Commit (test BEFORE implementation)
```bash
# Commit test file first
git add [test-file]
git commit -m "test(scope): add failing test for [behavior]"

# Then commit implementation
git add [impl-file]
git commit -m "feat(scope): implement [behavior]"
```
**Never use `git commit -m "$(cat <<'EOF'...)"` — command substitution + heredoc always triggers a security prompt. Use a plain multi-line `-m` string instead (safe as long as the message contains no `#`-prefixed lines).**

For commit messages that include `Co-Authored-By:` trailers, use the Write tool (not printf — it triggers security prompts):
```
Write /tmp/commit-msg.txt:
type(scope): description

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
```
```bash
git commit -F /tmp/commit-msg.txt
```

### Push Branch
```bash
git push -u origin feature/[name]
```
Always push before sending D:. Unpushed commits are lost on crash.

### Create PR
Write the body to a temp file first — avoids heredoc/quoted-newline security prompts:
```
Write ./pr-body.md:
## Summary
- [what this PR does]
- [acceptance criteria met]

Closes #N

## Test plan
- [ ] Unit tests pass
- [ ] Quality check passes
- [ ] Smoke tested on [platform]
```
```bash
gh pr create --title "feat(scope): description" --body-file ./pr-body.md && rm -f ./pr-body.md
```
**Never use `--body "$(cat <<'EOF'...)"` or `cat > /tmp/file << 'BODY'` with `#`-prefixed lines — both trigger a security prompt.**

### Two-Track Post-PR Flow

> Merge ownership rules: see [harness/rules/MERGE-OWNERSHIP.md](../rules/MERGE-OWNERSHIP.md)
### After Adversarial Review — Human Merges (Track 2 only)

Human reviews in GitHub UI and merges. **Agents NEVER merge production code PRs. Agents NEVER approve.**

`gh pr merge` and `gh pr review --approve` are NEVER run by any agent. Self-approval is blocked on GHE solo setup.

### Submodule / Multi-repo PRs

When working in a submodule repo (iOS/JustEat, Android, web, BE):

```bash
# Set GH_HOST before any gh command in a submodule repo
export GH_HOST=github.je-labs.com

# Push to submodule remote (working directory is submodule worktree)
git push -u origin [branch]

# Create PR in submodule repo
gh pr create --title "feat(scope): description" --body-file ./pr-body.md && rm -f ./pr-body.md
```

Send V: with full repo + PR reference so Lead and Reviewer can target the correct repo:
```
V: TASK-[N] PR #[N] opened in iOS/JustEat repo. Branch feature/[name]. Platform: ios.
```

Reviewer must set `export GH_HOST=github.je-labs.com` before running any `gh pr` commands against a submodule PR.

## Checking PR Status
```bash
gh pr view [PR-number]
gh pr checks [PR-number]
```

## CONFIRMED-D: Pattern — Polling Merge Queue

After sending D: to Lead, builder enters WAIT-FOR-MERGE state. Poll until confirmed or cap reached:

```bash
# Poll command (run every 10 seconds)
gh pr view <PR-number> --json state,mergeStateStatus
```

**Confirmed merge:** `state` = `"MERGED"` → send `CONFIRMED-D:` to Lead via SendMessage.

**Queue ejected:** `mergeStateStatus` = `"BLOCKED"` or `state` = `"CLOSED"` → resolve conflict, re-queue with `gh pr merge <N> --hostname github.je-labs.com --merge --auto`, continue polling.

**Poll cap:** 12 polls × 10 seconds = 2 minutes maximum. If not confirmed after 2 minutes, send `B: [lead-name] merge queue not confirmed after 2 min — PR #N` and stop. Do NOT send CONFIRMED-D:.

**Branch naming:** Use `feature/[slug]` for all branches. When a builder has `🏠` upstream param (hold in hive), the branch stays local and no upstream PR is opened until Lead sends `👑` authorization.

**Builder shuts down only after receiving CLOSE: from Lead** — which Lead sends in response to CONFIRMED-D:. Never self-terminate.

## If CI Fails
1. Read CI output: `gh run view --log-failed`
2. Fix locally
3. Push fix: `git push origin feature/[name]`
4. CI re-runs automatically

## Jet iOS PR Requirements

All PRs targeting the Jet iOS repo (`iOS/JustEat`) **must** satisfy these four requirements before sending `V:` to Lead. Self-validate every time.

### Checklist
- [ ] PR opened as **draft** (`--draft` flag on `gh pr create`)
- [ ] **Milestone** set to the highest-numbered open milestone
- [ ] **Jira ticket link** included in the PR body under a `## Jira` heading
- [ ] **Ticket number** is the **first line** of the PR description body

### 1. Always open as draft
```bash
gh pr create --draft --title "..." --body-file /tmp/pr-body.md
```

### 2. Set milestone to highest-numbered open milestone
```bash
gh api repos/iOS/JustEat/milestones --hostname github.je-labs.com \
  | python3 -c "import sys,json; ms=[m for m in json.load(sys.stdin) if m['state']=='open']; print(sorted(ms,key=lambda m:m['number'])[-1]['number'])"
```
Pass the result with `--milestone <number>` or set it after PR creation via the GitHub UI.

### 3. Jira ticket link in PR body
```markdown
## Jira
https://justeattakeaway.atlassian.net/browse/CTLG-385
```

### 4. Ticket number as first line of PR body
```markdown
CTLG-385: Age verification UI update — new heading text and layout

## Summary
...
```

## Issue Hygiene

When filing a new issue to replace or refine an existing one: immediately close the old issue as a duplicate, OR write `Closes #old, Closes #new` in the PR body. Never leave the original issue open and unlinked.

```bash
# Close old issue as duplicate when filing a replacement
gh issue close <old-number> --comment "Duplicate of #<new-number>"
```

Alternatively, include both in the PR body:
```markdown
Closes #<old-number>
Closes #<new-number>
```

This ensures the issue tracker stays clean and no stale issues linger after work lands.

## Rebase Recovery

When a PR is ejected from the merge queue due to a line-level conflict (the queue cannot auto-rebase), resolve it manually:

```bash
# In your worktree
git -C /path/to/worktree fetch origin
git -C /path/to/worktree rebase origin/main

# Resolve any conflicts, then:
git -C /path/to/worktree rebase --continue

# Force-push the rebased branch
git -C /path/to/worktree push --force-with-lease origin [branch-name]
```

Then re-add the PR to the merge queue via GitHub UI or `gh pr merge <PR-number> --hostname github.je-labs.com --merge --auto`.

**This is the exception path.** For most parallel builder conflicts, the merge queue handles rebase automatically — no manual action needed.

### Reverting Corrupted Content on an Open PR Branch

Use `git revert [bad-commit]` — **never** `git push --force` on an open PR branch.
Force-pushing on an open PR destroys reviewer context and may cause the merge queue to reject the PR.

## Repo Info
- Repo: https://github.je-labs.com/grocery-and-retail-growth/testharness
- Main branch: main
- Merge queue enabled (ruleset ID 831) — PRs go through the queue; no direct squash merges to main
- Delete branch after merge (--delete-branch flag required)

## Gotchas

| # | Trap | What breaks | Fix |
|---|------|------------|-----|
| 1 | `git commit -m "$(cat <<'EOF'...)"` heredoc | Security prompt every time | Write message to `./commit-msg.txt` (worktree-relative) with Write tool, then `git commit -F ./commit-msg.txt && rm -f ./commit-msg.txt` |
| 2 | `gh pr create --body "$(cat ...)"` or `cat > file << 'BODY'` with `#`-lines | Security prompt | Write body to `./pr-body.md` (worktree-relative), use `--body-file ./pr-body.md && rm -f ./pr-body.md` |
| 3 | Forgetting `gh pr merge --merge --auto` after PR open | PR idles outside merge queue | Always queue immediately after opening |
| 4 | Agent running `gh pr merge` or `gh pr review --approve` on Track 2 | Violates Two-Track Model; self-approval blocked | Agents never merge/approve Track 2 PRs — human only |
| 5 | Pushing without `-u` flag | Subsequent pushes fail; tracking branch missing | Always `git push -u origin [branch]` on first push |
| 6 | Leaving old issue open when filing a replacement | Duplicate issue clutter | Close old as duplicate immediately: `gh issue close <old> --comment "Duplicate of #<new>"` |
| 7 | Missing `export GH_HOST=github.je-labs.com` in submodule worktrees | `gh` commands target wrong host | Set `GH_HOST` before any `gh` command in a submodule |
| 8 | `--hostname` flag on `gh issue create` | Flag does not exist — command fails | Omit it; set `export GH_HOST=github.je-labs.com` before running instead |

## Cycle Time

**Definition:** time from issue creation to PR merge.

```bash
# Get issue creation timestamp
gh issue view <ISSUE-N> --json createdAt --hostname github.je-labs.com

# Get PR merge timestamp
gh pr view <PR-N> --json mergedAt,createdAt --hostname github.je-labs.com
```

Cycle time = `mergedAt` − `createdAt` (issue). When issue number is unknown, fall back to PR `createdAt`.

**Loop count:** number of times a builder received reviewer feedback (F: signals) and pushed fixes before the PR was merged. Track manually per PR during the session.

**Trend signals:**

| Metric | Rising trend | What it signals | When to flag to PO |
|--------|-------------|-----------------|-------------------|
| Avg cycle time | Up | Tickets are growing in scope or complexity | Flag when avg exceeds 2× the previous session's average |
| Avg loop count | Up | Scope confusion, unclear acceptance criteria, or builder misreading specs | Flag when avg loops/PR exceeds 2 |

**Recording:** both metrics are recorded in `docs/sessions/YYYY-MM-DD[letter].json` at session end (see step 7b in SKILL-session-shutdown.md) and displayed in the session-end dashboard SESSION STATS block.

## See Also

> PR workflow conventions: see [jet-company-standards](https://github.je-labs.com/JustEatTakeaway/jet-company-standards)
