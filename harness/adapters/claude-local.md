# claude_local Adapter Overlay

Claude Code CLI adapter for Paperclip.

## Auth Prerequisites

| Auth Method | Required | Notes |
|-------------|----------|-------|
| `ANTHROPIC_API_KEY` env var | Recommended | API key authentication |
| Claude Code subscription | Fallback | Uses logged-in Claude Code session |

If neither is available, the adapter logs a warning and attempts to use the default session.

## CWD / Instructions-Path Expectations

### Working Directory

- Set via `adapterConfig.cwd` on the agent
- Must be an absolute path
- Must be readable/writable by the server process
- Default in harness scripts: `/workspace`

### Instructions Path

- Set via `instructionsFilePath` / `instructions-path`
- Must be an absolute path
- Point to the role entry file (e.g., `/workspace/harness/runtime-instructions/builder/AGENTS.md`)
- Claude Code loads this as the dense runtime contract

### Skills Discovery

Claude Code discovers skills via `--add-dir <tmpdir>` flag at execution time. The adapter creates a temp directory with symlinks to Paperclip skills and passes it at runtime. No skills are written to the agent's actual `cwd`.

## Model Config Policy

| Config Field | Value |
|--------------|-------|
| `model` | Optional; defaults to user's Claude Code default |
| Suggested models | `claude-sonnet-4-20250514`, `claude-opus-4-20250514` |

Model selection is per-invocation, not enforced by the harness. The adapter passes model hints through CLI arguments.

## Common Failure Modes

### 1. `ANTHROPIC_API_KEY` not set and no subscription

**Symptom:** Adapter logs warning, falls back to default session which may not exist.

**Fix:**
```sh
export ANTHROPIC_API_KEY=sk-ant-...
```
Or ensure Claude Code is logged in via `claude login`.

### 2. Working directory does not exist

**Symptom:** Adapter fails with "cwd does not exist" error.

**Fix:**
```sh
# Ensure the workspace directory exists and is accessible
mkdir -p /workspace
chmod 755 /workspace
```
Update the agent's `adapterConfig.cwd` to an absolute path that exists.

### 3. Instructions file not found

**Symptom:** Claude Code starts without role contract, agent behavior is generic.

**Fix:**
```sh
# Verify the instructions path exists
ls -la /workspace/harness/runtime-instructions/builder/AGENTS.md

# Reset via API if path is wrong
paperclip agents update <agent-id> --instructions-path /workspace/harness/runtime-instructions/builder/AGENTS.md
```

### 4. Permission denied on cwd

**Symptom:** Adapter spawns but exits immediately with permission error.

**Fix:**
```sh
# Check ownership
ls -la /workspace

# Fix permissions
chown -R $(whoami):$(id -gn) /workspace

# Or if running in Docker, ensure volume mount is correct
```

### 5. Claude Code not installed

**Symptom:** Adapter fails with "command not found: claude".

**Fix:**
```sh
# Install Claude Code
npm install -g @anthropic-ai/claude-code

# Or via official installer
curl -sSL https://claude.ai/download | sh
```
