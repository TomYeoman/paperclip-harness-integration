# Harness Scripts

These scripts make harness setup reproducible across machines and companies.

## Why these scripts exist

- We want setup to be replayable (not tied to one local DB backup).
- We want new contributors to bootstrap the same project/issue/agent structure.
- We want CI or automation to execute the same flow consistently.

Canonical strategy/operations decisions are tracked in `harness/adr/`.

## Maintenance policy (required)

- If a harness change adds or modifies Paperclip API behavior, make it scriptable in `harness/scripts/`.
- Update this README in the same PR to reflect any new flags, defaults, ordering, or prerequisites.
- Exemption: local-only issue operations (e.g., assigning, commenting, or status moves for a one-off local run) do not require script updates when harness behavior is unchanged.
- Avoid introducing UI-only runbook steps for core setup unless there is no API path.
- Use `harness/templates/PR-CHECKLIST.md` for harness PR reviews.

## Script inventory (kept minimal)

1. `setup-harness-docker.sh`
   - **Primary entrypoint for Docker users.**
   - Runs the full sequence in the running `paperclip` container:
     1) bootstrap project + hello-world issue, 2) configure role agents.
   - Use this first in most setups.

2. `bootstrap-harness-project-context.sh`
   - Ensures project `Harness Scaffolding` + label `harness` exist.
   - Ensures one initial issue exists: `HARNESS: Hello world`.
   - Sets issue instructions to run `pwd && ls -a` and report output.
   - Use for fresh bootstrap or to re-sync project metadata.

3. `setup-harness-agent-configs.sh`
   - Creates/updates role agents (Builder/Reviewer/Tester/etc.) under the CEO.
   - Sets adapter type/model/cwd and per-role `instructionsFilePath`.
   - Use after role files are ready, and whenever role config drifts.

## Why each agent still "knows" about common rules

Role contracts are split into two layers:

- `harness/AGENTS.md` = shared governance contract
- `harness/roles/ROLE-*.md` = role-specific behavior

To keep agent instructions isolated in Paperclip, each agent points to a dedicated runtime entry file under:

- `harness/runtime-instructions/<role>/AGENTS.md`

Each runtime entry only points that agent at:

1. the shared core contract (`harness/AGENTS.md`)
2. its own role contract (`harness/roles/ROLE-...md`)

This avoids loading all role files as a single instructions bundle while keeping one shared source of truth.

## Typical usage

### One command (Docker)

```sh
PAPERCLIP_API_KEY=<board-token> \
PAPERCLIP_COMPANY_ID=<company-id> \
HARNESS_ROLE_SET=core \
HARNESS_ADAPTER_TYPE=opencode_local \
./harness/scripts/setup-harness-docker.sh
```

### Optional toggles for `setup-harness-docker.sh`

- `HARNESS_RUN_CONTEXT_BOOTSTRAP=true|false`
- `HARNESS_RUN_AGENT_SETUP=true|false`

Example (skip issue creation, only refresh agent config):

```sh
PAPERCLIP_API_KEY=<board-token> \
PAPERCLIP_COMPANY_ID=<company-id> \
HARNESS_RUN_CONTEXT_BOOTSTRAP=false \
HARNESS_RUN_AGENT_SETUP=true \
./harness/scripts/setup-harness-docker.sh
```

## Required env vars

- `PAPERCLIP_API_KEY`: board token
- `PAPERCLIP_COMPANY_ID`: target company

Optional:

- `PAPERCLIP_API_BASE` (default `http://localhost:3100`)
- `PAPERCLIP_COMPOSE_FILES` (comma-separated; defaults to quickstart, plus workspace override if present)
- `HARNESS_ROLE_SET` (`minimal|core|full`, default `core`)
- `HARNESS_ADAPTER_TYPE` (default `opencode_local`)
- `HARNESS_MODEL` (override auto-discovered model)
- `HARNESS_HELLO_ISSUE_TITLE` (default `HARNESS: Hello world`)

Role set mapping:

- `minimal`: Builder + Reviewer
- `core`: Builder + Reviewer + Tester + Architect
- `full`: Builder + Reviewer + Tester + Architect + Auditor
