# Submodule Workflow (Track 3)

End-to-end workflow for building features in submodule repos (iOS, Android, consumer-web) without waiting for upstream human merge gates.

> Merge ownership rules: see [MERGE-OWNERSHIP.md](MERGE-OWNERSHIP.md)

## When to use this workflow

Use Track 3 when:
- Building a cross-platform feature that includes iOS, Android, or web changes
- The feature spans multiple milestone checkpoints and cannot wait for upstream human approval at each step
- Local integration testing in testharness requires submodule code to be on a feature branch

Do NOT use Track 3 for backend changes — backend code lives in `/backend/` as local testharness directories and uses Track 1 (harness PR) or Track 2 (production PR) depending on the change.

## Submodule paths

| Platform | Submodule path | Upstream repo |
|----------|---------------|---------------|
| iOS | `/Users/corey.latislaw/Documents/Code/Claude/testharness/ios` | `git@github.je-labs.com:iOS/JustEat.git` |
| Android | `/Users/corey.latislaw/Documents/Code/Claude/testharness/android` | `git@github.je-labs.com:Android/app-core.git` |
| Web | `/Users/corey.latislaw/Documents/Code/Claude/testharness/consumer-web` | `git@github.je-labs.com:Web/consumer-web.git` |

## Setup (Lead responsibility before builder spawn)

```bash
# Verify submodule is initialized and clean
git -C /Users/corey.latislaw/Documents/Code/Claude/testharness submodule status
```

Lead includes the submodule path and target branch name in the builder spawn prompt. Builder fetches and creates the branch as its first operation (see Step 1 below).

## Builder workflow

### Step 1: Fetch origin and create branch
```bash
git -C /Users/corey.latislaw/Documents/Code/Claude/testharness/[platform] fetch origin
git -C /Users/corey.latislaw/Documents/Code/Claude/testharness/[platform] checkout -b feature/[name] origin/main
git -C /Users/corey.latislaw/Documents/Code/Claude/testharness/[platform] branch --show-current
```
Fetch first — always. Never branch from a stale local ref. Verify branch shows `feature/[name]` before proceeding. If it does not: send B: to Lead immediately.

> **Why fetch-first?** Submodule checkouts in testharness often land in detached HEAD state (pointing at the SHA recorded in the testharness pointer, not at any branch). Branching from a detached HEAD silently imports any commits between that SHA and the current upstream main — commits that belong to other features. `git fetch origin` followed by `git checkout -b feature/[name] origin/main` ensures the new branch starts exactly at the current upstream main with no stale history attached. Never shortcut this to `git checkout -b feature/[name]` — the result will appear identical locally but the branch base will be wrong.

### Step 2: Build and commit in submodule
```bash
# All work happens in the submodule path
git -C /Users/corey.latislaw/Documents/Code/Claude/testharness/[platform] add [files]
# Write commit message to commit-msg.txt using Write tool
git -C /Users/corey.latislaw/Documents/Code/Claude/testharness/[platform] commit -F ./commit-msg.txt && rm -f ./commit-msg.txt
```

### Step 3: Update testharness pointer (per milestone — not per commit)
After reaching a milestone checkpoint:
```bash
# Stage the submodule pointer update
git -C /Users/corey.latislaw/Documents/Code/Claude/testharness add [platform]

# Get short SHA for commit message
SHA=$(git -C /Users/corey.latislaw/Documents/Code/Claude/testharness/[platform] rev-parse --short HEAD)

# Write commit message to commit-msg.txt using Write tool
# Content: chore(submodule): update [platform] to $SHA
git -C /Users/corey.latislaw/Documents/Code/Claude/testharness commit -F ./commit-msg.txt && rm -f ./commit-msg.txt
```

### Step 4: Open harness pointer PR and send V: to Lead
Push the pointer branch to testharness and open a harness PR:
```bash
git -C /Users/corey.latislaw/Documents/Code/Claude/testharness push origin harness/[feature-branch]
# Write pr-body.md using Write tool first
GH_HOST=github.je-labs.com gh pr create \
  --repo grocery-and-retail-growth/testharness \
  --base main \
  --head harness/[feature-branch] \
  --title "chore(submodule): update [platform] to [sha-short]" \
  --body-file ./pr-body.md && rm -f ./pr-body.md
```
Send V: to Lead with the PR number. Lead spawns a Reviewer same turn. Reviewer conducts adversarial review of the pointer and associated submodule code.

### Step 5: Reviewer feedback loop (harness pointer PR)
After Reviewer agent review completes:
1. Fix ALL Reviewer feedback (blocking and non-blocking)
2. Push fixes and send F: to Reviewer via SendMessage for re-verification
3. Only send D: to Lead when Reviewer sends "adversarial review complete"

