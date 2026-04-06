# Skill: Course Correction

Load this skill when: >30% through implementation AND a fundamental assumption is wrong, spec mismatch discovered, blocking dependency missing, or current approach won't work.

## Trigger Criteria
All of these must be true to warrant course correction (vs. normal debugging):
- More than 30% through planned implementation
- AND one of:
  - Fundamental assumption is wrong (e.g., interface doesn't exist as expected)
  - Spec mismatch discovered (implementation direction contradicts spec)
  - Blocking dependency missing (Architect hasn't produced required interface)
  - Approach fundamentally won't work (not a bug — a design problem)

## Decision Tree

**Impact <20 lines, same files only?**
→ Self-correct. Document in DONE message. No Lead involvement needed.
Example: Discovered timezone enum needed a UTC alias — added 3-line when branch in existing sealed class. Documented in DONE: "COURSE-CORRECT: added UTC alias to TimezoneEnum, 3 lines, same file."

**Impact ≥20 lines, same files only?**
→ Lead GO required. Send COURSE-CORRECT message. Wait for G: before continuing.
Example: Calendar comparison algorithm needs complete rewrite for recurring events — affects CalendarComparator.kt only but 45 lines changed.

**New files or deletes needed?**
→ Architect redesign. Send COURSE-CORRECT to Lead. Lead pauses Builder and assigns Architect.
Example: Sharing protocol needs a separate encryption module — new file required, not in original interface design.

**Affects other agents' work?**
→ Lead coordinates pause + redesign. Send COURSE-CORRECT to Lead immediately — do not continue.
Example: Calendar data model change impacts another Builder working on the UI layer — both must stop.

**Involves user data, security, or scope change?**
→ PO escalation. Lead facilitates. Do not self-decide.
Example: Spec says "nearby friends" but doesn't define search radius — this is a product decision, not a technical one.

## Course Correction Message Format
```
COURSE-CORRECT: [TASK-ID]
WHAT CHANGED: [what assumption/requirement turned out to be wrong]
WHY: [evidence — file:line, spec quote, or interface mismatch]
IMPACT: [lines affected, files affected, other agents affected]
BRANCH STRATEGY: [continue same branch / start fresh branch]
PROPOSED FIX: [what I intend to do instead]
BLOCKED: [yes/no — can I continue while waiting for GO?]
```

## Branch Strategy
**Continue same branch** (most cases):
- Approach change doesn't invalidate existing commits
- Same overall PR scope
- Just a different implementation path

**Start fresh branch** (fundamental redesign):
- First branch's commits are wrong/misleading
- Interface changed — old code references non-existent interface
- PO approved scope change requiring different feature set

To abandon a branch:
```bash
git checkout main
git pull origin main
git checkout -b feature/[name]-v2
```
Old branch: leave it, don't delete — Lead may want to inspect what went wrong.

## Anti-Patterns
- **Silent pivot**: changing approach without notifying Lead — other agents may depend on your original plan
- **Scope creep during correction**: "while I'm here I should also fix..." — no. Fix the blocker only.
- **Not updating tests**: if the spec was misread, tests based on the wrong spec must be updated — but get confirmation first
- **Continuing after BLOCKED=yes**: wait for Lead G: before any more implementation

## After Course Correction Approved
1. Update DISCOVERY gate with revised PLAN
2. Re-run tests from scratch against corrected approach
3. Note correction in DONE message SELF-AUDIT block
