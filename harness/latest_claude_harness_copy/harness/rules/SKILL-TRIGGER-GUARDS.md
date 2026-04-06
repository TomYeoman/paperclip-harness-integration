# Skill Trigger Guard Convention

> **Purpose:** Prevent JetConnect-specific skills from firing in non-JetConnect repos. Formalises the `service.json` detection gate pattern used in `SKILL-capability-testing.md` and `jet-datadog/jetconnect-tricks.md`.

---

## The Problem

Some skills contain knowledge that is only correct for JetConnect service repos (repos with a `service.json` at root). Firing these skills against non-JetConnect repos (REWE, iOS, Android, consumer-web) produces incorrect commands, bucket names, and test instructions that will silently fail or mislead builders.

---

## The Convention

### JetConnect skills MUST carry a detection gate

Any skill (or skill section) that contains JetConnect-specific content must begin with a **Detection Gate** block that guards activation on the presence of `service.json` at the repo root:

```markdown
## Detection Gate

This skill applies only when `service.json` exists at the repo root (JetConnect service repos only).
Confirm before proceeding:

\```bash
test -f service.json && echo "JetConnect — proceed" || echo "Not JetConnect — do not load this skill"
\```

If `service.json` is absent, stop immediately. Do not apply patterns from this skill.
```

### SKILLS-INDEX load triggers must be explicit

Entries for JetConnect-specific skills in `harness/SKILLS-INDEX.md` must include the guard condition in the Load trigger column:

```
Only load if: `service.json` exists at repo root (JetConnect service repos only)
```

This is the signal for the Lead and any agent reading the index to skip the skill without even loading the file.

---

## Affected Skills

The following skills carry or should carry a JetConnect trigger guard:

| Skill | Guard location | Status |
|-------|---------------|--------|
| `harness/skills/SKILL-capability-testing.md` | `## Detection Gate` block at top of file | Present (formalised) |
| `.agents/skills/jet-datadog/jetconnect-tricks.md` | Opening note + SKILLS-INDEX entry | Present (formalised) |
| `harness/skills/SKILL-jetc-atlas-context.md` | SKILLS-INDEX load trigger wording | Present |
| `harness/skills/SKILL-aws-cli.md` | SKILLS-INDEX load trigger wording (JetConnect profile section only) | Partial — skill is not JetConnect-only, but the AWS profile and bucket naming sections apply JetConnect-only |
| `harness/system-knowledge/SERVICE-JETCONNECT.md` | Detection gate at top of page | Present |

---

## Applying the Guard to a New Skill

When adding a new skill that contains JetConnect-specific content:

1. Add a `## Detection Gate` section at the top (or top of the JetConnect-specific section if the skill is not entirely JetConnect-specific).
2. Add the SKILLS-INDEX entry with the `service.json` guard condition in the Load trigger.
3. Reference `harness/system-knowledge/SERVICE-JETCONNECT.md` for shared idioms rather than duplicating content.

---

## Why `service.json`

`service.json` is present in all JetConnect Go service repos (e.g. `order-amendments`, `ordering-bridge`). It is absent in all non-JetConnect repos in this project (REWE .NET, iOS, Android, consumer-web). It is the cheapest and most reliable signal available without network access.
