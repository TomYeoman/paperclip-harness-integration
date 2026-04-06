#!/usr/bin/env bash
# otel-start.sh — start local OTEL stack (idempotent)
# Usage: bash harness/otel/otel-start.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check Docker is available and running
if ! command -v docker &>/dev/null; then
  echo "otel-start: docker not found — skipping" >&2
  exit 0
fi

if ! docker info &>/dev/null 2>&1; then
  echo "otel-start: Docker not running (try: colima start) — skipping" >&2
  exit 0
fi

# Start stack (docker compose up -d is idempotent — no-ops if already running)
cd "$SCRIPT_DIR"
docker compose up -d --quiet-pull 2>&1 | grep -v "^$" || true

echo "📊 OTEL stack running — Grafana: http://localhost:4000"