### Step 6: D: and merge queue
After Reviewer all-clear, Lead queues the harness pointer PR via merge queue. Builder polls:
1. Poll every 10s: `gh pr view <PR-number> --hostname github.je-labs.com --json state,mergeStateStatus`
2. Max 2 minutes (12 polls)
3. On confirmed merge: send CONFIRMED-D: to Lead
4. If poll times out: send B: to Lead and stop — do not send CONFIRMED-D:
5. Lead sends CLOSE: — builder shuts down unless `👑` is pending

**Builder does NOT open an upstream PR.** Upstream PR promotion requires an explicit `👑` signal from Lead (see below).

### Upstream PR promotion

Lead sends `👑 [platform]` only after explicit PO milestone sign-off. Builder must NOT open an upstream PR on its own judgment.

On receiving `👑 [platform]` from Lead:
1. Push the feature branch to the upstream repo:
   ```bash
   git -C /Users/corey.latislaw/Documents/Code/Claude/testharness/[platform] push -u origin feature/[name]
   ```
2. Open PR against upstream main:
   ```bash
   # Write pr-body.md using Write tool first
   GH_HOST=github.je-labs.com gh pr create \
     --repo [upstream-org]/[upstream-repo] \
     --base main \
     --head feature/[name] \
     --title "feat(scope): description" \
     --body-file ./pr-body.md && rm -f ./pr-body.md
   ```
3. Send V: to Lead with upstream PR number. Track 2 rules apply from this point (adversarial review, human merge — no agent merge).

**`gh pr merge --auto` is NOT available on platform repos (iOS/JustEat, Android/app-core, Web/consumer-web).** After `👑`, Builder does not poll for merge. Instead, monitor PR state:
```bash
GH_HOST=github.je-labs.com gh pr view <PR-number> --json state
```
Poll every 10s, max 2 minutes (12 polls). If PR is not merged within 2 minutes: send B: to Lead and stop.

### Step 7: Freeze submodule pointer at upstream merge
After the upstream PR is merged to main, update the testharness submodule pointer one final time to track the upstream main SHA:
```bash
git -C /Users/corey.latislaw/Documents/Code/Claude/testharness/[platform] fetch origin main
git -C /Users/corey.latislaw/Documents/Code/Claude/testharness/[platform] checkout main
git -C /Users/corey.latislaw/Documents/Code/Claude/testharness/[platform] pull origin main
git -C /Users/corey.latislaw/Documents/Code/Claude/testharness add [platform]
# Commit: chore(submodule): freeze [platform] pointer at merged main
git -C /Users/corey.latislaw/Documents/Code/Claude/testharness commit -F ./commit-msg.txt && rm -f ./commit-msg.txt
```

## Builder spawn template (Track 3)

Include in every Track 3 builder spawn prompt:

```
Platform: [ios|android|web]
Submodule path: /Users/corey.latislaw/Documents/Code/Claude/testharness/[platform]
Feature branch: feature/[name]
Upstream repo: [upstream-repo-slug]

Track 3 rules:
- Work at the submodule path — NOT a /tmp worktree
- First operation: `git fetch origin && git checkout -b feature/[name] origin/main`
- Verify branch with `git -C [submodule-path] branch --show-current` before any work
- Update testharness pointer after each milestone checkpoint (not per commit)
- Pointer commit format: `chore(submodule): update [platform] to [sha-short]`
- Open harness pointer PR (Track 1); send V: to Lead for Reviewer
- Do NOT open upstream PR — wait for explicit `👑` signal from Lead
- Agents NEVER merge submodule branches — human gate at upstream PR
- gh pr merge --auto is NOT available on platform repos — poll gh pr view instead
```

## Push permissions

> **Confirmed 2026-03-25 (issue #540 for resolution options)**

The agent account (`corey-latislaw`) does **not** have the same push access to all platform repos:

| Platform | Upstream repo | Agent push access |
|----------|--------------|-------------------|
| iOS | `iOS/JustEat` | Yes — agent can push feature branches |
| Android | `Android/app-core` | **No — pull-only** |
| Web | `Web/consumer-web` | **No — pull-only** |

**Implication for `👑`:** When Lead sends `👑 android` or `👑 web`, the builder's `git push -u origin feature/[name]` step **will be rejected**. The push must be performed by the PO directly, or access must first be granted via `#540`. The builder should stop at Step 1 of the upstream PR promotion sequence, send `B: cannot push to [platform] — pull-only access; PO must push or grant access (#540)`, and wait.

iOS promotion proceeds normally — builder can push and open the upstream PR without PO intervention.

## NON-NEGOTIABLE

- Agents NEVER run `gh pr review --approve` or `gh pr merge` for upstream submodule PRs
- Submodule pointer in testharness MUST be committed per milestone — stale pointer causes integration failures
- Builder NEVER opens an upstream PR without receiving `👑` from Lead — Lead never sends `👑` without explicit PO instruction
- Backend changes (/backend/) are NEVER treated as submodule work — they are local code in testharness
