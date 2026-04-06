# SKILL: Atlas Context

**Load trigger:** When the task explicitly mentions JETConnect — e.g. "this touches JetConnect", a named JETConnect service, or a cross-service change within the JETConnect ecosystem. Do NOT load for services outside JETConnect; Atlas has no knowledge of them.

---

## What Atlas Is

Atlas is a read-only context engine with a code graph of 200+ **JETConnect** repos. It can answer questions about service relationships, event flows, and cross-repo blast radius that no single-repo analysis can surface.

**Scope limit:** Atlas only has knowledge of JETConnect services. It cannot answer questions about services outside that ecosystem (e.g. consumer-facing apps, internal tooling, this harness repo). Querying Atlas for non-JETConnect context will return empty or hallucinated answers.

**Atlas output is not an exhaustive change set.** It reflects the JETConnect portion of the blast radius only. A change may also impact services, consumers, or integrations outside JETConnect that Atlas has no visibility into. Always treat Atlas findings as a partial picture — use them to inform discovery, not to conclude that the full impact is known.

It is **not** an implementation tool. Claude Code remains the implementation runtime. Atlas feeds context into the discovery phase only.

---

## Calling Atlas

Atlas exposes an OpenAI-compatible chat completions endpoint. Call it directly with Bash — no MCP server required.

**Prerequisite:** Atlas must be running (`cd ~/git/atlas && npm start`). This starts the Go core on port 4802.

### Request

```bash
ATLAS_KEY=$(grep ^ATLAS_API_KEY ~/git/atlas/.env | cut -d= -f2-)
curl -s -X POST http://localhost:4802/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ATLAS_KEY" \
  -d '{
    "model": "atlas-sonnet",
    "stream": false,
    "messages": [{"role": "user", "content": "YOUR QUESTION HERE"}]
  }' | jq -r '.choices[0].message.content'
```

### Model choice

| Task | Model |
|------|-------|
| Standard discovery questions | `atlas-sonnet` |
| Quick lookups (single service/event) | `atlas-haiku` |
| Complex multi-hop reasoning (blast radius across many services) | `atlas-opus` |

---

## Discovery Protocol

Call Atlas in the **DISCOVERY gate** before implementation. Ask in this order:

### 1. Change surface

> "What services, events, handlers, or endpoints are involved in [feature/change]?"

### 2. Impacted consumers

> "What services consume [event/endpoint]? What breaks if I change its contract?"

### 3. Blast radius

> "If I modify [service/event/endpoint], what is the full downstream impact across JETConnect?"

### 4. Confirm handlers

> "What handlers in [service] process [event/request type]? What do they emit?"

Anchor questions to a specific service where possible — it significantly improves answer quality:

> "In the context of menus-utf-connector: what events does it produce and who consumes them?"

---

## Discovery Gate Integration

Include Atlas findings in your `DISCOVERY:` block. The `ATLAS:` field is an **extension field** — valid only when this skill is active (JETConnect tasks). It extends, but does not replace, the canonical DISCOVERY gate from ROLE-BUILDER-CORE.md. Do not include `ATLAS:` in discovery gates for non-JETConnect tasks.

```
DISCOVERY: [TASK-ID]
READ: [files read]
ATLAS: [questions asked + key findings]
UNDERSTAND: [2-3 sentences including cross-repo context]
UNKNOWNS: [list or NONE]
PLAN: [checklist]
R: yes | blocked:[reason]
```

---

## Gotchas

| Symptom | Cause | Fix |
|---------|-------|-----|
| `curl: connection refused` | Atlas not running | `cd ~/git/atlas && npm start` |
| `401 Unauthorized` | Token expired or key missing | Check `atlas/.env` has `ATLAS_API_KEY`; re-run `npm start` to refresh Helix token |
| Empty `ATLAS_KEY` variable | Key not set in `.env` | Add `ATLAS_API_KEY` from 1Password to `atlas/.env` |
| Empty/vague response | Question too broad | Narrow the question or use `atlas-opus` |
| Timeout | Complex multi-hop query | Split into two narrower questions or use `atlas-opus` |
| Irrelevant/hallucinated response | Service is outside JETConnect | Do not use Atlas — it has no knowledge of non-JETConnect repos |
| Silent `401` on valid token | Base64 padding truncated by `cut -d= -f2` | Use `cut -d= -f2-` to preserve trailing padding characters |
