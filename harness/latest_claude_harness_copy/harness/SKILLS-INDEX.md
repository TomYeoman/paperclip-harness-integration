# Skills Index

> This is a lazy-load lookup table. Do NOT load all skills at once. Read the skill file only when the trigger condition is true.

## Design Notes

**No frontmatter by design.** Skill files in this index intentionally omit YAML/TOML frontmatter. Each skill file is 500–1,000 tokens; this index is ~200 tokens. Frontmatter (name, description, type fields) would duplicate what the index table already provides and add per-file overhead with no benefit — agents resolve skills through this index, not by scanning skill files directly. See `docs/investigations/AUDIT-TOKEN-EFFICIENCY.md §2.1` for the token efficiency rationale behind the lazy-load pattern.

**Skills are flat files (current).** All skills live as single `.md` files in `harness/skills/`. Folder-per-skill structure (e.g. `SKILL-agent-spawn/index.md` + `gotchas.md`) is future state — only restructure a skill into a folder when it genuinely outgrows a single file.

**Gotchas sections (current pattern).** High-traffic skills include a `## Gotchas` table near the bottom — a scannable summary of the highest-signal failure modes. Add a Gotchas section when touching a skill file, not in a bulk pass. Do NOT create a separate `gotchas.md` file unless the skill has been promoted to a folder.

