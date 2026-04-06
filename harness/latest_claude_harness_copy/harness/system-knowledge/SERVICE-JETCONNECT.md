# JetConnect Service Knowledge

> **JetConnect-only.** This page applies exclusively to repos containing `service.json` at root. Do NOT apply JetConnect testing patterns to REWE, iOS, Android, or consumer-web repos.

JetConnect is JET's Go-based microservice mesh for the ordering, amendment, and monitoring flows. Services communicate via Kafka/SQS events with correlation propagated by the go-kit eventbus middleware.

---

## Detection Gate

Before applying any pattern from this page, confirm the repo is a JetConnect service:

```bash
test -f service.json && echo "JetConnect repo — apply patterns below" || echo "Not a JetConnect repo — stop"
```

If `service.json` is absent, none of the commands or conventions on this page apply.

---

## Monorepo-Store Workflow

### One-time session setup

```bash
# Clone monorepo-store alongside your service repo
cd ~/git
git clone git@github.je-labs.com:jetconnect/monorepo-store.git
cd monorepo-store

# Replace the monorepo copy of your service with your local branch
make replace SERVICES=<your-service-name>   # e.g. order-amendments

# Generate shim code (required after replace or first checkout)
make build

# Start the full backend stack (Docker + all services)
make start
# Wait for "Services started". Verify:
curl -s http://localhost:8080/ping
```

### Log tailing

```bash
# Logs for a specific service
make tail-logs | jq 'select(.app == "<service-name>")'

# Errors across all services
make tail-logs | jq 'select(.level == "error")'
```

### Teardown

```bash
make stop
```

---

## Capability Tests

Capability tests are end-to-end integration tests that exercise the full JetConnect backend. Run them after unit tests pass, before raising a PR.

### Setup (one-time)

```bash
cd ~/git
git clone git@github.je-labs.com:jetconnect/capability-testing.git
cd capability-testing
cp .env.local .env
```

### Run commands

```bash
# All justeat capability tests
go test ./captests/justeat/... -v -count=1 -timeout 20m -failfast

# Grocery/substitution tests only (recommended for order-amendments)
go test ./captests/justeat/... -v -count=1 -timeout 20m -failfast -run TestGroceryFlows

# Single subtest
go test ./captests/justeat/... -v -count=1 -timeout 20m -run "TestGroceryFlows/<SubtestName>"
```

---

## Service-to-Capability Map

| Service | Capability suite | Key test function | Key subtests | Test file |
|---------|-----------------|-------------------|--------------|-----------|
| order-amendments | `captests/justeat/` | `TestGroceryFlows` | `TestAmendOrderFailed`, `TestAmendOrderConnectSuccess`, `TestModifyOrderConnectSucceeded`, `TestFinalOrderSucceeded_LastMileDelivered_WithSubstitution`, `TestFinalOrderSucceeded_LastMileDelivered_NoAmendments` | `grocery_flows_test.go` |

> Add rows here as services are onboarded to capability testing.

---

## Feature Flag Snapshot Update

Capability tests consume a static `flagdata.json` snapshot rather than live JetFM. When a new flag is introduced, update the snapshot before running tests:

```bash
# From the capability-testing repo root
curl -s https://features.api.justeattakeaway.com/config/v1/jetconnect/staging | jq . > flagdata.json
```

Commit the updated snapshot with the PR that introduces the flag.

---

## Datadog: JetConnect Bucket Naming Conventions

JetConnect logs are stored in Datadog Flex Logs (`--storage=flex` required for all queries).

### Service naming in Datadog

Datadog service names mirror the Go module/service name in `service.json`. Examples:
- `order-amendments`
- `ordering-bridge`
- `monitoring-service`

Use these names for `service:<name>` filters.

### Cross-service request correlation

Events propagate across services via Kafka/SQS. The go-kit eventbus middleware attaches a correlation ID to every consumed event. Use it to trace a single event across all services simultaneously:

```bash
# Trace by request ID (most common)
pup logs search \
  --query="@http.request_id:\"<request-id>\"" \
  --from=1h --limit=50 --storage=flex

# Trace by execution ID (used in some services)
pup logs search \
  --query="@execution_id:\"<execution-id>\"" \
  --from=1h --limit=50 --storage=flex
```

Sort results by timestamp to reconstruct execution sequence. Both `@http.request_id` and `@execution_id` refer to the same correlation value — different services use different field names.

**Field lookup note:** always use the `@` prefix for structured field lookups. Without it DataDog performs full-text search only.

### Common query patterns

```bash
# Errors in a specific service
pup logs search \
  --query="status:error AND service:order-amendments" \
  --from=1h --limit=20 --storage=flex

# Errors across all JetConnect services
pup logs aggregate \
  --query="status:error" \
  --from=1h --compute="count" --group-by="service" --storage=flex
```

---

## Prerequisites

| Tool | Install | Verify |
|------|---------|--------|
| Go 1.24+ | `brew install go` | `go version` |
| Docker Desktop | docker.com | `docker info` |
| dev-tool | JET internal onboarding | `dev-tool --version` |
| mkcert | `brew install mkcert` | `mkcert --version` |
| pup 0.25+ | `brew tap datadog-labs/pack && brew install datadog-labs/pack/pup` | `pup --version` |

---

## Related Skills

| Skill | When to load |
|-------|-------------|
| `harness/skills/SKILL-capability-testing.md` | Full capability test setup and gotchas |
| `.agents/skills/jet-datadog/SKILL.md` | Full pup CLI reference |
| `.agents/skills/jet-datadog/jetconnect-tricks.md` | JetConnect-specific Datadog query patterns |
| `harness/skills/SKILL-aws-cli.md` | S3 bucket inspection, IAM, JetConnect AWS profiles |
| `harness/skills/SKILL-jetc-atlas-context.md` | Atlas read-only context engine for JetConnect repos |
