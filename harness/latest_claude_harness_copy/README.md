# Agent Orchestration Harness

## What is this?

This repository contains an agent orchestration harness for coordinating multiple AI agents working in parallel on a software project using Claude Code. The harness manages a team of specialized agents — Lead, Architect, Builders, Reviewer, Tester, and Auditor — each with defined roles, communication protocols, and quality gates. It has been battle-tested over 22+ sessions, 350+ commits, and 240+ PRs. Every rule in the harness traces back to a real failure.

## Quick Start

1. Launch Claude Code in this directory
2. Say: **"Read LAUNCH-SCRIPT.md and begin."**
3. The Lead agent takes it from there

## Key Files

| File | Purpose |
|------|---------|
| `CLAUDE.md` | Dense agent reference — auto-loaded every session |
| `CLAUDE-HUMAN.md` | Same information in readable prose with explanations |
| `LAUNCH-SCRIPT.md` | Current session's startup guide — read this to resume |
| `harness/roles/` | Agent role definitions (Lead, Builder, Reviewer, etc.) |
| `harness/skills/` | Lazy-loaded skill files (load only when needed) |
| `harness/SKILLS-INDEX.md` | Lookup table — find the right skill file quickly |
| `tasks/MILESTONES.md` | Project milestones and task definitions |
| `tasks/PRODUCT-BRIEF.md` | Product vision, scope, and constraints |
| `docs/BUILD-JOURNAL.md` | Session-by-session narrative log |

## Agent Team

| Role | Model | What they do |
|------|-------|-------------|
| **Lead** | Opus | Orchestrates all agents — never writes code |
| **PM** | Haiku/Sonnet | Product discovery and milestone definition |
| **Architect** | Sonnet/Opus | Designs interfaces and ADRs, 2 milestones ahead |
| **Builder** | Sonnet | Implements features with TDD |
| **Reviewer** | Sonnet/Opus | Reviews PRs — never merges |
| **Tester** | Sonnet | Writes integration and acceptance tests |
| **Auditor** | Opus | Security, architecture, and performance audits |

## Session Flow

Sessions begin by reading `LAUNCH-SCRIPT.md`, which contains the handoff from the previous session: open PRs, active issues, remaining milestone tasks, and pending harness updates. The Lead reads this script, assigns tasks to agents, and monitors progress. Sessions end with the shutdown protocol (see `harness/skills/SKILL-session-shutdown.md`), which generates the next session's launch script and commits all deliverables.

## Starting a Session

Say `start` (or any combination of keywords below) as your opening message. Lead reads `LAUNCH-SCRIPT.md`, pulls the latest state, and begins.

### Session keywords

| Keyword(s) | What it does |
|-----------|-------------|
| `🍯` or `swarm` | Parallel builders, auto-continue after each task |
| `🐝` or `worker` | Single builder, pause for PO input between tasks (default) |
| `🌻` or `release` | Builders open upstream PRs on task completion |
| `🏠` or `hive` | Work stays local until you say otherwise (default) |
| `debug` | Verbose narration + OTEL cost report at session end |

Keywords can be combined: `start debug swarm` · `🍯 🌻` · `start debug worker`

Full reference: [harness/SESSION-FLAGS.md](harness/SESSION-FLAGS.md)

## Beehive

Beehive is the build protocol that governs how agents are spawned and how their work reaches production. Every builder spawn uses two parameters.

### Modes

| Mode | Symbol | When to use |
|------|--------|-------------|
| **swarm** | 🍯 | Multiple builders in parallel, auto-continue after each task completes. Always used for harness work. Optionally used for full milestones. |
| **worker** | 🐝 | Single builder, one task. Builder completes the task and pauses. Lead shows a dashboard and waits for PO input before the next assignment. Use for a specific bug or issue. |

A session can mix both — the mode is per-task, not per-session.

### Upstream

All work stays in the hive by default. Nothing goes upstream until you say so.

| Signal | Meaning |
|--------|---------|
| 🏠 | Hold in hive — no upstream PR opened. **Default for all work.** |
| 🌻 | Release to sunflower — upstream PR opens on task completion. |
| 👑 `[platform]` (Lead signal) | PO authorizes release. Overrides 🏠 hold. Lead never sends this without explicit PO instruction. After 👑, human review and merge is required — agents cannot merge upstream PRs. |

### Rules

- **Harness work is always `swarm` + `🏠`.** No gates, no manual approval — but it never ships upstream without `👑`.
- **Worker builders pause after every task.** The PO drives the next assignment.
- **Swarm builders auto-continue.** Lead assigns the next task without PO input.

### Agent naming

You can identify a builder's mode at a glance in the team pane:

- `🍯b-auth-flow` — swarm builder working on auth flow
- `🐝b-fix-login` — worker builder on a single login bug fix

## Observability

A local OTEL stack (Grafana + Prometheus + collector) ships with the harness for real-time session metrics: token usage, cost by model and tool, context window pressure, cache hit rate, and per-agent spend.

```bash
bash harness/otel/otel-start.sh   # starts automatically on session start
# Grafana: http://localhost:4000  (admin / admin)
```

Full setup: [harness/otel/README.md](harness/otel/README.md)

## Harness Improvement

The harness improves every session. When an agent makes a mistake, the pattern is captured in `harness/lessons.md` and applied to the relevant role or skill file within 5 minutes. Future agents read the improved rules.
