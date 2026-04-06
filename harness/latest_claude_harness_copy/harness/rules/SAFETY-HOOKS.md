# Safety Hooks

Documents the PreToolUse hook protection active in `~/.claude/settings.json`.
Audited 2026-03-24. Update this file whenever hooks change.

## Hook Registration

| Matcher | Hook Script | Purpose |
|---------|-------------|---------|
| `Bash` | `bash-pretooluse.sh` | Chains `block-dangerous.sh` then `rtk-rewrite.sh` |
| `Read` | `block-dangerous.sh` | Blocks sensitive file path access |
| `Edit` | `block-dangerous.sh` | Blocks sensitive file path access |
| `Write` | `block-dangerous.sh` | Blocks sensitive file path access |

Hooks run at the `PreToolUse` event — before the tool executes. They are NOT
bypassed by `bypassPermissions` mode. `disableBypassPermissionsMode: "disable"`
in `settings.json` also prevents agents from entering bypass mode.

## Bash Command Blocks (`block-dangerous.sh`)

The following patterns are checked against the full command string via `grep -qE`:

| Pattern | Blocks |
|---------|--------|
| `^rm(\s\|$)` | `rm` as first token — covers `rm -rf`, `rm -f`, etc. |
| `^sudo(\s\|$)` | All sudo invocations |
| `^su(\s\|$)` | User switching |
| `^dd(\s\|$)` | Disk write via dd |
| `^mkfs(\s\|$)` | Filesystem creation |
| `^shred(\s\|$)` | Secure file deletion |
| `^ssh(\s\|$)` | SSH connections |
| `git\s+clean(\s\|$)` | All `git clean` forms |
| `git\s+reset(\s\|$)` | All `git reset` forms including `--hard` |
| `git\s+push\s+.*--force($\|\s)` | Force push (special-cased: `--force-with-lease` is allowed) |
| `push\s+--force($\|\s)` | Force push alias match |
| `chmod\s+777` | World-writable permission grant |
| `chmod\s+-R` | Recursive chmod |
| `^mv\s+/($\|\s)` | Move root directory |
| `^mv\s+~/($\|\s)` | Move home directory |
| `\|\s*(bash\|sh)(\s\|$)` | Piped shell execution (e.g. `curl ... \| bash`) |
| `^pkill(\s\|$)` | Process kill by name |
| `^killall(\s\|$)` | Kill all matching processes |
| `kill\s+-9` | Force kill signal |
| `git\s+branch\s+(-D\|--delete)(\s\|$)` | Branch deletion |
| `xargs\s+rm(\s\|$)` | Piped rm via xargs (e.g. `find . \| xargs rm`) |

### Intentionally not blocked

| Command | Reason |
|---------|--------|
| `git checkout -- .` / `git restore .` | PO decision 2026-03-24: agents may need to discard working tree changes; left unblocked by design |

### Known limitation

The `^rm(\s|$)` anchor only catches `rm` as the **first token**. Commands like
`find . -exec rm {} \;` are not blocked. This is a documented accepted gap —
the `xargs rm` pattern covers the most common piped form.

## File Path Blocks (`block-dangerous.sh`)

Applied to `Read`, `Edit`, and `Write` tool calls. Checks `file_path` against:

| Pattern | Blocks |
|---------|--------|
| `\.env$` | `.env` files |
| `\.env\.` | `.env.production`, `.env.local`, etc. |
| `/secrets/` | Any path containing a `/secrets/` directory |

### Known gaps (accepted)

Credential files outside these patterns (e.g. `~/.ssh/id_rsa`, `~/.aws/credentials`,
`/etc/passwd`) are not blocked at the hook level. These are protected by file system
permissions. If agents routinely need access to credential paths, add patterns here.

## Known behaviour: Edit/Read/Write permission prompts in agent worktrees

**Symptom:** Agents in worktrees under `/private/tmp/` receive "Do you want to make
this edit?" prompts even though `Edit(**)` and `Edit(/private/tmp/**)` are in the
global allow list.

**Root cause investigated 2026-03-24:** The hook itself (`block-dangerous.sh`) is NOT
the cause. Manual testing confirms it exits 0 with no stdout/stderr for all ordinary
Edit calls to `/private/tmp/` paths. The prompt is surfaced by Claude Code's permission
UI, not by the hook.

**Suspected cause:** Claude Code may surface an approve/deny prompt whenever any
PreToolUse hook is registered for a matcher — regardless of hook exit code — as a
safety UX layer. This is a platform behaviour, not a misconfiguration.

**Workaround:** The PO approves these prompts as they appear. If this becomes high
friction, the mitigation is to remove the `Edit`/`Read`/`Write` matchers from the
hook registration in `settings.json` (losing file-path blocking for those tools),
or to scope the hook to only fire on dangerous patterns rather than all calls.

## Auditing

To verify coverage is still intact:

```bash
cat ~/.claude/hooks/block-dangerous.sh
cat ~/.claude/hooks/bash-pretooluse.sh
cat ~/.claude/settings.json | jq '.hooks'
```

After any change to these files, update this document and append an entry to
`harness/lessons.md`.
