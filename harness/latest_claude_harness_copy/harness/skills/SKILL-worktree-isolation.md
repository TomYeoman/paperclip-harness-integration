# Skill: Worktree Isolation

Load this skill when: about to create a worktree for an agent, or debugging contamination issues.

## The Problem
Claude Code's built-in `isolation: "worktree"` creates worktrees INSIDE the repo tree (e.g., `/c/testharness/.worktrees/b-feature`). This causes:
- `git status` in main repo shows agent files as untracked/modified
- `git clean` in main repo deletes agent's uncommitted work
- Multiple agents stepping on each other's git index
- Branch switches in main checkout affect all "isolated" worktrees

## The Solution
Manual worktrees OUTSIDE repo tree + teammates (TeamCreate/SendMessage) for visibility.

## Agent Spawn Sequence

**Step 1: Create worktree outside repo**
```bash
# From repo root (e.g., /c/testharness)
git worktree add ../b-[feature] -b feature/[feature] main
# Result: /c/b-[feature] — completely separate from /c/testharness
```

**For parallel builders — pre-create ALL worktrees before spawning any:**
```bash
git worktree add /private/tmp/wt-[slug-a] -b [branch-a] origin/main
git worktree add /private/tmp/wt-[slug-b] -b [branch-b] origin/main
git worktree add /private/tmp/wt-[slug-c] -b [branch-c] origin/main
```

`isolation: "worktree"` alone is insufficient for parallel builders. Lead must pre-create and hardcode absolute paths before spawning. **Reason:** The Bash tool CWD does NOT persist between calls inside a builder session. Plain `git` without `-C /path` operates on the shell's reset CWD — often the main repo — contaminating it and other builders' worktrees.

**Rule: Every git command in a spawn prompt must use `git -C /private/tmp/wt-[slug]` — never plain `git`.**

**Required warning in every parallel builder spawn prompt:**
> ⚠️ CRITICAL: The Bash tool CWD does NOT persist between calls. NEVER run plain `git` — always use `git -C /private/tmp/wt-[slug]` for every single git command.

**Step 2: TeamCreate (once per session)**
```
TeamCreate: { name: "session-YYYY-MM-DD" }
```

**Step 3: Spawn agent with absolute worktree path**
```
Agent {
  name: "b-[feature]",
  team_name: "session-YYYY-MM-DD",
  mode: "bypassPermissions",
  prompt: "Working directory: /c/b-[feature]\n..."
}
```

> **Note:** `mode: "bypassPermissions"` is permanently disabled (`disableBypassPermissionsMode: "disable"` in `~/.claude/settings.json`) — it is a no-op and does NOT skip permission checks. The global allow list in `~/.claude/settings.json` is the only security model. Ensure all tools the agent uses are in the allow list, including `Glob(/private/tmp/**)` and `Grep(/private/tmp/**)` for macOS worktrees.

## Agent Safety Rules
Before ANY git operation, agent must run:
```bash
pwd
git rev-parse --show-toplevel
```
Run as separate Bash calls. Both outputs must match the expected worktree path. If they don't, STOP and notify Lead.

## Banned Commands (agents must never run these)
- `git clean` — deletes untracked files (potentially another agent's work)
- `git reset --hard` — destroys uncommitted changes
- `git checkout -- .` — overwrites working tree
- `git restore .` — overwrites working tree
- `cd /path && git command` — compound cd+git triggers permission prompts; use `git -C /path command` instead

## Push Before DONE
Agents must push their branch before sending D: message:
```bash
git push -u origin feature/[feature]
```
Unpushed commits are lost if agent crashes or context compacts.

## Contamination Symptoms
Signs that worktree isolation has failed:
- `git status` in main repo shows unexpected modified/untracked files
- Unexpected branch switches in main checkout
- Files disappear from agent worktree
- Agent reports working on wrong branch
- Two agents both modified the same file

## Gotchas

| # | Trap | What breaks | Fix |
|---|------|------------|-----|
| 1 | Worktree inside repo tree | `git status` shows agent files; `git clean` deletes them | Always `git worktree add ../[name]` — parent dir, never subdir |
| 2 | Skipping `pwd` + `git rev-parse --show-toplevel` check | Agent commits to wrong repo/branch | Run both as separate Bash calls before any git op; stop if mismatch |
| 3 | `cd /path && git command` | Permission prompt on every command | Use `git -C /path command` instead |
| 4 | `git clean` or `git reset --hard` | Destroys another agent's uncommitted work | These commands are banned for agents — file-by-file only |
| 5 | Forgetting `git worktree prune` at session end | Stale refs accumulate; future worktrees can collide on path | Always run `git worktree prune` during session shutdown |
| 6 | Using `isolation: "worktree"` for parallel builders without pre-creating worktrees | Bash CWD resets between calls; plain `git` runs in main repo; branch contamination | Lead pre-creates all worktrees with `git worktree add /private/tmp/wt-[slug] -b [branch] origin/main` before spawning; every git command in spawn prompt must use `git -C /private/tmp/wt-[slug]` |
| 7 | Plain `git` in spawn prompt (no `-C /path`) | CWD not preserved between Bash calls; git operates on main repo | All git commands must be `git -C /private/tmp/wt-[slug] <subcommand>` — no exceptions |

## Recovery Procedures

**Dirty PO checkout (agent contaminated main repo):**
```bash
# See what's dirty
git status
git diff

# If changes are agent work you want to keep — stash them
git stash push -m "rescued from contamination"

# If changes are garbage — careful reset
git checkout -- [specific-file]  # file by file, never git restore .
```

**Session-end cleanup:**
```bash
# List all worktrees
git worktree list

# Remove merged/dead worktrees
git worktree remove ../b-[feature]  # if clean
git worktree remove --force ../b-[feature]  # if dirty (work is on branch)

# Prune stale worktree refs
git worktree prune
```

**Agent in wrong directory:**
1. Stop agent immediately
2. Check where it actually is: agent runs `pwd`
3. Respawn with corrected absolute path in prompt
4. Check for any commits made in wrong location: `git log --all --oneline -10`
