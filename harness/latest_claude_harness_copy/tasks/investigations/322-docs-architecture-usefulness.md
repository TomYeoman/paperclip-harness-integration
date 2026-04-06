# Investigation: docs/architecture usefulness for agents (#322)

**Date:** 2026-03-23
**Scope:** All files in `docs/architecture/`
**Method:** Compared each file's content against CLAUDE.md, harness role files, and SYSTEM-KNOWLEDGE.md to determine overlap and unique value.

---

## Files Assessed

### 1. README.md
**Label:** HUMAN REFERENCE ONLY
**Content:** Index of the architecture directory.
**Overlap with agent sources:** None — it is a table of contents for the docs/architecture directory itself.
**Unique value to agents:** None. The index is only useful if agents were reading the other docs, which they are not.
**Verdict:** Keep excluded. No value to agents; useful for human onboarding only.

---

### 2. AGENT-ROLES.md
**Label:** HUMAN REFERENCE ONLY
**Content:** Role definitions (Lead, PM, Architect, Builder, Reviewer, Tester, Auditor) with model choices, capabilities, and constraints. Includes a Mermaid diagram.
**Overlap with agent sources:**
- Fully duplicated across `harness/roles/ROLE-*.md` files — the actual authoritative source loaded into every agent's spawn prompt.
- CLAUDE.md `AGENT TEAM` section covers the same role table and model choices.
**Unique value to agents:** None. Agents load their own role file plus CLAUDE.md. The narrative in AGENT-ROLES.md is a human-readable expansion of what is already operationally present.
**Verdict:** Keep excluded. Fully redundant with role files.

---

### 3. CODEBASE-MAP.md
**Label:** None (no HUMAN REFERENCE ONLY banner)
**Content:** Practical repo navigation guide — iOS module structure, backend on-demand clone strategy, cross-repo workflow, submodule paths.
**Overlap with agent sources:** Partial. CLAUDE.md covers architecture rules and branch conventions but not concrete repo paths, module structures, or the iOS snapshot regeneration protocol.
**Unique value to agents:** HIGH. This file contains information agents genuinely lack:
- iOS snapshot regeneration protocol (when to delete `__Snapshots__`, how to regenerate)
- Backend on-demand clone strategy and discovery checklist
- Cross-repo multi-builder spawning pattern
- Concrete repo paths: `ios/Modules/`, `consumer-web/`, `backend/[service-name]/`
- Warning: iOS repo is ~30GB — unscoped searches cause timeouts

**Important:** This file has NO "HUMAN REFERENCE ONLY" banner, unlike the others. It is already intended to be agent-readable.
**Verdict:** INCLUDE. Already in-scope for agents by omission of the exclusion label. Verify it is actually loaded in agent contexts — if not, add it to session start checklist or SYSTEM-KNOWLEDGE.md pointers.

---

### 4. SESSION-LIFECYCLE.md
**Label:** HUMAN REFERENCE ONLY
**Content:** Session start checklist, Mermaid sequence diagrams of the feature session flow and PM pairing flow, shutdown sequence with 6 mandatory deliverables.
**Overlap with agent sources:**
- Session start checklist is identical to CLAUDE.md `SESSION START` section (10 steps verbatim).
- Shutdown deliverables are covered in CLAUDE.md `SESSION END` section and `SKILL-session-shutdown.md`.
- Sequence diagrams are visual expansions of communication patterns already in CLAUDE.md.
**Unique value to agents:** Minimal. The session-length guidance (cap at 3 hours, write handoff notes at 2 hours) is not in CLAUDE.md but is low-stakes.
**Verdict:** Keep excluded. Largely duplicates CLAUDE.md. The one unique datum (session length cap) could be added to ROLE-LEAD.md if needed.

---

