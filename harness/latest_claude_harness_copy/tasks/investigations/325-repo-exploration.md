# Investigation #325: code-review-graph — What Can We Bring In?

**Repo:** https://github.com/tirth8205/code-review-graph
**Date:** 2026-03-23
**Investigator:** b-325-explore

---

## What Is It?

`code-review-graph` is a Claude Code plugin that builds a persistent, incrementally-updated knowledge graph of a codebase using Tree-sitter AST parsing, stored in SQLite. It exposes 9 MCP tools to give Claude precise, minimal context instead of scanning entire files.

**Headline claim:** 6.8x fewer tokens on code reviews (measured on httpx, FastAPI, Next.js). Up to 49x on large monorepos. Quality scores improved from 7.2 → 8.8 average.

---

## Architecture

```
Repository → Tree-sitter Parser → SQLite Graph → Blast Radius → Minimal Context
```

- **Parser:** 14 languages (Python, TypeScript, JS, Vue, Go, Rust, Java, C#, Ruby, Kotlin, Swift, PHP, Solidity, C/C++)
- **Graph:** nodes (File, Class, Function, Type, Test) + edges (CALLS, IMPORTS_FROM, INHERITS, IMPLEMENTS, CONTAINS, TESTED_BY, DEPENDS_ON)
- **Storage:** `.code-review-graph/graph.db` (SQLite WAL mode)
- **Server:** FastMCP stdio transport via `uvx code-review-graph serve`
- **Hooks:** `PostToolUse` on Write/Edit/Bash → `code-review-graph update` (incremental, <2s for 2900-file project)
- **Session hook:** `SessionStart` → checks for graph DB, prints guidance to Claude

---

## The 9 MCP Tools

| Tool | Purpose |
|------|---------|
| `build_or_update_graph` | Full or incremental build |
| `get_impact_radius` | Blast radius from changed files |
| `query_graph` | Predefined queries: callers_of, callees_of, imports_of, importers_of, children_of, tests_for, inheritors_of, file_summary |
| `get_review_context` | Focused subgraph + review prompt (token-efficient) |
| `semantic_search_nodes` | Keyword + optional vector search |
| `list_graph_stats` | Aggregate stats |
| `embed_graph` | Vector embeddings (optional, sentence-transformers) |
| `get_docs_section` | Load specific doc section only (90%+ savings) |
| `find_large_functions` | Find oversized functions/classes by line count |

---

## Skills Provided

Three skills (named `build-graph`, `review-delta`, `review-pr`) are defined but appear to be served dynamically from the MCP server rather than as plain markdown files (they return 404 from raw GitHub URLs). The plugin manifest points `skills` to `./skills/` and they are served at install time.

---

## Hooks Pattern

```json
{
  "PostToolUse": [{
    "matcher": "Write|Edit|Bash",
    "hooks": [{"type": "command", "command": "code-review-graph update 2>/dev/null || true"}]
  }]
}
```
This is a clean pattern: silent incremental update on every file change, never blocking. Aligns with our `inject-timestamp.sh` hook model.

---

## Plugin Manifest

Installed via `claude plugin marketplace add tirth8205/code-review-graph`. Uses `.claude-plugin/plugin.json` with `mcpServers` + `skills` pointer. MIT licensed.

---

## What We Can Bring In

### High Value — Adopt

1. **Install the plugin as-is.**
   The project is large enough (iOS, Android, web, backend submodules) that token savings will be material. The 49x reduction on Next.js-scale monorepos is directly relevant to the consumer-web module.
   - Install: `claude plugin marketplace add tirth8205/code-review-graph && claude plugin install code-review-graph@code-review-graph`
   - Requires: Python 3.10+, `uv`
   - Adds `.code-review-graph/graph.db` to `.gitignore`

2. **`PostToolUse` hook pattern.**
   The pattern of running a fast update silently after every Write/Edit/Bash is worth encoding in `harness/setup/` as a reference for future hooks. We already have `inject-timestamp.sh`; this shows the full `hooks.json` structure clearly.

3. **`SessionStart` hook.**
   The `session-start.sh` pattern — check for DB, print guidance to Claude — is a clean model for any tool that needs conditional session context. We could apply this pattern for other environment checks.

4. **`get_docs_section` lazy-load pattern.**
   Loading only the specific documentation section needed (90%+ savings) directly mirrors our `SKILLS-INDEX.md` lazy-load design. Worth referencing in `harness/SKILLS-INDEX.md` design notes as external validation.

5. **`find_large_functions` tool concept.**
   Automated detection of functions >40 lines aligns with our CODE RULES max-40-lines-per-fn rule. Could be used as a pre-PR check.

6. **`get_impact_radius` for code review context.**
   When Reviewer agents run, seeding them with blast-radius context instead of full file reads would reduce their token spend. The `get_review_context` tool is the right primitive for this.

### Medium Value — Reference

7. **Builtin-call filter list (`_BUILTIN_CALL_NAMES`).**
   The 100+ JS/TS method names filtered from `callers_of` results is a well-curated list. If we ever build our own graph tooling, this is a good starting point for noise reduction.

8. **Security invariants in `CLAUDE.md`.**
   Their security conventions (no `eval`, no `shell=True`, path traversal prevention, `_sanitize_name()` for prompt injection defense) are worth reviewing against our SECURITY section. They're more concrete than ours for Python code.

9. **`get_docs_section` → token-efficient documentation retrieval.**
   The idea of slicing large documentation files into named sections that agents can request individually is a pattern we could apply to `SYSTEM-KNOWLEDGE.md` if it grows large.

### Low Value / Not Applicable

10. **VS Code extension** — we don't use VS Code in agent workflows; not relevant.
11. **Embeddings / vector search** — optional, requires extra deps; skip for now.
12. **CLI commands (watch, visualize)** — nice for human devs but not needed in agent workflows.

---

## Recommended Actions

| Action | Priority | Effort |
|--------|----------|--------|
| Open harness ticket: install code-review-graph plugin + add DB to .gitignore | High | Small |
| Open harness ticket: add PostToolUse hook pattern to harness/setup/ docs | Medium | Small |
| Open harness ticket: update SKILL-pr-review.md to use get_review_context before full file reads | Medium | Small |
| Note in SKILLS-INDEX.md design notes: lazy-load pattern externally validated by code-review-graph get_docs_section | Low | Trivial |

---

## Risks / Caveats

- Python 3.10+ and `uv` required — verify agent machines have these before installing.
- Initial graph build ~10s for 500-file project; will be longer for our monorepo. Run once at session start via skill, not on every spawn.
- The plugin is community-maintained (single author, not JET). Pin to a version; don't auto-update.
- `.code-review-graph/graph.db` is a SQLite binary — must be in `.gitignore` (not committed).
- Token savings are measured on Python/TS repos; Kotlin/Swift coverage is present but less battle-tested.
