# System Knowledge

> **How to update this file**: Architect updates after each milestone design. Builders read before starting a module. Lead reads at session start to understand current state.

## Service Knowledge Pages

Platform- and service-specific testing idioms, integration patterns, and conventions. Load lazily — only the page for the service you are working on.

| Page | What it contains | Load when |
|------|-----------------|-----------|
| [harness/system-knowledge/SERVICE-JETCONNECT.md](system-knowledge/SERVICE-JETCONNECT.md) | Monorepo-store workflow, capability test commands, service-to-capability map, feature flag snapshot update, Datadog bucket naming and correlation patterns | **Only load if: `service.json` exists at repo root.** When working on any JetConnect service (order-amendments, ordering-bridge, etc.) |

> **JetConnect skill trigger guard convention:** Any skill that is JetConnect-specific must carry a `service.json` detection gate. See **[harness/rules/SKILL-TRIGGER-GUARDS.md](rules/SKILL-TRIGGER-GUARDS.md)** for the full convention and the list of affected skills.

---

## Setup

New machine or first session? See **[harness/setup/GITHUB-ENTERPRISE-SETUP.md](../harness/setup/GITHUB-ENTERPRISE-SETUP.md)** for:
- `gh` CLI authentication against `github.je-labs.com`
- Required token scopes (`repo`, `read:org`, `workflow`)
- SSO/2FA steps and common errors

## Issue Ownership

Where a GitHub issue lives determines who owns it and how it is tracked.

| Work type | Repo | When to close |
|-----------|------|---------------|
| Shippable bugs, features, refactors, investigations with a defined output (e.g. a merged PR) | Submodule repo (iOS/JustEat, Android/app-core, consumer-web, order-amendments, etc.) | When the upstream PR merges |
| Session discovery artefacts — findings not yet matured into a ticket (e.g. a spike that surfaced a new issue) | `grocery-and-retail-growth/testharness` (temporary) | Once the submodule issue is created and linked |
| Harness infrastructure improvements — CLAUDE.md, skills, roles, tooling, sessions | `grocery-and-retail-growth/testharness` | When the harness PR merges |

**Rule:** builders opening new shippable work during a session must create the issue in the relevant submodule repo, not in testharness. Harness issues are for harness infrastructure only.

