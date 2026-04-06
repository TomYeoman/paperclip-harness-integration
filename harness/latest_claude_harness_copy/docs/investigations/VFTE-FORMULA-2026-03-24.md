# Virtual FTE (vFTE) Formula

**Date:** 2026-03-24
**Issue:** #438 (parent: #432)

## Purpose

vFTE quantifies the agent team's output in human-equivalent engineering hours. It translates PR volume into a comparable productivity metric, enabling session-over-session efficiency tracking.

---

## Formula

```
vFTE_hours = Σ(PRs merged × estimated_human_hours_per_PR × (1 − rework_rate))
session_efficiency = vFTE_hours / session_wall_clock_hours
```

### Components

| Term | Definition |
|------|-----------|
| `PRs merged` | Count of PRs merged during the session (from `gh pr list --state merged`) |
| `estimated_human_hours_per_PR` | T-shirt size mapped to hours — see table below |
| `rework_rate` | `revision_count / total_prs_merged` — fraction of PRs that required at least one CHANGES_REQUESTED cycle |
| `session_wall_clock_hours` | Elapsed real time from session start to shutdown |

### T-shirt Size → Hours Mapping

| Size | Hours | When to use |
|------|-------|-------------|
| XS   | 1h    | Typo fixes, config changes, single-line edits |
| S    | 2h    | Small bug fix, minor doc update, 1-file change |
| M    | 4h    | Standard feature, multi-file change, new test suite |
| L    | 8h    | Complex feature, cross-module change, significant refactor |
| XL   | 16h   | Architecture change, new service scaffold, large migration |

**T-shirt size is a required field on all GitHub issues.** PM sets this during issue creation via the `size: XS/S/M/L/XL` label. If a merged PR has no size label, default to M and flag the gap in the dashboard.

---

## Getting the Inputs

### T-shirt sizes from GitHub

```bash
# Get size label for a PR's linked issue
gh issue view <N> --json labels --hostname github.je-labs.com | jq '.labels[] | select(.name | startswith("size:")) | .name'
```

If no issue is linked, check the PR body for a size annotation or default to M.

### Revision count (rework)

```bash
# Count CHANGES_REQUESTED reviews on a PR
gh pr view <N> --json reviews --hostname github.je-labs.com | jq '[.reviews[] | select(.state=="CHANGES_REQUESTED")] | length'
```

Sum these across all merged PRs for the session to get `revision_count`. Then:

```
rework_rate = revision_count / total_prs_merged
```

---

## Example Calculation

**Session 2026-03-24b** (hypothetical):

| PR  | Title                        | Size | Hours | Revisions |
|-----|------------------------------|------|-------|-----------|
| #412 | harness: session shutdown skill | S  | 2h    | 0         |
| #414 | harness: launch script 2026-03-24b | S | 2h | 0        |
| #407 | harness: fix permission prompts | M  | 4h    | 1         |

```
revision_count = 1
total_prs_merged = 3
rework_rate = 1/3 = 0.333

vFTE_hours = (2 × (1 − 0.333)) + (2 × (1 − 0.333)) + (4 × (1 − 0.333))
           = (2 × 0.667) + (2 × 0.667) + (4 × 0.667)
           = 1.33 + 1.33 + 2.67
           = 5.33h

session_wall_clock_hours = 3.0h (example)
session_efficiency = 5.33 / 3.0 = 1.78x
```

Interpretation: the team delivered the equivalent of ~1.78 human engineering hours per wall-clock hour.

---

## Baseline Period

The first 5 sessions will establish what "normal" efficiency looks like. Do not treat early numbers as targets — collect them as data. After session 5, compute:

- Mean vFTE_hours per session
- Mean session_efficiency
- P25/P75 range

These become the baseline thresholds for "healthy", "watch", and "flag" bands in the dashboard.

---

## Storage

Record per session in `docs/sessions/YYYY-MM-DD[letter].json`:

```json
{
  "vfte_hours_estimate": 5.33,
  "vfte_efficiency": 1.78
}
```

See `docs/sessions/README.md` for full schema.

---

## PM Action Required

T-shirt sizing must be a **required field** on all new tickets. PM must:

1. Add `size: XS/S/M/L/XL` label at issue creation — not retrospectively
2. Include sizing guidelines in the issue template
3. Flag any merged PR without a size label during session review

Without consistent sizing, vFTE calculations will degrade to M-defaulted estimates and lose precision.
