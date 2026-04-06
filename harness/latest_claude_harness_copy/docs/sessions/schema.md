# Session JSON Schema

Canonical schema for per-session KPI records in `docs/sessions/`.
Field names use OTel GenAI-compatible conventions where applicable.

## Canonical JSON structure

```json
{
  "session": "2026-03-24c",
  "date": "2026-03-24",
  "wall_clock_minutes": null,
  "prs_merged": null,
  "prs_queued": null,
  "agents_spawned": null,
  "agents_completed": null,
  "agents_blocked": null,
  "spawn_to_done_ratio": null,
  "b_rate": null,
  "avg_loop_count_per_pr": null,
  "avg_pr_cycle_time_minutes": null,
  "coordination_overhead_pct": null,
  "vfte_hours_estimate": null,
  "vfte_efficiency": null,
  "lessons_encoded": null,
  "cost_model_breakdown": {
    "opus_spawns": null,
    "sonnet_spawns": null,
    "haiku_spawns": null
  }
}
```

## Field definitions

### Identity fields

| Field | Type | Description | Source |
|-------|------|-------------|--------|
| `session` | string | Session identifier: date + letter suffix | Lead writes manually |
| `date` | string | ISO 8601 date (YYYY-MM-DD) | Lead writes manually |

### Time fields

| Field | Type | Description | Computation | Issue |
|-------|------|-------------|-------------|-------|
| `wall_clock_minutes` | integer\|null | Elapsed wall-clock minutes from first agent spawn to session-end dashboard output | Session start/end timestamps from `inject-timestamp.sh` hook output | #433 |

### PR fields

| Field | Type | Description | Computation | Issue |
|-------|------|-------------|-------------|-------|
| `prs_merged` | integer\|null | PRs merged into main this session | `gh pr list --state merged` filtered by session date | #433 |
| `prs_queued` | integer\|null | PRs added to merge queue but not yet merged at session end | `gh pr list --state open` filtered to queued state | #433 |
| `avg_pr_cycle_time_minutes` | float\|null | Average time from issue creation to PR merge | For each merged PR: `mergedAt − issue.createdAt` in minutes; average across session PRs. Use `gh issue view <N> --json createdAt` for issue timestamp | #435 |
| `avg_loop_count_per_pr` | float\|null | Average number of reviewer F: feedback cycles per PR before merge | Manual tally from session messages: count F: signals per PR, average across session | #435 |

### Agent fields

| Field | Type | Description | Computation | Issue |
|-------|------|-------------|-------------|-------|
| `agents_spawned` | integer\|null | Total distinct agents created (TeamCreate + Agent calls) | Count from session tool call log | #433 |
| `agents_completed` | integer\|null | Count of D: completion messages received | Tally D: messages from session log | #433 |
| `agents_blocked` | integer\|null | Count of B: blocked messages received | Tally B: messages from session log | #433 |
| `spawn_to_done_ratio` | float\|null | Fraction of agents that completed successfully | `agents_completed / agents_spawned` | #433 |
| `b_rate` | float\|null | Fraction of agents that hit a blocker | `agents_blocked / agents_spawned` | #433 |

### Overhead fields

| Field | Type | Description | Computation | Issue |
|-------|------|-------------|-------------|-------|
| `coordination_overhead_pct` | float\|null | Percentage of Lead's tool calls spent on coordination vs. feature work | Ratio of Lead coordination tool calls (SendMessage, TeamCreate) to total Lead tool calls × 100 | #438 |

### vFTE fields

| Field | Type | Description | Computation | Issue |
|-------|------|-------------|-------------|-------|
| `vfte_hours_estimate` | float\|null | Estimated equivalent human engineering hours delivered | Sum across agents: `(agents_completed × avg_task_complexity_hours)`. Complexity baseline: Builder = 2h, Reviewer = 0.5h, Tester = 1h, Auditor = 1.5h | #434 |
| `vfte_efficiency` | float\|null | vFTE hours delivered per wall-clock hour | `vfte_hours_estimate / (wall_clock_minutes / 60)` | #434 |

### Quality fields

| Field | Type | Description | Computation | Issue |
|-------|------|-------------|-------------|-------|
| `lessons_encoded` | integer\|null | Number of L: events written to `harness/lessons.md` this session | Count new entries appended to `harness/lessons.md` this session | #433 |

### Cost fields

| Field | Type | Description | Computation | Issue |
|-------|------|-------------|-------------|-------|
| `cost_model_breakdown.opus_spawns` | integer\|null | Number of Opus model agent spawns | Count agents spawned with model=opus | #440 |
| `cost_model_breakdown.sonnet_spawns` | integer\|null | Number of Sonnet model agent spawns | Count agents spawned with model=sonnet (default) | #440 |
| `cost_model_breakdown.haiku_spawns` | integer\|null | Number of Haiku model agent spawns | Count agents spawned with model=haiku | #440 |

## Null policy

Fields are set to `null` when:
- The value cannot be computed without access to data not available at shutdown time
- The metric definition changed and retroactive computation would be inaccurate

Do not omit fields — always include every field from the canonical structure, using `null` for unknown values. This ensures schema consistency for tooling that reads the records.

## OTel mapping notes

Where OTel GenAI semantic conventions apply, field names mirror the convention:
- `gen_ai.agent.name` → corresponds to agent name entries in `cost_model_breakdown` keys
- `gen_ai.usage.input_tokens` → not yet tracked per-session; reserved for future addition

See the [OpenTelemetry GenAI semantic conventions](https://opentelemetry.io/docs/specs/semconv/gen-ai/) for reference.
