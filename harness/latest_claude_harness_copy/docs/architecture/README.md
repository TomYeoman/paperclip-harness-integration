> **HUMAN REFERENCE ONLY** — This document is not loaded into agent contexts and is not authoritative for agent behavior. CLAUDE.md and role files (harness/roles/) are the canonical sources. This file exists for human onboarding and reference.

---

# Harness Architecture

This directory documents the architecture of the AI agent harness — the orchestration system that coordinates teams of specialized AI agents to build software. The harness is built on top of Claude Code's multi-agent capabilities and provides structure, discipline, and repeatability for AI-assisted software development.

**Who this is for:** Engineers onboarding to the harness, stakeholders wanting to understand how AI development works here, and Lead agents bootstrapping a new session.

## Contents

| Document | What it covers |
|----------|---------------|
| [AGENT-ROLES.md](AGENT-ROLES.md) | Each agent role: purpose, model choice, capabilities, and hard constraints |
| [SESSION-LIFECYCLE.md](SESSION-LIFECYCLE.md) | A full session from cold start to shutdown, with sequence diagrams |
| [WORKTREE-MODEL.md](WORKTREE-MODEL.md) | Git worktree isolation — why it exists and how the directory structure works |
| [COMMUNICATION-DSL.md](COMMUNICATION-DSL.md) | The message protocol agents use to coordinate, plus the PR lifecycle |
| [MILESTONE-WORKFLOW.md](MILESTONE-WORKFLOW.md) | Spec-chain TDD, milestone gates, and how PM/Architect/Builder fit together |
| [LEARNING-SYSTEM.md](LEARNING-SYSTEM.md) | How the harness captures lessons and improves across sessions |
