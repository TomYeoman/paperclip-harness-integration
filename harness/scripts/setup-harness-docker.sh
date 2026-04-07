#!/usr/bin/env bash
set -euo pipefail

# One-command harness bootstrap for Docker deployments.
# Runs (in order):
# 1) project + hello-world issue bootstrap
# 2) optional parity test-project fixture bootstrap
# 3) agent role configuration
# 4) optional GitHub integration preflight

if ! command -v docker >/dev/null 2>&1; then
  echo "docker is required" >&2
  exit 1
fi

if [[ ! -f "harness/scripts/bootstrap-harness-project-context.sh" ]]; then
  echo "Missing harness/scripts/bootstrap-harness-project-context.sh" >&2
  exit 1
fi
if [[ ! -f "harness/scripts/setup-harness-agent-configs.sh" ]]; then
  echo "Missing harness/scripts/setup-harness-agent-configs.sh" >&2
  exit 1
fi
if [[ ! -f "harness/scripts/bootstrap-harness-parity-fixtures.sh" ]]; then
  echo "Missing harness/scripts/bootstrap-harness-parity-fixtures.sh" >&2
  exit 1
fi
if [[ ! -f "harness/scripts/setup-harness-github.sh" ]]; then
  echo "Missing harness/scripts/setup-harness-github.sh" >&2
  exit 1
fi

: "${PAPERCLIP_API_KEY:?Set PAPERCLIP_API_KEY (board token)}"
: "${PAPERCLIP_COMPANY_ID:?Set PAPERCLIP_COMPANY_ID}"

API_BASE="${PAPERCLIP_API_BASE:-http://localhost:3100}"
SERVICE="${PAPERCLIP_COMPOSE_SERVICE:-paperclip}"
COMPOSE_ENV_FILE="${PAPERCLIP_COMPOSE_ENV_FILE:-.env}"
COMPOSE_FILES_RAW="${PAPERCLIP_COMPOSE_FILES:-}"

if [[ -z "$COMPOSE_FILES_RAW" ]]; then
  if [[ -f "docker/docker-compose.workspace.yml" ]]; then
    COMPOSE_FILES_RAW="docker/docker-compose.quickstart.yml,docker/docker-compose.workspace.yml"
  else
    COMPOSE_FILES_RAW="docker/docker-compose.quickstart.yml"
  fi
fi

IFS=',' read -r -a compose_files <<< "$COMPOSE_FILES_RAW"

compose_cmd=(docker compose)
if [[ -f "$COMPOSE_ENV_FILE" ]]; then
  compose_cmd+=(--env-file "$COMPOSE_ENV_FILE")
fi
for file in "${compose_files[@]}"; do
  trimmed="${file## }"
  trimmed="${trimmed%% }"
  if [[ ! -f "$trimmed" ]]; then
    echo "Compose file not found: $trimmed" >&2
    exit 1
  fi
  compose_cmd+=(-f "$trimmed")
done

run_context="${HARNESS_RUN_CONTEXT_BOOTSTRAP:-true}"
run_parity_fixtures="${HARNESS_RUN_PARITY_FIXTURES_SETUP:-false}"
run_agents="${HARNESS_RUN_AGENT_SETUP:-true}"
run_github="${HARNESS_RUN_GITHUB_SETUP:-false}"

running_services="$(${compose_cmd[@]} ps --status running --services || true)"
service_running=false
while IFS= read -r line; do
  if [[ "$line" == "$SERVICE" ]]; then
    service_running=true
    break
  fi
done <<< "$running_services"

if [[ "$service_running" == "false" ]]; then
  echo "Service '$SERVICE' is not running. Starting it..."
  ${compose_cmd[@]} up -d "$SERVICE"
fi

exec_env=(
  -e "PAPERCLIP_API_BASE=$API_BASE"
  -e "PAPERCLIP_API_KEY=$PAPERCLIP_API_KEY"
  -e "PAPERCLIP_COMPANY_ID=$PAPERCLIP_COMPANY_ID"
)

optional_envs=(
  PAPERCLIP_PROJECT_ID
  HARNESS_WORKSPACE_CWD
  HARNESS_PROJECT_NAME
  HARNESS_LABEL_NAME
  HARNESS_LABEL_COLOR
  HARNESS_HELLO_ISSUE_TITLE
  HARNESS_FIXTURE_PROJECT_NAME
  HARNESS_FIXTURE_PROJECT_DESCRIPTION
  HARNESS_FIXTURE_LABEL_NAME
  HARNESS_FIXTURE_LABEL_COLOR
  HARNESS_FIXTURE_WORKSPACE_CWD
  HARNESS_FIXTURE_INCLUDE_ISSUES
  HARNESS_FIXTURE_RESET_STATE
  HARNESS_ROLE_SET
  HARNESS_ADAPTER_TYPE
  HARNESS_MODEL
  HARNESS_GH_CONFIG_DIR
  HARNESS_CONFIGURE_CEO
  HARNESS_CEO_INSTRUCTIONS_PATH
  HARNESS_BUILDER_NAME
  HARNESS_REVIEWER_NAME
  HARNESS_TESTER_NAME
  HARNESS_ARCHITECT_NAME
  HARNESS_AUDITOR_NAME
  HARNESS_PM_NAME
  HARNESS_QE_NAME
  HARNESS_CONTRACT_TESTER_NAME
  HARNESS_INTEGRATION_TESTER_NAME
  HARNESS_SECURITY_RESEARCHER_NAME
  HARNESS_SECURITY_REVIEWER_NAME
  HARNESS_GIT_DIR
  HARNESS_GITHUB_REMOTE
  HARNESS_GITHUB_REPO
  HARNESS_BASE_BRANCH
)

for key in "${optional_envs[@]}"; do
  if [[ -n "${!key:-}" ]]; then
    exec_env+=(-e "$key=${!key}")
  fi
done

run_script() {
  local local_path="$1"
  local temp_name="$2"
  echo "Running $local_path..."
  ${compose_cmd[@]} exec -T --user node "${exec_env[@]}" "$SERVICE" \
    sh -lc "cat >/tmp/$temp_name && chmod +x /tmp/$temp_name && /tmp/$temp_name" < "$local_path"
}

if [[ "$run_context" == "true" ]]; then
  run_script "harness/scripts/bootstrap-harness-project-context.sh" "bootstrap-harness-project-context.sh"
fi

if [[ "$run_parity_fixtures" == "true" ]]; then
  run_script "harness/scripts/bootstrap-harness-parity-fixtures.sh" "bootstrap-harness-parity-fixtures.sh"
fi

if [[ "$run_agents" == "true" ]]; then
  run_script "harness/scripts/setup-harness-agent-configs.sh" "setup-harness-agent-configs.sh"
fi

if [[ "$run_github" == "true" ]]; then
  run_script "harness/scripts/setup-harness-github.sh" "setup-harness-github.sh"
fi

echo "Harness setup complete."
