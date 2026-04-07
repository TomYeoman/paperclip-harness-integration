#!/usr/bin/env bash
set -euo pipefail

if ! command -v node >/dev/null 2>&1; then
  echo "node is required" >&2
  exit 1
fi

: "${PAPERCLIP_API_BASE:?Set PAPERCLIP_API_BASE (example: http://localhost:3100)}"
: "${PAPERCLIP_API_KEY:?Set PAPERCLIP_API_KEY (board token or agent token with project/issue permissions)}"
: "${PAPERCLIP_COMPANY_ID:?Set PAPERCLIP_COMPANY_ID}"

export HARNESS_FIXTURE_PROJECT_NAME="${HARNESS_FIXTURE_PROJECT_NAME:-Harness Parity Validation}"
export HARNESS_FIXTURE_PROJECT_DESCRIPTION="${HARNESS_FIXTURE_PROJECT_DESCRIPTION:-Dedicated replayable harness parity and smoke validation project.}"
export HARNESS_FIXTURE_LABEL_NAME="${HARNESS_FIXTURE_LABEL_NAME:-harness-test}"
export HARNESS_FIXTURE_LABEL_COLOR="${HARNESS_FIXTURE_LABEL_COLOR:-#0f766e}"
export HARNESS_FIXTURE_WORKSPACE_CWD="${HARNESS_FIXTURE_WORKSPACE_CWD:-/workspace}"
export HARNESS_FIXTURE_INCLUDE_ISSUES="${HARNESS_FIXTURE_INCLUDE_ISSUES:-true}"
export HARNESS_FIXTURE_RESET_STATE="${HARNESS_FIXTURE_RESET_STATE:-false}"

node <<'NODE'
const base = process.env.PAPERCLIP_API_BASE.replace(/\/+$/, "");
const apiKey = process.env.PAPERCLIP_API_KEY;
const companyId = process.env.PAPERCLIP_COMPANY_ID;

const projectName = process.env.HARNESS_FIXTURE_PROJECT_NAME || "Harness Parity Validation";
const projectDescription =
  process.env.HARNESS_FIXTURE_PROJECT_DESCRIPTION ||
  "Dedicated replayable harness parity and smoke validation project.";
const labelName = process.env.HARNESS_FIXTURE_LABEL_NAME || "harness-test";
const labelColor = process.env.HARNESS_FIXTURE_LABEL_COLOR || "#0f766e";
const workspaceCwd = process.env.HARNESS_FIXTURE_WORKSPACE_CWD || "/workspace";

function parseBoolean(value, fallback) {
  if (value === undefined || value === null || String(value).trim() === "") return fallback;
  const normalized = String(value).trim().toLowerCase();
  if (["1", "true", "yes", "y", "on"].includes(normalized)) return true;
  if (["0", "false", "no", "n", "off"].includes(normalized)) return false;
  return fallback;
}

const includeIssues = parseBoolean(process.env.HARNESS_FIXTURE_INCLUDE_ISSUES, true);
const resetState = parseBoolean(process.env.HARNESS_FIXTURE_RESET_STATE, false);

const contextBlock = [
  "## Harness Validation Context",
  "- Workstream: harness parity validation",
  `- Execution target: repository code in \`${workspaceCwd}\``,
  "- Scenario source: `harness/testing/HARA-12-manual-test-scenarios.md`",
  "- Assertion source: `harness/testing/HARA-12-assertion-matrix.md`",
].join("\n");

