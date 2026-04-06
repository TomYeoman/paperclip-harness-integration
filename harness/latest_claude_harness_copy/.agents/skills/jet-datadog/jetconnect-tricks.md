# jet-datadog: JetConnect Query Tricks

> Companion to `.agents/skills/jet-datadog/SKILL.md`. Load this file when working in a JetConnect repo — it contains query patterns that depend on JetConnect-specific middleware and field conventions.

## Cross-Service Request Correlation

When an event propagates through multiple JetConnect services (e.g., ordering-bridge → order-amendments → monitoring), use `@http.request_id` or `@execution_id` to see the full trace across all consumers simultaneously:

```bash
# Trace a single event across all services
pup logs search \
  --query="@http.request_id:\"<request-id>\"" \
  --from=1h --limit=50 --storage=flex

# Alternative: use execution_id (same correlation ID, different field name in some services)
pup logs search \
  --query="@execution_id:\"<execution-id>\"" \
  --from=1h --limit=50 --storage=flex
```

Sort results by timestamp to reconstruct the execution sequence. This surfaces:
- Which services received the event and in what order
- Where the first failure occurred (vs. downstream cascading errors)
- Whether errors in service A caused failures in service B

**Why this works:** the `http.request_id` field is propagated via the go-kit eventbus middleware. Every service that consumes the same Kafka/SQS event shares the same `request_id`. Use `@` prefix for structured field lookups — without it, DataDog does full-text search only.
