#!/usr/bin/env bash
# stop-token-report.sh — Claude Code Stop hook: token/cost report + OTEL push
#
# Parses the JSONL transcript at turn level for accurate per-tool cost attribution:
#   - Each assistant turn has its own token usage + list of tool calls
#   - That turn's cost is split equally across the tools it used
#   - Skill tools are labelled "Skill:<name>" (matches the live PostToolUse hook)
#   - Turns with no tool calls are tracked as unattributed "thinking" cost
#
# Pushes to OTEL:
#   claude_code_session_cost_usd     — total session cost
#   claude_code_tool_cost_usd        — per-tool cost (turn-level attribution)
#   claude_code_tool_calls_total     — per-tool call count (with skill names)
#
# Opt-in: only runs when HARNESS_DEBUG=1
#
# Registration: add to ~/.claude/settings.json under hooks.Stop

set -euo pipefail

if [[ "${HARNESS_DEBUG:-0}" != "1" ]]; then exit 0; fi
if ! command -v jq &>/dev/null; then echo "stop-token-report: jq not found" >&2; exit 0; fi

OTEL_ENDPOINT="${OTEL_EXPORTER_OTLP_ENDPOINT:-http://localhost:4318}"
AGENT_TYPE="${HARNESS_AGENT_TYPE:-lead}"

payload=$(cat)
transcript_path=$(echo "$payload" | jq -r '.transcript_path // empty')
session_id=$(echo "$payload" | jq -r '.session_id // "unknown"')

if [[ -z "$transcript_path" || ! -f "$transcript_path" || ! -s "$transcript_path" ]]; then
  exit 0
fi

# --- Turn-level attribution (accurate) ---
#
# For each assistant turn that contains tool calls:
#   1. Calculate the turn's cost from its usage block
#   2. Extract tool names — for Skill tools, use "Skill:<skill_name>"
#   3. Split the turn's cost equally across the tools in that turn
#
# Turns with no tool calls contribute to "unattributed" cost (pure reasoning/output).
#
# Output: {"Bash": 0.45, "Skill:jet-datadog": 0.12, "_unattributed": 0.03, ...}