| Skill file | What it contains | Load trigger |
|------------|-----------------|--------------|
| harness/skills/SKILL-agent-spawn.md | Pre-spawn checklist, TeamCreate, worktree setup, anti-patterns, prompt template | When about to spawn an agent |
| harness/skills/SKILL-worktree-isolation.md | Manual worktree creation outside repo, contamination prevention, recovery procedures | When creating a worktree or debugging contamination symptoms |
| harness/skills/SKILL-new-feature-checklist.md | 4-phase feature workflow: discovery, TDD implementation, quality gates, PR and merge | When starting implementation of a new feature task |
| harness/skills/SKILL-jetfm-feature-flags.md | Language-agnostic JetFM feature flag protocol: flag existence gate (Step 0), create flag, gate at entry point, default off, enable via Sonic; Go and .NET examples; PR checklist | When implementing any new user-facing feature |
| harness/skills/WORKFLOW-BUG-FIX.md | Lean bug fix workflow: triage gate, skips PM/Architect, Builder spawns directly, code review still required | When assigned a bug fix issue — check triage gate first to confirm this workflow applies |
| harness/skills/SKILL-live-learning.md | Correction enforcement hierarchy, NON-NEGOTIABLE blocks, broadcast protocol, lessons.md format | When PO corrects a behavior or a new pattern is identified |
| harness/skills/SKILL-session-shutdown.md | 6 mandatory shutdown deliverables: lessons, harness issue, build journal, launch script, commit, clear overrides | When session is ending |
| harness/skills/SKILL-course-correction.md | Mid-implementation pivot protocol, decision tree, branch strategy | When >30% through implementation and fundamental assumption is wrong |
| harness/skills/SKILL-pr-review.md | Complete PR review checklist: quality check, TDD ordering, structure-insensitivity, code rules, platform standards | When received V: message and about to review a PR |
| `SKILL-reviewer.md` *(on-demand — not installed by default; install via issue #385)* | PR review checklist and Reviewer agent conventions from ai-platform community skill | When spawning a Reviewer agent — install first via `npx skills add --skill skill-reviewer` if not present |
| harness/skills/SKILL-github-pr-workflow.md | Branch naming, commit format, push, PR creation, adversarial review loop, submodule PRs, merge ownership | When creating a branch, committing work, or managing a PR lifecycle |
| harness/skills/SKILL-coding-standards-ios.md | Swift/iOS hard-block violations: force-unwrap, force-cast, @MainActor, retain cycles, SwiftLint, async/await, snapshot tests, iOS verification gate, SonarQube coverage gate | When Platform is iOS in spawn prompt, or when spawning a Builder or Reviewer for iOS work |
| harness/skills/SKILL-coding-standards-android.md | Kotlin/Android hard-block violations: !! operator, runBlocking in ViewModels, GlobalScope, Hilt DI, coroutine scoping, detekt | When spawning a Builder or Reviewer for Android work |
| harness/skills/SKILL-coding-standards-web.md | TypeScript/React hard-block violations: any type, non-null assertion, console.log, React hooks rules, ESLint, Jest | When spawning a Builder or Reviewer for web work |
| harness/skills/SKILL-coding-standards-backend.md | Backend hard-block violations: unhandled promises, catch-all exceptions, structured logging, input validation, TLS, no credentials in source | When spawning a Builder or Reviewer for backend work |
| harness/roles/ROLE-BUILDER-CORE.md | Universal Builder constraints: NON-NEGOTIABLE block, TDD rules, PR workflow, DISCOVERY gate, VERIFICATION GATE, COMMIT instructions, D: protocol | Load for ALL builders on ALL platforms — required baseline |
| harness/roles/ROLE-BUILDER-IOS.md | iOS-specific: iOS VERIFICATION GATE, fastlane commands, snapshot regeneration, large repo exploration rules, iOS quality gates | Load when: Platform: ios in spawn prompt |
| harness/roles/ROLE-BUILDER-ANDROID.md | Android-specific: Android VERIFICATION GATE, Gradle commands, detekt, Hilt DI, coroutine scoping gates | Load when: Platform: android in spawn prompt |
| harness/roles/ROLE-BUILDER-WEB.md | Web-specific: Web VERIFICATION GATE, npm commands, TypeScript/React quality gates | Load when: Platform: web in spawn prompt |
| harness/roles/ROLE-BUILDER-BACKEND.md | Backend-specific: Backend VERIFICATION GATE, structured logging, input validation, TLS, no credentials gates | Load when: Platform: backend in spawn prompt |
| harness/roles/ROLE-SEC-RESEARCHER.md | Security Researcher: STRIDE threat model, OWASP Top 10 secondary check, go/no-go gate; pre-Builder on `security-sensitive` tickets | When ticket has `security-sensitive` label and about to spawn a Security Researcher |
| harness/roles/ROLE-SEC-REVIEWER.md | Security Reviewer: milestone diff review, threat model verification, OWASP scan, go/no-go gate; milestone completion and PROMOTE: gate | When closing a milestone or before sending PROMOTE: signal |
| `SKILL-jet-agents-md.md` *(on-demand — not installed by default)* | Jet-specific agent conventions from the JE Labs AI guild; install via `npx skills add` if not present | When working with Jet-specific agent patterns or when `jet-agents-md` has been installed into harness/skills/ |
| harness/skills/SKILL-PRD-To-Tickets.md | Break a PRD into tracer-bullet vertical slice GitHub issues; HITL/AFK classification, dependency ordering, issue creation via gh | When asked to convert a PRD to issues, create implementation tickets, or break down a PRD into work items |
| harness/skills/SKILL-jetc-atlas-context.md | Atlas read-only context engine for JETConnect repos: calling Atlas, discovery protocol, blast radius queries, DISCOVERY gate integration, gotchas | When the task explicitly mentions JETConnect — a named JETConnect service or a cross-service change within the JETConnect ecosystem |
| `.agents/skills/jet-datadog` *(community — installed)* | Query DataDog logs, metrics, APM, monitors via `pup` CLI. EU site (`datadoghq.eu`), Flex Logs (`--storage=flex` required). Prereqs: `pup auth login`, `DD_SITE=datadoghq.eu` | When querying DataDog logs, error rates, APM traces, or monitors for any JET service |
| `.agents/skills/jet-datadog/jetconnect-tricks.md` | JetConnect-specific Datadog query patterns: cross-service request correlation via `@http.request_id` / `@execution_id` across Kafka/SQS consumers | **Only load if: `service.json` exists at repo root (JetConnect service repos only).** When investigating a JetConnect event flow across multiple services |
| harness/skills/SKILL-aws-cli.md | AWS SSO login, S3 bucket existence checks, IAM role inspection, cross-service S3 access patterns; JetConnect profile setup (`flyt-staging`, `flyt-production`) and bucket naming convention | When investigating AWS resource errors (AccessDenied, NoSuchBucket), or confirming whether a bucket or IAM policy exists |
| harness/skills/SKILL-capability-testing.md | Monorepo-store setup, capability test invocation, service-to-capability mapping, feature flag mocking, gotchas | **Only load if: `service.json` exists at repo root (JetConnect service repos only).** When the task involves cross-service integration testing or running capability tests against monorepo-store |

## Coding Standards

Platform-specific coding standards identified during adversarial review via the `S:` DSL signal. Append-only files — see `standards/BEST-PRACTICES.md` for the full protocol.

| File | Platform |
|------|----------|
| [standards/BEST-PRACTICES.md](../../standards/BEST-PRACTICES.md) | Protocol, deprecation rules, graduation path |
| [standards/dotnet.md](../../standards/dotnet.md) | .NET / ASP.NET Core |
| [standards/ios-swift.md](../../standards/ios-swift.md) | iOS / Swift |
| [standards/android-kotlin.md](../../standards/android-kotlin.md) | Android / Kotlin |
| [standards/typescript.md](../../standards/typescript.md) | TypeScript / React |

> Load trigger: when a Reviewer sends `S:` or when a Builder needs to check platform standards before submitting a PR.

## Milestone Boundary Triggers

Load these when a milestone is closing or a retrospective is due:

| Trigger | File | What it contains |
|---------|------|-----------------|
| Milestone boundary reached | `harness/templates/RETRO-TEMPLATE.md` | Full retrospective template |

## Community Skills (ai-platform — JET-wide)

### Two-Layer Model

Skills exist at two layers that complement each other — they do not overlap or compete:

| Layer | Repo | Scope | Load mechanism | Managed by |
|-------|------|-------|----------------|------------|
| **JET-wide** | `ai-platform/skills` | JET conventions + infrastructure — how JET works | Auto-triggered by Claude's skill system | AI Platform team + guild community |
| **Team-specific** | `testharness/harness/skills/` | Team workflow + project patterns — how this team works | Explicitly loaded via this index | This team |

**Rule:** Cross-reference where relevant. Never duplicate content between layers. When a community skill covers the same ground as a harness skill, the harness skill should defer to or reference the community one.

### Install

```bash
npx skills add git@github.je-labs.com:ai-platform/skills.git --skill <skill-name>
```

Installed skills land in `harness/skills/`. Add an entry to the index table above with an appropriate load trigger.

**Do NOT bulk-install.** Pull skills on demand when a specific task requires them.

### Find Skills

- `#agent-skills` channel in the Jet (JE Labs) Slack workspace — pinned repo link
- `#guild-ai` channel for broader community discussion
- Direct repo: `git@github.je-labs.com:ai-platform/skills.git`

### Contribute Back

Before contributing a harness skill upstream, discuss in `#interest-agent-skills` first. Contribution candidates identified in the 2026-03-19 audit: `SKILL-agent-spawn.md` (issue #235) and `SKILL-worktree-isolation.md` (issue #236).

> Historical skills audit (2026-03-19): see [docs/investigations/SKILLS-AUDIT-2026-03-19.md](../../docs/investigations/SKILLS-AUDIT-2026-03-19.md)
