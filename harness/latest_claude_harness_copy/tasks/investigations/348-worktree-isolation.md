# Investigation: Native `isolation: "worktree"` Flag — Issue #348

**Date:** 2026-03-23
**Claude Code Version Tested:** 2.1.81
**Status:** FINDING — flag exists but behavior differs from what issue expected

---

## Summary

The `isolation: "worktree"` parameter referenced in the issue title does **not** exist as an Agent spawn parameter in Claude Code v2.1.81. What does exist is a CLI flag `--worktree` / `-w` for interactive sessions. The harness manual worktree pattern remains the correct approach for parallel builder isolation.

---

## Findings

### 1. Claude Code Version

Current version: **2.1.81** (issue referenced v2.1.49+, so we are well past the claimed fix version).

### 2. `isolation: "worktree"` as Agent Spawn Parameter

Does **not** exist in v2.1.81. The Agent tool does not accept an `isolation` property. The claim in the issue that "the worktree isolation bug is fixed in v2.1.49/2.1.50" cannot be verified via Agent spawn — no such parameter is exposed.

### 3. `--worktree` CLI Flag

Claude Code v2.1.81 does expose a `--worktree` / `-w` flag for interactive CLI sessions:

```
-w, --worktree [name]    Create a new git worktree for this session (optionally specify a name)
--tmux                   Create a tmux session for the worktree (requires --worktree)
```

This flag is for **interactive `claude` sessions started from the CLI** — not for Agent tool spawns inside an existing Claude Code session. It is unrelated to the parallel builder isolation problem the harness solves.

### 4. Current Harness Behavior (Confirmed Correct)

The harness already documents the correct approach in three places:

- `harness/roles/ROLE-LEAD.md` §Builder Worktree Protocol (lines 118–134)
- `harness/AGENT-COMMUNICATION-PROTOCOL.md` §Builder Worktree Isolation (lines 78–99)
- `harness/skills/SKILL-worktree-isolation.md` (full skill)

All three explicitly state that `isolation: "worktree"` does NOT provide filesystem isolation for in-process agents, and mandate manual `git worktree add /tmp/[name]` outside the repo tree.

---

## Conclusion

**No changes required to CLAUDE.md or any harness file.**

The harness protocol is correct and up to date. The `--worktree` CLI flag in v2.1.81 does not address the Agent-spawn isolation problem. The manual worktree pattern remains necessary for parallel builder isolation.

### What would change if native isolation were confirmed working

If a future Claude Code version added a true `isolation: "worktree"` parameter to the Agent tool that created an out-of-tree worktree automatically, the following files would need updating:

1. `harness/roles/ROLE-LEAD.md` — remove manual `git worktree add` pre-spawn step; replace with `isolation: "worktree"` in Agent call
2. `harness/AGENT-COMMUNICATION-PROTOCOL.md` §Builder Worktree Isolation — update protocol
3. `harness/skills/SKILL-worktree-isolation.md` — update "The Problem" section and agent spawn sequence
4. `CLAUDE.md` §DISPATCH — update Spawn Sequence to reflect native flag

Until such a parameter is confirmed, these files remain unchanged.

---

## References

- Issue: #348
- Harness skill: `harness/skills/SKILL-worktree-isolation.md`
- ROLE-LEAD.md: `harness/roles/ROLE-LEAD.md` lines 118–134
- AGENT-COMMUNICATION-PROTOCOL.md: lines 78–99
