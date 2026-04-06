# Investigation: Secrets Management Tooling and Agent Injection Pattern

**Issue**: #321
**Date**: 2026-03-23
**Author**: b-321-secrets

---

## Summary

The harness states "No credentials in source — env/secrets manager only" but no tooling, injection pattern, or rotation lifecycle has been defined. Agents currently have no explicit mechanism for receiving or rotating secrets beyond static environment variables. This is an operational and security gap.

---

## Current State

### What exists today

| Location | Rule | Gap |
|----------|------|-----|
| `CLAUDE.md` (SECURITY section) | "No credentials in source — env/secrets manager only" | No tooling specified |
| `CLAUDE-HUMAN.md` | Same rule | No tooling specified |
| `harness/context/CLAUDE-BUILDER.md` | "No credentials in source — env/secrets manager only" | No tooling specified |
| `harness/roles/ROLE-BUILDER-BACKEND.md` | "No credentials in source — use env vars or secrets manager only" | No tooling specified |
| `harness/skills/SKILL-coding-standards-backend.md` | Credential check in PR checklist | No tooling specified |

### How agents currently receive env vars

Agent env injection happens via `.claude/settings.json` (project level) and `~/.claude/settings.json` (global level):

**Project-level** (`.claude/settings.json`):
```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

**Global-level** (`~/.claude/settings.json` `env` block):
```json
{
  "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1",
  "MAX_THINKING_TOKENS": "20000",
  "CLAUDE_CODE_SUBAGENT_MODEL": "sonnet"
}
```

None of these are secrets. The `env` block in `settings.json` is the established injection channel — it is how Claude Code passes environment variables into agent processes. This is the natural integration point for a secrets manager.

### Active secrets in use

| Secret | Usage | Current location |
|--------|-------|-----------------|
| `ANTHROPIC_API_KEY` | Claude Code runtime | Shell environment / machine-level (not in repo) |
| `gh` CLI token | GitHub Enterprise API access | `~/.config/gh/hosts.yml` (machine-level) |

No secrets were found hardcoded in source. The PII audit (2026-03-23, `docs/ANTHROPIC-PREP-PII-REPORT.md`) confirmed: "No API keys, tokens, passwords, or hardcoded secrets were found outside the excluded directories."

### CI/CD

No CI workflow files exist under `.github/workflows/`. The stack is TBD (M0 not yet complete). CI secrets injection is not yet required but needs to be defined before M1.

---

## Gap Analysis

| Area | Gap | Risk |
|------|-----|------|
| Tooling | No secrets manager (Vault, AWS Secrets Manager, 1Password, etc.) designated | Medium — manual machine-level secret management is error-prone at scale |
| Agent injection pattern | No documented pattern for injecting secrets into worktree-isolated agent processes | Medium — ad-hoc today; becomes critical when agents need API keys for external services |
| Secret rotation | No rotation lifecycle defined; no pattern for zero-downtime rotation | High — a rotated secret will silently break agent workflows if not propagated |
| CI | No CI workflow exists; no secrets injection pattern for pipeline | Low now, High at M1 |
| Audit trail | No record of which secrets agents access or when | Medium — compliance risk |

---

## Options Analysis

### Option A: `settings.json` env block + machine-level secrets manager

**Pattern**: Developer or CI runner populates env vars from a secrets manager (e.g., `aws secretsmanager get-secret-value`, `vault kv get`, `op run`) before launching Claude Code. The `~/.claude/settings.json` `env` block propagates those vars into all agent processes including worktree-isolated builders.

**Injection flow**:
```
Secrets Manager → shell env (op run / vault env / aws-vault) → claude code process → settings.json env block → agent worktrees
```

**Pros**:
- No harness code changes — uses existing injection channel
- Works with any secrets manager (vendor-agnostic)
- Rotation is handled by the secrets manager; next session launch picks up new value
- Consistent with how `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` is already injected

**Cons**:
- Requires a launch wrapper (`op run -- claude`, `vault env -- claude`, etc.)
- Does not support mid-session rotation without restarting Claude Code

**Rotation lifecycle**:
1. Secret rotated in secrets manager
2. Old value invalidated (configurable grace window)
3. Next Claude Code session launch picks up new value via wrapper
4. Mid-session: not needed for API keys consumed by agents (agents use the key at spawn time)

---

### Option B: Direct SDK integration (Vault / AWS SDK call at agent spawn)

**Pattern**: Harness spawns a setup step that calls the secrets manager SDK and writes resolved values to the agent's env before the agent task begins.

**Pros**: Supports mid-session rotation; fine-grained per-agent scoping

**Cons**:
- Requires harness code to call Vault/AWS SDK — couples harness to a specific vendor
- Stack is TBD; no SDK language is defined
- Over-engineered for current state (no agents yet calling external APIs that need rotation)

---

### Option C: 1Password CLI (`op run`)

**Pattern**: Standardise on 1Password as the team's secrets manager. Use `op run -- claude` as the launch wrapper. Reference secrets as `op://vault/item/field` in settings.

