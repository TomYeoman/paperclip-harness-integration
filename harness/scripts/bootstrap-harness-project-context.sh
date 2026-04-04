#!/usr/bin/env bash
set -euo pipefail

if ! command -v node >/dev/null 2>&1; then
  echo "node is required" >&2
  exit 1
fi

: "${PAPERCLIP_API_BASE:?Set PAPERCLIP_API_BASE (example: http://localhost:3100)}"
: "${PAPERCLIP_API_KEY:?Set PAPERCLIP_API_KEY (board token or agent token with project/issue permissions)}"
: "${PAPERCLIP_COMPANY_ID:?Set PAPERCLIP_COMPANY_ID}"

export HARNESS_PROJECT_NAME="${HARNESS_PROJECT_NAME:-Harness Scaffolding}"
export HARNESS_LABEL_NAME="${HARNESS_LABEL_NAME:-harness}"
export HARNESS_LABEL_COLOR="${HARNESS_LABEL_COLOR:-#0ea5e9}"
export HARNESS_WORKSPACE_CWD="${HARNESS_WORKSPACE_CWD:-/workspace}"

node <<'NODE'
const base = process.env.PAPERCLIP_API_BASE.replace(/\/+$/, "");
const apiKey = process.env.PAPERCLIP_API_KEY;
const companyId = process.env.PAPERCLIP_COMPANY_ID;
const projectName = process.env.HARNESS_PROJECT_NAME;
const labelName = process.env.HARNESS_LABEL_NAME;
const labelColor = process.env.HARNESS_LABEL_COLOR;
const workspaceCwd = process.env.HARNESS_WORKSPACE_CWD;

const contextBlock = [
  "",
  "## Harness Execution Context",
  "- Workstream: harness",
  `- Execution target: repository code in \`${workspaceCwd}\``,
  "- Primary references: `harness/adr/ADR-000-original-harness-spec.md`, `harness/adr/ADR-001-agentic-harness-paperclip-adaptation.md`",
  `- Runtime note: this Paperclip instance is configured with a bind-mounted workspace at \`${workspaceCwd}\``,
].join("\n");

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

function ensureContextBlock(description) {
  const current = (description ?? "").trim();
  if (current.includes("## Harness Execution Context")) return current;
  if (!current) return contextBlock.trim();
  return `${current}${contextBlock}`;
}

function unique(arr) {
  return [...new Set(arr.filter(Boolean))];
}

async function ensureProjectId() {
  const projects = await request("GET", `/api/companies/${companyId}/projects`);
  const existing = Array.isArray(projects)
    ? projects.find((p) => (p?.name || "").trim().toLowerCase() === projectName.toLowerCase())
    : null;
  if (existing?.id) return existing.id;

  const created = await request("POST", `/api/companies/${companyId}/projects`, {
    name: projectName,
    description:
      "Paperclip-native harness build. Sources: harness/adr/ADR-000-original-harness-spec.md and harness/adr/ADR-001-agentic-harness-paperclip-adaptation.md.",
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
    ? labels.find((l) => (l?.name || "").trim().toLowerCase() === labelName.toLowerCase())
    : null;
  if (existing?.id) return existing.id;

  const created = await request("POST", `/api/companies/${companyId}/labels`, {
    name: labelName,
    color: labelColor,
  });
  return created.id;
}

async function listHarnessIssues() {
  const issues = await request("GET", `/api/companies/${companyId}/issues?q=${encodeURIComponent("HARNESS:")}`);
  if (!Array.isArray(issues)) return [];
  return issues.filter((issue) => typeof issue?.title === "string" && issue.title.startsWith("HARNESS:"));
}

async function main() {
  const projectId = await ensureProjectId();
  const labelId = await ensureLabelId();
  const issues = await listHarnessIssues();

  if (issues.length === 0) {
    console.log("No HARNESS issues found. Nothing to update.");
    return;
  }

  console.log(`Project: ${projectId}`);
  console.log(`Label:   ${labelId}`);
  console.log(`Issues:  ${issues.length}`);

  for (const issue of issues) {
    const full = await request("GET", `/api/issues/${issue.id}`);
    const description = ensureContextBlock(full.description);
    const labelIds = unique([...(Array.isArray(full.labelIds) ? full.labelIds : []), labelId]);
    const payload = {
      projectId,
      labelIds,
      description,
    };
    const updated = await request("PATCH", `/api/issues/${issue.id}`, payload);
    const ident = updated.identifier || issue.id;
    console.log(`Updated ${ident} -> project + label + context`);
  }
}

main().catch((error) => {
  console.error(error instanceof Error ? error.message : String(error));
  process.exit(1);
});
NODE
