#!/usr/bin/env bash
set -euo pipefail

if ! command -v node >/dev/null 2>&1; then
  echo "node is required" >&2
  exit 1
fi

: "${PAPERCLIP_API_BASE:?Set PAPERCLIP_API_BASE (example: http://localhost:3100)}"
: "${PAPERCLIP_API_KEY:?Set PAPERCLIP_API_KEY (board token)}"
: "${PAPERCLIP_COMPANY_ID:?Set PAPERCLIP_COMPANY_ID}"

export HARNESS_ROLE_SET="${HARNESS_ROLE_SET:-core}"
export HARNESS_ADAPTER_TYPE="${HARNESS_ADAPTER_TYPE:-opencode_local}"
export HARNESS_WORKSPACE_CWD="${HARNESS_WORKSPACE_CWD:-/workspace}"
export HARNESS_MODEL="${HARNESS_MODEL:-}"
export HARNESS_CONFIGURE_CEO="${HARNESS_CONFIGURE_CEO:-true}"
export HARNESS_GH_CONFIG_DIR="${HARNESS_GH_CONFIG_DIR:-/paperclip/.config/gh}"

export HARNESS_CEO_INSTRUCTIONS_PATH="${HARNESS_CEO_INSTRUCTIONS_PATH:-/workspace/harness/runtime-instructions/ceo/AGENTS.md}"
export HARNESS_BUILDER_NAME="${HARNESS_BUILDER_NAME:-Harness Builder}"
export HARNESS_REVIEWER_NAME="${HARNESS_REVIEWER_NAME:-Harness Reviewer}"
export HARNESS_TESTER_NAME="${HARNESS_TESTER_NAME:-Harness Tester}"
export HARNESS_ARCHITECT_NAME="${HARNESS_ARCHITECT_NAME:-Harness Architect}"
export HARNESS_AUDITOR_NAME="${HARNESS_AUDITOR_NAME:-Harness Auditor}"

node <<'NODE'
const base = process.env.PAPERCLIP_API_BASE.replace(/\/+$/, "");
const token = process.env.PAPERCLIP_API_KEY;
const companyId = process.env.PAPERCLIP_COMPANY_ID;

const roleSet = (process.env.HARNESS_ROLE_SET || "core").toLowerCase();
const adapterType = process.env.HARNESS_ADAPTER_TYPE || "opencode_local";
const workspaceCwd = process.env.HARNESS_WORKSPACE_CWD || "/workspace";
const explicitModel = (process.env.HARNESS_MODEL || "").trim();
const configureCeo = (process.env.HARNESS_CONFIGURE_CEO || "true").toLowerCase() !== "false";
const ghConfigDir = (process.env.HARNESS_GH_CONFIG_DIR || "").trim();

const ceoInstructionsPath =
  process.env.HARNESS_CEO_INSTRUCTIONS_PATH || "/workspace/harness/runtime-instructions/ceo/AGENTS.md";

const agentNames = {
  builder: process.env.HARNESS_BUILDER_NAME || "Harness Builder",
  reviewer: process.env.HARNESS_REVIEWER_NAME || "Harness Reviewer",
  tester: process.env.HARNESS_TESTER_NAME || "Harness Tester",
  architect: process.env.HARNESS_ARCHITECT_NAME || "Harness Architect",
  auditor: process.env.HARNESS_AUDITOR_NAME || "Harness Auditor",
};

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

function ciEquals(a, b) {
  return String(a || "").trim().toLowerCase() === String(b || "").trim().toLowerCase();
}

function byName(agents, name) {
  return agents.find((a) => ciEquals(a.name, name) && a.status !== "terminated") || null;
}

async function resolveModel() {
  if (adapterType === "opencode_local") {
    const models = await request("GET", `/api/companies/${companyId}/adapters/${adapterType}/models`);
    const ids = Array.isArray(models) ? models.map((m) => m?.id).filter(Boolean) : [];

    if (explicitModel) {
      if (ids.length > 0 && !ids.includes(explicitModel)) {
        console.warn(`[warn] HARNESS_MODEL=${explicitModel} not found in discovered models; continuing anyway`);
      }
      return explicitModel;
    }

    if (ids.length === 0) {
      throw new Error(
        "No opencode models discovered. Set HARNESS_MODEL explicitly or fix OpenCode auth/model discovery.",
      );
    }
    return ids[0];
  }

  if (explicitModel) return explicitModel;
  if (adapterType === "codex_local") return "gpt-5.3-codex";
  return null;
}