**Pros**: Team-friendly UI; works on macOS; integrates with GH Actions via `1password/load-secrets-action`

**Cons**: Requires 1Password subscription; adds a tool dependency

---

## Recommendation

**Adopt Option A with `op run` (1Password) as the recommended wrapper**, with the flexibility to substitute `vault env` or `aws-vault` if the platform team has an existing standard.

**Rationale**:
- Harness is pre-M0; no vendor lock-in yet — pick the least-opinionated option
- `settings.json` env injection is already proven and used; no new mechanism needed
- Option B (SDK call at spawn) is premature — no external secrets are consumed today
- 1Password is already common at JET for developer secrets; reduces new tooling

**Short-term (now)**: Document the injection pattern in harness so agents know where to look. No implementation required until M1 CI is defined.

**Mid-term (M1)**: When CI/CD is defined, configure GitHub Actions secrets and add the `op run` wrapper to the launch script.

---

## Recommended Pattern (for harness documentation)

```
# How to inject a secret into Claude Code agents

1. Store the secret in your secrets manager (1Password, Vault, AWS Secrets Manager)
2. Add the env var name to ~/.claude/settings.json under "env":
   {
     "env": {
       "MY_API_KEY": "placeholder"  // value overridden by wrapper
     }
   }
3. Launch Claude Code via the secrets manager wrapper:
   op run --env-file=.env.secrets -- claude   # 1Password
   vault env -- claude                         # HashiCorp Vault
   aws-vault exec my-profile -- claude         # AWS Vault

All agents (including worktree-isolated builders) inherit env vars from the
parent Claude Code process — no per-agent configuration needed.

# Rotation
Secret rotation requires a Claude Code session restart. Mid-session rotation
is not supported. For secrets that rotate frequently, prefer short sessions
or use Option B (SDK call at spawn) — file a new issue if needed.
```

---

## Follow-on Tickets

| Priority | Title | Scope |
|----------|-------|-------|
| High | `harness: document secrets injection pattern in CLAUDE.md and SKILL-agent-spawn.md` | Add injection pattern to harness docs; no code change |
| Medium | `harness: define CI secrets injection pattern for GitHub Actions` | Needed at M1 when CI workflow is created |
| Low | `investigate: evaluate 1Password vs Vault vs AWS Secrets Manager for team standard` | Blocked on platform team input; not needed until first external API consumer |

---

## Files Audited

- `/CLAUDE.md` — security section
- `/CLAUDE-HUMAN.md` — security section
- `/.claude/settings.json` — env injection channel
- `~/.claude/settings.json` — global env injection
- `/harness/context/CLAUDE-BUILDER.md`
- `/harness/roles/ROLE-BUILDER-BACKEND.md`
- `/harness/skills/SKILL-coding-standards-backend.md`
- `/harness/skills/SKILL-agent-spawn.md`
- `/docs/ANTHROPIC-PREP-PII-REPORT.md`
- `/docs/BUILD-JOURNAL.md`
- `.github/` (no workflow files found)
