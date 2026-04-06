# PII and Sensitive Information Audit Report

**Date**: 2026-03-23
**Scope**: All files in repo EXCEPT `consumer-web/` and `ios/`
**Purpose**: Pre-flight check before sending zip to Anthropic engineer for feedback

---

## FINDINGS

### CRITICAL (must redact before sending)

None found.

No API keys, tokens, passwords, or hardcoded secrets were found outside the excluded directories. The `.env` files found were all under `consumer-web/` (excluded from scope).

---

### WARNING (should review before sending)

#### W1 — Real employee names (GitHub usernames and full names)

The following real employee identifiers appear in harness docs and git history:

| Identifier | Type | Files |
|------------|------|-------|
| `corey-latislaw` | GitHub username | `harness/roles/ROLE-LEAD.md`, `harness/lessons.md`, `harness/skills/SKILL-session-shutdown.md` |
| `hiral-thakkar` | GitHub username | `LAUNCH-SCRIPT.md`, `docs/BUILD-JOURNAL.md` |
| `Hiral` | First name | `LAUNCH-SCRIPT.md`, `docs/BUILD-JOURNAL.md` |
| `corey.latislaw@justeattakeaway.com` | Work email | Git commit history (not in file content) |
| `hiral.thakkar@justeattakeaway.com` | Work email | Git commit history (not in file content) |
| `jon.park@justeattakeaway.com` / `jon.park@just-eat.com` | Work emails | Git commit history (not in file content) |
| `colabug@gmail.com` | Personal email | Git commit history (not in file content) |

The git history itself contains these email addresses in commit author metadata — this cannot be removed without a full `git filter-repo` rewrite.

#### W2 — Internal Atlassian/JIRA URLs with page IDs

| URL | File |
|-----|------|
| `https://justeattakeaway.atlassian.net/wiki/spaces/AH/pages/7827362054` | `tasks/PRODUCT-BRIEF-LOYALTY.md`, `tasks/MILESTONES.md` |
| `https://justeattakeaway.atlassian.net/browse/GARG-1323` | `tasks/PRODUCT-BRIEF-LOYALTY.md`, `tasks/MILESTONES.md` |

These expose internal Confluence page IDs and JIRA project identifiers.

#### W3 — Internal JIRA ticket references (GARG-* and CTLG-*)

| Ticket | Context | Files |
|--------|---------|-------|
| `GARG-1323`, `GARG-1346`, `GARG-1390`, `GARG-886`, `GARG-767`, `GARG-595`, `GARG-579` | Loyalty epic and sub-tasks | `tasks/PRODUCT-BRIEF-LOYALTY.md`, `tasks/MILESTONES.md`, `tasks/MILESTONES-ARCHIVE.md`, `harness/lessons.md` |
| `CTLG-384`, `CTLG-385`, `CTLG-395` | Age verification tickets | `tasks/adr/001-age-verification-ui-update.md`, `tasks/PRODUCT-BRIEF.md`, `tasks/MILESTONES-ARCHIVE.md`, `harness/SYSTEM-KNOWLEDGE.md`, `docs/BUILD-JOURNAL.md` |

These are internal project identifiers. Anyone with the ticket numbers and Atlassian access could look up the work.

#### W4 — Internal GitHub Enterprise (GHE) hostname and org/repo names

| Item | Files |
|------|-------|
| `github.je-labs.com` (GHE hostname) | `CLAUDE.md`, `CLAUDE-HUMAN.md`, `harness/setup/GITHUB-ENTERPRISE-SETUP.md`, `harness/skills/SKILL-github-pr-workflow.md`, `harness/SKILLS-INDEX.md`, `harness/rules/MERGE-OWNERSHIP.md`, `harness/templates/LAUNCH-SCRIPT-TEMPLATE.md`, `harness/skills/SKILL-agent-spawn.md`, `harness/SYSTEM-KNOWLEDGE.md`, `docs/architecture/CODEBASE-MAP.md`, `docs/architecture/WORKTREE-MODEL.md`, `docs/investigations/MULTI-REPO-STRATEGY.md` |
| `grocery-and-retail-growth` (GitHub org) | `CLAUDE.md`, `CLAUDE-HUMAN.md`, `harness/setup/GITHUB-ENTERPRISE-SETUP.md`, `harness/skills/SKILL-github-pr-workflow.md` |
| `iOS/JustEat`, `Web/consumer-web`, `ai-platform/skills` (repo paths) | Various harness docs |
| `JustEatTakeaway/jet-company-standards` | `harness/skills/SKILL-github-pr-workflow.md` |

These reveal the internal GHE instance, org structure, and repo naming conventions.

#### W5 — Internal PR numbers on production repos