function desiredRoleSpecs() {
  const baseSpecs = [
    {
      key: "builder",
      name: agentNames.builder,
      role: "engineer",
      title: "Harness Builder",
      capabilities: "Implements HARA tasks in /workspace and opens PRs with issue linkage.",
      instructionsPath: "/workspace/harness/runtime-instructions/builder/AGENTS.md",
    },
    {
      key: "reviewer",
      name: agentNames.reviewer,
      role: "qa",
      title: "Harness Reviewer",
      capabilities: "Reviews HARA PRs against acceptance criteria and quality gates.",
      instructionsPath: "/workspace/harness/runtime-instructions/reviewer/AGENTS.md",
    },
  ];

  if (roleSet === "core" || roleSet === "full") {
    baseSpecs.push({
      key: "tester",
      name: agentNames.tester,
      role: "qa",
      title: "Harness Tester",
      capabilities: "Validates acceptance and regression behavior for HARA tasks.",
      instructionsPath: "/workspace/harness/runtime-instructions/tester/AGENTS.md",
    });
    baseSpecs.push({
      key: "architect",
      name: agentNames.architect,
      role: "engineer",
      title: "Harness Architect",
      capabilities: "Defines interfaces and design constraints for harness evolution.",
      instructionsPath: "/workspace/harness/runtime-instructions/architect/AGENTS.md",
    });
  }

  if (roleSet === "full") {
    baseSpecs.push(
      {
        key: "auditor",
        name: agentNames.auditor,
        role: "researcher",
        title: "Harness Auditor",
        capabilities: "Performs risk and governance audits for harness operations.",
        instructionsPath: "/workspace/harness/runtime-instructions/auditor/AGENTS.md",
      },
    );
  }

  return baseSpecs;
}

async function setInstructionsPath(agentId, path) {
  await request("PATCH", `/api/agents/${agentId}/instructions-path`, { path });
}

async function upsertRoleAgent(existingAgents, ceoId, model, spec) {
  const commonAdapterEnv = {
    ...(ghConfigDir ? { GH_CONFIG_DIR: ghConfigDir } : {}),
  };

  const adapterConfig = {
    cwd: workspaceCwd,
    ...(Object.keys(commonAdapterEnv).length > 0 ? { env: commonAdapterEnv } : {}),
    ...(model ? { model } : {}),
  };

  const existing = byName(existingAgents, spec.name);
  if (!existing) {
    const created = await request("POST", `/api/companies/${companyId}/agents`, {
      name: spec.name,
      role: spec.role,
      title: spec.title,
      reportsTo: ceoId,
      capabilities: spec.capabilities,
      adapterType,
      adapterConfig,
      budgetMonthlyCents: 0,
    });
    await setInstructionsPath(created.id, spec.instructionsPath);
    console.log(`created ${spec.name} (${created.id})`);
    return created.id;
  }

  const patched = await request("PATCH", `/api/agents/${existing.id}`, {
    role: spec.role,
    title: spec.title,
    reportsTo: ceoId,
    capabilities: spec.capabilities,
    adapterType,
    adapterConfig,
  });
  await setInstructionsPath(patched.id, spec.instructionsPath);
  console.log(`updated ${spec.name} (${patched.id})`);
  return patched.id;
}

async function main() {
  if (!["minimal", "core", "full"].includes(roleSet)) {
    throw new Error(`HARNESS_ROLE_SET must be one of: minimal, core, full (got ${roleSet})`);
  }

  const agents = await request("GET", `/api/companies/${companyId}/agents`);
  if (!Array.isArray(agents)) throw new Error("Unexpected agents response");

  const ceo = agents.find((a) => a.role === "ceo" && a.status !== "terminated") || null;
  if (!ceo) {
    throw new Error("No active CEO agent found. Create CEO first.");
  }

  const model = await resolveModel();
  if (model) {
    console.log(`using model: ${model}`);
  }

  if (configureCeo) {
    const commonAdapterEnv = {
      ...(ghConfigDir ? { GH_CONFIG_DIR: ghConfigDir } : {}),
    };
    await request("PATCH", `/api/agents/${ceo.id}`, {
      adapterConfig: {
        cwd: workspaceCwd,
        ...(Object.keys(commonAdapterEnv).length > 0 ? { env: commonAdapterEnv } : {}),
      },
    });
    await setInstructionsPath(ceo.id, ceoInstructionsPath);
    console.log(`updated CEO (${ceo.id}) -> cwd=${workspaceCwd}, instructions=${ceoInstructionsPath}`);
  }

  const specs = desiredRoleSpecs();
  for (const spec of specs) {
    await upsertRoleAgent(agents, ceo.id, model, spec);
  }

  console.log(`done: role set '${roleSet}' configured`);
}

main().catch((err) => {
  console.error(err instanceof Error ? err.message : String(err));
  process.exit(1);
});
NODE
