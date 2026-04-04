# codex_local Adapter Overlay

Codex CLI adapter for Paperclip.

## Auth Prerequisites

| Auth Method | Required | Notes |
|-------------|----------|-------|
| `OPENAI_API_KEY` env var | Recommended | API key for Codex |
| `codex login` | Alternative | Interactive login flow |

The adapter attempts `OPENAI_API_KEY` first, then falls back to checking for an active `codex login` session.

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
- Codex discovers and loads this file as the runtime contract

### Skills Discovery

Codex uses a global skills directory (`$CODEX_HOME/skills` or `~/.codex/skills`). The adapter symlinks Paperclip skills there if they don't already exist. Existing user skills are not overwritten.

## Model Config Policy

| Config Field | Value |
|--------------|-------|
| `model` | Optional; defaults to `gpt-5.3-codex` |
| Script override | `HARNESS_MODEL=gpt-5.3-codex` |

The harness script defaults to `gpt-5.3-codex` for `codex_local` when no explicit model is set.

## Common Failure Modes

### 1. `OPENAI_API_KEY` not set and no Codex login

**Symptom:** Adapter fails with authentication error.

**Fix:**
```sh
export OPENAI_API_KEY=sk-...
```
Or run `codex login` interactively.

### 2. Docker ownership mismatch

**Symptom:** Run logs or state writes fail with permission denied.

**Fix:**
```sh
# Run container with matching UID/GID
docker run -u $(id -u):$(id -g) ...

# Or fix ownership inside container
docker exec <container> chown -R codex:codex /home/codex
```

### 3. Working directory does not exist

**Symptom:** Adapter fails with "cwd does not exist" error.

**Fix:**
```sh
# Ensure the workspace directory exists
mkdir -p /workspace
chmod 755 /workspace
```

### 4. Instructions file not accessible

**Symptom:** Codex starts but loads generic instructions instead of role contract.

**Fix:**
```sh
# Verify permissions
ls -la /workspace/harness/runtime-instructions/builder/AGENTS.md

# Ensure readable by codex user (in Docker)
docker exec <container> chmod 644 /workspace/harness/runtime-instructions/builder/AGENTS.md
```

### 5. Codex CLI not installed

**Symptom:** Adapter fails with "command not found: codex".

**Fix:**
```sh
# Install Codex CLI
# Visit https://codex.dev to get started
# Or check OpenAI's official documentation for installation steps
```

### 6. Trust directory issues

**Symptom:** Codex refuses to run due to trust requirements.

**Fix:**
```sh
# Initialize trust directory for the workspace
cd /workspace
codex init

# Or allow trusted execution
export CODEX_ALLOW_UNTRUSTED=true
```
Note: Only use `CODEX_ALLOW_UNTRUSTED` in development environments.