| Reference | File |
|-----------|------|
| `PR #18752` (iOS/JustEat repo) | `harness/SYSTEM-KNOWLEDGE.md`, `docs/BUILD-JOURNAL.md` |
| `PR #18760` (iOS/JustEat repo) | `harness/SYSTEM-KNOWLEDGE.md`, `docs/BUILD-JOURNAL.md` |

These are internal PR numbers on the `iOS/JustEat` repo on the GHE instance.

#### W6 — Hardcoded local filesystem paths (username in paths)

| Path | File |
|------|------|
| `/Users/corey.latislaw/Documents/Code/...` (multiple paths) | `docs/architecture/WORKTREE-MODEL.md` |

These embed the local macOS username in example paths.

---

### INFO (low risk, context-only)

#### I1 — Company and product name references

`JustEatTakeaway`, `justeattakeaway`, `just-eat` appear throughout as:
- NPM package scopes: `@justeattakeaway/pie-icons-webc`, `@justeattakeaway/cw-l10n-services`
- Company product names in product briefs

These are the company's own packages/products and are not confidential — the company name is public.

#### I2 — Internal design system and library names

`snacks-design-system`, `@cw/common`, `cw-l10n-services` appear in ADR-001 and product briefs.
These are internal library names, not publicly documented, but not security-sensitive.

#### I3 — Internal team/feature names

References to `grocery-and-retail-growth` team and features like age verification, loyalty membership pricing.
These are team/feature names with no PII or security impact.

#### I4 — `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` in settings

`.claude/settings.json` contains this env var. It is a feature flag, not a credential.

---

## RECOMMENDATION

### Must address before sending

1. **Decide on git history**: The commit history contains real employee email addresses (`corey.latislaw@justeattakeaway.com`, `hiral.thakkar@justeattakeaway.com`, `jon.park@justeattakeaway.com`, `colabug@gmail.com`). To fully remove these, the repo would need a `git filter-repo` rewrite. **Consider instead**: send as an archive without `.git/` directory, or explicitly inform the Anthropic engineer that the git history contains real email addresses and confirm they are acceptable.

2. **Atlassian URLs**: `tasks/PRODUCT-BRIEF-LOYALTY.md` and `tasks/MILESTONES.md` contain direct links to internal Confluence pages and JIRA tickets with specific page/ticket IDs. If the loyalty feature work is context the Anthropic engineer does not need, consider redacting these files or replacing the URLs with placeholders.

### Recommended to address (optional, lower risk)

3. **Employee names in harness docs**: `corey-latislaw` and `hiral-thakkar` appear in `ROLE-LEAD.md`, `lessons.md`, `SKILL-session-shutdown.md`, and `BUILD-JOURNAL.md`. These could be replaced with generic placeholders (e.g., `<github-username>`) if privacy is a concern.

4. **GHE hostname and org names**: `github.je-labs.com` and `grocery-and-retail-growth` are referenced throughout the harness. These are structural references needed for the harness to make sense. If the harness is being shared to demonstrate the agent team pattern (not the specific company configuration), consider replacing `github.je-labs.com` with `github.example.com` and the org name with a placeholder. However, if the Anthropic engineer is evaluating real-world usage, keeping these provides accurate context.

5. **CTLG-* tickets and PR numbers**: In `harness/SYSTEM-KNOWLEDGE.md` and `docs/BUILD-JOURNAL.md`, specific internal ticket and PR numbers appear. These are low-risk but reveal project implementation details.

---

## SAFE TO SEND

The following categories are confirmed clean:

- **No API keys, tokens, or credentials** found in any file outside `consumer-web/` and `ios/`
- **No `.env` files** outside the excluded directories
- **No passwords or secrets** hardcoded anywhere in scope
- **All harness logic files** (`harness/roles/`, `harness/skills/`, `harness/context/`, `harness/rules/`) contain only process documentation — no PII, no credentials
- **`CLAUDE.md` and `CLAUDE-HUMAN.md`** contain no secrets (GHE hostname is present but not a credential)
- **`.claude/settings.json`** contains only a feature flag env var — no credentials
- **No internal IP addresses or VPN endpoints** found
- **No SSO tokens or OAuth secrets** found

---

## SUMMARY TABLE

| Category | Severity | Count | Action Required |
|----------|----------|-------|----------------|
| API keys / secrets | Critical | 0 | None |
| Employee emails (git history) | Warning | 4 | Decision needed on git history handling |
| Employee names in files | Warning | 2 | Optional redaction |
| Atlassian URLs + JIRA tickets | Warning | 9 | Consider redacting loyalty task files |
| GHE hostname + org/repo names | Warning | Throughout harness | Decision: keep for context or anonymise |
| Internal PR numbers | Warning | 2 | Low priority |
| Local filesystem paths | Warning | 7 lines | Low priority |
| Company/product names | Info | Many | No action needed |
| Internal library names | Info | Many | No action needed |
