# Skill: MCP Rate Limit Fallback

Load this skill when: Figma, Confluence, or Jira MCP hits a rate limit, 401 auth error, timeout, or other transient failure.

## Trigger Criteria

Any of these indicate a fallback is needed:
- MCP rate limit error (HTTP 429 or "rate limit exceeded" message)
- Authentication failure (401 Unauthorized)
- Connection timeout (socket timeout, connect timeout)
- Persistent MCP service unavailability (500/503 after single retry)
- Other MCP errors after one retry attempt

**DO NOT:**
- Retry the same MCP call multiple times in the same session
- Wait hoping the error resolves
- Attempt workarounds that consume more tokens
- Continue implementation blocked on the MCP call

## Decision Tree

```
MCP error occurs
└─ Is it a 401 (auth error)?
   ├─ YES → ask PO for alternative format
   │        (screenshot, PDF export, raw text copy)
   │        B: to Lead with request
   │
   └─ NO → Is it a rate limit (429)?
      ├─ YES → B: to Lead immediately
      │        "MCP rate limit hit, falling back to [alternative]"
      │
      └─ NO → Is it a timeout or transient error?
         ├─ YES → Single retry, then B: if still fails
         │
         └─ NO → B: to Lead with error details
```

## Fallback Paths (In Priority Order)

### 1. Ask PO for Screenshot
**When:** Design reference needed from Figma, small visual element
**How:**
- Message Lead: ask PO for screenshot of Figma node [nodeId]
- Describe what you need: "color palette from components page" or "button state variants"
- PO can screenshot Figma directly and paste into Claude Code agent tab

### 2. Request PDF Export
**When:** Multi-page design doc or comprehensive design specification
**How:**
- Message Lead: ask PO to export Figma page/file as PDF
- PO saves PDF → uploads to local repo at `docs/exports/[name].pdf`
- Builder reads PDF with Read tool (supports PDF viewing)

### 3. Request Raw Text/Markdown Copy
**When:** Confluence page or specification document
**How:**
- Message Lead: ask PO to copy page content as markdown or plain text
- PO uses Confluence "Export" → select "Word" or copy markdown manually
- Paste into a new markdown file in `docs/temp-exports/[name].md` in repo
- Builder reads the file

### 4. Manual Reconstruction from Specs
**When:** Design details are simple, described in ticket/spec
**How:**
- Read the ticket, ADR, or spec carefully
- Reconstruct layout/colors from written description
- Use existing design tokens or component library as reference
- Build without MCP reference

## Message Format for Fallback

Send B: to Lead with this format:

```
B: MCP fallback needed — [service]
MCP_ERROR: [429 rate limit | 401 auth | timeout | other: ...]
WHAT_NEEDED: [screenshot | PDF export | raw text copy | manual reconstruction]
DESCRIPTION: [specific design element or doc section needed]
IMPACT: [blocks my implementation of feature X | pauses design review]
FALLBACK_CHOICE: [which alternative is best for PO]
```

Example:
```
B: MCP fallback needed — Figma
MCP_ERROR: 429 rate limit (quota exceeded for file pqrs)
WHAT_NEEDED: screenshot
DESCRIPTION: Button component variants (hover, active, disabled states) from node 123:456
IMPACT: blocks ButtonComponent implementation, need design reference to match redlines
FALLBACK_CHOICE: PO screenshot of node 123:456 in Figma
```

## Anti-Patterns

- **Retry loop**: Do NOT attempt the same MCP call 3+ times. One retry max.
- **Token drain**: Do NOT keep parsing MCP errors and retrying — fallback after first failure.
- **Stall without escalation**: Do NOT sit and wait for MCP to recover. B: immediately.
- **Guessing at design**: Do NOT implement UI without design reference just because MCP failed. Ask for fallback.
- **Delaying escalation**: Do NOT try multiple fallbacks on your own. Tell Lead what you need, let Lead + PO coordinate.

## After Fallback Accepted

1. Lead coordinates with PO to provide alternative (screenshot, PDF, text, etc.)
2. Builder receives alternative in agent tab or committed to repo
3. Builder proceeds with implementation using fallback reference
4. If design details remain ambiguous, ask clarifying questions in follow-up message to Lead
5. Implement implementation as usual, reference the fallback artifact in DONE message: "Design reference: docs/exports/[name].[ext]"

## Rate Limit Prevention

- Query only what you need (don't fetch full file metadata if you only need one node)
- Reuse screenshots/exports across multiple references when possible
- Check harness/SYSTEM-KNOWLEDGE.md for existing exports or known workarounds (e.g., Code Connect warnings)
- Batch MCP reads: if you need 3 nodes, request all 3 upfront rather than one-by-one
