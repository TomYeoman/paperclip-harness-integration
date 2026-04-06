# Skill: PM + PO Discovery Session

Load this skill when: PM is pairing with PO to define product scope, validate platform coverage, structure milestones, and author tickets.

## Phase 1 — Pre-Session Readiness

Preparation checklist — complete before PO meeting:

- [ ] ADRs drafted or existing in `tasks/adr/` — Architect has defined interfaces that shape scope
- [ ] Jira epic(s) or GitHub issue(s) available for reference
- [ ] Figma design links accessible and validated — no 404s
- [ ] Platform availability confirmed with stakeholders — which of Web / iOS / Android / Backend are in scope?
- [ ] Previous PRDs and MILESTONES.md reviewed — understand current product state and sequencing
- [ ] harness/SYSTEM-KNOWLEDGE.md reviewed — know current module status and constraints
- [ ] Blockers or known constraints documented — e.g., "Backend API not ready until M2"

**Output**: A brief readiness checklist you can share with PO (3-5 lines). Do not proceed to Phase 2 if any pre-session item is red.

---

## Phase 2 — Inputs

Share context with PO:

- [ ] Jira epic or link to feature request
- [ ] Figma links (design flow file, wireframes, prototypes — link directly to frames, not top-level file)
- [ ] Existing product spec excerpts (if any)
- [ ] Stakeholder list — who needs to sign off on each milestone?
- [ ] Timing constraints — hard deadlines, release windows, market events

**Output**: A clean agenda doc or summary (1 paragraph) that PO sees at session start.

---

## Phase 3 — Platform Confirmation

**MANDATORY before any scope discussion.** Ask this as a single question with a checklist answer:

> **Which platforms are in scope for this feature? Please confirm each:**
> - Web: yes / no / TBD
> - iOS: yes / no / TBD
> - Android: yes / no / TBD
> - Backend: yes / no / TBD

**Do not skip this.** Platform scope is a first-class decision that shapes every milestone. If PO is uncertain about a platform, mark it TBD and define the decision point later (when, who decides, what unblocks it).

**Output**: Written platform decision. Example: "Web + Backend in M1. iOS + Android TBD — depends on Q2 roadmap."

---

## Phase 4 — Scope Boundaries

Present a three-way scope frame:

**In Scope:** Features, interactions, error states, platforms explicitly included
**Out of Scope:** Features or platforms explicitly excluded (with reason: "backend only", "v2", "market-specific", etc.)
**TBD:** Ambiguous areas that PO needs to decide

Walk through each section with PO, one at a time. For each TBD, record the decision point: _When do we decide? Who decides? What unblocks it?_

Example:

```
IN SCOPE:
- User can view order history (all platforms)
- Search by date range (Web only)
- Error handling for network timeout

OUT OF SCOPE:
- Analytics tracking (v2)
- Mobile offline mode (backend API not stable until Q2)
- Dark mode (design system not ready)

TBD:
- Pagination limits (decide when: after user research, owner: PO, unblock: week of [date])
```

**Output**: A scope document (1-2 pages max, clear bullets). Update this as PO clarifies.

---

## Phase 5 — Milestones

Map business phases to M-numbers. Walk through one at a time:

For each proposed milestone, confirm:
1. **What** — which features / user journeys / integrations?
2. **Which platforms** — subset of Phase 3 scope or all in-scope platforms?
3. **Why this sequencing** — dependencies, prerequisites, business drivers?
4. **Acceptance criteria** — how do we know this milestone is done?
5. **Dependencies** — other teams, APIs, designs needed before build starts?
6. **Rough T-shirt size** — S / M / L / XL (helps Lead estimate Builder load)

Example:

```
M1: Search + Filter
  What: Users can search orders by date range, status, amount
  Platforms: Web + Backend
  Why: Core user journey, unblocks M2 analytics
  Acceptance: Search query executes <500ms, all filter combinations work, error states handled
  Dependencies: Backend search API ready (owner: BE team lead, ETA: week of [date])
  Size: L

M2: Mobile Browse
  What: Simplified order view on iOS + Android (subset of Web features)
  ...
```

**Output**: A sequenced milestone list with all six items per milestone (in MILESTONES.md or draft).

---

## Phases 6–8: Exit Gates

See `harness/roles/ROLE-PM.md` for the definitive Phase 6–8 exit gates:
- Ticket writing format and checklist
- Platform confirmation requirements
- MILESTONES.md update (mandatory before D:)
- Parent discovery ticket closure

Do not duplicate these here — ROLE-PM.md is canonical.

---

## Pairing Discipline

**ONE QUESTION AT A TIME.** When multiple decisions are needed, present them as a numbered list up front so PO sees the full scope, then walk through each one individually. Never dump all questions and options in a single wall of text.

**Example — correct:**
```
Before we define milestones, I need to understand three things (one at a time):
1. Which platforms are in scope?
2. Are there hard deadlines?
3. Who owns sign-off?

Let's start with #1: Which platforms are in scope for this feature?
```

**Example — wrong:**
```
So I'm thinking we do Web first, then iOS, then maybe Android if time allows,
but we need to check with legal about the data handling, and also the backend
API might not be ready, so do you think we should...
```

---

## Recovery Table

| If you're stuck on... | Do this |
|----------------------|---------|
| Phase 1 failed (missing ADRs or links) | Contact Architect or Design; don't proceed until ready |
| Phase 3 unclear (platform scope TBD) | List the unknowns explicitly; ask PO to decide each one or set decision point |
| Phase 4 has too many TBDs | Prioritize: which TBDs block M1? Decide those now; park the rest |
| Phase 5 dependencies block everything | Create an ADR or task for the blocker; note it in MILESTONES.md; set decision date |
| Phase 6 tickets too vague | Go back to Phase 4 — scope boundaries are unclear; get PO to clarify |
| Phase 7 stakeholder missing | Async approval: send summary via email/Slack; set a deadline for approval |
| Phase 8 items incomplete | Finish them before next Builder session starts; do not hand off incomplete specs |

---

## Output Files

By session end, commit these files to a `harness/` branch:

```
tasks/PRODUCT-BRIEF.md        # Feature overview, scope, user journeys
docs/product/[feature].md    # Detailed PRD (if new feature)
tasks/adr/[name].md           # Architecture decisions affecting scope
tasks/MILESTONES.md          # Sequenced milestones with full context
GitHub issues               # One per Builder task (created during Phase 6)
tasks/OPEN-QUESTIONS.md     # Any parked decisions with decision point/owner
```

Create a PR with all docs changes; Lead merges (no Reviewer needed for docs-only).

---

## Checklist Before Next Builder Session

- [ ] tasks/PRODUCT-BRIEF.md exists and covers full feature
- [ ] All M1 acceptance criteria are testable (Tester can read and verify)
- [ ] All M1 GitHub issues created with platform scope called out
- [ ] Platform scope unambiguous for all platforms (in/out/TBD with decision point)
- [ ] Stakeholder approvals documented (approved / pending / blocked)
- [ ] MILESTONES.md updated and sequenced
- [ ] Figma links in tickets point to specific frames, not top-level files
- [ ] Phrase keys identified for localization tickets
- [ ] No TBDs left unparked (all have decision point, owner, ETA)
