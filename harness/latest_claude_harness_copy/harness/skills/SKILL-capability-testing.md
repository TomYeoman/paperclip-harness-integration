# SKILL: Capability Testing

Run end-to-end capability tests against the full JetConnect backend stack via monorepo-store.

## Detection Gate

This skill applies when **all** of the following are true:
1. The repo contains `service.json` at root (= JetConnect service)
2. The task involves behaviour changes that affect integrated ordering/amendment flows
3. Unit tests alone cannot verify the cross-service interaction

## Prerequisites

| Tool | Install | Verify |
|------|---------|--------|
| Go 1.24+ | `brew install go` | `go version` |
| Docker Desktop | docker.com | `docker info` |
| dev-tool | JET internal — see onboarding docs | `dev-tool --version` |
| mkcert | `brew install mkcert` | `mkcert --version` |

## Monorepo Setup (one-time per session)

```bash
# 1. Clone monorepo-store alongside your service repo
cd ~/git
git clone git@github.je-labs.com:jetconnect/monorepo-store.git
cd monorepo-store

# 2. Replace the monorepo copy of your service with your local branch
make replace SERVICES=order-amendments

# 3. Generate shim code (required after replace or first checkout)
make build

# 4. Start the full backend stack (Docker + all services)
make start
# Wait for "Services started" message. Verify:
curl -s http://localhost:8080/ping
```

To view logs filtered to your service:
```bash
make tail-logs | jq 'select(.app == "order-amendments")'
```

To view errors across all services:
```bash
make tail-logs | jq 'select(.level == "error")'
```

## Running Capability Tests

```bash
# Clone capability-testing alongside monorepo-store
cd ~/git
git clone git@github.je-labs.com:jetconnect/capability-testing.git
cd capability-testing

# Set up local environment
cp .env.local .env

# Run ALL justeat capability tests (includes substitution flows)
go test ./captests/justeat/... -v -count=1 -timeout 20m -failfast

# Run ONLY the grocery/substitution tests (recommended for order-amendments)
go test ./captests/justeat/... -v -count=1 -timeout 20m -failfast -run TestGroceryFlows

# Run a specific subtest
go test ./captests/justeat/... -v -count=1 -timeout 20m -run "TestGroceryFlows/TestFinalOrderSucceeded_LastMileDelivered_WithSubstitution"
```

## Service-to-Capability Mapping

| Service | Capability suite | Key test function | Key subtests | Test file |
|---------|-----------------|-------------------|--------------|-----------|
| order-amendments | `captests/justeat/` | `TestGroceryFlows` | `TestAmendOrderFailed`, `TestAmendOrderConnectSuccess`, `TestModifyOrderConnectSucceeded`, `TestFinalOrderSucceeded_LastMileDelivered_WithSubstitution`, `TestFinalOrderSucceeded_LastMileDelivered_NoAmendments` | `grocery_flows_test.go` |

> Add rows here as services are onboarded to capability testing.

## When to Run

1. **Before raising a PR** — after unit tests pass, run the relevant capability suite to verify integrated behaviour
2. **After a fix** — confirm the fix does not regress other grocery/ordering flows
3. **As part of the Verification Gate** — capability tests are the integration verification step before `D:`
4. **CI** — each service's `helper-monorepo-tests.yml` triggers the full suite automatically on PR

## How It Works

The monorepo-store compiles all JetConnect Go services into a single binary. Each service's `RunService` is exposed via a generated shim in `<service>/pkg/local/local.gen.go`. All services share:
- A local DynamoDB (via Docker)
- A local SNS/SQS (GoAWS via Docker)
- A local S3 (MinIO via Docker)
- An HTTPS proxy (mkcert + mountebank) for external service stubs

Service URLs in capability tests resolve as `http://<service-name>` which routes to `http://localhost:8080/<service-name>`.

Feature flags are mocked via a static `flagdata.json` snapshot. To update:
```bash
curl -s https://features.api.justeattakeaway.com/config/v1/jetconnect/staging | jq . > flagdata.json
```

## Gotchas

| Symptom | Cause | Fix |
|---------|-------|-----|
| `connection refused` on test run | Monorepo not started | Run `make start`, wait for `curl http://localhost:8080/ping` to succeed |
| Tests pass locally, fail in CI | Local service differs from main | Run `make replace SERVICES=<name>` + `make build` after your latest changes |
| `Environment file required` | Missing `.env` in capability-testing | `cp .env.local .env` in the capability-testing directory |
| Test hangs or times out | Service crashed — check logs | `make tail-logs \| jq 'select(.level == "error")'` |
| Stale feature flags | `flagdata.json` missing your new flag | Update from staging: see command in How It Works above |
| Service returns 404 | Service is in `services_to_ignore.txt` | Remove from ignore list, run `make build` again |
| Port 8080 in use | Previous monorepo session not stopped | `make stop` then `make start` |
| `make replace` has no effect | Forgot `make build` after replace | Always run `make build` after `make replace` |
| Stale binary after code change | Monorepo running old binary | `make stop` → `make build` → `make start` |
