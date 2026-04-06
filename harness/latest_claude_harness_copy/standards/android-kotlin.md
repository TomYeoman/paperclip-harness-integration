# Coding Standards — Android / Kotlin

> Append-only. Entries are added, never removed. See [BEST-PRACTICES.md](BEST-PRACTICES.md) for the full protocol.

---

## 2026-03-26 Never use !! (non-null assertion) on values from external sources

**Rule:** The `!!` operator is banned on any value derived from external sources (API responses, intents, bundles, shared preferences). Use `?: return`, `?: throw`, or safe-call chains.
**Why:** `!!` throws `NullPointerException` at runtime with no context. External data nullability cannot be enforced at compile time. Explicit null handling makes failure modes visible and recoverable.
**Source:** S: android-kotlin — no !! on external values (issue #555 example entry)
