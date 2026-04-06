# iOS Codebase Map

**Status:** Placeholder — awaiting input from Ben Sullivan and the iOS community.

**Purpose:** Agents working on iOS tasks must read this file before exploring the repo. The iOS repo is ~30GB. Traversing it without scoping first burns tokens and causes timeouts.

## How to Use This Map

1. Find the feature area your ticket touches in the table below.
2. Note the module path(s) listed.
3. Scope ALL file reads and searches to those paths only.
4. Never run unscoped searches across `ios/Modules/` or `ios/App/`.

## Module Map

<!-- TODO(#54): Ben Sullivan / iOS community to fill in the module structure below. -->
<!-- For each module, provide: module name, path within repo, owner team, brief description. -->

| Module | Path | Owner | Description |
|--------|------|-------|-------------|
| _(pending)_ | | | |

## Known High-Level Structure

From `docs/architecture/CODEBASE-MAP.md`:

- `ios/Modules/` — 46 feature modules (Tuist-generated)
- `ios/App/` — app entry point and app-level DI wiring
- `ios/UITests/` — UI/automation test suite
- `ios/WidgetExtension/` — home screen widget

Key modules known so far: `Checkout`, `APIClient`, `Restaurant`, `Account`, `AutomationTools`, `JustAnalytics`.

## Updating This File

When you discover which module owns a feature area, add a row to the table above and open a PR. Do not wait for a full audit — incremental additions are welcome.
