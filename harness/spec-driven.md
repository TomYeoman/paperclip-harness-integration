# Spec-Driven Development Policy

Runtime-agnostic spec chain and spec-first development standards for Paperclip-based harness execution.

## The Spec Chain

```
spec → interface → failing test → implementation → CI green
```

All implementation work follows this chain. Never reverse it.

- **spec**: Behavior specification written in domain language
- **interface**: Contract defining inputs, outputs, and boundaries
- **failing test**: Test that exercises the interface, written before implementation
- **implementation**: Code that satisfies the interface contract
- **CI green**: Quality gates passing before PR merge

## Spec Chain by Role

| Stage | Primary Actor | Reads | Produces |
|-------|--------------|-------|----------|
| Spec authoring | Architect / Lead | Feature brief, ADRs | `spec` in issue document |
| Interface design | Architect | Spec | Interface definitions, ADRs |
| Test authoring | Builder / Tester | Interface, spec | Failing test files |
| Implementation | Builder | Failing tests, interface | Production code |
| Validation | Reviewer | Implementation, tests | Approve / block |

## Spec Authoring Standards

Specs must be written in domain language, not implementation language:

- **Good**: "User receives notification within 5 seconds of event"
- **Bad**: "NotificationService.send() called with delay ≤ 5000ms"

Each spec item should be:
- **Observable**: describes behavior, not mechanism
- **Testable**: can be verified by a test
- **Unambiguous**: one interpretation, no may/might/should

## Spec Document Format

Issue documents with key `spec` follow this structure:

```markdown
# Feature: [Name]

## Behavior

1. [Observable behavior in domain language]
2. ...

## Boundaries

- [What is NOT in scope]
- ...

## Acceptance Criteria

- [ ] [Criterion 1]
- [ ] [Criterion 2]
```

## Ambiguity Protocol

| Situation | Action |
|-----------|--------|
| Low-risk assumption | ASSUMPTION: [stated assumption] — proceed |
| Genuine ambiguity | UNKNOWN: [question] — escalate |
| Data/privacy/security | STOP — escalate immediately |

Never guess on security-sensitive or data-handling behavior.

## Interface Design

Interfaces are named for their capability, not their implementation:

```
✓ UserRepository, NotificationService, PaymentGateway
✗ MySQLUserStore, EmailNotifier, StripeAdapter (impl leaking into name)
```

Interface files are owned by Architect. Builders implement against interfaces, not around them.

## Stage 1: Read Spec as a Test Plan

Architect (or whoever authors the spec) reads the spec and extracts each behavior as a potential test case. Every bullet in the spec becomes a test.

## Stage 2: Encode in Test Names

Test names use spec language:

```
✓ test_user_receives_notification_within_5_seconds
✓ test_payment_fails_when_card_declined
✗ testSendNotification
✗ testPaymentGateway
```

## Stage 3: Annotate Tests

Include `// SPEC:` references in tests to link back to the spec:

```python
def test_user_receives_notification_within_5_seconds():
    # SPEC: User receives notification within 5 seconds of event
    ...
```

## Stage 4: Test Before Implementation

Test file committed BEFORE implementation file, in the same PR. This is enforced by reviewer.

Verify ordering with: `git log --diff-filter=A -- <path>` — test file must appear before implementation file.

## Stage 5: No Gold-Plating

Implementation satisfies tests. Nothing more.

If the implementation is "better" than what the spec requires, update the spec first via Architect.

## Self-Correction Protocol

When spec and implementation diverge:

1. **Impact <20 lines, same files**: Self-correct, document in DONE
2. **Impact ≥20 lines**: Architect redesign required
3. **New files or deletes**: Architect involvement required
4. **Affects other agents' work**: Lead coordinates pause + redesign
5. **User data/security/scope**: Escalate to Lead/CEO

## Spec Chain Verification

Reviewer checks:
1. Test file committed before implementation file
2. All spec items have corresponding tests
3. Test names use spec language
4. No gold-plating (implementation does not exceed spec)
5. Interface files exist and are referenced by tests
