# Trio Workflow: PM ↔ QE ↔ Arch Roundtable

## Participants
| Role | Responsibility |
|------|---------------|
| PM | Writes PRD; responds to QE challenges; owns acceptance criteria |
| QE | Challenges requirements; writes BDD scenarios; defines observability |
| Architect | Flags interface implications; writes ADRs; confirms no architectural ambiguity |
| Lead | Orchestrates the roundtable; holds Builder unlock authority |
| PO | Approves final BDD doc; gates Builder spawn |

## Entry Conditions
The Trio Workflow begins when ALL of the following are true:
1. PM has written a PRD draft (at `tasks/PRODUCT-BRIEF.md` or a milestone-specific path)
2. Lead has confirmed the PRD is ready for QE challenge
3. No Builders are spawned for this feature yet

Lead signal to start: `G: qe [task-id] — PRD ready at [path]`

## Phase 1: PM ↔ QE (Requirement Challenge)

**Goal:** All requirements are unambiguous and testable.

```
PM writes PRD
    ↓
QE reads PRD → identifies challenges
    ↓
QE sends challenges to PM via SendMessage
    ↓
PM clarifies → updates PRD
    ↓
QE updates BDD doc
    ↓
[iterate until no open challenges — max 3 rounds]
    ↓
QE signals Phase 1 complete: I: qe [task-id] Phase 1 complete — [N] scenarios drafted
```

**QE challenge format:**
```
CHALLENGE: [requirement excerpt]
ISSUE: [why it is ambiguous or untestable]
NEEDED: [what clarification or change resolves it]
```

**Exit condition:** QE has no remaining open challenges. All BDD scenarios have testable assertions.

## Phase 2: Arch ↔ QE (Interface Implication Review)

**Goal:** All interface implications are captured in ADRs; no BDD scenario assumes a non-existent interface.

```
QE shares BDD draft with Architect via SendMessage
    ↓
Architect reviews for interface implications
    ↓
Architect flags implications → writes ADRs for each
    ↓
QE adds scenarios driven by architectural constraints
    ↓
Architect confirms: I: arch [task-id] interface review complete — ADRs: [list]
    ↓
QE sends: I: qe [task-id] Phase 2 complete — proceeding to consolidation
```

**Exit condition:** Architect confirms no remaining interface ambiguities. All new interfaces have ADRs.

## Phase 3: Output Consolidation

**Goal:** Produce the combined artefact that gates Builder spawn.

QE produces:
- BDD doc at `tasks/bdd/[task-id]-bdd.md` (using `harness/templates/BDD-TEMPLATE.md`)
  - All BDD scenarios with observability hooks
  - Challenge log (QE ↔ PM)
  - Arch interface implications
- Jira ticket descriptions combining ADRs + BDD scenarios
- tasks/MILESTONES.md updated with new milestone section (Goal, Status, Product Brief, ADR links, Tasks table with issue numbers)

**Jira ticket documentation checklist** — QE/PM must complete for every ticket before submitting to PO:
- [ ] Link to relevant ADR(s)
- [ ] Link to BDD scenario(s) that cover this ticket
- [ ] Link to product brief / PRD section
- [ ] Dependencies on other tickets listed
- [ ] Dependencies on external systems or services listed
- [ ] Acceptance criteria traceable to BDD scenarios
- [ ] Platform scope explicitly stated (iOS / Android / Web / Backend / all)
- [ ] tasks/MILESTONES.md updated with milestone section and all issue numbers
- [ ] Parent discovery ticket closed with a comment linking to: BDD doc path, ADR file paths, Confluence PRD URL, and all child ticket numbers

**INVEST checklist** — every criterion must be checked before submitting ticket to PO:
- [ ] **I — Independent:** Ticket has no dependency on another in-progress ticket; can be picked up in isolation.
- [ ] **N — Negotiable:** Scope describes outcomes; implementation approach is not prescribed to the builder.
- [ ] **V — Valuable:** Completing this ticket produces an observable change in user experience or system behaviour.
- [ ] **E — Estimable:** Ticket is specific enough for a builder to estimate effort; all ambiguous terms are defined.
- [ ] **S — Small:** Expected change is ≤400 lines. If larger, split into sub-tickets before submission.
- [ ] **T — Testable:** Every acceptance criterion maps to at least one BDD scenario in this document.

Tickets that fail any INVEST criterion must be revised and re-verified before PO review.

QE signals completion:
```
R: qe [task-id] BDD doc ready at tasks/bdd/[task-id]-bdd.md — awaiting PO approval
```

## Phase 4: PO Approval Gate

Lead presents BDD doc to PO.

| PO Decision | Lead Action | Next Step |
|-------------|-------------|-----------|
| Approved | Lead creates milestone plan | Proceed to milestone plan approval |
| Revise | `G: qe [task-id] revise: [feedback]` | QE returns to Phase 1 with PM |

**Approved BDD doc is immutable** — no scenario changes after PO approval without a new approval cycle.

### Phase 4b: Milestone Plan

After PO approves the trio output (BDD doc + Jira tickets), Lead creates a milestone plan before any Builders are spawned:

1. Lead drafts milestone plan covering scope, Builder assignments, and sequencing
2. Lead presents plan to PO
3. PO approves milestone plan

**Required fields in milestone plan:**
- Scope: which BDD scenarios and tickets are included in this milestone
- Builder assignments: which Builder handles which ticket
- Sequencing: dependency order — which tickets must land before others can start
- Dependency map: external or cross-ticket dependencies that could block progress

Only after milestone plan approval does Lead send G: to Builders.

| Milestone Plan Decision | Lead Action | Next Step |
|------------------------|-------------|-----------|
| Approved | `G: builders [task-id]` | Builders spawned — feature work begins |
| Revise | Lead revises plan | Re-present to PO |

## Output Artefacts

| Artefact | Path | Owner |
|----------|------|-------|
| BDD doc | `tasks/bdd/[task-id]-bdd.md` | QE |
| ADRs | `tasks/adr/ADR-[N]-[name].md` | Architect |
| Jira tickets | Jira project | Lead / PM |
| Milestone plan | Presented to PO by Lead | Lead |

## Builder Unlock Signal
Lead sends to all relevant Builders after milestone plan is approved:
```
G: [builder-name] [task-id] — BDD doc approved at tasks/bdd/[task-id]-bdd.md. ADRs: [list]
```

Builders read the BDD doc as their acceptance criteria. Test names must match BDD scenario names.

## Post-Merge Gate
After Builders merge and staging deploys, Lead triggers Integration Tester:
```
G: integration-tester [task-id] — staging deployed, BDD doc at tasks/bdd/[task-id]-bdd.md
```

Integration Tester runs every BDD scenario and every observability hook. Feature is DONE only when Integration Tester returns PASS on all platforms.

If Integration Tester fails: Lead sends Builder the failed scenario/event to fix. Builder fixes, merges, staging redeploys, Lead re-triggers Integration Tester. Repeat until PASS.
