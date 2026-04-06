# Skill: iOS / Swift Coding Standards

Load this skill when: spawning a Builder or Reviewer for iOS work, or reviewing an iOS PR.

## Hard-Block Violations (treat as CODE RULES violations — BLOCK immediately)
- [ ] Force-unwrap: `!` on any optional (e.g. `someValue!`) — use `guard let`, `if let`, or provide a default
- [ ] Force cast: `as!` — use `as?` with nil handling
- [ ] `@MainActor` missing on UI-touching code called from async context
- [ ] Retain cycle in closure: `[self]` capture without `[weak self]` or `[unowned self]` where applicable
- [ ] `try!` — use `try?` or `do/catch`
- [ ] `fatalError` in production code path (allowed only in unreachable `default:` arms with comment)
- [ ] Accessing UI from a background thread
- [ ] `DispatchQueue.main.sync` — deadlock risk; use `async` instead

## SwiftLint
Run SwiftLint before every commit. Zero violations required.
```bash
swiftlint lint --strict
```
If project has a `.swiftlint.yml`, its rules take precedence over this list for style (not safety) issues.

## Concurrency
- Prefer `async/await` over Combine or GCD for new code
- All `@Observable` / `ObservableObject` mutations on `@MainActor`
- Never share mutable state across actor boundaries without `Sendable` conformance
- `Task { }` detached tasks must be cancelled on deinit — store in a `Set<AnyCancellable>` or `[Task]`

## Architecture
- ViewModels must not import UIKit/SwiftUI directly — use protocol abstractions
- No business logic in View files
- Dependency injection via initialiser — no `shared` singletons in production code

## iOS Verification Gate (mandatory — #47)

**NEVER use bare `xcodebuild` for iOS tests. Always use swiftlane.**

| Step | Command |
|------|---------|
| Lint | `swiftlint lint --quiet` |
| Test | `swiftlane test package [ModuleName] --verbose` |
| Example | `swiftlane test package Checkout --verbose` |

Note: `Bash(swiftlane *)` must be confirmed in the global allowlist before running.

## iOS Quality Gates

For any PR targeting the Jet iOS repo (`iOS/JustEat`), run these checks before creating the PR.

### SwiftLint
- Read `.swiftlint.yml` from the iOS repo root **at discovery time** — know the rules before writing code
- Run before PR: `swiftlane lint` or `swiftlint lint` (whichever the project uses)
- Required result: zero warnings, zero errors
- If `.swiftlint.yml` is missing or `swiftlane`/`swiftlint` is not installed: flag as B: blocker before writing code

### SonarQube Coverage Gate
- Jet iOS enforces a minimum code coverage threshold via SonarQube
- Small UI-only PRs with no new tests risk failing the coverage gate
- If the PR adds no tests: note the coverage risk explicitly in the PR body so the reviewer is aware
- If coverage will drop: treat as a blocker — add tests or seek PO approval to proceed

### iOS Pre-PR Checklist
- [ ] Read `.swiftlint.yml` at discovery time
- [ ] Run SwiftLint — zero warnings
- [ ] Assess SonarQube coverage impact — note in PR body if coverage will drop
- [ ] PR opened as draft (see SKILL-github-pr-workflow.md § Jet iOS PR Requirements)

## Testing
- Run `swiftlane test package [ModuleName]` before opening a PR — NEVER use bare `xcodebuild` (they are not equivalent; swiftlane runs additional setup that CI depends on)
- XCTest preferred; Quick/Nimble allowed if project already uses it

### Snapshot Regeneration (mandatory for any UI change)
The repo uses `swift-snapshot-testing`. Any UI text, layout, or color change will produce a snapshot mismatch that fails CI. Stale snapshots are a hard block.

When your PR changes UI text, layout, or colors:
1. Find affected snapshot dirs: `find ios/Modules/[ModuleName] -type d -name __Snapshots__`
2. Delete snapshots for affected views only (not all snapshots)
3. Re-run `swiftlane test package [ModuleName]` to regenerate reference images
4. Commit the regenerated snapshots in the **same commit** as the UI change
5. If snapshots are not committed, CI will fail with snapshot mismatch errors
6. See `docs/architecture/CODEBASE-MAP.md` for full snapshot regen protocol.

## Strings
- All user-facing strings via localisation keys — no hardcoded English strings in UI code
- `NSLocalizedString` or SwiftUI `.localizable` macro only

## Merge Ownership
Builder opens PR in iOS/JustEat repo. Reviewer does adversarial review. Human (PO) merges in GitHub UI. No agent runs `gh pr merge`. No agent runs `gh pr review --approve`.
