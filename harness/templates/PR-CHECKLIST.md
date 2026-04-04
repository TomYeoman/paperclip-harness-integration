# Harness PR Checklist

Use this checklist for any PR that changes harness behavior, workflow, or Paperclip API automation.

## Metadata

- Related issue(s): `HARA-...`
- Scope summary (1-2 lines):

## Required checks

- [ ] **Issue linkage:** PR body references the related `HARA-*` issue(s).
- [ ] **Acceptance criteria:** All issue acceptance criteria are addressed.
- [ ] **Evidence posted:** PR URL is posted back to the Paperclip issue comments.
- [ ] **Review summary on issue:** Reviewer posted approve/block summary in the issue thread.

## Automation policy checks

- [ ] **Scriptable change:** If Paperclip API behavior changed, setup/runbook steps are scriptable in `harness/scripts/` (skip for local-only issue operations).
- [ ] **README updated:** `harness/scripts/README.md` updated to reflect new flags, defaults, order, or prerequisites (skip for local-only issue operations).
- [ ] **No UI-only drift:** No new core flow depends on manual UI-only steps without a documented API/script reason.

## Runtime and role checks

- [ ] `instructionsFilePath` behavior remains role-isolated (runtime entrypoint pattern).
- [ ] Shared governance remains in `harness/AGENTS.md`; role specifics remain in `harness/roles/ROLE-*.md`.
- [ ] `/workspace` execution assumptions remain correct for Docker-based local runs.

## Validation

- [ ] Scripts touched in this PR pass shell syntax checks (`bash -n ...`).
- [ ] Any changed setup script has a runnable example command in docs.
- [ ] Failures/limitations are documented in PR notes (if any checks are intentionally skipped).

## Reviewer issue summary template

```text
REVIEW: <issue-id>
PR: <url>
DECISION: approved | blocked
REASONS:
- <reason>
REQUIRED-CHANGES:
- <change or NONE>
```
