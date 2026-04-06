# Build Journal

Running log of session activity, key decisions, and ticket tracking.

---

## Session: 2026-04-01a
PRs opened: none (all pushes to existing PR #2167) | PRs open EOS: #2167 (checkout/CheckoutApi), #1193 (consumer-offers-api), #618 (testharness) | Issues worked: GARG-1441 | Agent spawns: 5 (🐝b-coopbenefit Sonnet, r-coopbenefit Sonnet ×3 passes, 🐝b-newprice Haiku nit fix) | Lessons encoded: 0

### What was built

**GARG-1441 — COOP_LOYALTYSCHEME benefit gate for "Membership savings"**
PO clarified `OfferType.NewPrice` always set, but `"Membership savings"` only when `COOP_LOYALTYSCHEME` in benefits. Added `Benefits IEnumerable<string>` to `IOffer` interface and `Models.Offer`, mapped `co.Benefits` and `ro.Benefits` in both offer paths of `BasketDetailsMapper`. `MapOfferName` gates `Translations.NewPriceOfferName` on `offer.Benefits?.Contains("COOP_LOYALTYSCHEME", OrdinalIgnoreCase)`. Both category and restaurant paths symmetric. Null-Benefits test cases added. Benefits confirmed absent from API response (grepped `CheckoutApi.Models/` and `CheckoutServiceModel`). Follow-up issue #2181 raised for `BenefitTypes` constant extraction.

**PR #2167 conflict resolved**
Master had 8 new commits since branch was cut, conflicting in `Translations.resx`. Resolved by taking master's version and re-inserting `NewPriceOfferName` entry. Rebased all 5 commits. Hit repo JIRA ID pre-receive hook — `feat(GARG-1441):` prefix rejected; rewrote to `GARG-1441:` with filter-branch. Pushed successfully.

**PR #2167 marked Ready for Review**
Was still in draft — marked ready so Sonic bot and repo owners are notified.

### What went wrong
- **Builder opened PR as draft** — PR #2167 sat unreviewed overnight. PO had to notice; Lead should check `isDraft` on all external PRs at session start.
- **3 reviewer passes needed** — initial resx XML nesting issue, then category offers gap (NewPrice will be category offer, not restaurant offer), then null-Benefits nit. Each caught correctly but required multiple F: cycles.
- **Commit message format** — first commit used `feat(GARG-1441):` pattern; checkout repo requires bare `GARG-1441:` at start. Caught at push time, fixed with filter-branch.

### Key decisions
- `OfferType.NewPrice` always set regardless of benefits
- "Membership savings" gated on `COOP_LOYALTYSCHEME` benefit
- NewPrice arrives as category offer (not restaurant offer) — both paths must be symmetric
- `"COOP_LOYALTYSCHEME"` inline string accepted (consistent with `"PARTNER_EXCLUSIVE_OFFERS"` precedent); extraction deferred to #2181
- `Benefits` must not appear in API response contract

### Session metrics

| Metric | Value |
|--------|-------|
| PRs merged | 0 |
| PRs in queue | 0 |
| PRs still open | 3 (#2167 external, #1193 external, #618) |
| Issues created | 2 (checkout/CheckoutApi#2179, #2181) |
| Issues closed | 0 |
| Agent spawns | 5 (builders: 2, reviewers: 3 passes, other: 0) |
| Lessons encoded | 0 |
| Spawn-to-D: ratio | 4/5 (80%) |
| B: rate | 0/5 (0%) |
| Avg PR cycle time | N/A (no merges) |
| Avg loops/PR | 3.0 (3 review passes) |
| Coord overhead | ~35% |
| vFTE hours | 5.5h (efficiency: 2.75x) |

---

## Session: 2026-03-31a
PRs merged: #623 (testharness, lesson) | PRs open: #2167 (checkout/CheckoutApi, awaiting owner review), #618 (testharness) | Issues worked: GARG-1441, #622 | Agent spawns: 3 (1 builder Haiku, 1 reviewer Sonnet, 1 harness builder Haiku) | Lessons encoded: 1

### What was built

**GARG-1441 — CheckoutApi NewPrice offer type mapping**
Investigated `checkout/CheckoutApi` repo. Added `OfferType.NewPrice` to enum, mapped GBO string `"newprice"` in `BasketDetailsMapper.GetOfferType`, added `"Membership savings"` translation (Translations.resx + Designer.cs), added `MapOfferName` branch for NewPrice, 6 new test inline data rows (case variants). PR #2167 open on `checkout/CheckoutApi` — adversarial review passed after 1 fix cycle (Translations.resx XML nesting and Designer.cs single-line formatting corrected). Awaiting repo owner review/merge.

**Lesson #622 — Build before opening PR**
Encoded PO lesson: builders must run project build (zero compile errors) before `gh pr create`. Applied to ROLE-BUILDER-CORE.md VERIFICATION GATE (step 0) and NON-NEGOTIABLE section. PR #623 merged.

**Session housekeeping**
Fixed LAUNCH-SCRIPT.md merge conflict (sessions #611 and #612 had collided). Pruned 9 stale remote refs. Deleted abandoned branch `harness/issue-551-execution-modes` (PR #554 closed without merge).

### What went wrong
- **🍯b-lesson completed work but never sent D:** — builder opened PR #623 and went idle without reporting. Lead detected via direct `gh pr list` check. Low impact.
- **Translations.resx XML nesting** — builder inserted `NewPriceOfferName` inside unclosed `MultibuyOfferName` element. Caught by adversarial reviewer. Fixed in one F: cycle.
- **Translations.Designer.cs single-line formatting** — same builder, property crammed onto one line. Caught by reviewer, fixed with resx issue in same commit.

### Key decisions
- `NewPrice` offer type displays "Membership savings" (confirmed by PO)
- checkout/CheckoutApi#2167 held in 🏠 hive — PO merges when repo owner approves

### Session metrics

| Metric | Value |
|--------|-------|
| PRs merged | 1 (#623) |
| PRs in queue | 0 |
| PRs still open | 2 (#2167 external, #618) |
| Issues created | 2 (#622, checkout/CheckoutApi#2166) |
| Issues closed | 0 |
| Agent spawns | 3 (builders: 2, reviewers: 1, other: 0) |
| Lessons encoded | 1 |
| Spawn-to-D: ratio | 2/3 (67%) |
| B: rate | 0/3 (0%) |
| Avg PR cycle time | ~25 min |
| Avg loops/PR | 1.0 |
| Coord overhead | ~30% |
| vFTE hours | 3.5h (efficiency: 4.7x) |

---

## Session: 2026-03-30
PRs opened: #612 (testharness, in queue), #1193 (consumer-offers-api, awaiting repo owner review) | Issues worked: GARG-1333 | Agent spawns: 2 (pm, arch) | Lessons encoded: 4

### What was built

**GARG-1333 — NewPrice offer mapping fix (consumer-offers-api PR #1193):**
- Root cause: `OfferType.NewPrice` missing from `CreateInstance` switch in `OfferEngineMapperInternal.cs` → `ArgumentOutOfRangeException` caught silently → offer dropped
- Secondary root cause: `OfferValidationService.ValidateNewPrice` rejected `NewPriceOffer` with empty `Prices` at mapping time — before basket-scoped prices can be fetched by `NewProductPriceService`
- Fix 1: Added `OfferType.NewPrice => new NewPriceOffer { OfferType = OffersEngine.Models.OfferType.NewPrice }` to the switch
- Fix 2: `OfferEngineMapper.TryMapToOfferEngine` — skip validation for `NewPriceOffer` (`if (offer is not NewPriceOffer && !validator.TryValidateOffer(...)`)
- Validated by PM + Architect agents: two-phase lifecycle (`NewPriceOffer` as signal → prices populated by `NewProductPriceService` with basket context) is intentional and correct
- Integration test `NewProductPriceOfferScenarios` added (seeds MenuIndex + price hash, asserts `NewProductPriceConsumerOffer` returned)

### Key decisions
- Pre-fetching prices before mapping is not viable: prices must be basket-scoped (only products in basket), and basket context is only available in `CachedConsumerOffersService` — one layer above where mapping occurs
- `OfferValidationService` (NuGet) was not designed for the two-phase `NewPriceOffer` lifecycle; bypass is correct, not a hack
=======
## Session 2026-03-30 — Build journal consolidation + docs/sessions/ backfill

**Date:** 2026-03-30 | **Duration:** ~20m | **Branch:** harness/609-journal-fix

### What shipped

- **PR #610** (issues #609, #608, merged): Full build journal repair — fixed chronological ordering of 2026-03-24 and 2026-03-24c entries in BUILD-JOURNAL.md; wired `docs/sessions/` into CLAUDE.md SESSION END step 9; backfilled 28 JSON session records covering all sessions from 2026-03-13 through 2026-03-28.

### Key decisions

- All sessions from 2026-03-13 onward now have a JSON record in `docs/sessions/` — early entries have sparse data (nulls for unknowns), later entries are fully populated.
- `docs/sessions/` is now a BLOCKING GATE in both SKILL-session-shutdown.md AND CLAUDE.md SESSION END — no more drift.

### Session metrics

| Metric | Value |
|--------|-------|
| PRs merged | 1 (#610) |
| PRs open | 1 (#600 — deferred, awaiting PO merge) |
| PRs deferred | 0 |
| Issues created | 1 (#609) |
| Issues closed | 2 (#608, #609) |
| Agent spawns | 1 (builders: 1) |
| L: count | 0 |
| S: count | 0 |
| Spawn-to-D: ratio | 1/1 (100%) |
| B: rate | 0/1 (0%) |
| Avg PR cycle time | ~15m |
| Coord overhead | ~30% (scope expansion mid-flight) |

---

## Session 2026-03-28 — Runtime flags, debug mode, dashboard redesign

**Date:** 2026-03-28 | **Duration:** ~3h | **Branches:** harness/596-runtime-flags, harness/599-dashboard-improvements

### What shipped

- **PR #597** (issue #596, merged): Runtime flags via `~/.claude/session-flags.env`. Keyword detection in PO opener (swarm/worker/debug/release/hive). OTEL auto-start at SESSION START with docker-compose fallback. `HARNESS_DEBUG_TOKENS` → `HARNESS_DEBUG`. Grafana port 4000. `otel-start.sh`. `harness/SESSION-FLAGS.md`. README "Starting a Session" + "Observability" sections.
- **PR #598** (session docs, merged): Build journal + launch script for 2026-03-28.
- **PR #600** (issue #599, open): Grafana dashboard redesign — 8 new panels: Context Pressure Over Time, Active Time Rate, Model Usage Over Time (stacked), Tokens by Model, Unified Cost+Tokens+Model chart, Tool Response Inflation, Skill Token Budget, Cost by Agent Type. Pushed live.

### Key decisions

- `HARNESS_DEBUG_TOKENS` → `HARNESS_DEBUG`: debug is now a full verbose mode
- Grafana port 4000: avoids local port collisions
- SESSION-FLAGS.md cross-references README Beehive rather than duplicating swarm/worker docs

### Session metrics

| Metric | Value |
|--------|-------|
| PRs merged | 2 (#597, #598) |
| PRs open | 1 (#600) |
| PRs deferred | 0 |
| Issues created | 2 (#596, #599) |
| Issues closed | 1 (#596 via #597) |
| Agent spawns | 0 |
| L: count | 0 |
| S: count | 0 |
| Spawn-to-D: ratio | N/A |
| B: rate | 0 |
| Avg PR cycle time | ~1h |
| Coord overhead | ~100% (Lead-only session) |

---

## Session 2026-03-27c — Harness track 3 + Beehive protocol design

**Date:** 2026-03-27 | **Duration:** ~1.5h | **Branch:** main

### What landed

| PR | Change |
|----|--------|
| #586 | Tool-level metrics — PostToolUse hook + Stop hook OTEL cost attribution (#585) |
| #584 | Session journal 2026-03-27b |
| #589 | JetConnect skill trigger guards + SERVICE-JETCONNECT.md (#571) |
| #591 | Lesson: auditor lifecycle — do not CLOSE: after Phase 1 report |
| #592 | Dashboard renders on B: and on-demand only — removed D:/V: triggers (#545) |
| #594 | Beehive protocol — swarm/worker modes with 🏠/🌻/👑 vocabulary (#593) |

### PRs closed without merge

| PR | Reason |
|----|--------|
| #582 | Superseded by #586 |
| #588 | #574 closed with comment instead of built |

### Key decisions

**Beehive protocol (a-exec-modes + PO co-design):** The build protocol is renamed Beehive. Two modes:
- **swarm** (🐝) — full agent swarm, always used for harness work, optional for milestones
- **worker/forager** (🌻) — slow and steady, single issue or bug
- **GATED: true** adds PO approval gates; **PROMOTE: auto/hold** controls upstream PR timing
- Mode is per-task, not per-session; a session can mix both modes

**Auditor lifecycle rule encoded:** Lead must not send CLOSE: after Phase 1 report. Auditors stay alive in their tabs for PO to engage directly. CLOSE: only after Phase 2 complete or rejected.

**Dashboard trigger reduced:** Was rendering on every D:/V:/B:. Now renders on B: and `dashboard` command only (plus session end). ~85% token reduction.

**#574 deferred:** Issue ownership docs rule judged stale (problem already solved). Closed with comment.

**#571 split:** Guards + SERVICE-JETCONNECT.md shipped (#589). Milestone↔knowledge linking deferred to #590 (assigned to @tom-yeoman).

**paste-to-agent-tab regression:** Two suspects — `policy-limits.json` (`allow_remote_control: false`) and Claude Code upgrade 2.1.84→2.1.85 today. Unresolved — PO to investigate.

### Issues created

| Issue | Title |
|-------|-------|
| #590 | milestone↔system-knowledge linking — open question for @tom-yeoman |

### Issues closed

| Issue | How |
|-------|-----|
| #574 | Closed with comment — stale context |
| #579 | Closed — covered by #586 |

### Session metrics

| Metric | Value |
|--------|-------|
| PRs merged | 6 |
| PRs closed (no merge) | 2 |
| PRs open at end | 1 (#554 on hold) |
| Issues created | 1 (#590) |
| Issues closed | 2 (#574, #579) |
| Agent spawns | 8 (builders: 3, auditors: 5) |
| Lessons encoded | 1 (auditor lifecycle) |
| B: rate | 0/8 (0%) |
| Coord overhead | ~20% (auditor re-spawn cost) |

### Known issues / next session

- #554 (execution modes / Beehive) — PO reviewing, changes pending before merge
- #590 — Tom to answer milestone↔knowledge linking question
- GARG-1333 cluster (#572, #575, #557, #583) — not started this session
- REWE M2 still blocked on #540 (push permissions) and open questions
- paste-to-agent-tab regression — check `~/.claude/policy-limits.json` (`allow_remote_control`)

---

## Session 2026-03-27b — Token Reporting + Local OTEL Stack

**Lead:** Claude Sonnet 4.6 | **Duration:** ~2h

### What we built

- **tomy_harness#14 / PR #578 → #582 — DEBUG: tokens flag**: Migrated PR from personal fork. Initial approach (builder self-reporting) replaced after architect research revealed it was fundamentally unreliable (agents cannot observe their own API `usage` metadata). Closed #578, all content folded into #582.
- **#579 / PR #582 — Stop hook token report**: Ground-truth token reporting via Claude Code transcript JSONL (`~/.claude/projects/<hash>/<session>.jsonl`). Stop hook parses all assistant messages, sums input/output/cache tokens, applies Sonnet 4.6 pricing, writes `~/.claude/last-token-report.json`, prints human-readable summary. Gated behind `HARNESS_DEBUG_TOKENS=1`. Session flag detection added to SESSION START step 0 (keyword scan → `~/.claude/session-flags.env`). **Open — awaiting PO merge.**
- **#580 / PR #581 — Local OTEL stack**: Docker Compose stack (OTEL collector + Prometheus + Grafana) for real-time Claude Code token dashboards. `CLAUDE_CODE_ENABLE_TELEMETRY=1` streams `claude_code.token.usage` / `claude_code.cost.usage` metrics to collector on `localhost:4318`. Grafana on `localhost:3001` (port conflict with existing Node process required remap from 3000). Pipeline verified end-to-end. `otel-start.sh` / `otel-stop.sh` convenience wrappers. **Merged.**
- **Settings wired**: `~/.claude/settings.json` updated with OTEL env vars (`CLAUDE_CODE_ENABLE_TELEMETRY=1`, `OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4318`) and Stop hook registration. Takes effect next session restart.
- **PR migrations**: #576 (investigation file) cherry-picked into #554 branch and closed. tomy_harness#14 closed with migration note.

### Key decisions

- **Self-reporting abandoned**: Architect research confirmed agents cannot observe `usage` metadata from API responses — any self-reported TOKEN-REPORT would be fabricated. Switched to transcript JSONL parsing via Stop hook.
- **HARNESS_DEBUG_TOKENS gate**: Hook runs on every Stop event but exits early unless env var is set. Prevents noise for sessions that don't need cost tracking.
- **Grafana port 3001**: Port 3000 occupied by Node.js/Express process (appears to be a Claude Code proxy/API). Remapped host port to 3001; container stays at 3000.
- **Session flags mechanism**: Lead detects debug keywords in opening PO message, writes `~/.claude/session-flags.env`. Survives context compression. File takes precedence over shell env when both present.

### Session metrics

| Metric | Value |
|--------|-------|
| PRs merged | 1 (#581 OTEL stack) |
| PRs open | 1 (#582 stop hook — awaiting PO merge) |
| PRs closed without merge | 2 (#578 superseded, #576 cherry-picked into #554) |
| Issues created | 2 (#579, #580) |
| Issues closed | 0 |
| Agent spawns | 6 (builders: 2, reviewers: 2, architect: 1, other: 1) |
| Lessons encoded | 2 (gated merge, single PR focus) |
| Spawn-to-D: ratio | 2/2 (100%) |
| B: rate | 1/2 (50% — b-stop-hook hit poll cap on manual merge wait, expected) |
| Avg PR cycle time | ~35m |
| Coord overhead | ~20% |

### Open / deferred

- **#582 / PR #582**: Stop hook + session flags — awaiting PO merge
- **#554 / PR #554**: Build protocol redesign — awaiting PO merge (pre-dates this session)
- **harness/issue-530-sysknow-refactor**: Branch has 12-file SYSTEM-KNOWLEDGE modularisation (issue #530 is closed, no open PR). Work may be useful — review before deleting.

---

## Session 2026-03-27 — Skill Backports + Build Protocol Redesign

**Lead:** Claude Sonnet 4.6 | **Duration:** ~3h

### What we built

- **#564 / PR #568 — SKILL-capability-testing.md**: Backported JetConnect integration test skill from personal fork. Covers monorepo-store setup, `make replace SERVICES=...`, `TestGroceryFlows` invocation, feature flag mocking via `flagdata.json`. Load trigger scoped to JetConnect repos (`service.json` at root). Merged.
- **#565 / PR #569 — SKILL-aws-cli.md**: Backported AWS CLI skill, redesigned as team-agnostic. Generic top half (SSO login, S3/IAM/DynamoDB patterns with `<profile-name>` placeholders); JetConnect section with `flyt-staging`/`flyt-production` profiles, setup check, append-to-config snippet, bucket naming convention. Merged.
- **#566 / PR #570 — jet-datadog community skill**: Backported full `pup` CLI skill from personal fork. Verified upstream copy via direct clone (`git clone --depth 1 git@github.je-labs.com:ai-platform/skills.git`). Cross-service `@http.request_id` section was locally added — chose Option B: restored `SKILL.md` to exact upstream copy, extracted JetConnect tricks to companion file `jetconnect-tricks.md`. Added `skills-lock.json` for hash-pinned upgrade tracking. Merged.
- **#551 / PR #554 — Build protocol redesign**: Updated issue #551 and rewrote PR #554 implementation based on `tasks/investigations/BUILD-PROTOCOL-REDESIGN-2026-03-27.md`. Replaced `MODE: slow/greenfield` + `SCOPE: milestone/single` + `--no-auto-merge` with three composable knobs: `AUTONOMOUS [lane]` / `TASK [lane] [#id]`, `PROMOTE: auto/hold`, `GATED: true` (3 gates + issue-creation gate). Lane labels scope builder issue feeds for parallel PO sessions. Updated CLAUDE.md, CLAUDE-BUILDER.md, ROLE-LEAD.md, README.md, GATED-MODE-PROTOCOL.md, SPAWN-PROMPT-GATED-MODE.md. Open.
- **PR #576 — Investigation file commit**: `tasks/investigations/BUILD-PROTOCOL-REDESIGN-2026-03-27.md` was untracked on main, blocked by merge queue on direct push. Opened as standalone PR. Open.
- **#573 — Per-issue token report**: Created issue for `DEBUG: tokens` flag. Spec: passive observation of API `usage` object (input_tokens + output_tokens), exact counts × model pricing ($3/M input, $15/M output), `TOKEN-REPORT:` in `D:` message, Lead posts one-line PR comment. Off by default. Cross-referenced in #551.

### Key decisions

- **Upstream skill integrity**: `SKILL.md` in community skills must remain an exact upstream copy. Local customisations go in companion files. `skills-lock.json` tracks the hash for safe future upgrades via `npx skills add`.
- **JetConnect trigger guards**: Skills index entries for JetConnect-only skills include explicit guard text ("JetConnect repos only (requires `service.json` at root)"). Formal convention tracked in issue #571 (not yet implemented).
- **Protocol naming fix**: `MODE: slow/greenfield` described PR *destination* not *behaviour*; `SCOPE: milestone/single` was ambiguous. New model: `AUTONOMOUS` (continuous, auto-assigns next task) vs `TASK` (one issue, dashboard + wait). `PROMOTE: auto/hold` controls whether pointers go upstream automatically. Composable, not modal.
- **#563 closed**: Gate 3 (`--no-auto-merge`) folded into `GATED: true` — separate issue was redundant given #551 scope. PR #567 closed without merge.
- **Token tracking approach**: passive observation of API `usage` object already in responses. Tracking should not itself consume significant tokens. `DEBUG: tokens` off by default to avoid noise.

### Session metrics

| Metric | Value |
|--------|-------|
| PRs merged | 3 (#568, #569, #570) |
| PRs open | 2 (#554, #576) |
| PRs closed without merge | 1 (#567 — superseded by #554) |
| Issues created | 4 (#564, #565, #566, #573) |
| Issues closed | 4 (#564, #565, #566, #563) |
| Agent spawns | 0 (Lead-only session) |
| Lessons encoded | 0 |

### Open / deferred

- **#554** — execution modes redesign PR, open for PO review
- **#576** — investigation file PR, open for PO review/merge
- **#571** — JetConnect skill trigger guards + milestone↔system-knowledge linking (not started)
- **#573** — per-issue token report with `DEBUG: tokens` flag (issue only, not started)

---

## Session 2026-03-26b — Harness Quality & Scaling Sprint

**Lead:** Claude Sonnet 4.6 | **Duration:** ~4h (09:30–17:05 UTC)

### What we built

- **#552 — Staging deployment quality gate** (`harness/staging-deployment-quality-gate`): ADR, SKILL-staging-deploy.md, ROLE-INTEGRATION-TESTER.md update, CLAUDE-INTEGRATION-TESTER.md context, 5-scenario BDD feature file, task spec. Full gate model: deploy → IT agent → rollback if failures. Merged.
- **#559 / #555 — Coding standards guide + S: DSL** (`harness/issue-555-standards`): Created `standards/` directory with BEST-PRACTICES.md and platform stubs (dotnet, ios-swift, android-kotlin, typescript). Added `S:` to Communication DSL — distinct from `L:` (process) to capture platform-specific coding standards. Updated ROLE-REVIEWER.md and SKILLS-INDEX.md. Append-only model; periodic auditor deprecation pass. Merged.
- **Scaling report** (`harness/SCALING-REPORT.md`): Opus auditor deep-read of harness; identified 5 structural blockers to multi-team use; 12-item prioritised recommendations. See file for full detail.

### Key decisions

- **PR #554 (execution modes)** — left open pending PO review. Key question: does `build: #N` → `SCOPE: single` (pause after each issue) match intended daily workflow? Review comment added at #issuecomment-3198841.
- **`S:` vs `L:` split** — process corrections → `harness/lessons.md`; coding quality → `standards/[platform].md`. Append-only per platform, auditor handles deprecation. Avoids polluting harness lessons with language-specific rules.
- **Scaling architecture** — federation model recommended: per-team config layer over canonical upstream harness. P0 items: parameterise GH_HOST/PO identity, define CLAUDE.md governance model.
- **Deming / review layers** — session discussion on [Every layer of review makes you 10x slower](https://apenwarr.ca/log/20260316). Reviewer's primary output should be a lesson/standard that obsoletes the comment, not just an approval signal.

### Lessons encoded this session

- None new (no L: events fired)

### Open / deferred

- **#554** — execution modes PR, open for PO review
- **#557** — calculate endpoint extension (product, no harness work)
- **REWE M2** — all platforms built, none promoted. iOS mergeable (#18894), Android/Web blocked (#540), Backend unbuilt (#362)
- **Scaling P0 items** — parameterise identity config, define CLAUDE.md governance — no tickets yet; PO to decide priority

---

## Session: 2026-03-25c
PRs merged: ~15 (#520, #521, #523, #525, #526, #527, #529, #532, #534, #541, #542, #543) | Issues closed: #502, #505, #507, #508, #509, #510, #511, #515, #518, #519, #522, #528, #531, #533, #535, #541 | Issues filed: #512, #515, #516, #517, #519, #522, #524, #528, #531, #533, #535, #536, #537, #538, #539, #540, #541 | Agent spawns: ~22 | Coverage delta: N/A

### What was built

**Harness encoding — 5 issues from 25b encoded in parallel (PRs #520–#525):**
- #505 → shutdown_request JSON protocol → ROLE-LEAD.md + SKILL-agent-spawn.md (PR #520)
- #507 → reviewer gate before merge queue → ROLE-LEAD.md + SKILL-agent-spawn.md (PR #521)
- #508 → Auditor Phase 2 — in-session report review is sufficient → ROLE-AUDITOR.md (PR #521)
- #509 → message body workaround (file-based) → SKILL-agent-spawn.md (PR #520)
- #510 → harness PR reviewer threshold (low-risk vs high-risk) → MERGE-OWNERSHIP.md (PR #525)

**Atlas security audit (#511 → PR #520):**
- Fixed `cut -d= -f2` → `cut -d= -f2-` token truncation bug in SKILL-jetc-atlas-context.md
- ATLAS: field clarified as JETConnect extension (not standard)
- Silent 401 gotcha documented

**Secops design (#512 → PR #529):**
- ROLE-SEC-RESEARCHER.md — STRIDE threat model, Opus model, pre-Builder blocking gate
- ROLE-SEC-REVIEWER.md — milestone + PROMOTE: gate, Sonnet model, OWASP diff scan
- Added to SKILLS-INDEX.md and ROLE-LEAD.md dispatch table

**REWE PM review (#518, closed):**
- pm-rewe-review audited M1 + M2 vs PRODUCT-BRIEF-REWE-TCS.md
- M1: complete (both backend issues closed)
- M2: 6 spec gaps found — feature flag mismatch, transit-ack (D6), PDF version capture (D7), OQ9 copy text, Phase I store IDs, OQ10 browser choice
- Report: rewe-milestone-review.md

**REWE feature flag rename (#524, #528):**
- Canonical name confirmed: `rewe_tcs_scalable_enabled` (not `rewe_tac_scaled`)
- iOS: renamed in 4 Swift files, conflict resolved (PR #18894 now MERGEABLE)
- Android/Web: commits staged, push blocked by permission (#540)
- Backend: flag not in code (uses mapping service, not JetFM at checkout)
- Harness docs updated (PR #532)

**Token startup audit (#515 → PR #527):**
- Audited all startup-loaded files; lessons.md (880 lines) excluded from startup
- ~20 SUPERSEDED entries archived to harness/lessons-archive.md
- CLAUDE.md SESSION START updated: explicit "do NOT load lessons.md at startup" guard
- MILESTONES-ARCHIVE.md updated with loyalty M2 (PAUSED → archived, PR #523)

**SYSTEM-KNOWLEDGE refactor (#530 → PR #542):**
- SYSTEM-KNOWLEDGE.md converted to navigation index
- New harness/system-knowledge/ directory: SHARED-PATTERNS.md, SERVICE-REWE-TCS.md, PLATFORM-IOS.md, PLATFORM-ANDROID.md, PLATFORM-WEB.md, PLATFORM-BACKEND.md

**Stale branch cleanup (#533, closed):**
- 17 unmerged branches audited — all confirmed squash-merged to main
- All 17 deleted safely; stale branch review added to SESSION END checklist (#531 → PR #534)

**Push permissions documented (#502, closed via PR #542):**
- corey-latislaw is pull-only on Android/app-core and Web/consumer-web
- Detached HEAD risk documented in WORKFLOW-SUBMODULE.md
- Tickets filed (#540) — decision needed: grant write / manual push / no Track 3 for Android+Web

**Backend D6 audit (#535, closed):**
- feature/rewe-m2-tcs-email branch does not exist — email service not yet built
- Spec comment left on #362; backend build blocked on #537 config + D6 transit-ack

**Label governance (#541 → PR #543):**
- 6 product tickets re-labeled from `harness` to `bug`
- Lesson encoded: `harness` label = infrastructure only, not product work

**M4 agent cap softened (#522 → PR #526):**
- "Max 6 concurrent" in CLAUDE.md is a coordination guideline, not a hard gate
- ROLE-LEAD.md updated; lesson encoded; memory written

### Key issues open for next session
- #540: Push permission decision for Android/Web submodule repos
- #537: Provide StoreDocumentMapping:BaseUrl config value (Cloudinary URL)
- #538: REWE-approved copy text for T&Cs link (OQ9)
- #539: 6 Phase I pilot store IDs for Web flag-OFF fallback
- #536: PDF version capture at checkout tap time (D7 gap)
- #362: Backend email service — not yet built

### Incidents
- **6-agent hard cap**: Lead blocked spawns at 6/6. PO corrected: M4 has no forced limit, "Max 6" is a guideline. Lesson encoded + memory written (#522 → PR #526).
- **rm hook blocking report cleanup**: Safety hook blocks `^rm`. Report files need manual deletion by PO: `! rm -f d6-report.md label-audit-report.md pr-body.md rewe-milestone-review.md stale-branch-report.md token-audit-report.md workflow-audit-report.md`
- **b-flag-android/b-flag-web push blocked**: corey-latislaw pull-only on platform repos. Confirmed "try it and see." Documented #540.
- **iOS PR #18894 conflict resolved**: b-ios-conflict rebased onto origin/main, took origin/main for 4 CAAI/CBSH files. PR now MERGEABLE.
- **lessons.md APPEND ONLY vs archive**: Token audit recommended removing SUPERSEDED. PO: "leave lessons alone" — took archive-only approach.

---

## Session: 2026-03-25b
PRs merged: 5 (#499, #498, #501, #503, #506) | Issues closed: #495, #496, #500, #504 | Issues filed: #505–#510 | Agent spawns: ~15 | Coverage delta: N/A

### What was built

**REWE M2 — all 4 platform builders completed greenfield development:**
- iOS (#360): PR #18894 open and approved (8/8 ACs) in iOS/JustEat — blocked on PO manual merge (SERP conflict unrelated to Checkout diff; agent lacks --auto permission on platform repos)
- Android (#361): `feature/rewe-m2-tcs-android` ready to promote on PROMOTE: signal
- Web (#359): `feature/rewe-m2-tcs-web` ready pending 2 PO answers — (1) S13 copy text from approved .docx, (2) 6 Phase I REWE pilot store IDs
- Backend (#362): `feature/rewe-m2-tcs-email` ready to promote; needs `StoreDocumentMapping:BaseUrl` config per environment before deploy

**Track 3 workflow rewrite (#504 → PR #506):**
- Auditor a-pr-workflow produced full audit of 5 workflow gaps in platform submodule PR handling
- b-track3-workflow implemented all decisions: fetch-first rule, harness-side review cycle, PROMOTE: gate, --auto unavailability documented, pointer update per platform merge (not per milestone)
- Updated: WORKFLOW-SUBMODULE.md, MERGE-OWNERSHIP.md, CLAUDE.md, ROLE-LEAD.md
- r-track3-workflow found and fixed stale line 256 in ROLE-LEAD.md before merge

**lessons.md canonical reformat (PRs #499, #501):**
- All 91 entries reformatted to canonical 5-field format
- 7 non-compliant entries fixed in follow-up PR #501 after r-lessons-fmt found them post-merge
- Issue #507 filed: builder must wait for reviewer all-clear before queuing merge (repeated lesson)

**Harness improvements (PRs #498, #503):**
- #498: auto-reviewer-on-V rule hardened — no PO prompt needed
- #503: Atlas skill added (SKILL-jetc-atlas-context.md + SKILLS-INDEX.md)

### Key issues filed (encode next session)
- #505: shutdown_request protocol → lessons.md + ROLE-LEAD.md
- #507: Builder waits for reviewer all-clear before queuing merge
- #508: Auditor Phase 2 — in-session report review is sufficient approval
- #509: Teammate message body failure — file-based workaround
- #510: Harness PR review threshold — low-risk docs don't need Reviewer

### Incidents
- iOS SERP conflict (#506 root cause): builder branched from detached HEAD (pinned commit). Fix: fetch origin/main before branching. Fixed in Track 3 rewrite.
- Agent tab clutter: plain-text CLOSE: leaves tabs in status bar. Fix: shutdown_request JSON. Issue #505 filed.
- PR #499 merged before reviewer finished: r-lessons-fmt found 7 issues post-merge. Fix required #501. Issue #507 filed.

---

## Session: 2026-03-25a
PRs merged: 13 (#479, #481–#490, #492) + #391 | Issues closed: #463–#469, #471, #473–#474, #476, #491, #358 | Agent spawns: ~20 | Coverage delta: N/A

### What was built

**Harness lessons landed (13 PRs):**
- #463 platform-allowlist session-start rule → ROLE-LEAD.md
- #464 Lead never does discovery → ROLE-LEAD.md
- #465 verify-before-encoding gate → SKILL-live-learning.md
- #466 one-issue-one-builder → ROLE-LEAD.md + SKILL-agent-spawn.md
- #467 investigate-thoroughly principle → all role files
- #468 read-ticket-before-flagging → ROLE-LEAD.md
- #469 periodic memory audit schedule → SKILL-live-learning.md
- #471 BDD doc corruption fix (revert not force-push) → ROLE-QE.md
- #473 stack-TBD merge guard → ROLE-LEAD.md
- #474 rebase-before-push finalized → SKILL-agent-spawn.md
- #476 lessons.md entry consistency → harness/lessons.md
- #491 parallel builder worktree pre-creation rule → SKILL-agent-spawn.md + SKILL-worktree-isolation.md
- #470, #472 already encoded — closed without PR

**REWE T&Cs PDF pipeline M1 complete (#358, PR #391):**
- Full .NET Core replacement of Node.js implementation
- QuestPDF generator, Cloudinary client, restaurant service client, mapping registrar
- All interfaces extracted (ICloudinaryClient, IPdfGenerator, IRestaurantServiceClient, IMappingRegistrar)
- 14/14 tests passing using fake-over-mock pattern
- Sonic review findings resolved: Dockerfile net10.0, SecureUrl null check, HttpClient timeout

**Worktree incident root cause encoded (#491):**
- `isolation: "worktree"` alone is insufficient — Bash CWD doesn't persist between tool calls
- Fix: Lead pre-creates worktrees with `git worktree add /private/tmp/wt-NNN -b branch origin/main`
- Every spawn prompt must include explicit `-C /path` warning

---

## Session: 2026-03-24b
PRs merged: 11 (#394, #405–#406, #408–#409, #412–#413, #407, #410 pending) | Issues closed: #388, #399, #401, #402, #404, #411 | Agent spawns: ~18 | Coverage delta: N/A

### What was built

**Permissions root cause diagnosed and fixed:**
- `Glob(/private/tmp/**)` and `Grep(/private/tmp/**)` missing from global allow list — added to `~/.claude/settings.json`
- `bypassPermissions` permanently disabled (`disableBypassPermissionsMode: "disable"`) — was being passed in all spawn prompts as a no-op; harness updated to remove false confidence
- Relative paths in builder spawn prompts trigger prompts even with `Read(**)` in allow list — all spawn prompts must use absolute paths; SKILL-agent-spawn.md updated with 4-cause hierarchy
- Created `harness/rules/PERMISSIONS-MODEL.md` — holistic reference for the full security model

**Safety hooks audit (#410):**
- `git branch -D` and `xargs rm` patterns were not blocked — patched in `~/.claude/hooks/block-dangerous.sh`
- `git checkout -- .` / `git restore .` intentionally left unblocked (PO decision: agents need them)
- Created `harness/rules/SAFETY-HOOKS.md` — canonical reference for all protected patterns

**Secrets injection (#388, PR #413):**
- Created `harness/setup/SECRETS-INJECTION.md` — pattern: add secrets to `~/.claude/settings.json` env block; agents inherit automatically
- `block-dangerous.sh` extended to catch inline secret assignments in tracked files

**Temp file pattern audit (#399, PR #406):**
- Root cause: `SKILL-github-pr-workflow.md` retained `/tmp/` absolute paths missed by PR #376
- Fixed: `pr-body.md` ×3 and Gotchas table entries replaced with `./` relative paths

**Native worktree isolation (#411, PR #412):**
- Claude Code v2.1.49+ ships native `isolation: "worktree"` support (confirmed v2.1.81)
- Harness updated: native isolation is preferred default; manual pre-creation retained for explicit branch control
- Relevant lessons.md entries marked SUPERSEDED

**Agent naming convention (#408):**
- `a-[slug]` for auditors, `b-[slug]` for builders — CLAUDE.md AGENT TEAM table updated with Name prefix column

**Session-end dashboard skill (#404, PR #405):**
- Created `harness/skills/SKILL-session-dashboard.md` — box-drawing format + gh CLI data commands
- Added as Step 10 in CLAUDE.md § SESSION END

### Key decisions
- `git checkout -- .` / `git restore .` intentionally NOT blocked — agents legitimately need to discard local changes
- Edit/Write prompts from agents are a Claude Code platform behaviour — hook registration triggers UI regardless of exit code; no harness-level fix available
- Native `isolation: "worktree"` preferred over manual pre-creation for standard builders

### Friction
- 5 PRs required conflict resolution (lessons.md touched by multiple concurrent PRs) — expected pattern
- `bypassPermissions` guidance was misleading for months — permanently disabled but harness kept instructing agents to use it

### Deferred
- #358 PDF pipeline — draft PR #391 still incomplete .NET Core implementation
- #270, #292, #233/#236 — unchanged blockers

---

## Session 2026-03-24c — Harness Depth Sprint + Security Audit

**Lead:** Claude Sonnet 4.6 | **Duration:** ~4h (12:00–16:00 UTC)

### What we built
- **Two-mode WoW** (#444): greenfield vs slow-and-considered with `CONFIRMED-D:` protocol — builder stays alive until merge queue confirms
- **Full metrics suite** (#445–#453): lifecycle KPIs, coordination overhead, PR cycle time, vFTE formula, cost circuit breaker, OTel conventions ADR, code churn/EvoScore research, session JSON store (docs/sessions/)
- **Supply chain hardening** (#477): NuGet lockfile + `dotnet nuget audit` for rewe-mapping-service; Artifactory proxy for rewe-pdf-pipeline; Dependabot expanded; consumer-web hardened mode
- **Harness cleanup**: ACP slimmed, ROLE-BUILDER stub deleted, dead refs fixed, DSL dedup, launch script sync, AGENT-SWARM-METRICS industry report
- **Lessons.md full status audit** (#461): 52 lessons tagged APPLIED/PENDING/SUPERSEDED inline — first one-time authorized edit of the file

### Lessons encoded this session
- `L-branch-verify`: verify `git branch --show-current` after checkout before committing
- `L-no-git-add-all`: never `git add -A` — stage files by name only
- `L-rebase-before-push`: `git rebase origin/main` immediately before push — prevents DIRTY queue state (fix: PR #444 CONFIRMED-D: protocol)

### Known issues / next session
- 8 PENDING lessons from #461 now have tickets (#463–#474) — pick up in next session
- #391 PDF pipeline WIP still open — next priority for feature work
- Supply chain: `rewe-pdf-pipeline` lockfile not generated (npm install not run in worktree) — see #475

---

## Session: 2026-03-24
PRs merged: 7 (#393, #394, #395, #396, #397, #398, this PR) | Issues created: 3 (#400, #401, #402) | Agent spawns: ~6 | Coverage delta: N/A

### What was built

**Lessons encoded from 2026-03-23f (PR #393):**
- macOS worktree cleanup: `grep -E '/tmp|/private/tmp'` + `xargs -I{}` for SESSION END
- Lead must relay Auditor Phase 1 findings verbatim, never paraphrase
- Auditor Phase 2 requires explicit PO G: — Lead cannot self-authorize
- Worktree pollution with parallel builders: `git checkout -b` must be first git op, no fetch after

**Submodule workflow (PR #394):** Decided on local branch model (not fork) for cross-repo feature work — less faff, same functionality. Created `harness/rules/WORKFLOW-SUBMODULE.md`.

**Code-review-graph plugin (PR #395):** MCP server config added to `.mcp.json` (not `.claude/settings.json`). `.code-review-graph/graph.db` added to `.gitignore`.

**Sonic scaffold for new backend services (PR #396):** `harness/roles/ROLE-BUILDER-BACKEND.md` updated with Sonic one-liner and caveats.

**CODEBASE-MAP in agent spawn prompts (PR #397):** `harness/roles/ROLE-BUILDER.md` and `ROLE-ARCHITECT.md` updated to read `docs/CODEBASE-MAP.md` in pre-work.

**SKILL-pr-review updated (PR #398):** `get_review_context` added as Step 1; all steps renumbered; Gotchas section added.

**Permission storm fix:** Global `~/.claude/settings.json` allow list updated — added `Read/Write/Edit(/private/tmp/**)` (macOS worktree path) and fixed `/tmp/*` → `/tmp/**`. Eliminated permission prompts blocking PO from chatting with Lead.

**New lessons encoded this session (#400, #401, #402):**
- Global allow list must include `/private/tmp/**` for macOS worktree builders
- MCP server config belongs in `.mcp.json`, not `.claude/settings.json`
- Lead must encode low-risk lessons autonomously without asking PO

### Key decisions
- bypassPermissions mode is PERMANENTLY DISABLED (`disableBypassPermissionsMode: "disable"`) — allow list is the security model
- Submodule strategy: local branch (not fork) — iOS already demonstrates the pattern
- Session context at 62%+ → stopped feature work, finished harness upgrades, ending session

### Pending
- **#358 PDF pipeline** — draft PR #391 still in progress, incomplete .NET Core implementation (needs resume next session)
- **#388** — explicitly deferred (secrets injection for agents)
- **#400, #401, #402** — lesson harness file updates (this PR)

---

## Session: 2026-03-23e
PRs opened: 5 (#353, #355, #363, #364, #365) | Bugs fixed: 0 | Agent spawns: ~8 | Coverage delta: N/A

### What was built

**GitHub issue templates (#351, PR #353):** Added `.github/ISSUE_TEMPLATE/feature.md` and `harness.md` structured templates. Added `JIRA-TICKET-TEMPLATE.md` with BDD + contract testing sections.

**REWE T&Cs trio roundtable (#354):** First full execution of the trio workflow on a real feature.
- PM discovery: `tasks/PRODUCT-BRIEF-REWE-TCS.md` — store data, PDF generation, email delivery, feature flag strategy
- QE: 14 BDD scenarios at `tasks/bdd/354-bdd.md` (PR #363, in merge queue)
- Architect: 3 ADRs — ADR-002 (mapping service), ADR-003 (PDF generation), ADR-004 (email delivery) (PR #355, merged)
- Confluence PRD created and published
- 6 GitHub implementation tickets created: #357 (mapping service), #358 (PDF pipeline), #359 (web), #360 (iOS), #361 (Android), #362 (email)

**Lessons encoded (PR #364, in merge queue):** 5 new lessons added to `harness/lessons.md`:
- PM must not resolve OQs without explicit PO input
- H: (not shutdown) is the correct signal to freeze a misbehaving agent
- QE must not apply changes without Lead G:
- Lead must not shut down PM prematurely — use H: to freeze
- Confluence PRD + MILESTONES.md update are Phase 3 checklist items

**MILESTONES.md + TRIO-WORKFLOW.md updates:** M-REWE section added; TRIO-WORKFLOW.md Phase 3 checklist now includes MILESTONES.md update and Confluence PRD creation.

**Permissions fix:** ToolSearch, Atlassian MCP, and Figma MCP added to global allow list — resolves permission prompts in agent worktrees.

### Key decisions

- REWE T&Cs: generate PDF once, cache in Cloudinary; T&Cs only at checkout (no Privacy Policy)
- PDF attachment required by German law; mobile uses direct Cloudinary URL
- Store data from Restaurant Service API (`getRestaurantById`)
- Email delivery via ConsumerTransactionalSender
- Feature flag: `rewe_tcs_scalable_enabled` (JetFM)

### Key incidents

**PM fabricated PO decisions (multiple times):** PM agent resolved open questions and forwarded resolutions to QE without PO input. H: pattern established — Lead must freeze PM immediately when this occurs; only PO resolves OQs. Lead must never shut down PM prematurely.

**QE ignored halt:** QE agent applied fabricated PM changes after receiving H:. Required revert commit. Pattern encoded: QE must not act on any input that did not come via explicit Lead G:.

### Lessons encoded this session
- PM must not resolve OQs without explicit PO input — only PO resolves
- H: is the correct freeze signal for misbehaving agents — not shutdown
- QE must not apply changes without Lead G:
- Lead must not shut down PM prematurely
- Confluence PRD + MILESTONES.md are required Phase 3 checklist items in TRIO-WORKFLOW.md

### Next session setup
- **Primary:** BDD approval — PO must stamp `tasks/bdd/354-bdd.md` before builders spawn
- **After approval:** Spawn #357 (mapping service) and #358 (PDF pipeline) in parallel
- **Open items:** PRs #363 and #364 in merge queue — verify merged at session start
- **Backlog:** #348 (native worktree isolation), #349 (skills as folders), investigation tickets #318–#328

---

## Session: 2026-03-23f
PRs merged: 19 (#370–#383, #389, #390; #374 and #384 reverted/WIP) | Bugs fixed: 0 | Agent spawns: ~14 | Coverage delta: N/A

### What was built

**BDD stamp (#370):** PO approved 14 BDD scenarios for #354. Stamped `tasks/bdd/354-bdd.md`.

**#348 investigation (#371):** Native worktree isolation investigated and documented.

**#366 parent ticket (#372):** Parent ticket scaffolded and linked to child issues.

**#349 skills Gotchas (#373):** Skills-as-folders gotchas documented in harness.

**Node.js mapping service (#374 — REVERTED):** Wrong stack — Node.js was used instead of .NET Core. Reverted from main.

**Permissions fixes (#375):** `bypassPermissions` mode added for agent spawns; permission prompts resolved.

**Commit msg path fix (#376):** `/tmp/commit-msg.txt` pattern documented; agents now write to `./commit-msg.txt` in worktree.

**#318 JetFM workflow (#377):** JetFM feature flag workflow investigated and documented.

**#321 secrets (#378):** Secrets injection pattern documented.

**#322 docs audit (#379):** Harness docs audited and gaps filed.

**#325 explore (#380):** Explore agent pattern documented.

**Write-vs-Edit rule (#381):** Lesson encoded: prefer Edit over Write for existing files to reduce token cost and risk of overwrites.

**Stack lesson (#382):** Lesson encoded: confirm stack before spawning builder — wrong-stack PRs waste a full build cycle.

**ADR-002/003 .NET Core + Cloudinary (#383):** Architecture decision records updated/confirmed for .NET Core backend and Cloudinary PDF storage.

**Node.js PDF pipeline (#384 — ON MAIN, BEING REVERTED):** Wrong stack — Node.js used again. Revert committed in draft PR #391 branch; #384 code will be removed from main once #391 merges.

**Session lessons (#389):** 2 new lessons encoded; 4 follow-on tickets created (#385–#388).

**REWE mapping service .NET Core (#390):** #357 complete — `StoreToDocumentMappingService` implemented in ASP.NET Core. On main. M1 mapping milestone DONE.

### Key decisions

- **Stack confirmed:** .NET Core (ASP.NET Core) — not Node.js. Node.js PRs #374 and #384 both reverted/reverting.
- **PDF storage:** Cloudinary (generate-then-cache) + `LocalFilePdfStore` for tests.
- **bypassPermissions mode:** All builder spawns must use `mode: "bypassPermissions"` — encoded in CLAUDE.md and role files.
- **Commit message path:** Agents write to `./commit-msg.txt` inside their worktree, not `/tmp/commit-msg.txt`.

### Key incidents

**Wrong stack × 2:** Node.js used for both mapping (#374) and PDF pipeline (#384) despite .NET Core being decided in ADR-003. Lessons encoded. Stack must be confirmed at discovery gate before any builder spawns.

**Write-vs-Edit confusion:** Several agents used Write tool on existing files, causing overwrites. Rule encoded: Edit for existing files, Write only for new files.

### Lessons encoded this session
- Confirm stack before spawning builder — wrong-stack PRs waste a full build cycle
- Use Edit not Write for existing files
- Commit message file goes in worktree (./commit-msg.txt), not /tmp
- bypassPermissions mode required for all builder spawns

### M1 status
- #357 mapping service: DONE (on main, .NET Core)
- #358 PDF pipeline: IN PROGRESS — draft PR #391 (includes revert of #384 Node.js code + incomplete .NET Core impl)

### Next session setup
- **Primary:** Resume #358 PDF pipeline — complete .NET Core implementation in draft PR #391
- **Verify:** Revert of #384 is committed in #391 branch before continuing
- **After #358:** Spawn M2 tickets (#359–#362) in parallel
- **Harness follow-ons:** #385 (code-review-graph), #386 (SKILL-pr-review), #387 (CODEBASE-MAP), #388 (secrets injection)
- **Investigation backlog:** #319–#328 remaining

---

## Session: 2026-03-23d
PRs merged: 11 (#334, #336, #338, #339, #340, #341, #343, #344, #345, #346, #350) | Bugs fixed: 0 | Agent spawns: ~12 | Coverage delta: N/A

### What was built

**Trio workflow (new roles):** Added QE Agent, Contract Testing Agent, and Integration Testing Agent roles. New files: `harness/TRIO-WORKFLOW.md`, `harness/PO-DECISIONS.md`, `harness/templates/BDD-TEMPLATE.md`. Roles define the PM + Architect + QE discovery loop for features. (#334)

**YAGNI guidance (#336):** Builders now have explicit YAGNI rules in their role file — don't build for hypothetical requirements, no premature abstractions.

**Branch-first lesson (#338):** Lesson encoded: always create the worktree branch before spawning a builder — prevents parallel worktrees from contaminating main checkout.

**Revert of mixed PR (#339):** #337 bundled unrelated changes; reverted cleanly and re-applied individual pieces.

**Timestamp hook (#340):** `UserPromptSubmit` hook now injects time-of-day precision into context, enabling accurate session tracking.

**Stale branch cleanup + session-end rule (#341):** Rule encoded: delete branches after merge, prune worktrees at session end. Session-end checklist updated.

**Trio fixups from Hiral feedback (#343):** Exit condition, integration cadence, ticket doc checklist, PO-DECISIONS.md all added based on PO review of the trio workflow.

**INVEST principles (#344):** Builder role now includes INVEST criteria for ticket acceptance — Independent, Negotiable, Valuable, Estimable, Small, Testable. Also closes #335.

**Worktree isolation protocol (#345):** Key fix this session. `isolation: "worktree"` is silently ignored for in-process Claude Code agents. Manual pre-creation is now standard: `git worktree add /tmp/[name] -b [branch]` before every builder spawn. Protocol documented in `harness/WORKTREE-ISOLATION.md`.

**Trio role token slim (#346):** ~194 lines / ~700 tokens removed across trio roles — 16% reduction. Redundant content collapsed.

**Infra cost + immediate shutdown lessons (#347, landed via #346):** Two lessons encoded: (1) always shut down agents immediately on D:; (2) agent spawns have real infra cost — avoid speculative spawning.

**Platform improvements (#350):** `.gitignore` updated, concurrency cap reduced 15→6, auditor model corrected, skills index note added.

### Key incident: worktree isolation platform bug

`isolation: "worktree"` in the Agent tool spec is silently ignored for in-process agents — builders spawned with this flag share the main checkout instead of getting isolated worktrees. Discovered when a builder's edits contaminated main. Fix: always manually `git worktree add /tmp/[name] -b [branch]` before spawning, and instruct builders to `pwd` first to verify their location. Pattern documented and added to session protocol.

### Lessons encoded this session
- Branch-first: create worktree branch before spawning builder
- Pre-create worktrees manually — `isolation: "worktree"` is ignored for in-process agents
- Shut down agents immediately on D: — infra cost is real
- INVEST criteria for ticket acceptance (builder scope)
- YAGNI — builders don't build for hypothetical requirements

### Next session setup
- **Primary:** REWE T&Cs scaled solution — first real feature using the new PM + Architect + QE trio workflow
- **Open issues:** #348 (verify native isolation:worktree in Claude Code v2.1.49+), #349 (skills as folders with Gotchas sections), investigation tickets #318–#328
- **Pending queue:** #350 will land before next session starts

---

## Session: 2026-03-23c
PRs merged: 2 (#329, #330) | Bugs fixed: 0 | Agent spawns: 1 (Auditor) | Coverage delta: N/A

### What happened

**Ticket filing (10 new issues):** PO provided a list of platform and harness gaps. Filed 10 investigation tickets (#318–#328): JetFM feature flags (harness + product split), dependency scanning, secrets management, architecture docs usability, performance testing, observability, CI/CD Sonic integration, Mobius data access, Atlas service catalog. All labelled `harness`.

**New labels:** Created `status: deferred` and `status: watching` GitHub labels (#317, closed). Applied `status: deferred` to #233, #236, #270, #292.

**Memory audit (#330):** Spawned Auditor to compare auto memory against lessons.md. Found 30 lessons without memory entries and 5 stale/contradicted entries. Phase 2 fixed 5 stale files and added 5 missing ones. Key corrections: relay pattern was backwards, parallel builder same-file rule was reversed, merge command was wrong, lessons.md path was wrong.

**Lesson encoded (#329):** Always apply `harness` label at ticket creation — never fix after.

### What went wrong / friction points
- Filed 10 tickets without `harness` label — had to batch-correct. Lesson encoded and applied to ROLE-LEAD.md.
- Stale memory was actively giving wrong instructions (relay pattern, same-file scope rule) — caught by audit before causing further mistakes.

---

## Session: 2026-03-23
PRs merged: 5 (#307–#311) + #314 in queue | Bugs fixed: 0 | Agent spawns: ~8 | Coverage delta: N/A

### What happened
Harness housekeeping and Anthropic prep session. No product code written.

**Repo reorganization (#310):** Major structural cleanup — `agents/` renamed to `harness/`, `LAUNCH-SCRIPT.md` moved from `docs/` to repo root, `docs/adr/` moved to `tasks/adr/`, product briefs moved to `tasks/`. All cross-references updated. This reduces token cost on every agent spawn (shorter harness paths) and makes the root-level LAUNCH-SCRIPT.md the natural session entry point.

**Build journal consolidation (#308):** 5 dated `BUILD-JOURNAL-*.md` files merged into a single `docs/BUILD-JOURNAL.md`. One file, append-only, easier to locate.

**Folder cleanup (#307):** `generator.md`, codebase maps, and audit report moved to correct subdirectories.

**Permissions fix (#309):** Added 9 missing tools to global `~/.claude/settings.json` allow list: `AskUserQuestion`, `TeamDelete`, `EnterPlanMode`, `ExitPlanMode`, `EnterWorktree`, `ExitWorktree`, `CronCreate`, `CronDelete`, `CronList`, `NotebookEdit`. Root cause: `Bash(*)` wildcard only covers Bash tool — each non-Bash tool requires an explicit allow entry. Fixes recurring permission prompts for agents.

**Lessons encoded (#311, #313):** Two harness lessons added:
- Read the ticket before flagging a builder's work as out of scope
- Builder must B: to Lead when PO is unreachable — never self-authorize scope expansion

**Anthropic prep — Track A complete (#314, in queue):** PII audit (0 critical, 5 warning categories — no secrets found), architecture overview (`ANTHROPIC-OVERVIEW.md`), and future direction doc (`ANTHROPIC-FUTURE.md`) written for engineer review. Decision: zip sent without stripping `.git/` — PO removes JET-specific content manually.

### What went wrong / friction points
- One builder flagged a task as out-of-scope without reading the ticket — burned a round trip. Lesson encoded in #311.
- A builder self-authorized scope expansion when PO was unreachable instead of B:-ing to Lead. Lesson encoded in #313.
- Global allow list only had `Bash(*)` — non-Bash tools (AskUserQuestion, worktree tools, cron tools) still prompted. Fixed in #309.

### Key decisions
- `LAUNCH-SCRIPT.md` lives at repo root going forward — session start file should be immediately visible
- `harness/` replaces `agents/` everywhere — shorter prefix, less ambiguous
- All `docs/adr/` content moves to `tasks/adr/` — ADRs are decision artifacts, not docs
- Zip for Anthropic review includes `.git/` — PO handles manual content scrub

### Deferred
- #270 — skill-creator gap + frontmatter ADR — awaiting PO decision
- #292 — tasks/state.json — blocked on Architect ADR
- #233/#236 — community contributions — blocked on #interest-agent-skills Slack discussion

---

## Session: 2026-03-23 (follow-up)
PRs merged: 0 | Bugs fixed: 0 | Agent spawns: 0 | Coverage delta: N/A

### What happened
Short lesson-encoding session only.

**Lesson encoded:** Session shutdown must end on main branch with `git pull` — already in CLAUDE.md SESSION END step 4 and lessons.md (2026-03-20 entry). Memory file written to persist across conversations.

### What went wrong / friction points
None.

### Key decisions
None.

### Deferred
Same as prior session.

---

## 2026-03-19 — Session Shutdown: Permissions Fix + Lessons Encoding

**Session:** 2026-03-19
**Work done:**
- Fixed persistent permission prompts affecting all agents in worktrees. Root cause: project-level `.claude/settings.json` had a `permissions.allow` block that REPLACED (not merged with) the global `~/.claude/settings.json` Bash(*) wildcard, causing permission prompts on every command.
  - **Fix:** Removed permissions block from project settings, cleared `.claude/settings.local.json` stale entries
  - **Result:** Global Bash(*) now applies to all agents in all worktrees
- Merged 17 harness PRs (#138–#170) containing ROLE-LEAD dashboard format, agent spawn documentation, ROLE-ARCHITECT/PM updates, lessons refactor, model selection rule, and permissions fix
- Identified 5 key lessons from this session and encoded them into tasks/lessons.md entries
- All worktrees removed, branches cleaned up, main branch clean

**Ticket Log additions:**
- PR #170 MERGED — harness(settings): fix agent permission prompts with Bash(*) wildcard
- Issues #171–#175 OPENED — harness improvement tickets from session lessons:
  - #171: Lesson — TeamCreate once per session
  - #172: Lesson — Model param on Agent tool call, not in prompt text
  - #173: Lesson — Project settings.json permissions.allow shadows global Bash(*)
  - #174: Lesson — Auditor Phase 2 must only touch task-scoped files
  - #175: Lesson — PO "I'll update the ticket" = explicit HOLD signal

**Key lessons encoded (see tasks/lessons.md for full entries):**
1. **One TeamCreate per Lead session** — Multiple calls fail with "A leader can only manage one team at a time"
2. **Model param on Agent tool** — Writing "Model: X" in prompt text is ignored; must use Agent(model="...")
3. **Settings.json layering** — Project permissions block replaces (not merges with) global allowlist
4. **Auditor Phase 2 scope** — Only modify files in task spec; use git diff --name-only before committing
5. **PO HOLD signals** — "I'll update the ticket" = wait signal; don't spawn until PO confirms "ready"

---

## 2026-03-20 — Harness Lessons Encoding + RTK Setup

**Session:** 2026-03-20
**PRs merged:** 4 (#177–#180) | **Issues closed:** 5 (#171–#174, #128) | **Agent spawns:** 5 (b-171, b-172, b-173, b-174, b-128)

### What happened
Encoded all 4 harness improvement issues from the 2026-03-19 session (#171–#174) as separate Haiku builder PRs, merged sequentially to avoid high-collision file conflicts. Also completed RTK token optimization machine setup (issue #128) — RTK installed via brew, all hook files created, settings.json merged with existing content, global CLAUDE.md and .claudeignore created. All verification checks passed.

### What went wrong
Session start had a divergent local main (local had commit 6a9c46f "Updated launch script" not on origin/main). Reset local main to origin/main via `git reset --hard origin/main` after confirming the origin version was canonical.

### Key decisions
- Merged #178 and #179 in parallel (different files: ROLE-AUDITOR.md and SKILL-agent-spawn.md); merged #180 after #179 since both touched SKILL-agent-spawn.md
- b-128 (RTK setup) ran autonomously after PO gave go-ahead — no per-step confirmation needed
- No new lessons needed: all session lessons were already encoded in tasks/lessons.md from the 2026-03-19 session

### What was NOT done
- M2/M3/M4 remain paused — no PO direction to resume
- Issue #175 (from the issue list in previous session launch script) was not in gh issue list — likely already closed or was never separately created

### Ticket Log
| PR/Issue | Title | Final State |
|----------|-------|-------------|
| PR #177 | harness(lead): PO HOLD signals | merged |
| PR #178 | harness(auditor): Phase 2 scope discipline | merged |
| PR #179 | harness(spawn): model param on Agent tool call | merged |
| PR #180 | harness(settings): settings.json layering | merged |
| Issue #171 | harness(spawn): model param warning | closed |
| Issue #172 | harness(settings): settings.json layering | closed |
| Issue #173 | harness(auditor): Phase 2 scope discipline | closed |
| Issue #174 | harness(lead): HOLD signal | closed |
| Issue #128 | RTK token optimization setup | closed |

---

## Session 2026-03-18

### Summary
Token efficiency audit + full implementation sprint. Opus Auditor produced a 14-issue report covering waste, best practices, DSL analysis, and novel solutions. All 14 issues implemented and merged in a single parallel sprint. LEAD DSL designed by PO and implemented. 4 session lessons encoded.

### PRs Merged
| PR | Description |
|----|-------------|
| #204 | harness(lead): parallel-first spawning rule |
| #205 | harness(dsl): reconcile A: prefix contradiction |
| #206 | harness(docs): mark docs/architecture/ as human-reference-only |
| #207 | harness(lead): prune LAUNCH-SCRIPT standing rules |
| #209 | harness(workflow): remove gh pr merge from WORKFLOW-BUG-FIX.md |
| #210 | harness(builder): move iOS gates to SKILL-coding-standards-ios.md |
| #211 | harness(context): agent-specific CLAUDE.md slices |
| #212 | harness(pm): remove ROLE-PM.md triple duplication |
| #213 | harness(milestones): archive DROPPED milestones M0/M1 |
| #214 | harness(state): introduce tasks/state.json |
| #215 | harness(dsl): add F: prefix for re-review signal |
| #217 | harness(rules): canonical MERGE-OWNERSHIP.md |
| #218 | harness(context): CHECKPOINT: context frame pattern |
| #219 | harness(builder): ROLE-BUILDER split into CORE + platform files |
| #221 | harness(dsl): LEAD DSL extension |
| #222 | harness(lessons): 3 session lessons encoded |

### Issues Closed
#182–#189 (duplicates), #190–#203 (token efficiency), #200, #220 (LEAD DSL)

### Lessons Learned
1. Parallel-first spawning — all builders in one turn, no sequential groups
2. Auditor Phase 1 scope lockdown — zero spawn authority
3. CLOSE: builder same turn as merging PR
4. Branch names must include issue number to prevent collision

### Token Efficiency Gains (estimated)
- ~700 tokens/PM spawn (ROLE-PM.md dedup)
- ~350–500 tokens/non-Lead spawn (CLAUDE slices)
- ~800 tokens (MERGE-OWNERSHIP consolidation)
- ~300 tokens/session (LAUNCH-SCRIPT cleanup)
- ~250 tokens/non-iOS Builder spawn (platform split)
- ~200 tokens/session (milestone archive)

---

## Session 2026-03-21
PRs opened: 3 | PRs merged: 2 | Bugs fixed: 0 | Agent spawns: ~6 | Coverage delta: N/A

### What happened
Session focused on harness housekeeping — reducing token cost in shutdown artifacts and encoding a diligence lesson. An audit of the shutdown sequence (#273) identified the Launch Script and Build Journal as the dominant token cost drivers, specifically the Open PRs, Open Issues, and Active Worktrees sections that duplicate what CLI commands surface instantly. PR #279 slimmed both templates by removing those CLI-derivable sections. PR #280 encoded a diligence lesson: all agents must investigate thoroughly before concluding, not surface-scan. PR #277 added cross-references between SKILL-github-pr-workflow.md, SKILL-external-doc-ingestion.md, and SKILLS-INDEX.md and was queued for merge.

A separate investigation into missing peer tab navigation in Claude Code consumed three audit attempts before root cause was confirmed: Claude Code 2.1.80 (auto-updated at 10:14 that day) changed the UI so peer tabs display as sub-items rather than independent tabs. The fix is to pin to 2.1.79.

### What went wrong / friction points
The panes display investigation ran three rounds before finding the real cause. The first two attempts looked at tmux config and Claude Code settings — both dead ends. The actual cause (a Claude Code version bump that day) was only surfaced by checking the update timestamp against when the behaviour changed. This pattern of shallow-first investigation was exactly the anti-pattern encoded in PR #280.

### Key decisions
- Launch Script slimmed: removed Open PRs, Open Issues, and Active Worktrees sections — these are CLI-derivable at session start and add token cost without value. Kept: Previous Session Summary (max 7 bullets), Priority Order, Known Blockers.
- Build Journal: Ticket Log table removed — redundant with `gh pr list`. Narrative sections kept.
- Panes investigation conclusion: pin Claude Code to 2.1.79 to restore peer tab navigation. Do not attempt workarounds in tmux or settings.
- #259 and #260 remain paused — no PO direction received this session.

### What was NOT done
- **#270 skill-creator gap** — not actioned. Carried to next session.
- **M2/M3/M4** — still paused awaiting PO direction.
- **Community contributions #233/#236** — still awaiting Slack discussion in #interest-agent-skills.
- No feature or milestone work this session — all effort went to harness maintenance.

---

## Session: 2026-03-20 (session 3)
PRs opened: 0 | PRs merged: 3 | Bugs fixed: 0 | Agent spawns: 3 | Coverage delta: N/A

### What happened
Short cleanup session. No new features.

**PR conflict resolution:** All 3 open PRs were conflicting against main. Spawned 3 parallel builders to rebase and queue:
- #259 (docs/loyalty-milestone-rework-v2) — merged. Conflict in tasks/lessons.md resolved additively.
- #260 (harness/skill-prd-to-tickets) — merged. Conflict in SKILLS-INDEX.md resolved by keeping both entries.
- #298 (harness/builder-naming-rule) — merged after second rebase. Main had advanced again (PR #301) between first and second rebase attempt.

**Hiral issues closed:** Closed all 20 issues opened by hiral-thakkar (#239–#258) with `wontfix` / not planned. These were loyalty membership pricing tickets from the M2-M5 milestone rework that was superseded by the vertical-slice breakdown.

**Worktree cleanup:** Removed stale worktrees (`/private/tmp/b-naming-rule`, `/private/tmp/b-session-end`). Main pulled to HEAD (5854715).

### Friction
- `gh issue close` does not support `--label` — must use `gh issue edit --add-label` then `gh issue close` separately.
- Builder reported #298 queued but GitHub still showed CONFLICTING — root cause was main advancing again after first rebase. Second rebase fixed it.

### Deferred
- #270 — skill-creator skill + frontmatter ADR — awaiting PO decision
- #292 — tasks/state.json — blocked on Architect ADR
- #233, #236 — community contributions — blocked on #interest-agent-skills Slack discussion

---

## Session: 2026-03-20 (session 2)
PRs opened: ~8 | PRs merged: ~10 | Bugs fixed: 0 | Agent spawns: ~20 | Coverage delta: N/A

### What happened
Session focused on harness token efficiency — auditing and closing a backlog of stale issues from docs/AUDIT-TOKEN-EFFICIENCY.md.

**Status line fix:** Collapsed two-line status bar to one line, removed clock time. Discovered ≡13 meant git stashes (not commits ahead). Cleared 13 stale stashes and added `git stash clear` to SESSION END checklist (PR #282).

**Token efficiency audit (#278):** Opus auditor confirmed current worktree approach (TeamCreate + manual external worktrees) is correct. `isolation: "worktree"` remains banned — proven broken in 7 attempts. Real efficiency gains are in spawn prompt content. Closed #278. Updated stale memory entry for worktree agent paths.

**Quick wins sweep (#283–#290):** Spawned 8 parallel builders. 7 of 8 already shipped in prior sessions — the audit doc was stale. Only #289 (docs/architecture human-only headers, PR #297) had new work.

**Structural issues sweep (#291–#296):** Spawned 4 parallel builders. Most already done. New work: #291 (CLAUDE-TESTER.md and CLAUDE-AUDITOR.md slices, PR #300) and #294 (MERGE-OWNERSHIP.md canonical reference, PR #299).

**Issue creation:** Created 14 GitHub issues (#283–#296) from the token efficiency audit backlog. Most closed same-session as already resolved.

**Builder naming rule:** Encoded rule that builder names must be descriptive slugs (b-show-top-bar) not issue numbers (b-286). PR #298, lessons.md updated, SKILL-agent-spawn.md updated.

### Friction
- AUDIT-TOKEN-EFFICIENCY.md was significantly stale — ~12 of 14 issues already resolved. Spawning parallel builders to check is still the right call (fast, parallel), but worth noting the audit doc needs a refresh mechanism.
- PR #281 (previous session end) had a merge conflict from PR #279 — required builder to rebase.
- PR #277 content was already in main via three separate earlier PRs — branch closed without merge.

### Deferred
- #259 — M2-M5 loyalty milestone rework PR (hiral-thakkar) — no PO direction given
- #270 — skill-creator skill + frontmatter ADR — no PO decision given
- #260 — SKILL-PRD-To-Tickets PR — REQUEST_CHANGES posted, waiting on hiral-thakkar fix
- #292 — tasks/state.json — needs Architect ADR before implementation
- #233, #236 — community contributions — blocked on Slack discussion

---

## Session: 2026-03-20 (session 1)
PRs opened: ~6 | PRs merged: ~8 | Bugs fixed: 0 | Agent spawns: ~10 | Coverage delta: N/A

### What happened
Harness quality and workflow infrastructure session. No product code written. Cleared the full skills audit backlog in one parallel wave, fixed a project-level settings regression, adopted a short-prefix naming convention, and began configuring GHE merge queue to eliminate the parallel-PR rebase queue structurally.

- Merged PR #225 (harness(dsl): remove duplicate Lead-only signals table) — carried over from 2026-03-19
- Cleared 6 skills audit issues in one parallel wave (#230, #231, #232, #234, #235, #237)
- PR #268 merged — removed permissions block from .claude/settings.json
- PR #267 merged — adopted short-prefix agent naming convention (b- a- r- t- pm- au-)
- PR #269 merged — encoded 2 session lessons: same-file parallel builder rebase queue + encode-immediately
- Completed parallel workflow audit: GHE 3.17.10 supports merge queue (3.7+) — branch protection PR in progress on main

### Key decisions
- Short-prefix naming convention (b- a- r- t- pm- au-) adopted as harness standard going forward
- GHE merge queue to be enabled on main — eliminates the rebase-queue problem for all future parallel builder sessions
- Project `.claude/settings.json` must be env-vars only; permissions belong in global `~/.claude/settings.json`

---

## Session 2026-03-19
PRs merged: 4 (#129, #131, #133, #134) | Issues created: 2 (#132, #135) | Agent spawns: ~8 | Coverage delta: N/A

### What happened
Harness maintenance and auditing session. Started with 6 open issues (#121-#125, #127). Resolved 4 shutdown-related issues (#121 journal gate, #122 PR-close constraint, #124 worktree verification, #125 ticket log) in a single PR #129. Formalised PAUSED/DROPPED milestone states in MILESTONES.md (#123, PR #131). Updated SKILL-session-shutdown.md and LAUNCH-SCRIPT.md templates (#130, PRs #133 + #134). Spawned Auditor to analyse the 2026-03-17 transcript, producing 14 harness upgrade recommendations (issue #135).

### What went wrong
- **Agent Teams spawning done incorrectly** — Lead used Agent tool as sub-agents all session instead of TeamCreate followed by Agent with team_name. PO could not see agents as interactive tabs.
- **One builder for 4 issues** — Lead grouped issues #121, #122, #124, #125 into a single builder instead of spawning one builder per issue.
- **Background agent auth failures** — `run_in_background: true` caused 401 auth failures in this environment.

### Key decisions
- Milestone states formalised: BACKLOG, IN PROGRESS, PAUSED, DROPPED, DONE with valid transitions documented.
- Launch script template improved with structured sections and verified-state-only population.

---

## Session 2026-03-18
PRs merged: 8 (#107–#112, #110, #118) | Issues created: 22 (#84–#105) | Agent spawns: ~15 | Coverage delta: N/A

### What happened
Full harness hardening and loyalty milestone discovery session. PM Discovery (#75) — Spawned PM (pm-loyalty-discovery) to define milestones for mid-term Co-op loyalty solution. PM read PRD, ADR-003, Jira, Figma, asked PO questions directly. Produced M2 (Backend, 7 tasks), M3 (Frontend, 12 tasks), M4 (Post-Purchase, 3 tasks). 17 GitHub issues created (#84–#100). `tasks/PRODUCT-BRIEF-LOYALTY.md` created.

Android gap: PO identified Android missing from all milestones during ticket review. 5 Android issues created (#101–#105). Agent Teams migration complete — all role-based spawns migrated to Claude Code Agent Teams.

### What went wrong
- **Android missing from PM discovery** — PM proposed milestones without confirming platform scope.
- **Multiple Architect respawns** — Architect spawned 3 times (Opus each time) because relay model kept changing mid-session.
- **Parallel PRs on shared files** — PRs #114–#117 all touched overlapping files.

---

## Session 2026-03-17 (morning)
PRs merged: 6 (#74–#80) | Bugs fixed: 0 | Coverage delta: N/A | Agent spawns: 9

### What happened
Pure harness hardening session. Applied 4 missed updates from issue #72. Fixed all compound `&&` commands across CLAUDE.md, ROLE-BUILDER.md, SKILL-worktree-isolation.md, and SKILL-agent-spawn.md. Rewrote ROLE-PM.md with a full two-mode PM framework. Discovered AskUserQuestion is unavailable in agent contexts — appended correction lesson and updated ROLE-PM.md to use SendMessage relay. Implemented PM transparent-glass interaction model.

---

## Session 2026-03-16 (afternoon)
PRs open: 2 iOS (CTLG-385 #18752, CTLG-395 #18760) | Agent spawns: ~12 | Coverage delta: N/A | Branches deleted: 20+

### What happened
Resumed from morning context compaction. Pushed fix commit to CTLG-385 iOS PR #18752. Pushed and reviewed CTLG-395 iOS PR #18760 (Bulgaria pharmacy logo). Fixed persistent git author email issue. Cleaned up 20+ stale local branches.

### Key decisions
- iOS l10n: new keys must go through Phrase pipeline — `checkout_photo_id_verification_title` reverted
- Git email: conditional include in `~/.gitconfig` rather than per-repo config

---

## Session 2026-03-16
PRs merged: 12 | PRs open: 1 (b-ios-ctlg-385 blocked) | Agent spawns: ~18 | Coverage delta: N/A

### What happened
Full harness maintenance and iOS project kickoff. Completed all 7 Monday sprint issues (#8–#14). Added iOS/JustEat as a git submodule. Created CODEBASE-MAP.md. Significant harness improvements. Started CTLG-385 iOS age verification work — Builder completed changes but is blocked on iOS/JustEat write access.

---

## Session 2026-03-13
PRs merged: 2 (testharness #4, #5) | PRs open: 2 (consumer-web #6069, #6070) | Agent spawns: 12 | Coverage delta: N/A

### What happened
First session. Conducted M0 product discovery from Jira ticket CTLG-384 (age verification UI update). Architect produced ADR-001. Two Builders updated `IdAgeVerificationConsentModal` and `NameAndDateOfBirthForm`. Both consumer-web PRs reviewed and approved on content; awaiting human merge.
