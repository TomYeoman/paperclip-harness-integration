# Merge Ownership

> Canonical source. All other files reference this document.

## Merge Queue

`main` is protected by a GitHub merge queue (ruleset ID 831, enabled 2026-03-20). All PRs targeting `main` go through the queue. The queue auto-rebases PRs in order — parallel builders do not need to manually rebase unless the queue ejects a PR due to a genuine line-level conflict.

## Upstream Param Protocol

Every builder spawn prompt must declare an upstream param (default `🏠` if omitted).

**`🏠` hold in hive (default)**
Local-only development. No upstream PR until Lead sends explicit `👑` authorization (which requires PO instruction):
- Builder develops locally on a feature branch
- Builder opens local PR when checkpoint is reached; Lead spawns Reviewer same turn
- Reviewer all-clear → Lead queues PR via merge queue → Builder polls (2-min cap) → CONFIRMED-D: → CLOSE:
- Upstream PR NOT opened until Lead sends `👑 [platform]`
- After `👑`, Track 2 merge rules apply (adversarial review, human merges — no agent merge, no --auto)
- Useful for spike work, experimental features, or submodule feature branch development

**`🌻` release to sunflower (default upstream)**
Standard PR/review/merge-queue cycle. Builder stays alive through merge queue confirmation:
- Builder sends `D:` after queuing PR
- Builder polls `gh pr view <N> --json state,mergeStateStatus` every 10s, max 2 minutes (12 polls)
- On confirmed merge: builder sends `CONFIRMED-D:` to Lead
- Lead sends `CLOSE:` in response
- Poll timeout: send `B:` to Lead and stop

## Harness PR Reviewer Threshold

Not all harness PRs require a Reviewer. Classify on V: receipt before deciding.

**Low-risk — Lead queues directly, no Reviewer needed:**
- Docs-only changes: lessons.md entries, ROLE-*.md updates, SKILL-*.md documentation
- Harness encoding PRs (adding lessons, updating protocols)
- Single-file harness rule changes with no cross-file dependencies

**High-risk — Reviewer required before queuing:**
- Changes to CLAUDE.md (project root)
- Changes to hooks or settings.json
- New agent roles or major role rewrites
- Changes that affect builder lifecycle or merge protocol
- Any harness PR touching 3+ files with interdependencies

**Low-risk workflow:** Lead queues immediately on V: → `GH_HOST=github.je-labs.com gh pr merge <N> --merge --auto` — no Reviewer spawned.

**High-risk workflow:** Lead spawns Reviewer same turn as V: → Reviewer all-clear → Lead queues.

## Track 1 — Harness repo (markdown-only changes)

- No adversarial review needed for low-risk PRs (see Harness PR Reviewer Threshold above)
- Lead merges via merge queue (Builder opens PR, Lead adds to queue)
- Lead NEVER writes or edits files — Builder always writes, Lead only merges

**Builder workflow:**
1. Push branch: `git push -u origin [branch]`
2. Create PR: Write body to `./pr-body.md` using Write tool, then `gh pr create --title "harness(scope): description" --body-file ./pr-body.md && rm -f ./pr-body.md`
3. Send V: message to Lead
4. Lead adds PR to merge queue: `gh pr merge <PR-number> --hostname github.je-labs.com --merge --auto`
5. Queue auto-rebases and merges — no manual rebase needed
6. Send D: to Lead
7. Poll merge queue every 10s (max 2 minutes / 12 polls): `gh pr view <PR-number> --json state,mergeStateStatus`
8. When queue confirms merge: send CONFIRMED-D: to Lead
9. If poll times out (2 min): send B: to Lead and stop — do not send CONFIRMED-D:
10. Lead sends CLOSE: — builder shuts down

## Track 2 — Submodule repos (production code: iOS/JustEat, Android, web, BE)

- Builder opens PR
- Reviewer agent conducts adversarial review
- Builder addresses feedback from both the Reviewer agent AND human reviewers, makes code changes, and resubmits
- Agents NEVER merge. Agents NEVER approve. Human merges in GitHub UI. Always.
- `gh pr merge` and `gh pr review --approve` are NEVER run by any agent

**Builder workflow:**
1. Push branch: `git push -u origin [branch]`
2. Create PR: Write body to `./pr-body.md` using Write tool, then `gh pr create --title "feat(scope): description" --body-file ./pr-body.md && rm -f ./pr-body.md`
3. Send V: message to Lead
4. **WAIT — do not proceed.** Enter holding state. Do not modify the branch. Do not start other tasks. Wait for Reviewer feedback via SendMessage before taking any further action.
5. Fix ALL feedback (blocking and non-blocking) from **both** the Reviewer agent AND human reviewers on branch
6. Push fixes: `git push origin [branch]`
7. Send `F: [PR number] fixes pushed` to Reviewer via SendMessage
8. Reviewer re-reviews. If further issues found, loop repeats (return to step 5).
9. When Reviewer sends "adversarial review complete, send D: to Lead" — send D: to Lead
10. Human reviews in GitHub UI and adds to merge queue
11. Poll merge queue every 10s (max 2 minutes / 12 polls): `gh pr view <PR-number> --json state,mergeStateStatus`
12. When queue confirms merge: send CONFIRMED-D: to Lead
13. If poll times out (2 min): send B: to Lead and stop
14. Lead sends CLOSE: — builder shuts down

