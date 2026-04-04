#!/usr/bin/env bash
set -euo pipefail

if ! command -v pnpm >/dev/null 2>&1; then
  echo "pnpm is required" >&2
  exit 1
fi

: "${PAPERCLIP_API_BASE:?Set PAPERCLIP_API_BASE (example: http://localhost:3100)}"

AUTH_ARGS=(--api-base "$PAPERCLIP_API_BASE")
if [[ -n "${PAPERCLIP_API_KEY:-}" ]]; then
  AUTH_ARGS+=(--api-key "$PAPERCLIP_API_KEY")
fi

resolve_company_id() {
  if [[ -n "${PAPERCLIP_COMPANY_ID:-}" ]]; then
    echo "$PAPERCLIP_COMPANY_ID"
    return 0
  fi

  local output
  if ! output="$(pnpm paperclipai company list "${AUTH_ARGS[@]}" --json 2>/tmp/paperclip-seed-company-list.err)"; then
    echo "Failed to list companies." >&2
    echo "If using board auth, run: pnpm paperclipai auth login --api-base $PAPERCLIP_API_BASE" >&2
    echo "Or set PAPERCLIP_API_KEY to an agent key with issue create permissions." >&2
    echo "Details:" >&2
    cat /tmp/paperclip-seed-company-list.err >&2 || true
    exit 1
  fi

  local id
  id="$(printf '%s' "$output" | node -e '
const fs = require("fs");
const raw = fs.readFileSync(0, "utf8");
const data = JSON.parse(raw);
const list = Array.isArray(data) ? data : Array.isArray(data.companies) ? data.companies : [];
if (list.length === 1 && list[0] && list[0].id) process.stdout.write(list[0].id);
')"

  if [[ -z "$id" ]]; then
    echo "Could not auto-resolve PAPERCLIP_COMPANY_ID." >&2
    echo "Set PAPERCLIP_COMPANY_ID explicitly." >&2
    exit 1
  fi

  echo "$id"
}

PAPERCLIP_COMPANY_ID="$(resolve_company_id)"

json_id() {
  node -e 'const fs=require("fs");const raw=fs.readFileSync(0,"utf8");const o=JSON.parse(raw);process.stdout.write(o.id || (o.issue && o.issue.id) || "")'
}

create_issue() {
  local title="$1"
  local description="$2"
  local priority="$3"
  local parent_id="${4:-}"
  local project_id="${PAPERCLIP_PROJECT_ID:-}"

  local description_with_context
  description_with_context="${description}

## Harness Execution Context
- Workstream: harness
- Execution target: repository code in ${HARNESS_WORKSPACE_CWD:-/workspace}
- Primary references: harness/discovery.md, harness/harness.md
- Runtime note: this Paperclip instance is configured with a bind-mounted workspace at ${HARNESS_WORKSPACE_CWD:-/workspace}"

  local cmd=(
    pnpm --silent paperclipai issue create
    -C "$PAPERCLIP_COMPANY_ID"
    --title "$title"
    --description "$description_with_context"
    --status todo
    --priority "$priority"
    "${AUTH_ARGS[@]}"
    --json
  )

  if [[ -n "$project_id" ]]; then
    cmd+=(--project-id "$project_id")
  fi

  if [[ -n "$parent_id" ]]; then
    cmd+=(--parent-id "$parent_id")
  fi

  local output
  output="$("${cmd[@]}")"

  local id
  id="$(printf '%s' "$output" | json_id)"

  if [[ -z "$id" ]]; then
    echo "Failed to parse issue id for: $title" >&2
    echo "$output" >&2
    exit 1
  fi

  echo "$id"
}

echo "Creating parent issue..."
PARENT_ID="$(create_issue \
  "HARNESS: Paperclip-native orchestration migration" \
  "Migrate harness orchestration to Paperclip-native primitives (issues, checkout, comments, approvals, routines) with runtime overlays for claude_local/codex_local/opencode_local." \
  "high")"
echo "Parent: $PARENT_ID"

create_child() {
  local title="$1"
  local desc="$2"
  local prio="$3"
  local id
  id="$(create_issue "$title" "$desc" "$prio" "$PARENT_ID")"
  echo "Child:  $id  $title"
}

echo "Creating child issues..."
create_child \
  "HARNESS: Define runtime-agnostic core contract" \
  "Create the core harness contract used across claude_local, codex_local, and opencode_local. Include discovery/verification gates and merge ownership rules." \
  "high"

create_child \
  "HARNESS: Define role contracts (Lead/Architect/Builder/Reviewer/Tester/Auditor)" \
  "Write role contracts with strict scope boundaries, escalation triggers, and non-negotiable behavioral rules." \
  "high"

create_child \
  "HARNESS: Define protocol + spec-driven + TDD standards" \
  "Publish communication protocol, spec chain policy, and TDD standards aligned with Paperclip issue workflow." \
  "high"

create_child \
  "HARNESS: Add adapter overlays for claude_local/codex_local/opencode_local" \
  "Document adapter-specific runtime nuances (auth, instructions path, cwd/trust checks, diagnostics) while preserving shared governance." \
  "high"

create_child \
  "HARNESS: Establish Paperclip issue lifecycle for harness execution" \
  "Define canonical issue states, assignment policies, reviewer handoff, and PR URL traceability comments." \
  "high"

create_child \
  "HARNESS: Seed launch/session artifacts" \
  "Create launch script, build journal, and lessons starter artifacts for repeatable session handoffs." \
  "medium"

create_child \
  "HARNESS: Run pilot milestone with Lead/Builder/Reviewer" \
  "Execute one full workflow from issue assignment to merged PR and capture lessons for harness refinement." \
  "high"

create_child \
  "HARNESS: Expand to Architect/Tester/Auditor and routines" \
  "Add forward-design, acceptance testing, auditing, and routine-driven cadence after pilot stabilization." \
  "medium"

echo "Done."
