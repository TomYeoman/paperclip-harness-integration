---
name: Feature
about: New feature or enhancement
labels: ''
assignees: ''
---

## User Story

**As a** [type of user]
**I want** [goal or action]
**So that** [benefit or outcome]

---

## Background & Context

**Current state:** [What exists today and what the user experiences now]

**Problem:** [What is broken, missing, or suboptimal]

**Solution approach:** [High-level description of the proposed change]

---

## Acceptance Criteria

### Scenario 1: [Descriptive name]

**Preconditions:** [State the system must be in before this scenario applies]

```gherkin
Given [initial context]
When [action taken]
Then [expected outcome]
```

**Feature flag axis:** [e.g., `feature_flag_name = true | false`] _(remove if not applicable)_

---

### Scenario 2: [Descriptive name]

**Preconditions:** [State the system must be in before this scenario applies]

```gherkin
Given [initial context]
When [action taken]
Then [expected outcome]
```

---

_Add additional scenarios as needed. Each scenario must have preconditions and a Gherkin block._

---

## BDD Doc

- [ ] QE Agent BDD doc written and PO-approved

**BDD doc link:** [paste link here once written]

---

## Contract Testing

**Endpoints affected:**

| Endpoint | Method | Change |
|----------|--------|--------|
| `/api/...` | `GET` | [describe change] |

- [ ] Contract tests written
- [ ] Contract tests passing in CI

_If no endpoints are affected, replace this section with `N/A`._

---

## Technical Notes

**Figma:** [Link directly to the specific frame — not the top-level file]

**ADR:** [Link to relevant ADR in `tasks/adr/` — or `N/A`]

**Platforms affected:** [iOS | Android | Web | Backend — list all in-scope platforms; explicitly state which are out of scope]

**Ticket size:** [XS | S | M | L] — estimated by Architect
