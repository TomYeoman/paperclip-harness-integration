# Local OTEL Stack

Real-time token and cost dashboards for Claude Code sessions.

## Prerequisites

- Docker + Docker Compose
- Claude Code v1.x+

## Start

```bash
cd harness/otel
docker compose up -d
```

Grafana: http://localhost:4000 (admin / admin)

## Connect Claude Code

Add to `~/.claude/settings.json` under `env`:

```json
{
  "env": {
    "CLAUDE_CODE_ENABLE_TELEMETRY": "1",
    "OTEL_EXPORTER_OTLP_ENDPOINT": "http://localhost:4318",
    "OTEL_EXPORTER_OTLP_PROTOCOL": "http/protobuf"
  }
}
```

Or use `/update-config` to set these.

## Stop

```bash
docker compose down
```

To also remove stored data:

```bash
docker compose down -v
```

## Dashboards

- **Claude Code -- Token Usage**: http://localhost:4000/d/claude-tokens

## Verifying metrics

After starting the stack and running a Claude Code session, check that metrics are flowing:

```bash
curl -s http://localhost:8889/metrics | grep claude_code
```

The exact metric names emitted by Claude Code under `CLAUDE_CODE_ENABLE_TELEMETRY=1` may differ from the dashboard queries. If panels show "No data", check the metrics endpoint above and update the Prometheus queries in the dashboard accordingly.

## Ports

| Service        | Port |
|----------------|------|
| OTLP gRPC      | 4317 |
| OTLP HTTP      | 4318 |
| Prometheus UI  | 9090 |
| Prom exporter  | 8889 |
| Grafana        | 3000 |
