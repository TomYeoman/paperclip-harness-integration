#!/usr/bin/env bash
set -euo pipefail

if ! command -v node >/dev/null 2>&1; then
  echo "node is required" >&2
  exit 1
fi

: "${PAPERCLIP_API_BASE:?Set PAPERCLIP_API_BASE (example: http://localhost:3100)}"
: "${PAPERCLIP_API_KEY:?Set PAPERCLIP_API_KEY (board token)}"
: "${PAPERCLIP_COMPANY_ID:?Set PAPERCLIP_COMPANY_ID}"
: "${PAPERCLIP_PROJECT_ID:?Set PAPERCLIP_PROJECT_ID}"

node <<'NODE'
const base = process.env.PAPERCLIP_API_BASE.replace(/\/+$/, "");
const token = process.env.PAPERCLIP_API_KEY;
const companyId = process.env.PAPERCLIP_COMPANY_ID;
const projectId = process.env.PAPERCLIP_PROJECT_ID;

const defaultMode = process.env.HARNESS_EXECUTION_WORKSPACE_MODE || "isolated_workspace";
const workspaceStrategyType = process.env.HARNESS_WORKSPACE_STRATEGY_TYPE || "git_worktree";
const branchTemplate = process.env.HARNESS_BRANCH_TEMPLATE || "harness/issue-{issueNumber}";
const worktreeParentDir = process.env.HARNESS_WORKTREE_PARENT_DIR || "/workspace/worktrees";
const allowIssueOverride = (process.env.HARNESS_ALLOW_ISSUE_OVERRIDE || "true").toLowerCase() !== "false";

async function request(method, path, body) {
  const res = await fetch(`${base}${path}`, {
    method,
    headers: {
      authorization: `Bearer ${token}`,
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

async function main() {
  console.log(`Fetching project ${projectId}...`);
  const project = await request("GET", `/api/projects/${projectId}`);

  const executionWorkspacePolicy = {
    enabled: true,
    defaultMode: defaultMode,
    allowIssueOverride: allowIssueOverride,
    workspaceStrategy: {
      type: workspaceStrategyType,
      branchTemplate: branchTemplate,
      worktreeParentDir: worktreeParentDir,
    },
  };

  console.log(`Updating project with executionWorkspacePolicy:`);
  console.log(JSON.stringify(executionWorkspacePolicy, null, 2));

  const updated = await request("PATCH", `/api/projects/${projectId}`, {
    executionWorkspacePolicy: executionWorkspacePolicy,
  });

  console.log(`Updated project ${updated.name} (${updated.id})`);
  console.log(`executionWorkspacePolicy: ${JSON.stringify(updated.executionWorkspacePolicy, null, 2)}`);
}

main().catch((err) => {
  console.error(err instanceof Error ? err.message : String(err));
  process.exit(1);
});