const fixtureTemplates = [
  {
    key: "hello-world",
    title: "HARNESS TEST: Hello world",
    status: "todo",
    priority: "low",
    descriptionLines: [
      "Initial fixture sanity task for new-machine setup validation.",
      "",
      "Run this in your working directory and post output in an issue comment:",
      "",
      "`pwd && ls -a`",
    ],
  },
  {
    key: "scenario-1",
    title: "HARNESS TEST: Scenario 1 happy path lifecycle",
    status: "todo",
    priority: "medium",
    descriptionLines: [
      "Validate `todo -> in_progress -> in_review -> done` with PR + review evidence.",
      "",
      "Reference: `harness/testing/HARA-12-manual-test-scenarios.md` (Scenario 1).",
      "Expected artifacts:",
      "- issue status transition history",
      "- PR URL",
      "- `REVIEW:` comment",
      "- `DONE:` comment",
    ],
  },
  {
    key: "scenario-2",
    title: "HARNESS TEST: Scenario 2 block/unblock lifecycle",
    status: "todo",
    priority: "medium",
    descriptionLines: [
      "Validate `in_progress -> blocked -> in_progress` with explicit blocker and unblock evidence.",
      "",
      "Reference: `harness/testing/HARA-12-manual-test-scenarios.md` (Scenario 2).",
      "Expected artifacts:",
      "- blocker evidence comment",
      "- unblock evidence comment",
      "- status transition sequence",
    ],
  },
  {
    key: "scenario-3",
    title: "HARNESS TEST: Scenario 3 merge queue lifecycle",
    status: "todo",
    priority: "high",
    descriptionLines: [
      "Validate queued PR behavior where issue remains `in_review` until merge confirmation.",
      "",
      "Reference: `harness/testing/HARA-12-manual-test-scenarios.md` (Scenario 3).",
      "Expected artifacts:",
      "- queued-state proof",
      "- `QUEUE:` comment",
      "- merge confirmation proof",
      "- `CONFIRMED-D:` comment before `done`",
    ],
  },
  {
    key: "scenario-4",
    title: "HARNESS TEST: Scenario 4 non-queue direct close",
    status: "todo",
    priority: "medium",
    descriptionLines: [
      "Validate non-queue direct close path after approved + merged PR.",
      "",
      "Reference: `harness/testing/HARA-12-manual-test-scenarios.md` (Scenario 4).",
      "Expected artifacts:",
      "- merged PR evidence",
      "- direct `in_review -> done` transition evidence",
    ],
  },
  {
    key: "scenario-5",
    title: "HARNESS TEST: Scenario 5 parity role provisioning",
    status: "todo",
    priority: "medium",
    descriptionLines: [
      "Validate `HARNESS_ROLE_SET=parity` provisions expected role catalog and instruction paths.",
      "",
      "Reference: `harness/testing/HARA-12-manual-test-scenarios.md` (Scenario 5).",
      "Expected artifacts:",
      "- setup script output",
      "- agent list evidence",
      "- `instructionsFilePath` validation per parity role",
    ],
  },
  {
    key: "scenario-6",
    title: "HARNESS TEST: Scenario 6 learning capture",
    status: "todo",
    priority: "medium",
    descriptionLines: [
      "Validate immediate `L:` lesson capture and `retro` linkage before closure.",
      "",
      "Reference: `harness/testing/HARA-12-manual-test-scenarios.md` (Scenario 6).",
      "Expected artifacts:",
      "- `L:` comment",
      "- retro document revision",
      "- close gate evidence",
    ],
  },
  {
    key: "scenario-7",
    title: "HARNESS TEST: Scenario 7 canonical source precedence",
    status: "todo",
    priority: "low",
    descriptionLines: [
      "Validate runtime behavior follows canonical docs over human-reference docs.",
      "",
      "Reference: `harness/testing/HARA-12-manual-test-scenarios.md` (Scenario 7).",
      "Expected artifacts:",
      "- runtime entrypoint file reads",
      "- canonical precedence declaration",
      "- non-authoritative banner checks",
    ],
  },
];

const issueFixtures = fixtureTemplates.map((fixture) => ({
  ...fixture,
  description: [...fixture.descriptionLines, "", contextBlock].join("\n"),
}));

async function request(method, path, body) {
  const res = await fetch(`${base}${path}`, {
    method,
    headers: {
      authorization: `Bearer ${apiKey}`,
      "content-type": "application/json",
      accept: "application/json",
    },
    body: body === undefined ? undefined : JSON.stringify(body),
  });

  if (!res.ok) {
    const text = await res.text();
    throw new Error(`${method} ${path} failed (${res.status}): ${text}`);
  }

  return res.json();
}

