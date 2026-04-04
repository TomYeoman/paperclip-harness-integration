# opencode_local Adapter Overlay

OpenCode CLI adapter for Paperclip.

## Auth Prerequisites

| Auth Method | Required | Notes |
|-------------|----------|-------|
| Model discovery at startup | Yes | Adapter auto-discovers available models |
| `OPENCODE_API_KEY` | For API calls | Passed as JWT via Paperclip env |

The adapter queries available models at runtime. If no models are discovered and no explicit model is set, the adapter fails with an error.

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
- OpenCode loads this as the dense runtime contract

### Skills Discovery

OpenCode supports Paperclip skills via its skill system. The adapter injects skills at runtime from the repository's `skills/` directory. No skills are written to the agent's `cwd`.

## Model Config Policy

| Config Field | Source |
|--------------|--------|
| `model` | Auto-discovered from adapter API, or explicit via `HARNESS_MODEL` |

The harness script (`setup-harness-agent-configs.sh`) uses this resolution order:

1. If `HARNESS_MODEL` env var is set, use that
2. Query `/api/companies/:companyId/adapters/opencode_local/models`
3. Use the first available model from discovery
4. Fail if no models available

```sh
# Override with explicit model
HARNESS_MODEL=opencode/big-pickle ./setup-harness-agent-configs.sh
```

## Common Failure Modes

### 1. No models discovered

**Symptom:** Adapter fails with "No opencode models discovered".

**Fix:**
```sh
# Set model explicitly
HARNESS_MODEL=opencode/big-pickle ./setup-harness-agent-configs.sh

# Or fix authentication - check API key is valid
echo $OPENCODE_API_KEY
```

### 2. Working directory does not exist

**Symptom:** Adapter fails with "cwd does not exist" error.

**Fix:**
```sh
# Ensure the workspace directory exists
mkdir -p /workspace
chmod 755 /workspace
```

### 3. Instructions file not found

**Symptom:** OpenCode starts without role contract, agent behavior is generic.

**Fix:**
```sh
# Verify the instructions path exists
ls -la /workspace/harness/runtime-instructions/builder/AGENTS.md

# Check adapter config
curl -s -H "Authorization: Bearer $PAPERCLIP_API_KEY" \
  "$PAPERCLIP_API_URL/api/agents/<agent-id>" | jq '.adapterConfig'
```

### 4. Permission denied on workspace

**Symptom:** Adapter spawns but cannot read/write files.

**Fix:**
```sh
# Check current permissions
ls -la /workspace

# Fix ownership
chown -R $(id -u):$(id -g) /workspace

# Or in Docker, verify volume mount
docker inspect <container> | jq '.[0].Mounts'
```

### 5. Invalid model specified

**Symptom:** Adapter warns about model not in discovered list.

**Fix:**
```sh
# List available models
curl -s -H "Authorization: Bearer $PAPERCLIP_API_KEY" \
  "$PAPERCLIP_API_URL/api/companies/$PAPERCLIP_COMPANY_ID/adapters/opencode_local/models"

# Use a model from the list
HARNESS_MODEL=<valid-model-id> ./setup-harness-agent-configs.sh
```

### 6. OpenCode CLI not installed

**Symptom:** Adapter fails with "command not found: opencode".

**Fix:**
```sh
# Install OpenCode CLI
# Check official OpenCode installation documentation
npm install -g opencode-ai

# Or use the appropriate package manager for your system
```
