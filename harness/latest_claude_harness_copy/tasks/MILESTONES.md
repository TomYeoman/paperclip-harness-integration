# Project Milestones

> PM defines milestones during product discovery (M0). Architect assigns tasks to each milestone. This file is the source of truth for project progress.
> Archived milestones (DROPPED/DONE): see tasks/MILESTONES-ARCHIVE.md

**TERMINOLOGY CLARIFICATION:** M-numbers (M0, M1, M2, etc.) are **harness-internal milestone identifiers**. The term "phase" refers to the **business delivery phase** and is distinct from M-numbers. PM and Lead always use M-numbers in communication and tickets — never "phase 1/2/3". If the PO uses "phase", map it to the corresponding M-number and confirm before proceeding.

## Completion Gates (apply to every milestone)
A milestone is complete when ALL of the following are true:
1. All tasks in milestone are DONE and merged to main
2. CI green on main
3. Project compiles and runs on all target platforms
4. PO validation: PO has reviewed and accepted the milestone deliverables
5. harness/SYSTEM-KNOWLEDGE.md updated with milestone module status
6. Retrospective written using harness/templates/RETRO-TEMPLATE.md

---

## M-REWE: REWE T&Cs — Store-specific Terms & Conditions at Scale
**Goal**: Replace hardcoded Phase I pilot implementation with a scalable, data-driven store-to-document mapping that serves T&C PDFs to all 1,600 REWE stores across checkout (Web/iOS/Android) and order confirmation email.
**Status**: IN PROGRESS — BDD approved, tickets created, builders not yet spawned
**Product Brief**: tasks/PRODUCT-BRIEF-REWE-TCS.md
**BDD Doc**: tasks/bdd/354-bdd.md
**Epic**: [GARG-869](https://justeattakeaway.atlassian.net/browse/GARG-869)
**Parent Issue**: #354
**ADRs**: tasks/adr/ADR-002-rewe-tcs-store-document-mapping.md | tasks/adr/ADR-003-rewe-tcs-pdf-supply-personalisation.md | tasks/adr/ADR-004-rewe-tcs-pdf-email-delivery.md
**Feature flag**: `rewe_tcs_scalable_enabled` (JetFM)
**Platforms**: Web, iOS, Android, Backend

### M1: Data Layer

| # | Task | GitHub Issue |
|---|------|-------------|
| 1 | [Backend] Store-to-document mapping service | #357 |
| 2 | [Backend] PDF generation pipeline | #358 |

### M2: Platform Integration

| # | Task | GitHub Issue |
|---|------|-------------|
| 3 | [Web] Checkout T&Cs link | #359 |
| 4 | [iOS] Checkout T&Cs link | #360 |
| 5 | [Android] Checkout T&Cs link | #361 |
| 6 | [Backend] Email PDF attachment | #362 |

### Completion Gates
1. All tasks in M1 and M2 are DONE and merged to main
2. CI green on main
3. Integration Tester passes all 14 BDD scenarios across all platforms
4. PO validation: PO has reviewed and accepted deliverables
5. harness/SYSTEM-KNOWLEDGE.md updated with milestone module status
6. Retrospective written using harness/templates/RETRO-TEMPLATE.md

