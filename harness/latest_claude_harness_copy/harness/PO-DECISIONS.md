# PO Decisions Log

Auditable record of product owner and stakeholder decisions that shape harness behaviour.
Add an entry whenever a PO or stakeholder makes a decision that changes how the harness works.

---

## 2026-03-23 — Integration Testing Cadence (Hiral)
**Decision:** Run integration tests every 15 minutes (or at milestone completion if build is fast) — not on every merge.
**Reason:** Reduce infrastructure costs.
**Affects:** ROLE-INTEGRATION-TESTER.md

## 2026-03-23 — Trio Exit Condition (Hiral)
**Decision:** After PO approves trio output, Lead creates milestone plan before sending G: to builders. Builders do not receive GO immediately after trio approval.
**Reason:** Ensure milestone scope is planned before implementation begins.
**Affects:** TRIO-WORKFLOW.md

## 2026-03-23 — Jira Ticket Documentation Standard (Hiral)
**Decision:** Every Jira ticket created by the trio must include links to ADRs, BDD scenarios, PRD sections, and explicit dependency listings.
**Reason:** Builders need complete context in the ticket to finish the task without hunting for docs.
**Affects:** TRIO-WORKFLOW.md
