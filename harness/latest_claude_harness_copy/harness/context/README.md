# Agent Context Slices

Role-specific subsets of `CLAUDE.md`. Each slice contains only the sections relevant to that role, reducing non-Lead spawn context by 350–500 tokens per agent.

## Files

| File | Role | Sections included |
|------|------|-------------------|
| `CLAUDE-BUILDER.md` | Builder | ARCH RULES, CODE RULES, SECURITY, BRANCHES (Builder rules), COMMIT, SPEC CHAIN + TDD, VERIFICATION GATE, LOOP DETECTION, ESCALATE TO PO WHEN, COMMUNICATION DSL, DISCOVERY GATE |
| `CLAUDE-REVIEWER.md` | Reviewer | BRANCHES + PR MERGE (full Two-Track model), CODE RULES, SECURITY, COMMUNICATION DSL, ESCALATE TO PO WHEN |
| `CLAUDE-ARCHITECT.md` | Architect | ARCH RULES, CODE RULES, SECURITY, COMMUNICATION DSL, ESCALATE TO PO WHEN, DISCOVERY GATE |
| `CLAUDE-PM.md` | PM | DISPATCH (agent team context), COMMUNICATION DSL, DISCOVERY GATE, ESCALATE TO PO WHEN |
| `CLAUDE-TESTER.md` | Tester | CODE RULES, SPEC CHAIN + TDD, COMMIT, COMMUNICATION DSL, LOOP DETECTION, ESCALATE TO PO WHEN |
| `CLAUDE-AUDITOR.md` | Auditor | CODE RULES, SECURITY, COMMIT, COMMUNICATION DSL, LOOP DETECTION, ESCALATE TO PO WHEN |

## Usage

Include the role's slice in the spawn prompt instead of the full `CLAUDE.md`:

```
Files to read first:
- harness/roles/ROLE-[ROLE].md
- harness/context/CLAUDE-[ROLE].md   ← role-specific slice
- harness/skills/SKILL-coding-standards-[platform].md  ← Builder/Reviewer only
```

## Keeping Slices in Sync

When `CLAUDE.md` changes, update any affected slices:

1. Identify which sections changed in `CLAUDE.md`.
2. Open the slice files that include those sections (see table above).
3. Apply the same changes to the relevant slice(s).
4. Open a PR on the harness branch — docs-only, Track 1 merge.

The full `CLAUDE.md` is the source of truth. Slices are derived views — never edit a slice section without also editing the corresponding section in `CLAUDE.md`.
