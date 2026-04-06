# BDD Scenario Template

Use this template for every scenario in the BDD doc output from QE. Every field is mandatory.

---

## INVEST Compliance

QE must complete this block before writing scenarios. If any criterion fails, return the ticket to PM before proceeding.

- [ ] **I — Independent:** Ticket has no dependency on another in-progress ticket.
- [ ] **N — Negotiable:** Scope describes outcomes; implementation approach is not prescribed.
- [ ] **V — Valuable:** Completing this ticket produces an observable user or system benefit.
- [ ] **E — Estimable:** Ticket is specific enough for a builder to estimate effort.
- [ ] **S — Small:** Expected change is ≤400 lines; if not, split before proceeding.
- [ ] **T — Testable:** Every acceptance criterion below maps to at least one scenario in this document.

_Do not write scenarios until all six boxes are checked._

---

## Scenario: [Short descriptive name in plain language]

**Acceptance Criterion:** AC-[N] — [criterion text from PRD]
**Jira Ticket:** [PROJ-NNNN]
**Platform(s):** [Web | iOS | Android | Backend | All]
**Author:** QE Agent | [session date]

### Scenario

```gherkin
Given [precondition — system state before the action]
  And [additional precondition if needed]
When [user or system action]
  And [additional action if needed]
Then [observable outcome — what the user sees or system state changes]
  And [additional assertion if needed]
```

### Observability Hook

**Event name:** `[domain.event_name]` (e.g., `cart.item_added`, `auth.login_failed`)
**Trigger:** [which When step fires the event]
**Required payload fields:**
- `user_id`: string
- `[field]`: [type] — [description]
**Verification:** [how Integration Tester confirms — e.g., "check log stream for event within 5s of action"]

### Edge Cases Covered
- [Edge case 1 — include as separate scenario if non-trivial]
- [Edge case 2]

### Out of Scope
- [Anything explicitly excluded from this scenario]

---

## Challenge Log (QE ↔ PM)

_Record each challenge raised and PM resolution. Required for traceability._

| # | Requirement | Challenge | Resolution |
|---|-------------|-----------|------------|
| 1 | [excerpt] | [ISSUE text] | [PM response] |

---

## Arch Interface Implications

_Record any interface changes Architect flagged during Phase 2._

| Implication | ADR | Impact on BDD |
|-------------|-----|---------------|
| [e.g., new endpoint needed] | ADR-[N] | [scenario updated / no change] |

---

## PO Approval

- [ ] PO approved BDD doc — date: [YYYY-MM-DD]
- [ ] Builders unlocked: Lead sent `G: builders [task-id]`

_Do not modify below this line after PO approval._
