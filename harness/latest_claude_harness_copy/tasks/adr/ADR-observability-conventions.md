# ADR: Observability Conventions for Harness Structured Logging

**Status**: Accepted
**Date**: 2026-03-24
**Issue**: #439 (part of #432)

## Context

Issue #437 adds structured session logging to the harness. Agent sessions produce
telemetry (token counts, agent names, task IDs, operation types) that must be stored
in a structured format and may eventually be shipped to an external observability
backend (Datadog, Langfuse, or an OTel collector).

Field naming chosen now becomes the schema. Choosing arbitrary names today means a
migration cost when connecting to any standard backend tomorrow. OpenTelemetry has
published GenAI semantic conventions that cover exactly the fields harness sessions
produce — adopting them costs nothing and avoids that migration.

## Decision

Use **OpenTelemetry GenAI semantic conventions** for all structured log field names
in the harness. This is a naming convention only — no OTel SDK or library dependency
is required or introduced.

### Key fields

| Field | Type | Description |
|-------|------|-------------|
| `gen_ai.system` | string | AI provider. Value: `"claude"` |
| `gen_ai.agent.name` | string | Name of the spawned agent (e.g. `b-show-top-bar`) |
| `gen_ai.task.id` | string | GitHub issue number or task identifier |
| `gen_ai.operation.name` | string | Operation type (e.g. `"build"`, `"review"`, `"audit"`) |
| `gen_ai.usage.input_tokens` | integer | Prompt tokens consumed |
| `gen_ai.usage.output_tokens` | integer | Completion tokens produced |

Non-agent fields (timestamps, session IDs, outcomes) use standard metric naming
without a `gen_ai.` prefix.

## Backend decision

**Current backend**: file-based JSON logs written to `docs/sessions/`. Schema defined
in `docs/sessions/schema.md` (created in #437).

**Future backends**: Datadog or Langfuse when session volume warrants centralised
querying. Because field names are OTel-compatible, the migration will be a
configuration change, not a schema migration.

## Consequences

- Session JSON schema (`docs/sessions/schema.md`) uses `gen_ai.*` field names where
  applicable.
- Any future harness instrumentation that adds agent-related fields must follow
  `gen_ai.*` naming — record new fields in this ADR before shipping.
- No library dependency introduced; no build change required.
- Datadog/Langfuse integration is deferred; this ADR does not schedule it.
