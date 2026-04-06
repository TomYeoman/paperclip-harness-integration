# Agent Swarm Metrics — Industry Research Report
**Date:** 2026-03-24
**Context:** Issue #432 — Which metrics to save from each session?
**Scope:** How to measure agent swarms vs human teams; virtual FTE; velocity; industry best practices and antipatterns.

---

## Executive Summary

The field of agent swarm observability is maturing rapidly in 2024–2025, converging on OpenTelemetry as the standard transport layer and a shared vocabulary of traces, metrics, and events. Commercial platforms (LangSmith, Langfuse, AgentOps, Arize Phoenix) have moved beyond single-agent token/latency dashboards toward multi-agent trajectory evaluation and coordination scoring. Despite this progress, significant gaps remain: coordination overhead is rarely measured directly, cascade failure detection is largely manual, and code-generation-specific downstream metrics (PR quality, cycle time, review pass rate) are almost entirely absent from purpose-built observability tooling. The industry's measurement frameworks for code-gen agent swarms are nascent and represent the clearest opportunity for this project.

---

## 1. Virtual FTE / Human Team Comparison

**No industry standard exists yet.** The closest proxies available:

| Metric | What it measures | Human analogue |
|--------|-----------------|----------------|
| **PR Cycle Time** (issue-open → merged) | End-to-end delivery speed | Sprint velocity |
| **Test Pass Rate on First Submission** | Agent output quality without human fix | Junior engineer first-submission rate |
| **Revision Count before approval** | Review rework required | Code review round trips |
| **PRs merged per session** | Raw throughput | Story points closed per sprint |

Early industry data: AI-assisted development reduces PR cycle time 30–40% for PRs under 500 lines. A practical capacity model:

> **Effective capacity added** = PRs merged × (estimated human hours per PR) × (1 − rework rate)

A session producing 8 clean merged PRs that would each have taken a human 2 hours, with 10% rework, adds ~14.4 human-hours of effective capacity. This is not wall-clock equivalence — it is *effective output* normalised by quality.

---

## 2. Performance Metrics

### Task-level
- **Task Completion Rate (TCR):** Fraction of tasks successfully completed end-to-end. The single most cited KPI across all platforms.
- **True Cost per Task:** Token cost ÷ TCR. Raw cost-per-token is misleading — an agent costing $0.10/run but failing 50% of tasks has a true cost of $0.20/successful outcome.
- **Time-to-Completion / Latency:** End-to-end wall-clock time. Track as P50, P95, P99. Multi-agent systems require per-hop latency breakdowns to isolate bottlenecks.
- **Error Rate:** Proportion of runs resulting in error states (tool failure, model refusal, timeout).
- **Retry Rate:** How frequently agents re-attempt the same action — leading indicator of ambiguous tool outputs and soft failures.
- **Plan Adherence Score:** Whether the agent's execution path matched its stated plan.

### Coordination-level (multi-agent specific)
- **Coordination Overhead Ratio:** Tokens/time on orchestration (routing, handoffs, delegation) vs. tokens on substantive work. Almost entirely unmeasured by current commercial tools — a named gap.
- **Inter-Agent Communication Efficiency:** Message volume between agents relative to task complexity. Unbounded agent-to-agent exchange is a known failure mode.
- **Agent Utilisation:** Fraction of spawned agents actively working vs. blocked or idle at any moment.
- **Handoff Success Rate:** Fraction of agent-to-agent task handoffs completed without information loss or re-work.
- **Spawn-to-Done Ratio:** Fraction of spawned agents that complete cleanly (D: signal) vs. time out or block (B: signal).

### Quality
- **Trajectory Evaluation Score:** Whether the agent followed the expected action sequence, not just whether the final output was correct.
- **Context Utilisation Score:** How efficiently agents use their context window — exhaustion is a direct failure mode.

---

## 3. Code-Gen Agent Specifics

Largely absent from LLM observability tools; tracked in engineering analytics platforms (LinearB, Waydev, Augment Code):