**Lead spawns Reviewer the moment V: is received for Track 2 PRs** — same response turn, no delay. Lead includes `Platform: [ios|android|web|backend]` in the Reviewer spawn prompt.

**Reviewer workflow when review is complete:**
1. Post final PR comment with checklist evidence block: `gh pr review [PR] --comment --body-file ./review-complete.md && rm -f ./review-complete.md`
2. Send Builder via SendMessage: "Adversarial review complete. Send D: to Lead."
3. Send Lead via SendMessage: "Adversarial review complete for PR #[N]. Ready for human review."

## Track 3 — Submodule feature branches (iOS/Android/Web local dev)

Use this track when building features in a submodule repo without waiting for upstream human merge gates.

- Builder fetches origin and checks out a feature branch from `origin/main` (`git fetch origin && git checkout -b feature/[name] origin/main`)
- Builder commits work in the submodule checkout
- testharness submodule pointer is updated to the feature branch tip SHA after each milestone, then a harness PR is opened for Reviewer review
- Upstream PR is NOT opened until Lead sends `👑 [platform]` — which requires explicit PO instruction
- After `👑`, Track 2 merge rules apply: adversarial review, human merges in GitHub UI — no agent merge, `gh pr merge --auto` is NOT available on platform repos
- Agents NEVER merge submodule branches to upstream main

**Builder workflow:**
1. Verify submodule is initialized: `git -C /Users/corey.latislaw/Documents/Code/Claude/testharness/[platform] status`
2. Fetch and create branch: `git -C /Users/corey.latislaw/Documents/Code/Claude/testharness/[platform] fetch origin && git -C /Users/corey.latislaw/Documents/Code/Claude/testharness/[platform] checkout -b feature/[name] origin/main`
3. Verify branch: `git -C /Users/corey.latislaw/Documents/Code/Claude/testharness/[platform] branch --show-current`
4. Commit work in submodule: `git -C /Users/corey.latislaw/Documents/Code/Claude/testharness/[platform] commit ...`
5. After each milestone checkpoint, update submodule pointer in testharness:
   ```bash
   git -C /Users/corey.latislaw/Documents/Code/Claude/testharness add [platform]
   git -C /Users/corey.latislaw/Documents/Code/Claude/testharness commit -F ./commit-msg.txt
   # commit message: chore(submodule): update [platform] to [sha-short]
   ```
6. Push harness branch and open harness pointer PR: send V: to Lead (Reviewer spawned same turn)
7. Address all Reviewer feedback; Lead queues harness pointer PR; Builder polls for CONFIRMED-D:
8. **WAIT for `👑 [platform]` from Lead before any upstream PR.** Lead sends `👑` only after explicit PO milestone sign-off.
9. On `👑 [platform]`: push feature branch to upstream, open upstream PR; Track 2 rules apply from this point
10. Poll `gh pr view --json state` (2-min cap) for merge confirmation; B: to Lead on timeout

**`👑 [platform]` is a Lead-only signal.** Lead never sends `👑` on its own judgment — it requires explicit PO instruction first.

**Submodule pointer commit convention:**
```
chore(submodule): update ios to abc1234
chore(submodule): update android to def5678
chore(submodule): update consumer-web to ghi9012
```

**NON-NEGOTIABLE for Track 3:**
- Builders NEVER merge submodule branches — human gate only at upstream PR
- Submodule pointer in testharness MUST be updated after each milestone (not per-commit — per milestone)
- All git commands on submodule use the submodule checkout path, not a /tmp worktree
- Backend (/backend/) is local code in testharness, not a submodule — use Track 1 or Track 2 for backend PRs

## Encode in every spawn prompt

Every Builder and Reviewer spawn prompt must include:
- Track 1 (harness, markdown-only): Lead merges, no Reviewer needed
- Track 2 (production code): Builder opens PR, Reviewer adversarially reviews, human merges
- Track 3 (submodule feature branch): Builder fetches and branches from origin/main, commits in submodule checkout, updates testharness pointer per milestone, opens harness pointer PR for Reviewer review; upstream PR only after Lead sends `👑` (requires PO instruction); Track 2 rules apply post-`👑`

Spawn prompts must NEVER include instructions to merge or approve. If a spawn prompt contradicts a role file's NON-NEGOTIABLE rules, the role file wins.

## Lead-only signals

| Signal | When to use |
|--------|-------------|
| `👑 [platform]` | Authorises builder to open upstream PR for the named platform. Requires explicit PO instruction — Lead NEVER sends `👑` on its own judgment. After `👑`, Track 2 rules apply (adversarial review, human merges). |

## NON-NEGOTIABLE

- Agents NEVER run `gh pr review --approve`
- Lead uses `gh pr merge --merge --auto` (merge queue) for Track 1 PRs — never `--squash` directly
- Human (PO) merges all Track 2 PRs in the GitHub UI — adds to merge queue via GitHub UI
- Self-approval is blocked on GHE solo setup — the same gh CLI auth is shared with Builder
- Reviewer's job ends at "adversarial review complete" — human merges
- `gh pr merge --auto` is NOT available on platform repos (iOS/JustEat, Android/app-core, Web/consumer-web) — poll `gh pr view --json state` instead
- Upstream PR NOT opened until Lead sends `👑 [platform]` — builder must wait even if feature is complete
