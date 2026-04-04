# Adapter Overlays

Runtime-specific guidance for `claude_local`, `codex_local`, and `opencode_local` adapters.

## Why Overlays Exist

Harness governance is runtime-agnostic. These overlays document the operational specifics that differ between adapters: authentication, working directory handling, model configuration, and common failure modes.

## Overlay Index

| Adapter | Auth Prerequisites | CWD Policy | Model Config |
|---------|-------------------|------------|--------------|
| [claude-local.md](./claude-local.md) | `ANTHROPIC_API_KEY` or subscription | Inherited from adapter config | `claude-4` family |
| [codex-local.md](./codex-local.md) | `OPENAI_API_KEY` or `codex login` | Inherited from adapter config | `gpt-5.3-codex` |
| [opencode-local.md](./opencode-local.md) | `OPENCODE_API_KEY` or model discovery | Inherited from adapter config | Discovered at runtime |

## Shared Constraints

All adapters:

- Require Paperclip env vars (`PAPERCLIP_AGENT_ID`, `PAPERCLIP_COMPANY_ID`, `PAPERCLIP_API_URL`, `PAPERCLIP_RUN_ID`)
- Inject `PAPERCLIP_API_KEY` as a short-lived JWT for API access
- Support `instructionsFilePath` / `instructions-path` for role contract binding
- Run in heartbeat mode: wake, execute bounded work, exit

## Choosing an Adapter

| Use Case | Recommended Adapter |
|----------|-------------------|
| Claude Code CLI available | `claude_local` |
| Codex CLI available | `codex_local` |
| OpenCode CLI available | `opencode_local` |
| Generic process execution | See Paperclip process adapter |
| Unknown runtime | Start with `opencode_local` |

## Adapter-Specific Script Behavior

The `setup-harness-agent-configs.sh` script uses `HARNESS_ADAPTER_TYPE` to configure agents:

```sh
HARNESS_ADAPTER_TYPE=opencode_local ./setup-harness-agent-configs.sh
```

Each adapter type triggers different model resolution logic in the script. See individual overlay docs for details.