| Metric | Signal |
|--------|--------|
| **PR Cycle Time** | Delivery speed; most actionable end-to-end KPI |
| **PR Size Distribution** | Oversized PRs (>400 lines) signal context drift or bundled unrelated changes |
| **Test Pass Rate on First Submission** | Fraction of agent PRs where CI passes without human intervention |
| **Review Pass Rate / Revision Count** | How many cycles before approval — lower = higher agent quality |
| **Code Churn Rate** | Lines modified/deleted shortly after agent commit — indicates low-confidence changes |
| **Loop Count per PR** | Times same file modified in one session — already tracked in this harness (N=3 threshold) |
| **EvoScore** (SWE-CI 2025) | Whether agent decisions facilitate future code evolution or accumulate technical debt |

---

## 4. Health Indicators

### Agent Failure Mode Taxonomy (2025 research)
- **Infinite loop / repetitive action:** Same tool called N times without state change. Most frequent production failure. *This harness: N=3 threshold already implemented.*
- **Context exhaustion:** Window fills; agent hallucinates or refuses tasks. Leading indicator: rapid token-per-turn growth.
- **Cascade failure:** One agent's error propagates through downstream agents. Research shows 41–86.7% of multi-agent failures trace back to a single root cause. Requires cross-agent trace correlation.
- **Unbounded agent-to-agent loops:** Two agents exchange replies without advancing state.
- **Ambiguous tool output misinterpretation:** Soft failure (empty/unexpected result) triggers indefinite retry.

### Health Signals
- Turn count / LLM call count per task (absolute ceiling as fail-safe)
- Spawn/shutdown ratio — more spawns than clean shutdowns = cascade or runaway orchestration
- Time-without-progress — wall-clock time since last meaningful state change
- P95 cost per session — circuit breaker trigger

---

## 5. Observability Tool Landscape

| Tool | What It Measures | Strengths | Gaps |
|------|-----------------|-----------|------|
| **LangSmith** | Traces, token usage, latency, error rate, cost, trajectory evaluation | Near-zero overhead; best-in-class trajectory eval | Weak on coordination overhead; no cascade detection |
| **Langfuse** | Latency, cost, error rate, quality scores, session replay | Open source; OTel native; human annotation workflow | ~15% perf overhead; limited multi-agent coordination |
| **AgentOps** | Agent-to-agent communication, tool usage, session stats, behavioral deviations | Best multi-agent native support | ~12% overhead; smaller ecosystem |
| **Arize Phoenix** | Traces, LLM evals, retrieval quality, drift detection | Strong on drift and retrieval | Less focus on coordination patterns |
| **Weights & Biases** | Experiment tracking, model perf, cost, custom metrics | Excellent for iterative dev and A/B eval | Research-oriented, not production-monitoring-first |
| **OpenLLMetry** | OTel instrumentation for LLM calls across frameworks | Vendor-neutral | Requires a backend (Datadog, Grafana, etc.) |
| **Datadog LLM Obs.** | OTel GenAI conventions, LLM tracing, cost, latency, error | Enterprise alerting; native OTel | Expensive; GenAI features newer and less mature |

**No tool provides:** coordination overhead ratio, spawn/shutdown health signals, or cascade failure root-cause attribution out of the box.

---

## 6. Industry Antipatterns

1. **Raw cost without TCR** — true cost is cost ÷ success rate.
2. **Per-agent metrics without cascade correlation** — the majority of failures originate from one agent; per-agent dashboards miss this.
3. **Hours as a proxy for output** — agent "hours" are not comparable to human hours; output quality (PR quality, test pass rate) is the right normalisation.
4. **Context exhaustion as a lagging indicator** — agents degrade silently. Monitor token-per-turn growth rate, not just total usage.
5. **Treating coordination tokens as waste** — some coordination overhead is necessary; the signal is the *ratio*, not the absolute count.
6. **Session-level metrics only** — trend analysis (is loop count rising session over session?) is more valuable than any single session snapshot.

