# What's Next — Future Direction

*Internal document for Anthropic engineering feedback. Written 2026-03-23.*

---

## What's Next

### Near-term (next 2-4 sessions)

**Resume M2–M5 Loyalty milestone work.** These milestones are fully specified (GitHub issues #239–#258) and paused awaiting PO direction. They cover: NewPrice offer type + CSV import pipeline, offers engine, and membership pricing display across Web/iOS/Android. The harness is ready; we just need the signal to restart.

**Skill-creator workflow (#270).** A meta-skill for generating new skills from observed patterns — currently blocked pending an ADR on skill frontmatter format. Unblocked, this would close a gap where PO-observed patterns are verbally noted but not automatically encoded.

**tasks/state.json architecture (#292).** The harness currently tracks session state in flat markdown files. An Architect ADR is needed before implementation. This would enable agents to do faster, structured state lookups rather than reading full markdown files.

**Community contribution process (#233, #236).** Two contributors want to submit skills. Blocked on an #interest-agent-skills Slack discussion that hasn't happened yet. The harness has no formal contribution workflow.

**Launch script and build journal token reduction.** Recent sessions (2026-03-21) slimmed both templates. More passes are likely as we learn what context is actually load-bearing vs. derivable on demand.

---

## Open Questions

**1. How should agent memory work across sessions?**
We solved intra-session memory (SendMessage, tasks/state.json) but cross-session memory is a patchwork: Claude Code's `/memory` system + harness repo files. The two systems can diverge. When they conflict, which wins? Right now: "trust what you observe" (current repo state), but agents don't always check before acting on stale memory.

**2. What is the right granularity for a "skill"?**
Skills range from single-purpose (SKILL-github-pr-workflow.md) to compound (SKILL-prd-to-tickets.md). No principled rule exists yet for when to split vs. merge. The current approach is "split when token cost warrants it." Is there a better model?

**3. When should Lead delegate vs. execute directly?**
The current rule: Lead never writes code, never reads files, never fetches tickets. But some tasks (closing GitHub issues, running `git log`) are faster for Lead to do directly than to spawn and wait. The rule exists to prevent scope creep, but it creates unnecessary round-trips. Where's the real line?

**4. Can the merge queue replace our two-track model?**
We added a two-track merge model (docs-only vs. code PRs) because the merge queue adds ~2 min latency per PR and was overkill for markdown changes. But the queue protects main integrity. Is there a way to get fast-path merges for clearly low-risk PRs without a separate track?

**5. How do we handle genuine context exhaustion mid-session?**
The CHECKPOINT: signal helps agents re-anchor, but when context approaches limits on a long session, agents silently lose earlier decisions. The `/compact` recommendation helps, but there's no hard gate. We've had cases where an agent resolved a merge conflict "from memory" and was working from a stale view of the file.

---

## Limitations We're Aware Of

**Context management is still manual.** Agents read long role files, skill files, and CLAUDE.md at spawn time. We've worked to reduce token cost (context slices, pruning duplicates, removing CLI-derivable content), but there's no dynamic context selection. An agent spawned for a 10-line docs fix loads the same harness rules as one doing a full milestone implementation.

**Agent coordination overhead is high.** Every inter-agent communication requires: TeamCreate, Agent spawn, SendMessage for every status update, and a separate shutdown sequence. A simple "read this file and report back" task that takes 5 seconds of thinking requires ~6 tool calls and 2-3 turns. The overhead is tolerable but visible.

**Merge queue latency.** On the GitHub Enterprise instance we use, the merge queue adds 2–5 minutes per PR. With 8–20 parallel builders per session, this creates a pipeline stall: builders finish fast but sit waiting for their PR to clear the queue. Sessions accumulate a PR backlog late in the day.

**Self-approval is blocked.** All agents auth as the same GitHub user (corey-latislaw). GHE branch protection blocks self-approval. This means Reviewer agents cannot actually approve PRs — the PO must approve code PRs manually in the GitHub UI. Reviewer agents currently only provide review comments, not approvals.

**No integration with the real codebase CI.** The harness scaffolds multi-platform work (Web, iOS, Android, backend), but the actual application code lives in separate repositories. Builders write code stubs and specs; real CI runs in those repos, not here. Integration fidelity depends on how accurately the harness captures cross-repo contracts.

**Lessons encoding requires 4 manual steps.** Every `remember:` event triggers: (1) Claude memory write, (2) tasks/lessons.md append, (3) relevant harness file update, (4) Builder PR. Step 4 is routinely the one that gets skipped if the session ends early. The process works but is fragile.

---

## What We'd Love Feedback On

**1. Is the DISCOVERY GATE pattern the right friction point?**
We require agents to issue a structured discovery block (READ / UNDERSTAND / UNKNOWNS / PLAN) before writing any code, with a Lead GO required unless the task is trivial. This prevents premature implementation but adds a full round-trip turn for every task. Do you see a lighter-weight version of this that preserves the intent?

**2. How do you think about role separation at the model level?**
We assign: Lead → Opus, Builder → Sonnet, Tester/PM scout → Haiku. This maps role complexity to model capability, but it means discovery and coordination burn Opus tokens even for routine tasks. Is there a principled way to think about model tiering for agentic teams beyond "more reasoning = more expensive model"?

**3. What's the right way to handle a Builder that's stuck in a loop?**
We have a LOOP DETECTION rule (same function modified 3+ times → stop). But in practice, when a Builder loops, Lead doesn't know until the Builder sends a B: signal or the token cost gets high. Is there a better mechanism — e.g., should Lead poll agents periodically, or should there be a turn budget?

**4. Is our `run_in_background: true` avoidance the right call?**
We banned `run_in_background: true` on Agent tool calls after persistent 401 auth failures. We work around it by never backgrounding agents (they all block the Lead). This means Lead can't do anything else while waiting for an agent to finish. Is the 401 issue a known bug, or is our workaround cargo-culted?

**5. How should the harness evolve once the product is actually shipping?**
Right now the harness is ahead of the product — we have scaffolding and tooling for a multi-platform loyalty feature that hasn't shipped. If/when M2–M5 are done and the product is live, the harness needs to shift from "build it" to "maintain it." What patterns in the current harness will create problems in a maintenance-mode workflow?
