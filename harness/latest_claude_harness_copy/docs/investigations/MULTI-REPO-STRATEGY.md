# Multi-Repo Strategy for Claude Code Agent Teams

**Date:** 2026-03-16
**Issue:** #14
**Status:** Complete — recommendation: worktree-per-repo

---

## Context

Large enterprise projects span multiple repos (microservices, shared libraries, platform layers). This harness currently integrates with a consumer-web repo via git submodule (`consumer-web/` at the repo root). The question: does this scale, and what is the right pattern for agent teams working across repos?

---

## Approaches Evaluated

### 1. Git Submodules

**How it works:** The harness repo declares other repos as submodules. Each submodule is checked out at a pinned commit inside the harness tree (e.g., `consumer-web/`).

| Dimension | Assessment |
|-----------|------------|
| Agent navigation ease | Poor. Submodule paths are inside the harness tree. Agents must know they are in a submodule context to avoid accidental commits to the wrong repo. `git rev-parse --show-toplevel` returns the submodule root, not harness root — creating confusion for path checks. |
| Context window cost | Low for reading (agents read files via absolute path). High for git state — agents must track two separate git histories, HEAD pointers, and remotes. |
| CI/CD impact | High friction. CI must pin submodule refs, update them in lockstep, and run separate pipelines. Submodule updates require a commit in the outer repo — a toil-heavy ceremony. |
| Scalability | Poor. Submodule management becomes O(N) overhead as services grow. `git submodule update --init --recursive` is slow and fragile on large sets. |

**Current state:** This harness uses submodules for `consumer-web`. This works for one repo with occasional reads. It does not scale to active multi-repo development by agents.

**When appropriate:** Read-only reference to a pinned external dependency that rarely changes. Not appropriate for active agent work spanning multiple repos.

---

### 2. Worktree-per-Repo

**How it works:** Each agent that needs to work in repo X gets a git worktree from X, placed outside the harness tree (sibling directory). The agent's working directory is the worktree root. No submodules needed.

```
/c/
  testharness/          # harness repo (main checkout)
  b-consumer-auth/      # agent worktree from consumer-web repo
  b-api-gateway/        # agent worktree from api-gateway repo
```

| Dimension | Assessment |
|-----------|------------|
| Agent navigation ease | Excellent. Agent's `pwd` and `git rev-parse --show-toplevel` match. No submodule ambiguity. Path safety checks from SKILL-worktree-isolation.md work unchanged. |
| Context window cost | Low. Agent reads only the files it needs in its own worktree. No cross-repo git state needed in context. |
| CI/CD impact | None. Each repo's CI runs independently. The harness does not modify CI pipelines in other repos. |
| Scalability | Excellent. Adding a new service repo requires one `git clone` and one `git worktree add`. Linear overhead, no cascading updates. |

**Setup pattern:**
```bash
# Clone target repo (once per machine, outside harness tree)
git clone git@github.je-labs.com:Web/consumer-web.git /c/consumer-web

# Create worktree for agent task
git -C /c/consumer-web worktree add /c/b-consumer-auth -b feature/auth main

# Spawn agent with /c/b-consumer-auth as working directory
```

**Cross-repo reads:** If an agent needs to read a file in repo B while working in repo A, it uses absolute paths. No checkout required for reads.

---

### 3. MCP Filesystem Access

**How it works:** A filesystem MCP server exposes read/write access to arbitrary paths. Agents access other repos by calling MCP tools rather than native file reads.

| Dimension | Assessment |
|-----------|------------|
| Agent navigation ease | Poor. MCP tools add indirection. Agent cannot use `grep`, `glob`, or `git` natively — must translate all operations to MCP calls. Debugging is harder. |
| Context window cost | High. MCP calls return data as structured output that must be parsed. Each file read is a round-trip tool call. Batch reads are expensive. |
| CI/CD impact | None directly, but MCP server must be running and available — adds infrastructure dependency. |
| Scalability | Moderate. MCP server scales horizontally but introduces a single point of failure and latency. |

**When appropriate:** Read-only access to repos that cannot be cloned (e.g., air-gapped, restricted access). Not appropriate for active development work where git operations are needed.

---

### 4. Mono-Repo Migration

**How it works:** All service repos merged into one repo. All agents work in one repo using the existing worktree isolation pattern.

| Dimension | Assessment |
|-----------|------------|
| Agent navigation ease | Excellent. Single `git rev-parse --show-toplevel`. All skills work unchanged. |
| Context window cost | Low per agent (still works in a scoped worktree). Higher for repo-wide reads (larger tree to search). |
| CI/CD impact | Major. Requires restructuring all CI pipelines, ownership rules, deploy triggers. Large one-time migration cost. |
| Scalability | Excellent once done. Google/Meta mono-repo patterns are proven at scale. |

**When appropriate:** Greenfield projects or teams with significant investment in tooling and DevX. Not feasible as a near-term option for existing enterprise multi-repo setups.

---

## Recommendation: Worktree-per-Repo

**Worktree-per-repo is the recommended pattern** for active multi-repo agent development.

**Rationale:**

1. **Safety:** The worktree path-check pattern (`pwd && git rev-parse --show-toplevel`) works identically. Agents cannot accidentally commit to the wrong repo.

2. **Context efficiency:** Each agent operates in a scoped worktree. No cross-repo git state pollutes the context window.

3. **Zero CI impact:** Other repos' CI pipelines are untouched. The harness orchestrates without coupling to downstream build systems.

4. **Linearly scalable:** Adding a new service is `git clone` + `git worktree add`. No cascading manifest updates.

5. **Compatible with existing skills:** SKILL-worktree-isolation.md and SKILL-agent-spawn.md apply without modification. The Lead simply clones each target repo once, then creates worktrees as needed.

**Submodules remain acceptable** for pinned read-only references (e.g., a shared proto schema repo that agents read but never commit to). They are not appropriate for active development.

---

## Setting Up Worktree-per-Repo

### One-Time Setup (per machine)

```bash
# Clone each service repo outside harness tree
git clone git@github.je-labs.com:Org/service-a.git /c/service-a
git clone git@github.je-labs.com:Org/service-b.git /c/service-b
```

### Per-Agent Setup (per task)

```bash
# Create agent worktree from the target repo
git -C /c/service-a worktree add /c/b-[agent-name] -b feature/[branch] main

# Spawn agent pointing at the worktree
Agent {
  name: "b-[agent-name]",
  prompt: "Working directory: /c/b-[agent-name]\n..."
}
```

### Keeping Repos in Sync

```bash
# Sync all cloned repos before a session
for repo in /c/service-a /c/service-b; do
  git -C $repo fetch origin && git -C $repo pull origin main
done
```

### Session Cleanup

```bash
# Remove merged worktrees
git -C /c/service-a worktree remove /c/b-[agent-name]
git -C /c/service-a worktree prune
```

---

## Submodule Guidance (if retained)

If submodules are retained for read-only reference repos:

- **Never commit to a submodule from inside a harness agent.** Agents working in the harness must treat submodule paths as read-only.
- **Pin submodule refs explicitly.** Avoid `branch = main` in `.gitmodules` — it creates invisible drift.
- **Update submodule refs intentionally** via a dedicated harness commit: `git submodule update --remote consumer-web && git add consumer-web && git commit -m "chore(submodule): update consumer-web to HEAD"`.
- **Do not create agent worktrees inside a submodule.** Use the worktree-per-repo pattern for any active development in a submodule target.
