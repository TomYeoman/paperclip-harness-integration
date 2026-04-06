# Spec-Driven Development

## The Chain
spec → interface → failing test → implementation → CI green

Every feature starts from spec. Every spec behavior becomes a test. Every test drives implementation. Nothing is built without a passing test to justify it.

## Core Philosophy: Discovery Over Tracking
Observe what is actually there — read the spec, read the interfaces, read the existing tests. Do not plan what you expect to find. Agents that skip discovery and implement from memory introduce subtle drift between spec and code.

## Stage 1: Read Spec as a Test Plan (Architect)
Architect reads spec and extracts behaviors — not implementation details.

For each requirement, ask:
- What is the input?
- What is the expected output?
- What error conditions exist?
- What state transitions occur?

Document as interface contracts:
```
// SPEC: User can add item to cart
// Input: userId, itemId, quantity
// Output: updated cart with item
// Error: item not found → ItemNotFoundException
// Error: quantity <= 0 → InvalidQuantityException
```

## Stage 2: Encode Spec in Test Names (Tester → Builder)
Test names must use spec language — the language a product manager would use.

**Good test names (spec language):**
- `"user can add item to cart"`
- `"adding out-of-stock item shows error"`
- `"cart total updates when quantity changes"`

**Bad test names (implementation language):**
- `"addItemReturnsTrue"`
- `"testCartUpdateMethod"`
- `"CartViewModelTest_whenAddItem_thenStateChanges"`

If the test name requires knowing how the code is structured, it's wrong.

## Stage 3: Annotate Tests with SPEC References
Every test includes a comment linking to the spec behavior:
```
// SPEC: User can add item to cart (tasks/PRODUCT-BRIEF.md#cart-management)
@Test
fun `user can add item to cart`() { ... }
```

This creates a traceable link: spec → test → implementation.

## Stage 4: Tests Written Before Implementation
Tester writes failing tests (or test stubs) first. Builder reads the test file, not the spec. Builder's job is to make the tests pass — nothing more.

**Handoff:**
1. Tester writes: test file with failing tests (may not compile yet — interface TBD)
2. Architect writes: interface that makes tests compile
3. Builder reads: test file only
4. Builder writes: implementation that makes tests pass
5. Builder never adds behavior not tested

## Stage 5: Ambiguity Protocol
When spec is ambiguous:

**ASSUMPTION** (low risk — no data/security/scope impact):
```
// ASSUMPTION: spec unclear on sort order — defaulting to most recent first.
// If wrong, change sort direction in CartRepository.kt:47.
```
Document assumption, proceed.

**UNKNOWN** (genuine ambiguity — could affect design):
Send A: message to Lead, include options:
```
A: TASK-042 — spec unclear on max cart size.
Options:
  A) No limit (simplest, may cause perf issues at scale)
  B) 100 items (arbitrary, needs constant in spec)
  C) PO decides
Blocking: no — proceeding with Option A until resolved.
```

**STOP** (data, privacy, security, or scope):
Always stop and send E: for PO decision. Never assume on these.

## Stage 6: No Gold-Plating
Implementation satisfies tests. Nothing more. If a behavior isn't tested, it's not in scope for this task.

Exceptions (require Lead GO):
- Security hardening obvious from context
- Performance optimization that's clearly necessary
- Error handling for conditions that would crash in production

## Summary Table
| Stage | Who | Reads | Produces | Model |
|-------|-----|-------|---------|-------|
| 1. Extract behaviors | Architect | Spec | Interface contracts | Sonnet/Opus |
| 2. Write test names | Tester | Contracts | Failing test file | Sonnet |
| 3. Annotate with SPEC | Tester | Spec | SPEC: comments | Sonnet |
| 4. Implement | Builder | Test file | Passing implementation | Sonnet |
| 5. Ambiguity | Any | Spec | ASSUMPTION or A: | — |
| 6. Review | Reviewer | Tests + impl | Approve or BLOCK | Sonnet/Opus |
