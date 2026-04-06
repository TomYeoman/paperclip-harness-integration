# Code Churn Rate & EvoScore — Research Spike

**Date:** 2026-03-24
**Author:** b-metrics-churn (issue #440)
**Parent:** #432 — Agent effectiveness metrics

---

## Code Churn Rate

### Definition

Code churn rate measures lines from a given PR that are modified or deleted within 2 subsequent sessions of that PR being merged.

A high churn rate indicates that merged code was incomplete, incorrect, or poorly understood — a signal that agent decisions are generating rework.

### Measurement

**Precise (git-based):**

```bash
# Find files touched by a given PR (after merge)
git diff main~1..main --name-only

# Then check if those files were modified again within 2 sessions
git log --since="<merge_date>" --diff-filter=M -- <files_in_pr> --oneline
```

**Limitations of git-based approach:**
- Requires knowing the exact merge date and files for each prior PR
- Session boundaries are not tracked by git — requires cross-referencing BUILD-JOURNAL.md
- A modification is not always rework; some modifications are legitimate extensions

### Practical Proxy: PR Revert Rate

Track PRs that were explicitly reverted within 2 sessions:

```bash
gh pr list --search "revert" --state merged --limit 20
```

This is easier to automate and captures the most egregious churn cases (full reversals). It undercounts partial rework but is a reliable lower bound.

### Session KPI

Add `churn_prs` to the docs/sessions/ schema:

```
churn_prs: N  # PRs from the prior 2 sessions that were modified or reverted this session
```

Track manually at session end: review recent git log against the prior 2 sessions' PR list in BUILD-JOURNAL.md and note any PRs whose files were touched again.

---

## EvoScore Feasibility Spike

### Reference

SWE-CI 2025 paper: https://arxiv.org/pdf/2503.13657

### Core Idea

EvoScore measures whether agent changes make the codebase easier or harder to evolve over time. It aggregates metrics such as:

- **Coupling delta** — did the PR increase or decrease afferent/efferent coupling?
- **Cohesion delta** — did the PR improve or degrade module cohesion?
- **Cyclomatic complexity delta** — did the PR increase or decrease average complexity?
- **Test coverage delta** — did the PR improve or degrade coverage?

A positive EvoScore means the agent left the codebase in a better-evolved state. A negative EvoScore means the agent introduced debt.

### Implementation Complexity: HIGH

To instrument EvoScore on this stack (.NET / ASP.NET Core) we would need:

| Requirement | Status |
|-------------|--------|
| Static analysis tool (e.g., NDepend, Roslyn analyzers) | Not configured |
| Per-PR coupling/cohesion snapshots | Not established |
| Baseline metrics storage | Not established |
| CI integration to diff metrics per PR | Not built |

All four prerequisites are missing. Standing up EvoScore from scratch would itself be a multi-session project.

### Verdict: Defer

EvoScore is not practical to instrument without a language-specific static analysis pipeline. The measurement overhead exceeds the diagnostic value at current project scale.

**Recommendation:** defer EvoScore instrumentation. Use PR revert rate and code churn rate as pragmatic proxies in the interim.

**Revisit when:** the .NET static analysis pipeline exists (Roslyn analyzers or NDepend configured in CI).

---

## Tracking Approach (Interim)

### docs/sessions/ schema addition

Add `churn_prs` field to session records:

```yaml
churn_prs: 0        # PRs from prior 2 sessions modified or reverted this session
revert_prs: 0       # subset: PRs that were fully reverted
```

### Monthly revert rate check

Run monthly (manually, at session start):

```bash
gh pr list \
  --search "revert" \
  --state merged \
  --hostname github.je-labs.com \
  --limit 50 \
  --json number,title,mergedAt \
  | jq '.[] | select(.mergedAt > "<1-month-ago>")'
```

### Decision log

| Date | Decision | Rationale |
|------|----------|-----------|
| 2026-03-24 | Defer EvoScore | HIGH complexity; no static analysis pipeline |
| 2026-03-24 | Adopt PR revert rate as proxy | Low instrumentation cost; catches worst cases |
| 2026-03-24 | Add churn_prs to session schema | Manual but zero tooling cost |
