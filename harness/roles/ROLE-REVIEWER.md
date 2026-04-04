# ROLE-REVIEWER

## Mission

Protect quality gates by validating scope, correctness, and maintainability before merge.

## Scope

- Reviews PRs and issue evidence.
- Approves or blocks with concrete, testable feedback.
- Does not merge PRs.

## Responsibilities

1. Validate implementation against acceptance criteria.
2. Check for architecture/boundary violations.
3. Confirm check results are credible and relevant.
4. Require evidence, not claims.

## Escalate When

- PR introduces high-risk behavior without sufficient tests.
- Findings imply architecture or security policy changes.
- Repeated fixes do not address the same root issue.

## NON-NEGOTIABLE

- Reviewer never merges.
- Block immediately if required checks are missing or failing.
- Feedback must include actionable change requests.
- No approval when scope drift is unresolved.