---

## 7. Gaps in Current Practice

1. **Coordination overhead is unmeasured** — no tool distinguishes orchestration tokens from substantive work tokens.
2. **Cascade failure attribution is manual** — research confirms this is the dominant failure mode; no production tool automates root-cause attribution.
3. **Code-gen downstream metrics are siloed** — token cost in LLM tools; PR quality in engineering analytics; no unified view.
4. **Context exhaustion is predictive-only in research** — tools report usage but don't predict or prevent exhaustion.
5. **Spawn/shutdown patterns as health signals are ignored** — lifecycle contains rich health information not modelled by current tools.

---

## 8. Recommendations for This Project

### Immediate (session-end dashboard additions)
1. **Spawn-to-D: ratio** — already derivable from session DSL signals. Add to dashboard.
2. **B: rate per session** — fraction of agents that blocked vs. completed. Rising B: rate = systematic blockers.
3. **PRs merged per session + cycle time** — capture from `gh pr list --merged` with timestamps.

### Short-term (harness instrumentation)
4. **Coordination overhead tracking** — emit Lead orchestration token cost separately from Builder token cost. Aim for <15% overhead; alert at >25%.
5. **Loop count per PR as session KPI** — already partially implemented; surface in dashboard with trend.
6. **Cost circuit breaker** — define P95 session cost threshold; Lead surfaces to PO if exceeded.

### Medium-term (structured logging)
7. **OTel GenAI semantic conventions** — use standard attribute names (`gen_ai.agent.name`, `gen_ai.task.id`, `gen_ai.operation.name`) even in structured logs for future portability.
8. **Cross-session trend store** — a simple JSON log per session in `docs/sessions/` capturing the KPIs above. Enables trend analysis across sessions without a full observability platform.

### Virtual FTE calculation (proposed formula)
```
vFTE_hours = Σ(PRs merged × estimated_human_hours_per_PR × (1 − rework_rate))
session_efficiency = vFTE_hours / session_wall_clock_hours
```
Baseline: measure `estimated_human_hours_per_PR` from ticket size estimates (T-shirt sizing) or historical cycle time. Track `rework_rate` from revision count before approval.

---

## Sources

- Langfuse: https://langfuse.com/blog/2024-07-ai-agent-observability-with-langfuse
- OpenTelemetry GenAI: https://opentelemetry.io/blog/2025/ai-agent-observability/
- OTel GenAI Semantic Conventions: https://opentelemetry.io/docs/specs/semconv/gen-ai/
- Beyond Black-Box Benchmarking (2025): https://arxiv.org/html/2503.06745v1
- MultiAgentBench (2025): https://arxiv.org/html/2503.01935v1
- Emergent Coordination in Multi-Agent LLMs: https://arxiv.org/abs/2510.05174
- Why Multi-Agent LLM Systems Fail (2025): https://arxiv.org/html/2603.03823v1 / https://galileo.ai/blog/multi-agent-llm-systems-fail
- SWE-CI EvoScore: https://arxiv.org/pdf/2503.13657
- AI Agent Metrics (Galileo): https://galileo.ai/blog/ai-agent-metrics
- KPIs for Production AI Agents (Google Cloud): https://cloud.google.com/transform/the-kpis-that-actually-matter-for-production-ai-agents
- LangSmith + AgentOps comparison: https://www.akira.ai/blog/langsmith-and-agentops-with-ai-agents
- Autonomous Development Metrics (Augment Code): https://www.augmentcode.com/tools/autonomous-development-metrics-kpis-that-matter-for-ai-assisted-engineering-teams
- LLMOps in Production 2025: https://www.zenml.io/blog/what-1200-production-deployments-reveal-about-llmops-in-2025
- Agent Reliability Gap (12 failure modes): https://medium.com/@Quaxel/the-agent-reliability-gap-12-early-failure-modes-91dba5a2c1ae
