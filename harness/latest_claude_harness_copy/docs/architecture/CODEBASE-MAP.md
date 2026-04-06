# Codebase Map

Reference for agents working across JET Ventures repos.

## Frontend Repos (one per platform)

### iOS — `ios/`
- **Remote:** `git@github.je-labs.com:iOS/JustEat.git`
- **Stack:** Swift, SwiftUI + UIKit, Tuist project generation
- **Structure:** `Modules/` (46 feature modules) · `App/` · `UITests/` · `WidgetExtension/`
- **Key modules:** Checkout, APIClient, Restaurant, Account, AutomationTools, JustAnalytics
- **Build:** Tuist + Xcode
- **Lint:** `swiftlint lint --quiet` — zero warnings required before commit
- **Tests:** `swiftlane test package [ModuleName] --verbose` — e.g. `swiftlane test package Checkout --verbose`
- **Submodule path:** `testharness/ios/`

#### iOS Snapshot Regeneration Protocol (#47)

Run this when any UI text, layout, or color changes:

1. Identify affected views from the diff
2. Find snapshot directories: `find ios/Modules/[ModuleName] -type d -name __Snapshots__`
3. Delete snapshots for affected views only: `rm ios/Modules/[ModuleName]/Tests/__Snapshots__/[ViewName]*`
4. Re-run tests to regenerate: `swiftlane test package [ModuleName] --verbose`
5. Commit regenerated snapshots in the same commit as the UI change — never in a separate commit

### Android
- **Remote:** TBD — not yet added as submodule
- **Stack:** Kotlin, likely Jetpack Compose
- **Strategy:** Add as submodule when Android work begins (see iOS submodule PR #29 as template)

### Web — `consumer-web/`
- **Remote:** `git@github.je-labs.com:Web/consumer-web.git`
- **Stack:** TBD — read `consumer-web/package.json` at session start
- **Submodule path:** `testharness/consumer-web/`

## Backend Repos (many)

Backend is distributed across many repos. No single submodule strategy applies.

### Recommended strategy: **on-demand clone into `backend/`**

Because there are too many backend repos to submodule all of them, the recommended approach is:

1. **Identify the repo** — use Jira ticket, Atlas, or PO to identify which backend service(s) the ticket touches
2. **Clone on demand** into a sibling directory outside the testharness tree:
   ```
   ~/Documents/Code/Claude/backend/[service-name]/
   ```
3. **Agent worktrees** for backend builders go outside the repo tree as always:
   ```
   ~/Documents/Code/Claude/b-[desc]/
   ```
4. **Don't add as submodules** unless the service will be modified across many sprints

### Backend discovery checklist
Before spawning a backend Builder:
- [ ] Identify service name from Jira or Atlas
- [ ] Confirm remote URL with PO or team docs
- [ ] Clone locally if not already present
- [ ] Read the service README and key interfaces before spawning

### Known backend repos
| Service | Remote | Notes |
|---------|--------|-------|
| _(add as discovered)_ | | |

## Working Across Repos

When a ticket touches multiple repos (e.g., iOS + backend API change):
- Spawn one Builder per repo — each gets its own worktree
- Builders work in parallel when changes are independent
- Serialize when one depends on the other (API contract first, then consumer)
- Use the DISCOVERY GATE to identify cross-repo dependencies before starting

## Adding a New Repo

1. For active development repos: `git submodule add git@github.je-labs.com:[org]/[repo].git [path]`
2. For occasional use: clone on-demand, don't submodule
3. Update this file with the new entry
4. Update `harness/SYSTEM-KNOWLEDGE.md` with any module/service context agents need
