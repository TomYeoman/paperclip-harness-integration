# SKILL: External Document Ingestion

**When to use:** Accessing external documents (Google Slides, Google Docs, Confluence) that are auth-blocked (401 Unauthorized)

## Core Rule
Never retry a 401 in the same session. If a document requires authentication you can't provide, ask the PO **immediately** for an alternative format rather than attempting workarounds.

## Canonical Workflows

### Google Slides (401)
**What happens:** WebFetch returns 401 — you cannot access Google Slides without authentication.

**Workaround:**
1. Ask PO: "I can't access the Google Slides link (it requires sign-in). Please export the slide deck as a PDF and save it to `docs/` in the repo."
2. Once saved, read the PDF using the Read tool with `pages` parameter if needed.

**Why this works:** PDF export gives you the full design intent without needing Google credentials.

---

### Google Docs (401)
**What happens:** WebFetch returns 401 — you cannot access Google Docs without authentication.

**Workaround — pick one (PO chooses):**
1. **Copy-paste raw text:** Ask PO to copy all text content and paste it directly into the chat.
2. **Export as Markdown:** Ask PO to export the doc as a `.md` file and save to `docs/` in the repo.

**Why this works:** Both preserve the content without auth. Markdown export is preferred if the doc has structured headings/lists.

---

### Confluence (Happy Path — MCP accessible)
**What happens:** Confluence is reachable via MCP tool. This is the preferred path.

**Workflow:**
1. Use the MCP Confluence tool to fetch the page directly by page ID or URL.
2. Parse the response — page content is returned as structured text/HTML.
3. Proceed with implementation using the fetched content.

**If MCP fails (rate limit, 401, timeout):** Fall back immediately — see [harness/skills/SKILL-mcp-fallback.md](SKILL-mcp-fallback.md) for the decision tree and message format.

---

### Private Confluence (401 — WebFetch)
**What happens:** WebFetch returns 401 — you cannot access private Confluence pages directly.

**Workaround — pick one (PO chooses):**
1. **Export as PDF:** Ask PO to open the Confluence page → ⋯ menu → Export as PDF → save to `docs/` in repo.
2. **Copy page content:** Ask PO to copy the full page content and paste it directly into the chat.

**Why this works:** Both preserve the full page structure (text + tables + lists) without needing Confluence access.

---

### Other Auth-Blocked Sources
For any other 401 (AWS docs, internal wikis, etc.):
1. Ask PO to export as PDF, Markdown, or plain text.
2. If export is not available, ask PO to copy-paste the relevant content.
3. If the content is sensitive or lengthy, suggest a summary from the PO instead.

---

## Quick Reference Table

| Source | Failure Mode | Canonical Workaround |
|--------|--------------|----------------------|
| Google Slides | 401 Unauthorized | Export as PDF → save to `docs/` |
| Google Docs | 401 Unauthorized | Export as Markdown or copy-paste raw text |
| Confluence (MCP accessible) | N/A — happy path | Use MCP Confluence tool directly; fall back per SKILL-mcp-fallback.md if MCP fails |
| Confluence (private, WebFetch) | 401 Unauthorized | Export as PDF or copy page content |
| Other auth-blocked | 401 Unauthorized | Ask PO for PDF, Markdown, or plain text export |

---

## Implementation Notes

- **Timing:** Ask for the alternative format immediately when you detect 401 — do not try to work around it.
- **Clarity:** Always explain to the PO what you need and why (e.g., "I need PDF format because I can't access Google auth").
- **Delegation:** This is a PO task, not a Builder task. Use SendMessage relay if you're an agent and need to ask the PO.
- **Persistence:** Once you have the alternative format (PDF, markdown, text), save it to `docs/` for future sessions.

---

## Example Dialog

**Bad:** Try WebFetch three times with different prompts hoping one will work.

**Good:**
```
I: Cannot access Google Slides link (401 Unauthorized)
A: PO, please export the slide deck as PDF and save to docs/my-slides.pdf
   Once done, I'll read it and proceed.
```

---

## See Also
- SKILL-live-learning.md — patterns for discovering unknowns
- harness/SYSTEM-KNOWLEDGE.md — which docs exist and where
