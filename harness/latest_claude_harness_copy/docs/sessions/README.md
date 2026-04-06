# docs/sessions/

This directory stores structured session KPI records for each engineering session.

## Purpose

Each file captures lifecycle event counts and derived ratios for a single session,
enabling trend analysis across sessions (spawn-to-D: ratio, B: rate, time-to-D: by role).

## File naming

`YYYY-MM-DD[letter].json` — letter suffix (a, b, c…) disambiguates multiple sessions on the same day.

## Schema reference

See [schema.md](schema.md) for the canonical field definitions, computation rules,
and which issue defines each metric. Field names follow OTel GenAI-compatible conventions
(per #439) so session records can be forwarded to an observability backend without transformation.

## How it is populated

At SESSION END, step 7b of `harness/skills/SKILL-session-shutdown.md`, Lead writes
`docs/sessions/YYYY-MM-DD[letter].json` with all computable fields filled in.
Unknown or uncomputable fields are set to `null`. The file is committed as part of
the shutdown deliverables PR.

## Not gitignored

These files are committed to the repo. They are the authoritative cross-session
trend store. Do not add `docs/sessions/*.json` to `.gitignore`.
