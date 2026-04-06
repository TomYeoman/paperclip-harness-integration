# Session Flags

Runtime configuration persisted in `~/.claude/session-flags.env`. Lead detects keywords in the PO's opening message, writes resolved values, and emits a startup line. Builders source the file at spawn so all agents share the same configuration. The file resets to defaults at session end.

For full documentation of **swarm/worker modes** and **hive/release/👑 upstream signals**, see the [Beehive section in README.md](../README.md#beehive).

## Keyword reference

| Keyword(s) | Flag | Effect |
|-----------|------|--------|
| `🍯` or `swarm` | `HARNESS_MODE=swarm` | Parallel builders, auto-continue — see [Beehive § Modes](../README.md#modes) |
| `🐝` or `worker` | `HARNESS_MODE=worker` | Single builder, pause after — see [Beehive § Modes](../README.md#modes) |
| `🌻` or `release` | `HARNESS_UPSTREAM=release` | Open upstream PRs on completion — see [Beehive § Upstream](../README.md#upstream) |
| `🏠` or `hive` | `HARNESS_UPSTREAM=hive` | Hold in hive (default) — see [Beehive § Upstream](../README.md#upstream) |
| `debug` | `HARNESS_DEBUG=1` | Verbose mode — see below |
| `builder-model` | `EXPERIMENTAL_HARNESS_BUILDER_CHOOSE_MODEL=true` | Experimental: Lead triages difficulty and picks haiku or sonnet per task |

Multiple keywords can appear in the same message:

```
start debug swarm 🌻
→ HARNESS_MODE=swarm, HARNESS_UPSTREAM=release, HARNESS_DEBUG=1
```

## Debug mode (`HARNESS_DEBUG`)

| Value | Behaviour |
|-------|-----------|
| `0` (default) | Concise output — signal-only |
| `1` (keyword: `debug`) | Verbose narration: Lead describes each session-start step as it runs, surfaces intermediate state, emits token counts at key stages. Stop hook runs the OTEL cost report at session end. |

## Builder model experiment (`EXPERIMENTAL_HARNESS_BUILDER_CHOOSE_MODEL`)

Boolean flag. Default `false` — standard behaviour (all builders on Sonnet). Set to `true` with the `builder-model` keyword to enable per-task model selection.

| Value | Behaviour |
|-------|-----------|
| `false` (default) | Standard — all builders use Sonnet |
| `true` (keyword: `builder-model`) | Lead triages task difficulty before each spawn and picks haiku or sonnet. Haiku for most work; Sonnet only when task genuinely warrants it (see triage criteria in CLAUDE.md DISPATCH). |

Lead logs the model decision in every builder spawn prompt: `Model: haiku — implement-to-spec` or `Model: sonnet — cross-cutting, 4 features affected`.

## Startup output

Lead always emits at the top of its first message:

```
⚙️  session-flags: mode=worker  upstream=hive  debug=off  builder-model=off
📊 Grafana: http://localhost:4000
```

Every builder emits as its first line:

```
⚙️  env: mode=swarm  upstream=hive  debug=on  builder-model=off
```

Spawn-prompt declarations (`Mode:` / `Upstream:`) take precedence over the flags file.

## Defaults

```
HARNESS_MODE=worker
HARNESS_UPSTREAM=hive
HARNESS_DEBUG=0
EXPERIMENTAL_HARNESS_BUILDER_CHOOSE_MODEL=false
```

Created automatically if absent. Reset at every session end.

## Examples

| Opening message | Flags set |
|----------------|-----------|
| `start` | All defaults |
| `start debug` | `HARNESS_DEBUG=1` |
| `start debug worker` | `HARNESS_MODE=worker`, `HARNESS_DEBUG=1` |
| `start debug swarm` | `HARNESS_MODE=swarm`, `HARNESS_DEBUG=1` |
| `🍯 🌻` | `HARNESS_MODE=swarm`, `HARNESS_UPSTREAM=release` |
| `start builder-model` | `EXPERIMENTAL_HARNESS_BUILDER_CHOOSE_MODEL=true` |
| `start debug swarm builder-model` | `HARNESS_MODE=swarm`, `HARNESS_DEBUG=1`, `EXPERIMENTAL_HARNESS_BUILDER_CHOOSE_MODEL=true` |
