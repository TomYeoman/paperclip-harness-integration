#!/usr/bin/env bash
set -euo pipefail

COMPOSE_FILE="${PAPERCLIP_COMPOSE_FILE:-docker/docker-compose.quickstart.yml}"
ENV_FILE="${PAPERCLIP_COMPOSE_ENV_FILE:-.env}"
SERVICE="${PAPERCLIP_COMPOSE_SERVICE:-paperclip}"
API_BASE="${PAPERCLIP_API_BASE:-http://localhost:3100}"
SEED_SCRIPT_PATH="${PAPERCLIP_SEED_SCRIPT:-harness/scripts/seed-harness-issues.sh}"
BOOTSTRAP_SCRIPT_PATH="${PAPERCLIP_BOOTSTRAP_SCRIPT:-harness/scripts/bootstrap-harness-project-context.sh}"
BOOTSTRAP_CONTEXT="${PAPERCLIP_BOOTSTRAP_CONTEXT:-true}"

if ! command -v docker >/dev/null 2>&1; then
  echo "docker is required" >&2
  exit 1
fi

if [[ ! -f "$COMPOSE_FILE" ]]; then
  echo "Compose file not found: $COMPOSE_FILE" >&2
  exit 1
fi

if [[ ! -f "$SEED_SCRIPT_PATH" ]]; then
  echo "Seed script not found: $SEED_SCRIPT_PATH" >&2
  exit 1
fi

if [[ "$BOOTSTRAP_CONTEXT" == "true" && ! -f "$BOOTSTRAP_SCRIPT_PATH" ]]; then
  echo "Bootstrap script not found: $BOOTSTRAP_SCRIPT_PATH" >&2
  exit 1
fi

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Warning: env file not found ($ENV_FILE). Continuing without it." >&2
fi

COMPOSE_BASE=(docker compose -f "$COMPOSE_FILE")
if [[ -f "$ENV_FILE" ]]; then
  COMPOSE_BASE=(docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE")
fi

running_services="$(${COMPOSE_BASE[@]} ps --status running --services || true)"
service_running=false
while IFS= read -r line; do
  if [[ "$line" == "$SERVICE" ]]; then
    service_running=true
    break
  fi
done <<< "$running_services"

if [[ "$service_running" == "false" ]]; then
  echo "Service '$SERVICE' is not running. Starting it..."
  ${COMPOSE_BASE[@]} up -d "$SERVICE"
fi

exec_env=(-e "PAPERCLIP_API_BASE=$API_BASE")
if [[ -n "${PAPERCLIP_API_KEY:-}" ]]; then
  exec_env+=(-e "PAPERCLIP_API_KEY=$PAPERCLIP_API_KEY")
fi
if [[ -n "${PAPERCLIP_COMPANY_ID:-}" ]]; then
  exec_env+=(-e "PAPERCLIP_COMPANY_ID=$PAPERCLIP_COMPANY_ID")
fi

echo "Running harness issue seeding in container service '$SERVICE'..."
${COMPOSE_BASE[@]} exec -T --user node "${exec_env[@]}" "$SERVICE" sh -lc 'cat >/tmp/seed-harness-issues.sh && chmod +x /tmp/seed-harness-issues.sh && /tmp/seed-harness-issues.sh' < "$SEED_SCRIPT_PATH"

if [[ "$BOOTSTRAP_CONTEXT" == "true" ]]; then
  if [[ -n "${PAPERCLIP_API_KEY:-}" && -n "${PAPERCLIP_COMPANY_ID:-}" ]]; then
    echo "Bootstrapping harness project context in container service '$SERVICE'..."
    ${COMPOSE_BASE[@]} exec -T --user node "${exec_env[@]}" "$SERVICE" sh -lc 'cat >/tmp/bootstrap-harness-project-context.sh && chmod +x /tmp/bootstrap-harness-project-context.sh && /tmp/bootstrap-harness-project-context.sh' < "$BOOTSTRAP_SCRIPT_PATH"
  else
    echo "Skipping context bootstrap: set PAPERCLIP_API_KEY and PAPERCLIP_COMPANY_ID to auto-create project/label mapping." >&2
  fi
fi
