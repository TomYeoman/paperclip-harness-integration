#!/usr/bin/env bash
# post-tool-use.sh — PostToolUse hook
#
# Fires after every Claude Code tool call. Tracks:
#   - Call counts per tool (Skill calls labelled "Skill:<name>")
#   - Response token size (context inflation — large responses blow up prompts)
#   - Skill prompt injection size (SKILL.md bytes → tokens)
#
# Pushes three OTEL metrics:
#   claude_code_tool_calls_total           — cumulative calls per tool
#   claude_code_tool_response_tokens       — cumulative response tokens per tool (context inflation)
#   claude_code_skill_prompt_tokens        — tokens injected per skill invocation (constant per skill)
#   claude_code_skill_cumulative_prompt_tokens — prompt tokens × invocations
#
# No-op if OTEL collector unreachable or dependencies missing.
# Never blocks Claude Code — all failures are silent.

set -euo pipefail

OTEL_ENDPOINT="${OTEL_EXPORTER_OTLP_ENDPOINT:-http://localhost:4318}"
AGENT_TYPE="${HARNESS_AGENT_TYPE:-lead}"
STATE_FILE="${HOME}/.claude/tool-counts.json"

if ! command -v jq &>/dev/null || ! command -v python3 &>/dev/null; then exit 0; fi

payload=$(cat)
tool_name=$(echo "$payload" | jq -r '.tool_name // "unknown"')
session_id=$(echo "$payload" | jq -r '.session_id // "unknown"')

# --- Skill: resolve name + measure prompt injection size ---
skill_name=""
skill_prompt_tokens=0
if [[ "$tool_name" == "Skill" ]]; then
  skill_name=$(echo "$payload" | jq -r '.tool_input.skill // empty')
  if [[ -n "$skill_name" ]]; then
    tool_name="Skill:${skill_name}"
    for search_base in "$PWD" "$HOME"; do
      for skill_subdir in ".claude/skills" ".agents/skills"; do
        skill_file="${search_base}/${skill_subdir}/${skill_name}/SKILL.md"
        if [[ -f "$skill_file" ]]; then
          bytes=$(wc -c < "$skill_file" 2>/dev/null || echo 0)
          skill_prompt_tokens=$(( bytes / 4 ))
          break 2
        fi
      done
    done
  fi
fi

# --- Measure response size (context inflation) ---
response_tokens=$(echo "$payload" | jq -r '(.tool_response // "") | tostring | length' 2>/dev/null || echo 0)
response_tokens=$(( response_tokens / 4 ))

# --- Update state file (cumulative counts per session+tool) ---
[[ -f "$STATE_FILE" ]] || echo '{}' > "$STATE_FILE"

current_calls=$(jq -r --arg s "$session_id" --arg t "$tool_name" '.[$s][$t] // 0' "$STATE_FILE" 2>/dev/null || echo 0)
current_resp=$(jq -r  --arg s "$session_id" --arg t "${tool_name}_resp" '.[$s][$t] // 0' "$STATE_FILE" 2>/dev/null || echo 0)

new_calls=$(( current_calls + 1 ))
new_resp_tokens=$(( current_resp + response_tokens ))

tmp=$(mktemp)
jq --arg s "$session_id" \
   --arg t  "$tool_name" --argjson c "$new_calls" \
   --arg tr "${tool_name}_resp" --argjson r "$new_resp_tokens" \
   '.[$s][$t] = $c | .[$s][$tr] = $r' "$STATE_FILE" > "$tmp" && mv "$tmp" "$STATE_FILE"

# --- Push to OTEL via Python (clean JSON, no bash string escaping) ---
python3 - <<PYEOF
import json, urllib.request, urllib.error, time, os, sys

endpoint = "${OTEL_ENDPOINT}/v1/metrics"
now_ns   = str(int(time.time() * 1e9))
sid      = "${session_id}"
atype    = "${AGENT_TYPE}"
tool     = "${tool_name}"
skill    = "${skill_name}"
calls    = ${new_calls}
resp_tok = ${new_resp_tokens}
s_prompt = ${skill_prompt_tokens}
s_cumul  = s_prompt * calls if s_prompt > 0 else 0

def dp(attrs_extra, value):
    return {
        "attributes": [
            {"key": "session_id", "value": {"stringValue": sid}},
            {"key": "agent_type", "value": {"stringValue": atype}},
        ] + [{"key": k, "value": {"stringValue": str(v)}} for k, v in attrs_extra.items()],
        "timeUnixNano": now_ns,
        "asDouble": float(value)
    }

def gauge(name, desc, datapoints):
    return {"name": name, "description": desc, "gauge": {"dataPoints": datapoints}}

metrics = [
    gauge("claude_code_tool_calls_total",
          "Cumulative tool calls this session",
          [dp({"tool": tool}, calls)]),
    gauge("claude_code_tool_response_tokens",
          "Cumulative approx tokens returned by this tool (context inflation)",
          [dp({"tool": tool}, resp_tok)]),
]

if s_prompt > 0:
    metrics += [
        gauge("claude_code_skill_prompt_tokens",
              "Approx tokens injected per skill invocation (SKILL.md size / 4)",
              [dp({"skill": skill}, s_prompt)]),
        gauge("claude_code_skill_cumulative_prompt_tokens",
              "Total prompt tokens injected by this skill this session",
              [dp({"skill": skill}, s_cumul)]),
    ]

body = json.dumps({"resourceMetrics": [{"resource": {"attributes": [
    {"key": "session.id", "value": {"stringValue": sid}},
    {"key": "agent.type", "value": {"stringValue": atype}},
]}, "scopeMetrics": [{"scope": {"name": "harness.hooks"}, "metrics": metrics}]}]}).encode()

try:
    req = urllib.request.Request(endpoint, data=body,
          headers={"Content-Type": "application/json"}, method="POST")
    urllib.request.urlopen(req, timeout=2)
except Exception:
    pass  # Never block Claude Code
PYEOF