per_tool_cost_json=$(jq -s '
  # Pricing per token (USD)
  def price(i; o; cw; cr):
    (i * 3.0 + o * 15.0 + cw * 3.75 + cr * 0.30) / 1000000;

  # Normalise tool name: "Skill" -> "Skill:<name>"
  def tool_label:
    if .type == "tool_use" then
      if .name == "Skill" then "Skill:\(.input.skill // "unknown")"
      else .name
      end
    else empty
    end;

  [.[] | select(.type == "assistant") |
    {
      tools: [.message.content[]? | tool_label],
      cost:  (.message.usage // {} |
               price(
                 (.input_tokens // 0),
                 (.output_tokens // 0),
                 (.cache_creation_input_tokens // 0),
                 (.cache_read_input_tokens // 0)
               ))
    }
  ] |
  reduce .[] as $turn ({};
    if ($turn.tools | length) == 0 then
      .["_unattributed"] += $turn.cost
    else
      ($turn.tools | length) as $n |
      reduce $turn.tools[] as $tool (.;
        .[$tool] += ($turn.cost / $n)
      )
    end
  )
' "$transcript_path" 2>/dev/null || echo '{}')

# --- Session token totals (for the summary report) ---
read -r input_tokens output_tokens cache_write_tokens cache_read_tokens < <(
  jq -s '
    [.[] | select(.type == "assistant") | .message.usage // empty] |
    {
      i:  ([.[].input_tokens                    // 0] | add // 0),
      o:  ([.[].output_tokens                   // 0] | add // 0),
      cw: ([.[].cache_creation_input_tokens     // 0] | add // 0),
      cr: ([.[].cache_read_input_tokens         // 0] | add // 0)
    } | "\(.i) \(.o) \(.cw) \(.cr)"
  ' "$transcript_path" 2>/dev/null || echo "0 0 0 0"
)
input_tokens=${input_tokens:-0}
output_tokens=${output_tokens:-0}
cache_write_tokens=${cache_write_tokens:-0}
cache_read_tokens=${cache_read_tokens:-0}

# --- Tool call counts (with skill names, matching the live hook) ---
tool_calls_json=$(jq -s '
  def tool_label:
    if .type == "tool_use" then
      if .name == "Skill" then "Skill:\(.input.skill // "unknown")"
      else .name
      end
    else empty
    end;
  [.[] | select(.type == "assistant") | .message.content[]? | tool_label]
  | group_by(.) | map({(.[0]): length}) | add // {}
' "$transcript_path" 2>/dev/null || echo '{}')

# --- Costs ---
input_cost=$(echo       "scale=6; $input_tokens       * 3.00  / 1000000" | bc)
output_cost=$(echo      "scale=6; $output_tokens      * 15.00 / 1000000" | bc)
cache_write_cost=$(echo "scale=6; $cache_write_tokens * 3.75  / 1000000" | bc)
cache_read_cost=$(echo  "scale=6; $cache_read_tokens  * 0.30  / 1000000" | bc)
total_cost=$(echo "scale=6; $input_cost + $output_cost + $cache_write_cost + $cache_read_cost" | bc)
total_display=$(printf "%.3f" "$total_cost")

timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# --- Write JSON report ---
report_path="$HOME/.claude/last-token-report.json"
mkdir -p "$(dirname "$report_path")"

jq -n \
  --arg     sid    "$session_id" \
  --arg     atype  "$AGENT_TYPE" \
  --argjson input  "$input_tokens" \
  --argjson output "$output_tokens" \
  --argjson cw     "$cache_write_tokens" \
  --argjson cr     "$cache_read_tokens" \
  --argjson cost   "$total_cost" \
  --argjson tools  "$tool_calls_json" \
  --argjson tcost  "$per_tool_cost_json" \
  --arg     ts     "$timestamp" \
  '{
    session_id:          $sid,
    agent_type:          $atype,
    input_tokens:        $input,
    output_tokens:       $output,
    cache_write_tokens:  $cw,
    cache_read_tokens:   $cr,
    total_cost_usd:      ($cost * 1000000 | round / 1000000),
    tool_calls:          $tools,
    tool_cost_usd:       $tcost,
    timestamp:           $ts
  }' > "$report_path"

# --- Push to OTEL ---
now_ns=$(python3 -c "import time; print(int(time.time() * 1e9))" 2>/dev/null || echo 0)

if [[ "$now_ns" != "0" ]]; then

  # Build OTLP datapoints for per-tool COST
  tool_cost_datapoints=$(echo "$per_tool_cost_json" | jq -r \
    --arg sid   "$session_id" \
    --arg atype "$AGENT_TYPE" \
    --arg ts    "$now_ns" \
    '[to_entries[] | {
      "attributes": [
        {"key": "tool",       "value": {"stringValue": .key}},
        {"key": "session_id", "value": {"stringValue": $sid}},
        {"key": "agent_type", "value": {"stringValue": $atype}}
      ],
      "timeUnixNano": $ts,
      "asDouble": .value
    }]' 2>/dev/null || echo "[]")

  # Build OTLP datapoints for per-tool CALL COUNT
  tool_count_datapoints=$(echo "$tool_calls_json" | jq -r \
    --arg sid   "$session_id" \
    --arg atype "$AGENT_TYPE" \
    --arg ts    "$now_ns" \
    '[to_entries[] | {
      "attributes": [
        {"key": "tool",       "value": {"stringValue": .key}},
        {"key": "session_id", "value": {"stringValue": $sid}},
        {"key": "agent_type", "value": {"stringValue": $atype}}
      ],
      "timeUnixNano": $ts,
      "asDouble": (.value | tonumber)
    }]' 2>/dev/null || echo "[]")

  curl -sf -X POST "${OTEL_ENDPOINT}/v1/metrics" \
    -H "Content-Type: application/json" \
    --connect-timeout 2 --max-time 5 \
    -d "{
      \"resourceMetrics\": [{
        \"resource\": {\"attributes\": [
          {\"key\": \"session.id\", \"value\": {\"stringValue\": \"${session_id}\"}},
          {\"key\": \"agent.type\", \"value\": {\"stringValue\": \"${AGENT_TYPE}\"}}
        ]},
        \"scopeMetrics\": [{
          \"scope\": {\"name\": \"harness.hooks.stop\"},
          \"metrics\": [
            {
              \"name\": \"claude_code_session_cost_usd\",
              \"description\": \"Total session cost in USD (ground truth from transcript)\",
              \"gauge\": {\"dataPoints\": [{
                \"attributes\": [
                  {\"key\": \"session_id\", \"value\": {\"stringValue\": \"${session_id}\"}},
                  {\"key\": \"agent_type\", \"value\": {\"stringValue\": \"${AGENT_TYPE}\"}}
                ],
                \"timeUnixNano\": \"${now_ns}\",
                \"asDouble\": ${total_cost}
              }]}
            },
            {
              \"name\": \"claude_code_tool_cost_usd\",
              \"description\": \"Per-tool cost: each turn cost split across tools in that turn\",
              \"gauge\": {\"dataPoints\": ${tool_cost_datapoints}}
            },
            {
              \"name\": \"claude_code_tool_calls_total\",
              \"description\": \"Per-tool call count (session-end, skill names resolved)\",
              \"gauge\": {\"dataPoints\": ${tool_count_datapoints}}
            }
          ]
        }]
      }]
    }" > /dev/null 2>&1 || true
fi

# --- Human-readable summary ---
fmt()      { printf "%'d" "$1"; }
fmt_cost() { printf "\$%.4f" "$1"; }

# Top tools by attributed cost (exclude _unattributed for the summary line)
tools_by_cost=$(echo "$per_tool_cost_json" | jq -r '
  to_entries
  | map(select(.key != "_unattributed"))
  | sort_by(-.value)
  | map("\(.key) \($ENV.fmt_cost // "")\(.value | . * 10000 | round / 10000)")
  | join(" · ")
' 2>/dev/null || echo "")

unattributed=$(echo "$per_tool_cost_json" | jq -r '.["_unattributed"] // 0' 2>/dev/null || echo 0)
unattributed_display=$(printf "%.4f" "$unattributed")

tool_calls_summary=$(echo "$tool_calls_json" | jq -r '
  to_entries | sort_by(-.value) | map("\(.key) x\(.value)") | join(" · ")
' 2>/dev/null || echo "none")

cat <<REPORT
--- Token Report -----------------------------------------------
  Agent:       ${AGENT_TYPE}
  Input:       $(printf "%10s" "$(fmt "$input_tokens")") tok  ($( printf "\$%.4f" "$input_cost"))
  Output:      $(printf "%10s" "$(fmt "$output_tokens")") tok  ($( printf "\$%.4f" "$output_cost"))
  Cache write: $(printf "%10s" "$(fmt "$cache_write_tokens")") tok  ($( printf "\$%.4f" "$cache_write_cost"))
  Cache read:  $(printf "%10s" "$(fmt "$cache_read_tokens")") tok  ($( printf "\$%.4f" "$cache_read_cost"))
  -------------------------------------------------------------
  Total cost:                ~\$$total_display
  Unattributed (reasoning):  \$$unattributed_display
  Tool calls:  $tool_calls_summary
REPORT

# Per-tool cost breakdown
echo "  Per-tool cost (turn-level attribution):"
echo "$per_tool_cost_json" | jq -r '
  to_entries | sort_by(-.value) |
  .[] | "    \(.key): $\(.value * 10000 | round / 10000 | tostring)"
' 2>/dev/null || true

echo "----------------------------------------------------------------"