### 5. COMMUNICATION-DSL.md
**Label:** HUMAN REFERENCE ONLY
**Content:** DSL prefix table, agent Q&A relay pattern, SendMessage usage rules, dashboard format, PR lifecycle with Mermaid diagram, anti-patterns table.
**Overlap with agent sources:**
- DSL prefix table is in CLAUDE.md `COMMUNICATION DSL` section verbatim.
- SendMessage rules are in CLAUDE.md and reinforced by memory feedback entries.
- Dashboard format is in `ROLE-LEAD.md`.
- PR lifecycle is in `ROLE-BUILDER-CORE.md`.
**Unique value to agents:** Minimal. The anti-patterns table is slightly more detailed than CLAUDE.md but all anti-patterns are already encoded in role files and NON-NEGOTIABLE blocks.
**Verdict:** Keep excluded. Fully redundant with CLAUDE.md + role files.

---

### 6. WORKTREE-MODEL.md
**Label:** HUMAN REFERENCE ONLY
**Content:** Why worktrees exist, critical rule (outside repo tree), worktree creation commands, agent safety verification steps, banned git commands, push-before-D: rule, session-end cleanup, contamination symptoms and recovery.
**Overlap with agent sources:**
- Worktree safety rules are in `ROLE-BUILDER-CORE.md` (banned commands, push before D:).
- Outside-repo-tree rule is referenced in CLAUDE.md `DISPATCH` and `AGENT TEAM` sections.
**Unique value to agents:** MODERATE. The contamination symptoms and recovery section is not in any role file. The concrete `git worktree add` command syntax is useful for Lead (who creates worktrees). The agent safety verification steps (run `pwd` then `git rev-parse --show-toplevel` as SEPARATE bash calls) are in ROLE-BUILDER-CORE.md but repeated here more explicitly.
**Verdict:** Selectively useful — the contamination/recovery section and the `git -C` usage guidance should move to `harness/SYSTEM-KNOWLEDGE.md` or a skill file. The bulk of the content is already in role files. Keep excluded but file follow-on to migrate the two unique sections.

---

### 7. MILESTONE-WORKFLOW.md
**Label:** HUMAN REFERENCE ONLY
**Content:** Spec chain, role responsibilities in the spec chain, milestone structure format, 6 completion gates, Architect continuity rule, DISCOVERY gate format, VERIFICATION gate format, PRD-ADR linkage, fakes over mocks.
**Overlap with agent sources:**
- Spec chain, DISCOVERY gate, and VERIFICATION gate are verbatim in CLAUDE.md `SPEC CHAIN + TDD` section and `ROLE-BUILDER-CORE.md`.
- Fakes over mocks is in CLAUDE.md and `harness/TDD-STANDARDS.md`.
- 6 completion gates are in `tasks/MILESTONES.md` format.
**Unique value to agents:** LOW. Architect continuity rule ("always running 2 milestones ahead") is in `ROLE-LEAD.md`. PRD-ADR linkage is low-use.
**Verdict:** Keep excluded. Fully duplicated. The Architect continuity rule is the one useful datum but already in ROLE-LEAD.md.

---

### 8. LEARNING-SYSTEM.md
**Label:** HUMAN REFERENCE ONLY
**Content:** Why verbal corrections don't stick (Lost in the Middle), enforcement hierarchy (tool-level deny → spawn prompt → CLAUDE.md → etc.), L: event 4-step process with format, NON-NEGOTIABLE block pattern, memory system description, automatic reflection triggers, verify-before-encoding rule.
**Overlap with agent sources:**
- L: event and 4-step process are in CLAUDE.md `COMMUNICATION DSL`.
- `remember:` command lifecycle is in ROLE-LEAD.md.
- NON-NEGOTIABLE block is in every role file.
**Unique value to agents:** MODERATE for Lead specifically. The enforcement hierarchy (tool-level deny is most reliable; verbal correction is least reliable) provides actionable reasoning for HOW to encode lessons — not just that lessons should be encoded. The "verify before encoding" rule is not in any role file.
**Verdict:** Selective inclusion. The enforcement hierarchy table and "verify before encoding" section are genuinely useful for Lead when doing L: processing. Consider moving those two sections into `ROLE-LEAD.md`. Keep excluded as a standalone doc.

---

### 9. STATE-SCHEMA.md
**Label:** None (no HUMAN REFERENCE ONLY banner)
**Content:** Full schema for `tasks/state.json` — field definitions, valid status values, JSON examples for each entry type, how Builders update state.json on D:, how Lead reads it at session start.
**Overlap with agent sources:** Not present in CLAUDE.md or any role file.
**Unique value to agents:** HIGH. This is operational protocol that both Lead and Builders need:
- Builders must update state.json on D: (5 specific steps)
- Lead reads state.json at session start (not MILESTONES.md)
- Valid status values and their meanings
- JSON structure for worktrees, PRs, and blocked issues

