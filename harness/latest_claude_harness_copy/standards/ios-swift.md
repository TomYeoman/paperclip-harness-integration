# Coding Standards — iOS / Swift

> Append-only. Entries are added, never removed. See [BEST-PRACTICES.md](BEST-PRACTICES.md) for the full protocol.

---

## 2026-03-26 Never use force-unwrap on optionals from external data

**Rule:** Force-unwrap (`!`) is banned on any optional derived from external data (API responses, user input, file system). Use `guard let`, `if let`, or provide a safe default.
**Why:** Force-unwrap on external data is a crash waiting to happen — the shape of external data cannot be guaranteed at compile time. Crashes in production from this pattern are entirely avoidable.
**Source:** S: ios-swift — no force-unwrap on external data (issue #555 example entry)
