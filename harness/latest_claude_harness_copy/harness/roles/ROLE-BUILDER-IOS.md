# Role: Builder Agent — iOS Extension

> Load this file **in addition to** `harness/roles/ROLE-BUILDER-CORE.md` when `Platform: ios` in spawn prompt.

## iOS VERIFICATION GATE
In addition to the universal VERIFICATION GATE in ROLE-BUILDER-CORE.md:
1. Run `bundle exec fastlane test` — zero failures
2. Run `bundle exec fastlane snapshot_verify` (or equivalent) — no unexpected diffs
3. Run SwiftLint — zero violations
4. Run SonarQube coverage gate — must meet or exceed baseline
5. Smoke test on device or simulator

## iOS Build Command Quick Reference
| Command | When to run | Expected |
|---------|-------------|----------|
| `bundle exec fastlane lint` | Before every commit | Zero warnings |
| `bundle exec fastlane test` | After every change | Zero failures |
| `bundle exec fastlane quality` | Before PR | Zero violations |
| `bundle exec fastlane coverage` | At PR creation | No regression |

_Fill in actual lane names after M0 defines stack._

## Large Repo File Exploration Rules
For repos exceeding 10GB (e.g., iOS at ~30GB), indiscriminate file traversal burns tokens fast.

**Required before any file reads in iOS or similarly large repos:**
1. Read `docs/architecture/CODEBASE-MAP.md` — identifies modules and structure
2. Read `docs/architecture/ios-codebase-map.md` — iOS-specific module map (pending Ben Sullivan input)
3. Identify the one or two modules your ticket touches
4. Limit all `find`, `glob`, and directory reads to those module paths only
5. Never run broad searches (e.g., `find ios/ -name "*.swift"`) — always scope to module subdirectory

## iOS Coding Standards
Load `harness/skills/SKILL-coding-standards-ios.md` for full hard-block violation list.

Key hard blocks (never violate):
- No force-unwrap (`!`) — handle nullability explicitly
- No force-cast (`as!`) without justification
- No `@MainActor` misuse — follow project threading model
- No retain cycles — check capture lists
- SwiftLint must pass with zero violations
- Use async/await, not completion handlers (for new code)
- Snapshot tests: regenerate only when UI intentionally changed

## Snapshot Regeneration Protocol
Only regenerate snapshots when UI change is intentional:
1. Confirm with PR description that UI change is expected
2. Run snapshot regeneration command
3. Review all diffs — reject unexpected changes
4. Commit updated snapshots in same PR as the UI change

### iOS UI Changes — Snapshot Tests

Any UI change requires snapshot regeneration:
1. Delete `__Snapshots__/` directories for affected views
2. Run `swiftlane test package` (NOT `xcodebuild`) to regenerate
3. Commit new snapshot files alongside the code change

CI will fail if snapshots are stale. Never skip regeneration.