**Important:** This file also has NO "HUMAN REFERENCE ONLY" banner — already intended as agent-readable.
**Verdict:** INCLUDE explicitly. Add to session start checklist and Builder VERIFICATION gate. Confirm it is loaded or referenced in agent spawns.

---

### 10. ios-codebase-map.md
**Label:** None (no HUMAN REFERENCE ONLY banner)
**Content:** iOS repo navigation guide — scoping instructions, placeholder module map, high-level structure, instruction to add rows incrementally.
**Overlap with agent sources:** CODEBASE-MAP.md covers the same iOS high-level structure.
**Unique value to agents:** MODERATE. The explicit "never run unscoped searches across ios/Modules/" warning is high-value for any iOS builder. The placeholder state means there is no specific module routing yet (pending Ben Sullivan / iOS community input). But the scoping discipline instruction is still useful even without the full table.
**Verdict:** INCLUDE for iOS builders. Already no exclusion label. Should be explicitly referenced in `ROLE-BUILDER-IOS.md` load instructions.

---

## Summary Table

| File | Excluded? | Unique value | Verdict |
|------|-----------|--------------|---------|
| README.md | Yes | None | Keep excluded |
| AGENT-ROLES.md | Yes | None | Keep excluded |
| CODEBASE-MAP.md | **No** | High | Already agent-readable — verify it is actively loaded |
| SESSION-LIFECYCLE.md | Yes | Low | Keep excluded |
| COMMUNICATION-DSL.md | Yes | Low | Keep excluded |
| WORKTREE-MODEL.md | Yes | Moderate (2 sections) | Keep excluded; migrate contamination+recovery to SYSTEM-KNOWLEDGE.md |
| MILESTONE-WORKFLOW.md | Yes | Low | Keep excluded |
| LEARNING-SYSTEM.md | Yes | Moderate (2 sections) | Keep excluded; migrate enforcement hierarchy + verify-before-encoding to ROLE-LEAD.md |
| STATE-SCHEMA.md | **No** | High | Already agent-readable — add explicit reference in session start checklist and ROLE-BUILDER-CORE.md |
| ios-codebase-map.md | **No** | Moderate | Already agent-readable — add reference in ROLE-BUILDER-IOS.md |

---

## Recommendation

**Keep the HUMAN REFERENCE ONLY label for 7 of 10 files.** Those files duplicate content already present in CLAUDE.md or role files. Including them would add token cost without adding behavioral value — agents already have the authoritative source.

**The 3 files without the label are already correctly classified as agent-readable:**
- `CODEBASE-MAP.md` — practical repo navigation with unique protocols
- `STATE-SCHEMA.md` — operational schema agents must follow
- `ios-codebase-map.md` — iOS scoping discipline

**The main gap is not the exclusion policy — it is that the 3 already-included files may not be actively referenced in spawn prompts or skill load triggers.**

---

## Follow-on Tickets

### Ticket A: Verify CODEBASE-MAP.md and STATE-SCHEMA.md are reachable from agent contexts
- Check session start checklist (CLAUDE.md) — neither file is listed
- Add `STATE-SCHEMA.md` reference to `ROLE-BUILDER-CORE.md` VERIFICATION gate (step: update state.json per STATE-SCHEMA.md)
- Add `ios-codebase-map.md` reference to `ROLE-BUILDER-IOS.md` load instructions

### Ticket B: Migrate unique sections from excluded docs to authoritative agent files
- WORKTREE-MODEL.md: move contamination symptoms + recovery to `harness/SYSTEM-KNOWLEDGE.md`
- LEARNING-SYSTEM.md: move enforcement hierarchy table + verify-before-encoding rule to `ROLE-LEAD.md`

### Ticket C: Update CODEBASE-MAP.md — Android entry is stale
- Android submodule was added in PR #367 (2026-03-23) — update the Android row from "TBD — not yet added as submodule" to reflect actual submodule path
