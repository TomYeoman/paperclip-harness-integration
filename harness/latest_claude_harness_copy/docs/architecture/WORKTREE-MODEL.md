> **HUMAN REFERENCE ONLY** — This document is not loaded into agent contexts and is not authoritative for agent behavior. CLAUDE.md and role files (harness/roles/) are the canonical sources. This file exists for human onboarding and reference.

---

# Worktree Model

Each Builder agent works in its own git worktree — a separate checkout of the repository on a separate branch, in a separate directory. This isolation lets multiple agents work on different features simultaneously without stepping on each other.

## Why Worktrees Exist

Without isolation:
- Two agents modifying the same files overwrite each other's changes
- A `git checkout` by one agent switches the branch for everyone
- `git status` in the main repo shows every agent's uncommitted work as noise
- `git clean` in the main repo deletes another agent's uncommitted work

With worktrees:
- Each agent has its own working directory, its own branch, its own index
- Lead's main checkout stays clean
- Agents can run in parallel without coordination at the git level

## Critical Rule: Worktrees OUTSIDE the Repo Tree

Claude Code's built-in `isolation: "worktree"` places worktrees **inside** the repo (e.g., `testharness/.worktrees/b-feature`). This causes all the contamination problems above.

The harness creates worktrees **manually, in sibling directories**:

```
~/Documents/Code/Claude/
├── testharness/              <- main repo (Lead's context, main branch)
├── b-feature-auth/           <- Builder worktree (feature/auth branch)
├── b-feature-cart/           <- Builder worktree (feature/cart branch)
├── a-milestone-2-design/     <- Architect worktree (design/milestone-2 branch)
├── r-auth-review/            <- Reviewer worktree (reads PR, no branch needed)
├── t-acceptance/             <- Tester worktree (test/acceptance branch)
├── pm-discovery/             <- PM worktree (docs/discovery branch)
└── au-security-audit/        <- Auditor worktree (harness/security-audit branch)
```

Note the naming convention: prefix matches the agent role prefix (`b-`, `a-`, `r-`, `t-`, `pm-`, `au-`).

## Creating a Worktree

Lead runs this from the main repo before spawning an agent:

```bash
# From: /Users/corey.latislaw/Documents/Code/Claude/testharness
git worktree add ../b-feature-auth -b feature/auth main
# Creates:  /Users/corey.latislaw/Documents/Code/Claude/b-feature-auth
# Branch:   feature/auth (branched from main)
```

The agent spawn prompt then specifies the absolute path:
```
Working directory: /Users/corey.latislaw/Documents/Code/Claude/b-feature-auth
Branch: feature/auth
```

## Agent Safety Verification

The first thing every agent does before any git operation is verify it is in the right place. These run as **separate Bash calls** — not chained with `&&`:

```bash
pwd
# Expected: /Users/corey.latislaw/Documents/Code/Claude/b-feature-auth

git rev-parse --show-toplevel
# Expected: /Users/corey.latislaw/Documents/Code/Claude/b-feature-auth
```

If either output is wrong — especially if it shows the main repo path — the agent stops and notifies Lead immediately.

## Branch Naming

| Branch type | Pattern | Example |
|-------------|---------|---------|
| Feature | `feature/[name]` | `feature/jwt-validation` |
| Bug fix | `fix/[desc]` | `fix/cart-total-rounding` |
| Architecture | `design/[name]` | `design/checkout-interfaces` |
| Harness update | `harness/[desc]` | `harness/add-builder-rules` |

Never commit directly to `main`.

## Worktree vs Submodule Repos

For multi-repo work (e.g., a Builder working on the iOS/JustEat submodule):

```bash
# Clone the target repo once (outside harness tree)
git clone git@github.je-labs.com:iOS/JustEat.git /Users/corey.latislaw/Documents/Code/iOS-JustEat

# Create a worktree in the target repo
git -C /Users/corey.latislaw/Documents/Code/iOS-JustEat worktree add \
    /Users/corey.latislaw/Documents/Code/b-ios-ctlg-385 \
    -b feature/ctlg-385 main
```

The agent works in `/Users/corey.latislaw/Documents/Code/b-ios-ctlg-385` and opens a PR against the iOS/JustEat repo.

## Banned Git Commands in Worktrees

Agents must never run these — they can destroy another agent's work:

| Command | Why it's banned |
|---------|----------------|
| `git clean` | Deletes untracked files — could be another agent's work |
| `git reset --hard` | Destroys uncommitted changes |
| `git checkout -- .` | Overwrites working tree |
| `git restore .` | Overwrites working tree |
| `cd /path && git command` | Compound commands trigger security prompts — use `git -C /path command` instead |

## Push Before D:

Every agent pushes its branch before sending the D: completion message. Unpushed commits are lost if the agent crashes or its context compacts.

```bash
git push -u origin feature/auth
```

## Session-End Cleanup

```bash
git worktree list          # See all active worktrees
git worktree prune         # Remove stale refs for deleted directories

# Remove a completed worktree (clean or dirty — work is on the pushed branch)
git worktree remove ../b-feature-auth         # if working tree is clean
git worktree remove --force ../b-feature-auth # if dirty (commits are on pushed branch, safe)
```

## Contamination Symptoms

If worktree isolation has failed, you'll see:
- `git status` in main repo shows unexpected modified/untracked files
- Unexpected branch switches in main checkout
- Files disappear from an agent's worktree
- An agent reports it's on the wrong branch
- Two agents both modified the same file

Recovery: `git status` and `git diff` to assess, then `git checkout -- [specific-file]` (never `git restore .`).
