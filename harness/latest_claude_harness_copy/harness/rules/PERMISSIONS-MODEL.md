# Permissions Mental Model

> Canonical reference. Read this before spawning any builder or auditor.

## The Mental Model in One Sentence

The **allow list in `~/.claude/settings.json`** is the only gate — every tool call an agent makes must be explicitly listed there, and nothing else provides access.

---

## What `bypassPermissions` Actually Does

```json
"disableBypassPermissionsMode": "disable"
```

This setting is permanently active in `~/.claude/settings.json`. It means:

- `mode: "bypassPermissions"` in Agent spawn calls is a **no-op**
- Spawning with `mode: "bypassPermissions"` does NOT grant elevated access
- The allow list governs every tool call — always, for every agent

**Practical consequence:** including `mode: "bypassPermissions"` in spawn prompts is harmless but misleading. The allow list is doing all the work.

---

## Allow List Is Additive Per Tool, Not Per Agent

The allow list applies globally across all agents in the session. There is no per-agent permission scoping. If a tool is listed, any agent can use it. If it is not listed, every agent sees a permission prompt.

**When you hit a prompt mid-session**, the cause is almost always one of:
1. A tool not listed in the allow list at all
2. A path pattern that does not match the actual filesystem path (see macOS symlink issue below)
3. A Category B security check (see below) — these cannot be suppressed by the allow list

---

## macOS `/tmp` Symlink Gap

macOS symlinks `/tmp` → `/private/tmp`. **Path pattern matching is not symlink-aware.**

| Pattern in allow list | Matches `/tmp/foo`? | Matches `/private/tmp/foo`? |
|---|---|---|
| `Read(/tmp/**)` | Yes (before symlink resolution) | **No** |
| `Read(/private/tmp/**)` | No | Yes |

This affects: `Read`, `Write`, `Edit`, `Glob`, `Grep`.

**Rule:** any allow list update for `/tmp/**` must also add the `/private/tmp/**` variant.

The canonical entries (already in `~/.claude/settings.json`) are:
```
Read(/tmp/**)           Read(/private/tmp/**)
Write(/tmp/**)          Write(/private/tmp/**)
Edit(/tmp/**)           Edit(/private/tmp/**)
Glob(/tmp/**)           Glob(/private/tmp/**)
Grep(/tmp/**)           Grep(/private/tmp/**)
```

---

## Absolute Paths in Worktrees

Builders run in worktrees under `/private/tmp/wt-[name]/`. File tool patterns like `Read(**)` are anchored to the project root (`/Users/.../testharness`), not the worktree.

**A builder using a relative path like `harness/file.md` will hit a prompt**, because the tool resolves it against the wrong root.

**Rule:** every file operation in a builder prompt must use an absolute path:
```
# Wrong — triggers prompt
Read(harness/rules/PERMISSIONS-MODEL.md)

# Correct
Read(/private/tmp/wt-builder-name/harness/rules/PERMISSIONS-MODEL.md)
```

**Enforcement:** Lead spawn prompts must include:
```
All file reads/writes MUST use absolute paths under /private/tmp/wt-[name]/.
```

---

## Category B Security Prompts

Some prompts fire regardless of the allow list. They are triggered by shell patterns that look like credential exfiltration or command injection:

| Pattern | Trigger | Example |
|---|---|---|
| Heredoc in commit | `git commit -m "$(cat <<'EOF'...)"` | Always prompts |
| Command substitution | `git commit -m "$(cat file)"` | Always prompts |
| `printf` to create file | `printf '...' > file` | Always prompts |

These are **Category B (security-check) prompts** — the allow list cannot suppress them.

**How to avoid:**
1. Use the **Write tool** to write the commit message to `./commit-msg.txt`
2. Commit with `git commit -F ./commit-msg.txt`
3. Clean up: `rm -f ./commit-msg.txt`

Same pattern for PR bodies: write to `./pr-body.md`, use `--body-file ./pr-body.md`, then delete.

**Temp files must use `./` relative paths** (relative to the worktree), never `/tmp/` or `/private/tmp/` absolute paths — those require extra allow list entries and introduce macOS symlink risk.

---

## Project-Level `settings.json` Shadowing

`~/.claude/settings.json` allow list is the global source of truth. Adding a `permissions.allow` block to the **project-level** `.claude/settings.json` **replaces** (does not merge with) the global allow list.

A narrow project-level allowlist shadows `Bash(*)` and every other global entry, causing permission prompts for all commands in agent worktrees.

**Rule:** project-level `.claude/settings.json` must contain env vars only — never a permissions block.

---

## Canonical Allow List

The current `~/.claude/settings.json` allow list (as of 2026-03-24):

```json
"allow": [
  "Bash(*)",
  "Read(**)",       "Read(/tmp/**)",       "Read(/private/tmp/**)",
  "Write(**)",      "Write(/tmp/**)",      "Write(/private/tmp/**)",
  "Edit(**)",       "Edit(/tmp/**)",       "Edit(/private/tmp/**)",
  "Glob(**)",       "Glob(/tmp/**)",       "Glob(/private/tmp/**)",
  "Grep(**)",       "Grep(/tmp/**)",       "Grep(/private/tmp/**)",
  "Agent",
  "TeamCreate",
  "SendMessage",
  "TaskCreate", "TaskGet", "TaskList", "TaskUpdate", "TaskOutput", "TaskStop",
  "WebFetch", "WebSearch",
  "Skill",
  "AskUserQuestion",
  "TeamDelete",
  "EnterPlanMode", "ExitPlanMode",
  "EnterWorktree", "ExitWorktree",
  "CronCreate", "CronDelete", "CronList",
  "NotebookEdit",
  "ToolSearch",
  "ListMcpResourcesTool", "ReadMcpResourceTool",
  "mcp__claude_ai_Atlassian__*",
  "mcp__claude_ai_Figma__*"
]
```

If you add a new tool or MCP server to any agent workflow, add it here first.

---

## Pre-Spawn Checklist

Before spawning any builder or auditor, verify:

- [ ] Worktree created at `/private/tmp/wt-[name]` (not inside the repo tree)
- [ ] All tools the agent will use are in the allow list
- [ ] Spawn prompt instructs agent to use absolute paths under `/private/tmp/wt-[name]/`
- [ ] Spawn prompt uses Write tool + `git commit -F` pattern for commits (no heredoc)
- [ ] Spawn prompt uses `./pr-body.md` + `--body-file` pattern for PRs (no heredoc)
- [ ] Project `.claude/settings.json` has no `permissions` block
- [ ] If adding a new `/tmp/**` entry, the `/private/tmp/**` variant is also added

---

## Summary Table

| Misconception | Reality |
|---|---|
| `mode: "bypassPermissions"` grants elevated access | No-op — `disableBypassPermissionsMode: "disable"` is set |
| `/tmp/**` in allow list covers macOS worktrees | No — macOS resolves `/tmp` → `/private/tmp`; add both |
| Relative paths work in worktree builders | No — file tools anchor to project root; use absolute paths |
| Category B prompts can be suppressed | No — use Write tool + `-F` pattern instead |
| Project `settings.json` can add permissions | No — it replaces the global list entirely |