function normalize(value) {
  return String(value || "")
    .trim()
    .toLowerCase();
}

function unique(items) {
  return [...new Set(items.filter(Boolean))];
}

function resolveLabelIds(issue, fixtureLabelId) {
  if (Array.isArray(issue?.labelIds) && issue.labelIds.length > 0) {
    return unique([...issue.labelIds, fixtureLabelId]);
  }
  if (Array.isArray(issue?.labels) && issue.labels.length > 0) {
    return unique([...issue.labels.map((label) => label?.id).filter(Boolean), fixtureLabelId]);
  }
  return [fixtureLabelId];
}

async function ensureProjectId() {
  const projects = await request("GET", `/api/companies/${companyId}/projects`);
  const existing = Array.isArray(projects)
    ? projects.find((project) => normalize(project?.name) === normalize(projectName))
    : null;

  if (existing?.id) {
    if (String(existing.description || "") !== projectDescription) {
      await request("PATCH", `/api/projects/${existing.id}`, {
        description: projectDescription,
      });
    }
    return existing.id;
  }

  const created = await request("POST", `/api/companies/${companyId}/projects`, {
    name: projectName,
    description: projectDescription,
    status: "in_progress",
    workspace: {
      name: "workspace",
      cwd: workspaceCwd,
      isPrimary: true,
    },
  });

  return created.id;
}

async function ensureLabelId() {
  const labels = await request("GET", `/api/companies/${companyId}/labels`);
  const existing = Array.isArray(labels)
    ? labels.find((label) => normalize(label?.name) === normalize(labelName))
    : null;

  if (existing?.id) return existing.id;

  const created = await request("POST", `/api/companies/${companyId}/labels`, {
    name: labelName,
    color: labelColor,
  });

  return created.id;
}

async function findIssueInProject(projectId, title) {
  const issues = await request("GET", `/api/companies/${companyId}/issues?q=${encodeURIComponent(title)}`);
  if (!Array.isArray(issues)) return null;

  return (
    issues.find(
      (issue) => normalize(issue?.title) === normalize(title) && String(issue?.projectId || "") === String(projectId),
    ) || null
  );
}

async function ensureIssue(projectId, labelId, fixture) {
  const existing = await findIssueInProject(projectId, fixture.title);

  if (!existing?.id) {
    const created = await request("POST", `/api/companies/${companyId}/issues`, {
      title: fixture.title,
      description: fixture.description,
      status: fixture.status,
      priority: fixture.priority,
      projectId,
      labelIds: [labelId],
    });
    return { issue: created, created: true };
  }

  const patchPayload = {
    projectId,
    labelIds: resolveLabelIds(existing, labelId),
    description: fixture.description,
    ...(resetState ? { status: fixture.status, priority: fixture.priority } : {}),
  };

  const updated = await request("PATCH", `/api/issues/${existing.id}`, patchPayload);
  return { issue: updated, created: false };
}

async function main() {
  const projectId = await ensureProjectId();
  const labelId = await ensureLabelId();

  console.log(`Project: ${projectId}`);
  console.log(`Label:   ${labelId}`);

  if (!includeIssues) {
    console.log("Issue fixtures: skipped (HARNESS_FIXTURE_INCLUDE_ISSUES=false)");
    return;
  }

  let createdCount = 0;
  let updatedCount = 0;

  for (const fixture of issueFixtures) {
    const { issue, created } = await ensureIssue(projectId, labelId, fixture);
    if (created) createdCount += 1;
    if (!created) updatedCount += 1;
    const ref = (issue && (issue.identifier || issue.id)) ?? "unknown";
    console.log(`${created ? "Created" : "Updated"}: ${ref} (${fixture.key})`);
  }

  console.log(`Issue fixtures: ${issueFixtures.length} total (${createdCount} created, ${updatedCount} updated)`);
}

main().catch((error) => {
  console.error(error instanceof Error ? error.message : String(error));
  process.exit(1);
});
NODE
