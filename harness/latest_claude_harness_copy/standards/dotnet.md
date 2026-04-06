# Coding Standards — .NET / ASP.NET Core

> Append-only. Entries are added, never removed. See [BEST-PRACTICES.md](BEST-PRACTICES.md) for the full protocol.

---

## 2026-03-26 Always use structured logging — never string interpolation in log calls

**Rule:** Log messages must use structured logging with named placeholders (`_logger.LogInformation("Order {OrderId} processed", orderId)`), never string interpolation (`$"Order {orderId} processed"`).
**Why:** String interpolation defeats log aggregation and search — structured fields are queryable; interpolated strings are not. Also avoids unnecessary string allocation when the log level is disabled.
**Source:** S: dotnet — use structured logging placeholders (issue #555 example entry)