Added: 2026-03-27 by b-574-issue-ownership (issue #574)

## Module Status

| Module | Status | Interface location | Assigned | Notes |
|--------|--------|-------------------|----------|-------|
| age-verification/id-consent-modal | in review | checkout/src/components/age-verification/id-age-verification-consent-modal/ | a-age-verif-spike | UI update only. See ADR-001. Enhanced file off-limits. PR #18752 open on iOS/JustEat, CTLG-385 warning text updated, heading pending Phrase l10n key. |
| age-verification/dob-modal | in review | checkout/src/components/age-verification/name-and-date-of-birth-modal/ | a-age-verif-spike | UI update only. See ADR-001. Enhanced file off-limits. PR #18752 open on iOS/JustEat. |
| CTLG-395 Bulgaria pharmacy logo | in review | — | — | Enabled in PR #18760, ready for merge. |

## Active Interfaces

_Architect lists interface locations here after M0 design._

Example format:
```
### UserRepository
Location: src/domain/UserRepository.kt (interface)
Prod impl: src/data/UserRepositoryImpl.kt
Fake: src/test/fakes/FakeUserRepository.kt
Status: complete
```

## Known Gotchas

_Builders: read this before starting a module to avoid known pitfalls._

### MCP rate limit fallback protocol
Figma, Confluence, and Jira MCP calls may hit rate limits, auth failures, or timeouts. Do NOT retry. Fall back immediately: ask PO for screenshot, PDF export, or raw text copy. Escalate with B: to Lead. See **[harness/skills/SKILL-mcp-fallback.md](skills/SKILL-mcp-fallback.md)** for full decision tree and message format.
Added: 2026-03-18 by b-146-mcp-fallback

### Translations: cw-l10n-services (external)
Translation strings for age verification components are **not stored in this repository**. They are served at runtime by `@justeattakeaway/cw-l10n-services`. Do not search the repo for translation values — look them up in the staging environment or the l10n portal. New or changed copy must go through the l10n pipeline before it appears in any environment.
Added: 2026-03-13 by a-age-verif-spike

### Figma: authentication required
The Age Verification Figma file (node `6642-37714`) requires a JET Figma account. Builders without access must request PNG redlines or a design handoff artefact from the designer before starting implementation. Do not guess at layout from the ticket description alone.
Added: 2026-03-13 by a-age-verif-spike

### Figma: Code Connect mappings not configured — use screenshot fallback
The Figma MCP emits warnings about missing Code Connect mappings when reading designs. Decision (issue #55): Code Connect setup is deferred indefinitely. Do NOT spend tokens attempting to resolve these warnings.

Correct fallback path:
1. Ignore any "missing Code Connect mapping" warnings from the MCP
2. Use `get_screenshot` to obtain a PNG of the design node
3. Pass the screenshot to the Builder as the design reference

Do not call `get_code_connect_map`, `get_code_connect_suggestions`, or `add_code_connect_map` — they will return empty or noisy results until Code Connect is configured.
Added: 2026-03-16 by b-figma-code-connect (issue #55)

### Secrets injection: use ~/.claude/settings.json env block
Never add API keys, tokens, or credentials to any tracked file. Inject secrets via the `env:` block in `~/.claude/settings.json` on the developer's machine — all agents inherit this automatically. See **[harness/setup/SECRETS-INJECTION.md](setup/SECRETS-INJECTION.md)** for the full pattern, forbidden locations, and pre-commit guard recommendations.
Added: 2026-03-24 by a-secrets (issue #388)

### Git worktree isolation: in-process agents require `git -C /path`
In-process agents (spawned via Agent Teams) always start in the main repo directory, not in the pre-created worktree. Running bare `git checkout` from the main repo changes the branch the PO sees in the status bar. All git operations in builder prompts must use `git -C /tmp/wt-[name]`. See L-1 in harness/lessons.md.
Added: 2026-03-23 by b-session-lessons-23f

### iOS: snapshot regeneration required for UI changes
The iOS repo uses `swift-snapshot-testing`. Any change to UI text, layout, or colors requires regenerating snapshot reference images — CI will fail with snapshot mismatches otherwise. See `harness/skills/SKILL-coding-standards-ios.md` for the full workflow. Always use `swiftlane test package [ModuleName]`, never bare `xcodebuild`.
Added: 2026-03-17 by au-transcript (issue #113)

## Code Quality Signals

Metrics used to assess agent decision quality across sessions.

### Code churn rate
Lines from a given PR that are modified or deleted within 2 subsequent sessions of merging. High churn = rework = poor agent decisions.
- Measurement: `git log --since="<merge_date>" --diff-filter=M -- <files_in_pr>`
- Session KPI: add `churn_prs` field to docs/sessions/ records
- Full definition: `docs/investigations/CODE-CHURN-EVOSCORE-2026-03-24.md`

### EvoScore
Measures whether agent changes make the codebase easier or harder to evolve (SWE-CI 2025). **Deferred** — requires static analysis pipeline (.NET/Roslyn) not yet configured. Revisit when .NET static analysis exists in CI.
- Full spike: `docs/investigations/CODE-CHURN-EVOSCORE-2026-03-24.md`

### PR revert rate (proxy for both)
Count of PRs reverted within 2 sessions. Practical lower bound for churn.
- Check monthly: `gh pr list --search "revert" --state merged`

Added: 2026-03-24 by b-metrics-churn (issue #440)

## Observability

**Standard**: OpenTelemetry GenAI semantic conventions (naming only — no SDK dependency).
**ADR**: `tasks/adr/ADR-observability-conventions.md` (issue #439, part of #432).
**Current backend**: `docs/sessions/` — file-based JSON logs. Schema: `docs/sessions/schema.md`.
**Field naming**: use `gen_ai.*` prefixes for all agent-related fields (`gen_ai.agent.name`, `gen_ai.task.id`, `gen_ai.operation.name`, `gen_ai.system`, `gen_ai.usage.input_tokens`, `gen_ai.usage.output_tokens`). Standard metric names for non-agent fields.
Added: 2026-03-24 by b-otel-conventions (issue #439)

### Role labels on metrics (issue #602)

All OTEL metrics carry an `agent_role` label so Grafana can split cost/tokens/calls by Lead vs Builder vs Reviewer etc.

**How it works:**
- Lead's env (`~/.claude/settings.json`) sets `OTEL_RESOURCE_ATTRIBUTES=agent.role=lead`
- Before spawning any agent, Lead writes a `.claude/settings.json` to the worktree:
  ```bash
  echo '{"env":{"HARNESS_AGENT_TYPE":"builder","OTEL_RESOURCE_ATTRIBUTES":"agent.role=builder"}}' \
    > /private/tmp/<worktree>/.claude/settings.json
  ```
  Use the correct value for each role: `builder` · `reviewer` · `tester` · `architect`
- OTEL collector promotes `agent.role` to a Prometheus label via `resource_to_telemetry_conversion: enabled: true`

**Without this step**, all builder/reviewer/tester metrics appear as `agent_role=lead` (the global default), making cost-by-role attribution impossible.

### Builder model triage (EXPERIMENTAL_HARNESS_BUILDER_CHOOSE_MODEL=true)

When the experiment flag is active, Lead triages task difficulty before every builder spawn and selects the model accordingly. The decision must be logged in the spawn prompt: `Model: haiku — <reason>` or `Model: sonnet — <reason>`.

**Haiku (default — most tasks):** implement-to-spec, tests, lint, config, docs, harness scripts, mechanical refactors.

**Sonnet escalation** (any one sufficient): new interfaces or ADRs, cross-cutting changes (3+ features), security-sensitive work, ambiguous spec requiring builder resolution, prior `B:` failure on same task, issue labeled `complexity:high`/`architecture`/`security`.

See `harness/SESSION-FLAGS.md` for keyword and default reference.
Added: 2026-03-28 by harness/602 (issue #602)

## Module Dependencies

_Architect maps dependencies here so Builders know what must be complete before their module can start._

Example:
```
auth → user-profile (auth must be complete before profile)
user-profile → settings (profile must be complete before settings)
cart → product-catalog (catalog interfaces must exist before cart implements)
```

## DI Module Map

_Architect defines which DI module registers which implementations._

Example:
```
AppModule: UserRepository → UserRepositoryImpl
AppModule: AuthService → AuthServiceImpl
TestModule: UserRepository → FakeUserRepository
TestModule: AuthService → FakeAuthService
```

_Fill in after M0 defines DI framework and module structure._
