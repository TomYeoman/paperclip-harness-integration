# Milestones Archive

> This file holds milestones that are DROPPED or DONE. Active milestones are in tasks/MILESTONES.md.

---

## M0: Project Scaffold
**Goal**: Establish product brief, milestone structure, and Architect research spike for CTLG-384.
**Status**: DROPPED — Agent Teams experiment. PRs closed.
### Tasks
| # | Task | Status | Agent |
|---|------|--------|-------|
| 1 | PM discovery — write PRODUCT-BRIEF.md | DONE | lead |
| 2 | Architect: research spike on consumer-web age verification | DONE | a-age-verif-spike |
| 3 | Builder: implement UI changes | IN PROGRESS | b-consent-modal, b-dob-modal |
### Completion Gates
1. All tasks DONE and merged to main
2. CI green on main
3. Project compiles on all targets
4. PO validation: PO has reviewed and accepted the milestone deliverables
5. harness/SYSTEM-KNOWLEDGE.md updated with milestone module status
6. Retrospective written using harness/templates/RETRO-TEMPLATE.md

---

## M1: Age Verification UI Update (CTLG-384)
**Goal**: Update the ID age verification consent modal and DOB entry screen to match new Figma layout and text.
**Status**: DROPPED — Agent Teams experiment. PRs closed (consumer-web #6069, #6070; iOS #18752, #18760).

### Tasks

| # | Task | GitHub Issue | Files |
|---|------|-------------|-------|
| 1 | Update IdAgeVerificationConsentModal JSX to match Figma layout | #2 | checkout/src/components/age-verification/id-age-verification-consent-modal/id-age-verification-consent-modal.jsx + checkout/tests/unit/component/id-age-verification/id-age-verification-consent-modal/id-age-verification-consent-modal.test.jsx |
| 2 | Update NameAndDateOfBirthModal JSX to match Figma layout | #3 | checkout/src/components/age-verification/name-and-date-of-birth-modal/name-and-date-of-birth-modal.jsx + checkout/tests/unit/component/name-and-date-of-birth/name-and-date-of-birth-modal.test.jsx |

### Completion Gates
1. All tasks in milestone are DONE and merged to main
2. CI green on main
3. Project compiles and runs on all target platforms
4. PO validation: PO has reviewed and accepted the milestone deliverables
5. harness/SYSTEM-KNOWLEDGE.md updated with milestone module status
6. Retrospective written using harness/templates/RETRO-TEMPLATE.md

---

## Milestone States

Valid states and their meanings:

| State | Meaning |
|-------|---------|
| BACKLOG | Defined but not yet started — awaiting scheduling |
| IN PROGRESS | Actively being worked on |
| PAUSED | Work defined, not scheduled — pick up only on explicit PO direction |
| DROPPED | Experiment complete or descoped — PRs closed, no further work |
| DONE | All completion gates met and PO accepted |

### State Machine

Valid transitions:

```
BACKLOG → IN PROGRESS → DONE
BACKLOG → PAUSED
IN PROGRESS → PAUSED
IN PROGRESS → DROPPED
PAUSED → DROPPED
```

Re-activating a PAUSED milestone requires explicit PO direction; update status to IN PROGRESS at that point.

---

## M2: Loyalty Backend — NewPrice Offer Type + CSV Import (REPLACED)
**Goal**: Introduce the `NewPrice` offer type in the offers system with bulk CSV import.
**Status**: DROPPED — replaced by vertical-slice breakdown (M2–M4 v2, issues #239–#258)
**Reason**: Original horizontal (backend-only) milestone replaced with thinner vertical slices per PRD-to-Tickets skill.

---

## M3: Loyalty Frontend — Membership Prices for All Customers (REPLACED)
**Goal**: Display membership prices to all customers across Menu, Item Details, Basket, and Checkout.
**Status**: DROPPED — replaced by vertical-slice breakdown (M2–M4 v2, issues #239–#258)
**Reason**: Same as M2.

---

## M4: Loyalty Post-Purchase — Savings Confirmation (REPLACED)
**Goal**: Show customers a confirmation of their membership savings after placing an order.
**Status**: DROPPED — replaced by vertical-slice breakdown (M2–M4 v2, issues #239–#258)
**Reason**: Same as M2. Post-purchase scope not in GARG-1323 epic — deferred.

---

## M2: Loyalty — Offer Creation + Data Pipeline
**Goal**: Enable operators to create NewPrice campaigns with CSV upload, process membership prices into Redis, and project them to menu CDN for client consumption.
**Status**: PAUSED — pick up explicitly when ready
**Archived**: 2026-03-25 — status was PAUSED
**Product Brief**: tasks/PRODUCT-BRIEF-LOYALTY.md
**Epic**: [GARG-1323](https://justeattakeaway.atlassian.net/browse/GARG-1323)
**ADR**: [048.3 — Membership Prices](https://justeattakeaway.atlassian.net/wiki/spaces/AH/pages/7827362054)

### Tasks

| # | Task | GitHub Issue |
|---|------|-------------|
| 1 | NewPrice offer type + CSV upload to S3 | #239 |
| 2 | Offer Management Web — CSV upload UI flow | #240 |
| 3 | CO Lambda — read CSV, map products, store ProductPrice in Redis | #241 |
| 4 | GMCDN — subscribe to MembershipPricesChanged and project prices | #242 |

### Completion Gates
1. All tasks in milestone are DONE and merged to main
2. CI green on main
3. Project compiles and runs on all target platforms
4. PO validation: PO has reviewed and accepted the milestone deliverables
5. harness/SYSTEM-KNOWLEDGE.md updated with milestone module status
6. Retrospective written using harness/templates/RETRO-TEMPLATE.md

---

## M3: Loyalty — Basket/Checkout Pricing + Offers Engine
**Goal**: Enable the offers engine, ConsumerOffers API, and GBO to calculate and return membership prices and savings for all customers.
**Status**: PAUSED — pick up explicitly when ready
**Archived**: 2026-03-25 — status was PAUSED
**Product Brief**: tasks/PRODUCT-BRIEF-LOYALTY.md
**Depends on**: M2 (NewPrice offers must exist in Redis before engine can calculate)

### Tasks

| # | Task | GitHub Issue |
|---|------|-------------|
| 1 | Offers engine — NewPrice campaign runner | #243 |
| 2 | ConsumerOffers API — basket/calculate returns membership prices | #244 |
| 3 | GBO — apply membership prices or return potential savings | #245 |

### Completion Gates
1. All tasks in milestone are DONE and merged to main
2. CI green on main
3. Project compiles and runs on all target platforms
4. PO validation: PO has reviewed and accepted the milestone deliverables
5. harness/SYSTEM-KNOWLEDGE.md updated with milestone module status
6. Retrospective written using harness/templates/RETRO-TEMPLATE.md

---

## M4: Loyalty — Menu + Item Details (All Platforms)
**Goal**: Display membership prices to all customers on Menu and Item Details screens across Web, iOS, and Android.
**Status**: PAUSED — pick up explicitly when ready
**Archived**: 2026-03-25 — status was PAUSED
**Product Brief**: tasks/PRODUCT-BRIEF-LOYALTY.md
**Depends on**: M2 (GMCDN must be projecting membership prices)

### Tasks

| # | Task | GitHub Issue |
|---|------|-------------|
| 1 | [Web] Menu — membership prices display | #246 |
| 2 | [Web] Item Details — membership price display | #249 |
| 3 | [Web] Offers carousel — membership prices | #258 |
| 4 | [iOS] Menu — membership prices display | #247 |
| 5 | [iOS] Item Details — membership price display | #250 |
| 6 | [Android] Menu — membership prices display | #248 |
| 7 | [Android] Item Details — membership price display | #251 |

### Completion Gates
1. All tasks in milestone are DONE and merged to main
2. CI green on main
3. Project compiles and runs on all target platforms
4. PO validation: PO has reviewed and accepted the milestone deliverables
5. harness/SYSTEM-KNOWLEDGE.md updated with milestone module status
6. Retrospective written using harness/templates/RETRO-TEMPLATE.md

---

## M5: Loyalty — Basket + Checkout Savings (All Platforms)
**Goal**: Display membership savings (linked) and potential savings (non-members) in Basket and Checkout across Web, iOS, and Android.
**Status**: PAUSED — pick up explicitly when ready
**Archived**: 2026-03-25 — status was PAUSED
**Product Brief**: tasks/PRODUCT-BRIEF-LOYALTY.md
**Depends on**: M3 (API must return savings data), M4 (feature flag + model established per platform)

### Tasks

| # | Task | GitHub Issue |
|---|------|-------------|
| 1 | [Web] Basket — membership savings display | #252 |
| 2 | [Web] Checkout — membership savings display | #255 |
| 3 | [iOS] Basket — membership savings display | #253 |
| 4 | [iOS] Checkout — membership savings display | #256 |
| 5 | [Android] Basket — membership savings display | #254 |
| 6 | [Android] Checkout — membership savings display | #257 |

### Completion Gates
1. All tasks in milestone are DONE and merged to main
2. CI green on main
3. Project compiles and runs on all target platforms
4. PO validation: PO has reviewed and accepted the milestone deliverables
5. harness/SYSTEM-KNOWLEDGE.md updated with milestone module status
6. Retrospective written using harness/templates/RETRO-TEMPLATE.md

---

## Adding Future Milestones

PM and Lead add milestones here after each milestone retrospective. Format:
```
## M[N]: [Name]
**Goal**: [one sentence]
**Status**: BACKLOG
### Tasks
_PM creates GitHub issues during planning._
### Completion Gates
[standard 6 gates]
```
