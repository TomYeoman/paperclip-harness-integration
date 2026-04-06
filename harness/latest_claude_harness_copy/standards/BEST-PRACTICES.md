# Coding Best Practices

## Purpose

This directory captures platform-specific coding standards identified during adversarial code review. Standards are encoded here when a Reviewer sends an `S:` DSL signal identifying a pattern worth formalising.

## Append-Only Rule

Entries are **added, never removed**. The append-only constraint preserves the full audit trail of why a standard was introduced. A periodic auditor pass handles deprecation — see [Deprecation](#deprecation) below.

## How to Add an Entry

1. Reviewer identifies a coding standard during review and sends `S: [platform] — [rule]` to Lead via SendMessage.
2. Reviewer (or the Builder who addressed the feedback) opens a PR adding the entry to the relevant platform file using the standard entry format:

```
## [date] [short rule title]
**Rule:** [the rule]
**Why:** [brief rationale]
**Source:** [S: signal from issue or PR number]
```

3. PR title: `harness(standards): add [platform] standard — [short rule title]`
4. PR body must reference the originating issue or PR.

## Platform Files

| Platform | File |
|----------|------|
| .NET / ASP.NET Core | [standards/dotnet.md](dotnet.md) |
| iOS / Swift | [standards/ios-swift.md](ios-swift.md) |
| Android / Kotlin | [standards/android-kotlin.md](android-kotlin.md) |
| TypeScript / React | [standards/typescript.md](typescript.md) |

## Deprecation

An auditor pass periodically marks entries as `[DEPRECATED]` with a reason. Deprecated entries are candidates for removal in the next auditor cycle. Only an auditor role may mark entries deprecated — Builders and Reviewers do not deprecate.

Format for deprecated entries:

```
## [date] [short rule title] [DEPRECATED]
**Rule:** [the rule]
**Why:** [original rationale]
**Source:** [original S: signal]
**Deprecated:** [date] — [reason, e.g. "superseded by #N", "framework now handles this natively"]
```

## Long-Term Vision

Mature platform files graduate into harness skills (`harness/skills/SKILL-coding-standards-[platform].md`). A platform file is a candidate for graduation when it has 10+ entries and a Reviewer has loaded it multiple times in a single milestone. Graduation requires an explicit PO decision.
