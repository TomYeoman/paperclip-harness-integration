# State Schema — tasks/state.json

`tasks/state.json` is the machine-readable source of truth for milestone and task state. At session start, Lead reads `tasks/state.json` (~100 tokens) to reconstruct the dashboard. `tasks/MILESTONES.md` is the human-readable view and is not the operational source of truth.

## Top-Level Fields

| Field | Type | Description |
|-------|------|-------------|
| `_comment` | string | Human note — ignored by tooling |
| `last_updated` | string (YYYY-MM-DD) | Date the file was last written |
| `milestones` | array | All active milestones |
| `active_worktrees` | array | Worktrees currently checked out (path + branch + issue) |
| `open_prs` | array | PRs not yet merged (number + title + milestone) |
| `blocked` | array | Issues blocked, with reason |

## Milestone Object

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Milestone identifier (e.g. `"M2"`) |
| `name` | string | Human-readable milestone name |
| `status` | string | See valid values below |
| `depends_on` | array\<string\> | Milestone IDs that must complete first (omit if none) |
| `issues` | array\<number\> | GitHub issue numbers in this milestone |

### Valid `status` Values

| Value | Meaning |
|-------|---------|
| `"PAUSED"` | Not currently active — requires explicit PO direction to resume |
| `"IN_PROGRESS"` | Active work underway |
| `"BLOCKED"` | Cannot proceed — see `blocked` array for reason |
| `"DONE"` | All tasks merged, CI green, PO accepted |
| `"DROPPED"` | Cancelled — see MILESTONES-ARCHIVE.md |

## active_worktrees Entry

```json
{
  "path": "/tmp/worktrees/feature-83",
  "branch": "feature/offers-csv-upload",
  "issue": 83
}
```

## open_prs Entry

```json
{
  "number": 201,
  "title": "feat(offers): CSV upload endpoint",
  "milestone": "M2",
  "issue": 84
}
```

## blocked Entry

```json
{
  "issue": 85,
  "reason": "Waiting for Architect interface for ConsumerOffersLambda"
}
```

## How Builders Update state.json on D:

When a builder sends D: (task complete), they must update `tasks/state.json`:

1. Remove the issue number from the milestone's `issues` array if it is done, OR mark it `"done"` in a per-issue status map if tracking granularly.
2. Remove the worktree entry from `active_worktrees`.
3. Add the PR to `open_prs` (if not yet merged).
4. Update `last_updated` to today's date.
5. Commit the state.json update in the same PR as the task work.

## How Lead Reads state.json at Session Start

At session start, Lead reads `tasks/state.json` to reconstruct the dashboard in ~100 tokens instead of parsing `tasks/MILESTONES.md` (~600 tokens). Lead checks:

1. `milestones[*].status` — which milestones are active vs paused
2. `active_worktrees` — any leftover worktrees from the previous session
3. `open_prs` — PRs needing follow-up
4. `blocked` — issues needing unblocking
5. `last_updated` — staleness check (if >1 session old, verify manually)
