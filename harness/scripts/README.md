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
     1) bootstrap project + hello-world issue, 2) optional parity test fixtures, 3) configure role agents.
   - Use this first in most setups.

2. `bootstrap-harness-project-context.sh`
   - Ensures project `Harness Scaffolding` + label `harness` exist.
   - Ensures one initial issue exists: `HARNESS: Hello world`.
   - Sets issue instructions to run `pwd && ls -a` and report output.
   - Use for fresh bootstrap or to re-sync project metadata.

3. `bootstrap-harness-parity-fixtures.sh`
   - Ensures project `Harness Parity Validation` + label `harness-test` exist.
   - Seeds replayable parity test issues for scenarios 1-7 from `harness/testing/HARA-12-manual-test-scenarios.md`.
   - Supports project-only cloning with `HARNESS_FIXTURE_INCLUDE_ISSUES=false`.
   - Use when validating a new machine/company against the harness scenario suite.

4. `setup-harness-agent-configs.sh`
   - Creates/updates role agents (Builder/Reviewer/Tester/etc.) under the CEO.
   - Sets adapter type/model/cwd and per-role `instructionsFilePath`.
   - Use after role files are ready, and whenever role config drifts.

5. `setup-harness-github.sh`
   - Validates GitHub integration for PR workflows from the harness runtime.
   - Checks `gh` auth, repo access, remote accessibility, and Issues availability.
   - Prints the expected branch -> push -> PR -> switch-back flow.
   - Adapter-specific behavior: see [harness/adapters/](../adapters/) for runtime overlay docs.

6. `setup-harness-workspace-policy.sh`
   - Configures project execution workspace policy for isolated worktree-based workspaces.
   - Sets `executionWorkspacePolicy.enabled=true` with `defaultMode=isolated_workspace`.
   - Configures `workspaceStrategy.type=git_worktree` with branch template.
   - Use to enable predictable git worktree isolation for harness issue runs.
   - Requires `PAPERCLIP_PROJECT_ID` env var (project to configure).

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
- `HARNESS_RUN_PARITY_FIXTURES_SETUP=true|false` (default false)
- `HARNESS_RUN_AGENT_SETUP=true|false`
- `HARNESS_RUN_GITHUB_SETUP=true|false` (default false)

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
- `PAPERCLIP_PROJECT_ID`: project ID to configure (required for workspace policy script)

Optional:

- `PAPERCLIP_API_BASE` (default `http://localhost:3100`)
- `PAPERCLIP_COMPOSE_FILES` (comma-separated; defaults to quickstart, plus workspace override if present)
- `HARNESS_ROLE_SET` (`minimal|core|full|parity`, default `core`)
- `HARNESS_ADAPTER_TYPE` (default `opencode_local`)
- `HARNESS_MODEL` (override auto-discovered model)
- `HARNESS_PM_NAME` (default `Harness PM`)
- `HARNESS_QE_NAME` (default `Harness QE`)
- `HARNESS_CONTRACT_TESTER_NAME` (default `Harness Contract Tester`)
- `HARNESS_INTEGRATION_TESTER_NAME` (default `Harness Integration Tester`)
- `HARNESS_SECURITY_RESEARCHER_NAME` (default `Harness Security Researcher`)
- `HARNESS_SECURITY_REVIEWER_NAME` (default `Harness Security Reviewer`)
- `HARNESS_HELLO_ISSUE_TITLE` (default `HARNESS: Hello world`)
- `HARNESS_FIXTURE_PROJECT_NAME` (default `Harness Parity Validation`)
- `HARNESS_FIXTURE_PROJECT_DESCRIPTION` (default `Dedicated replayable harness parity and smoke validation project.`)
- `HARNESS_FIXTURE_LABEL_NAME` (default `harness-test`)
- `HARNESS_FIXTURE_LABEL_COLOR` (default `#0f766e`)
- `HARNESS_FIXTURE_WORKSPACE_CWD` (default `/workspace`)
- `HARNESS_FIXTURE_INCLUDE_ISSUES` (default `true`)
- `HARNESS_FIXTURE_RESET_STATE` (default `false`; set true to reset status/priority on existing fixture issues)
- `HARNESS_GIT_DIR` (default `/workspace`)
- `HARNESS_GITHUB_REMOTE` (default `fork`)
- `HARNESS_GITHUB_REPO` (optional explicit `owner/repo`)
- `HARNESS_BASE_BRANCH` (default `master`)
- `HARNESS_GH_CONFIG_DIR` (default `/paperclip/.config/gh`)

Optional for workspace policy script:

- `HARNESS_EXECUTION_WORKSPACE_MODE` (default `isolated_workspace`)
- `HARNESS_WORKSPACE_STRATEGY_TYPE` (default `git_worktree`)
- `HARNESS_BRANCH_TEMPLATE` (default `harness/issue-{issueNumber}`)
- `HARNESS_WORKTREE_PARENT_DIR` (default `/workspace/worktrees`)
- `HARNESS_ALLOW_ISSUE_OVERRIDE` (default `true`)

### Seed parity fixtures directly (host mode)

```sh
PAPERCLIP_API_BASE=http://localhost:3100 \
PAPERCLIP_API_KEY=<board-token> \
PAPERCLIP_COMPANY_ID=<company-id> \
./harness/scripts/bootstrap-harness-parity-fixtures.sh
```

Project-only clone (no test issues):

```sh
PAPERCLIP_API_BASE=http://localhost:3100 \
PAPERCLIP_API_KEY=<board-token> \
PAPERCLIP_COMPANY_ID=<company-id> \
HARNESS_FIXTURE_INCLUDE_ISSUES=false \
./harness/scripts/bootstrap-harness-parity-fixtures.sh
```

Role set mapping:

- `minimal`: Builder + Reviewer
- `core`: Builder + Reviewer + Tester + Architect
- `full`: Builder + Reviewer + Tester + Architect + Auditor
- `parity`: Full set + PM + QE + Contract Tester + Integration Tester + Security Researcher + Security Reviewer

## GitHub integration setup (Docker)

Authenticate GitHub CLI inside the running Paperclip container once:

```sh
docker compose --env-file .env -f docker/docker-compose.quickstart.yml -f docker/docker-compose.workspace.yml exec --user node paperclip gh auth login
```

Alternative (non-interactive): set `GH_TOKEN` (or `GITHUB_TOKEN`) in `.env` so `gh` commands authenticate from environment.

Note: some adapter runtimes set a temporary `XDG_CONFIG_HOME`. In that case, set `GH_CONFIG_DIR=/paperclip/.config/gh` (or `HARNESS_GH_CONFIG_DIR`) so `gh` can still locate auth state.

Run GitHub preflight as part of harness setup:

```sh
PAPERCLIP_API_KEY=<board-token> \
PAPERCLIP_COMPANY_ID=<company-id> \
HARNESS_RUN_CONTEXT_BOOTSTRAP=false \
HARNESS_RUN_AGENT_SETUP=false \
HARNESS_RUN_GITHUB_SETUP=true \
HARNESS_GITHUB_REMOTE=fork \
HARNESS_BASE_BRANCH=master \
./harness/scripts/setup-harness-docker.sh
```
