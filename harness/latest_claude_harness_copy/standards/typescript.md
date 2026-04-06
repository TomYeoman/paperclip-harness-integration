# Coding Standards — TypeScript / React

> Append-only. Entries are added, never removed. See [BEST-PRACTICES.md](BEST-PRACTICES.md) for the full protocol.

---

## 2026-03-26 Never use `any` type — use `unknown` and narrow explicitly

**Rule:** The `any` type is banned. Use `unknown` when the type is genuinely unknown and narrow it with type guards before use. For third-party shapes, declare an interface or import the vendor type.
**Why:** `any` silently disables TypeScript's type checking, turning type errors into runtime errors. `unknown` forces explicit narrowing, keeping type safety intact at the boundary.
**Source:** S: typescript — no any type (issue #555 example entry)
