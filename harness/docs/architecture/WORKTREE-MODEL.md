# Worktree Model

> HUMAN REFERENCE ONLY — canonical behavior is defined by harness runtime docs.

## Canonical Sources

- `harness/scripts/setup-harness-workspace-policy.sh`
- `harness/scripts/README.md`

## Execution Workspace Strategy

Harness supports isolated execution workspaces using git worktree strategy when project policy enables it.

Key controls:

- project execution workspace policy (enabled/disabled)
- default mode selection (`isolated_workspace` recommended)
- branch template and worktree parent directory

## Operational Guidance

- keep worktree policy script-driven
- keep role runtime `cwd` anchored to `/workspace`
- use documented script flags instead of manual one-off configuration drift
