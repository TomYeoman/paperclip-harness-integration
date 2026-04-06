# Secrets Injection Pattern

> Last updated: 2026-03-24 by a-secrets (issue #388)

## Summary

Secrets are injected via the `env:` block in `~/.claude/settings.json` (the **global** user settings file, never the project settings file). All agents automatically inherit this environment from the parent session — no extra configuration needed per agent.

---

## Recommended Pattern: `~/.claude/settings.json` env block

This environment already uses the `env:` block for `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` and similar vars. The same mechanism works for API keys and other secrets.

**File:** `~/.claude/settings.json` (on the developer's machine — never committed)

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1",
    "MY_API_KEY": "sk-...",
    "ANOTHER_SECRET": "..."
  }
}
```

All agent teammates inherit this env automatically via the parent session process.

### How to add a new secret

1. Open `~/.claude/settings.json` on your local machine.
2. Add the key/value to the `"env"` block.
3. Restart the Claude Code session (env is read at startup).
4. Done — all agents in the session will have access via `process.env.MY_API_KEY` or `Environment.GetEnvironmentVariable("MY_API_KEY")`.

---

## If 1Password CLI (`op`) is available

`op` was not found in this environment, but if installed it can wrap session launches:

```bash
op run --env-file=.env.tpl -- claude
```

Where `.env.tpl` resolves secret references at runtime. This is the preferred approach for team-shared secrets. See [1Password CLI docs](https://developer.1password.com/docs/cli/secrets-automation/) for setup.

---

## Fallback: `.env` file outside the repo

If neither approach above is available, place a `.env` file **outside the repository tree** and source it before launching:

```bash
set -a && source ~/secrets/project.env && set +a
claude
```

Never place `.env` inside the repo directory, even if `.gitignore` lists it — gitignore is not a security boundary.

---

## What is forbidden

| Forbidden | Reason |
|-----------|--------|
| Secrets in `.claude/settings.json` **inside the repo** | That file is committed; any env var there is in git history |
| Secrets in `CLAUDE.md` or any harness file | These are committed files — visible to anyone with repo access |
| Hardcoded API keys in builder prompts | Prompts may be logged or stored in session history |
| Secrets in `harness/` docs | Same as CLAUDE.md — committed and visible |
| `.env` file inside the repo tree | Even if gitignored, it can be accidentally committed or leaked via `git stash` |

**The only safe locations:** `~/.claude/settings.json` (user-level, never committed), a secrets manager, or a `.env` file outside the repo tree.

---

## How agents receive secrets

Agents spawned via Agent Teams run in the same process as the Lead session. They inherit the full environment of the parent process, which includes everything set in `~/.claude/settings.json` `env:` block. No additional injection step is needed.

Worktree builders also inherit this environment — the worktree is a filesystem isolation, not a process isolation.

---

## Pre-commit guard

`block-dangerous.sh` (`~/.claude/hooks/block-dangerous.sh`) currently blocks writes to `.env` files and `/secrets/` paths. The following patterns should also be added to catch inline secret assignments being written to tracked files:

```bash
# Add to the FILE_PATTERNS array in block-dangerous.sh:
"API_KEY\s*="
"SECRET\s*="
"TOKEN\s*="
"PASSWORD\s*="
"PRIVATE_KEY\s*="
```

These catch cases where a builder writes something like `API_KEY=sk-abc123` directly into a source file or CLAUDE.md.

> Note: These patterns apply to the content being written (Edit/Write tool), not just filenames. If block-dangerous.sh only checks file paths, consider adding a content-scan pass for the patterns above when the destination file is a tracked repo path.

---

## Related

- `~/.claude/settings.json` — global env injection (never commit)
- `harness/setup/GITHUB-ENTERPRISE-SETUP.md` — gh CLI token setup
- `~/.claude/hooks/block-dangerous.sh` — file write protection
