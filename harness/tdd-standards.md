# TDD Standards

Test philosophy and quality standards for Paperclip-based harness execution.

## Warning

Your training data contains a lot of bad TDD. Tests that test implementation details are a liability — they break on every refactor while providing no confidence in behavior.

## The Spec Chain

```
spec → interface → failing test → implementation → CI green
```

This chain is mandatory. Test file committed BEFORE implementation file, in the same PR.

## Test Desiderata

Tests should be:

- **Fast**: unit tests under 100ms
- **Isolated**: no shared state between tests
- **Deterministic**: no randomness, no real time, no network dependencies
- **Readable**: test names are the spec language
- **Behavior-focused**: tests outcomes, not mechanisms

## Test at Export Boundary

Test per behavior, not per class:

```
✓ test_user_cannot_submit_empty_form
✓ test_payment_returns_error_on_declined_card
✗ testFormValidatorValidate
✗ testPaymentGatewayProcess
```

A "test everything about X" approach produces brittle tests tied to implementation structure.

## Structure-Insensitive Tests

Tests should pass or fail based on behavior, not structure:

- Can you rename a private method without breaking tests? If not, tests are too coupled
- Can you change internal implementation without updating tests? If yes, tests are at the right level
- Does adding a new private helper break tests? If yes, test is too specific

## Fakes Over Mocks

Hand-written Fakes with contract tests are preferred over mocked objects.

**Why**: Mocks test call sequences (structure). Fakes test behavior (output given input). Structure tests break on every refactor. Behavior tests survive refactors.

### Fake Template

```python
class FakeUserRepository(UserRepository):
    def __init__(self):
        self._users = {}
        self._calls = []

    async def get(self, id: str) -> Optional[User]:
        self._calls.append(("get", id))
        return self._users.get(id)

    async def save(self, user: User) -> None:
        self._calls.append(("save", user))
        self._users[user.id] = user

    def get_calls(self) -> list:
        return self._calls
```

### Contract Test Pattern

A contract test runs against both the Fake and the real implementation to ensure behavioral parity:

```python
def test_user_repository_contract(repo: UserRepository):
    # Insert
    user = User(id="u1", name="Alice")
    await repo.save(user)

    # Retrieve
    retrieved = await repo.get("u1")
    assert retrieved.name == "Alice"

    # Not found
    missing = await repo.get("nonexistent")
    assert missing is None
```

Run this test against `FakeUserRepository` and the real `UserRepository` implementation.

## The Gear-Down Pattern

When a behavior is complex, shift to lower-level tests for the algorithm itself, then delete the scaffolding when a boundary test covers the behavior.

```
High-level (boundary) test covers behavior → pass
  ↓
Isolate the complex part → lower-level test
  ↓
Delete scaffolding when boundary test is sufficient
```

Do not keep both high-level and low-level tests of the same behavior.

## Multiplatform Test Organization

For multiplatform projects:

| Test Type | Location | Runner |
|-----------|----------|--------|
| Shared logic | `commonTest/` | kotlin.test / pytest / jest |
| Platform impl | `androidTest/`, `iosTest/`, etc. | JUnit / XCTest / Karma |

Platform stubs must be covered by platform-specific tests. Do not skip platform testing.

## Anti-Patterns

**Trivially-passing assertions**: `assert True`, `assert 1 == 1` — these test nothing

**Forced synchrony hacks**: `time.sleep(2)` — tests must be deterministic

**Mocking everything**: if every collaborator is mocked, you are testing call sequences, not behavior

**Reflection-based tests**: tests that access private state via reflection are testing structure

**Hardcoded timestamps**: use time-frozen test utilities, not real clock

## Test Naming Conventions

| Pattern | Use When |
|---------|----------|
| `test_<subject>_<behavior>` | Standard behavior test |
| `test_<subject>_<error_condition>` | Error path test |
| `test_<subject>_returns_<value>_when_<condition>` | Conditional value test |

Names are full sentences in lowercase with underscores. They read like spec items.

## Regression Tests for Bug Fixes

Bug fixes require a regression test:

1. Write test that fails without the fix
2. Apply the fix
3. Test passes with the fix
4. Commit both test and fix in the same PR

Do not fix a bug without a regression test.

## CI Gate

Before any PR merge:
- All tests pass (zero failures)
- Quality/lint checks pass
- No new coverage regressions

Never skip CI failures. Investigate immediately.

## Reviewer TDD Checks

Reviewer verifies:
1. Test file committed before implementation (`git log --diff-filter=A`)
2. All tests named in spec language
3. Fakes used over mocks where behavior can be tested
4. No trivial assertions
5. No time-dependent tests without time-frozen utilities
6. Regression tests for all bug fixes
7. No tests that break on internal refactor (structure-insensitivity)
