# Skills Audit — 2026-03-19

Historical snapshot of community skill candidates. See SKILLS-INDEX.md for active skills.

Status key: **Adopt** = install when task matches | **Cross-ref** = reference from relevant harness skill | **Monitor** = no current overlap, check for updates | **Contributed** = harness version is a contribution candidate

| Skill name | Description | Status | Action / Notes |
|------------|-------------|--------|----------------|
| `jet-agents-md` | Jet-specific agent conventions — project setup, GHE auth, branch naming | **Adopt** | Install via `npx skills add`; entry already in index table above |
| `skill-creator` | Guidelines + template for writing well-structured, reusable skills | **Adopt** | Use when creating any new harness skill to ensure consistent format |
| `skill-reviewer` | PR review checklist and Reviewer agent conventions | **Adopt** | Index entry added (issue #230) — install via `npx skills add` when task requires it |
| `jet-company-standards` | JET coding standards and review conventions | **Cross-ref** | Issue #231 — add reference in `SKILL-github-pr-workflow.md` |
| `external-doc-ingestion` | Pattern for ingesting Confluence and external docs into agent context | **Cross-ref** | Issue #232 — add reference in `SKILL-external-doc-ingestion.md` |
| `agent-spawn` | Pre-spawn checklist, TeamCreate, anti-patterns | **Contributed** | Harness version: `SKILL-agent-spawn.md`; upstream contribution pending `#interest-agent-skills` discussion (issue #235) |
| `worktree-isolation` | Worktree creation and contamination prevention | **Contributed** | Harness version: `SKILL-worktree-isolation.md`; upstream contribution pending `#interest-agent-skills` discussion (issue #236) |
| `pr-review` | PR review checklist | **Monitor** | Harness has `SKILL-pr-review.md` with adversarial-review extensions; check community version for gaps |
| `github-pr-workflow` | Branch naming, commit format, PR lifecycle | **Monitor** | Harness has `SKILL-github-pr-workflow.md`; check community version for JET-specific additions |
| `live-learning` | Correction enforcement, lesson capture, broadcast protocol | **Monitor** | Harness has `SKILL-live-learning.md`; community version may offer lighter-weight variant |
| `session-shutdown` | Session end deliverables and cleanup | **Monitor** | Harness has `SKILL-session-shutdown.md` (6-step shutdown); compare periodically |
| `tdd-standards` | TDD discipline, fake/contract test patterns | **Monitor** | Harness has `harness/TDD-STANDARDS.md`; check for alignment |
| `discovery-gate` | Structured discovery before implementation | **Monitor** | Harness encodes in `CLAUDE.md`; community version may be extractable as a standalone skill |
| `new-feature-checklist` | Feature workflow phases | **Monitor** | Harness has `SKILL-new-feature-checklist.md`; compare for gaps |
| `course-correction` | Mid-implementation pivot protocol | **Monitor** | Harness has `SKILL-course-correction.md`; no community equivalent seen at audit time |
| `bug-fix-workflow` | Bug triage and fix workflow | **Monitor** | Harness has `WORKFLOW-BUG-FIX.md`; check community version for triage gate pattern |
| `coding-standards-ios` | iOS/Swift hard-block violations | **Monitor** | Harness has `SKILL-coding-standards-ios.md`; community version likely JET iOS team-owned |
| `coding-standards-android` | Android/Kotlin hard-block violations | **Monitor** | Harness has `SKILL-coding-standards-android.md`; community version likely JET Android team-owned |
| `coding-standards-web` | TypeScript/React hard-block violations | **Monitor** | Harness has `SKILL-coding-standards-web.md`; community version likely JET Web team-owned |
| `coding-standards-backend` | Backend hard-block violations | **Monitor** | Harness has `SKILL-coding-standards-backend.md` |
| `model-selection` | When to use Haiku vs Sonnet vs Opus | **Monitor** | Harness encodes in `~/.claude/CLAUDE.md`; community version may have JET-specific guidance |
| `context-management` | Managing context window efficiently | **Monitor** | Harness has `docs/investigations/AUDIT-TOKEN-EFFICIENCY.md`; community skill would be more authoritative |
| `parallel-spawn` | Spawning multiple builders in parallel | **Monitor** | Harness encodes in `CLAUDE.md` and `harness/lessons.md`; watch for community pattern |
| `checkpoint-resume` | Context checkpoint at 2-hour mark | **Monitor** | Not yet a harness skill; worth adopting — see token efficiency audit §5.4 |
| `merge-ownership` | Track 1 / Track 2 merge rules | **Monitor** | Harness has `harness/rules/MERGE-OWNERSHIP.md`; community version may be canonical source |
| `dsl-communication` | Inter-agent DSL prefix conventions | **Monitor** | Harness has `harness/AGENT-COMMUNICATION-PROTOCOL.md`; community version may be lighter-weight |
