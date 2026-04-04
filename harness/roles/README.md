# Roles Rollout Plan

This directory defines runtime-agnostic role contracts for harness execution.

## Files

- `ROLE-LEAD.md`
- `ROLE-ARCHITECT.md`
- `ROLE-BUILDER.md`
- `ROLE-REVIEWER.md`
- `ROLE-TESTER.md`
- `ROLE-AUDITOR.md`

## Recommended Activation Order

1. **Lead + Builder + Reviewer** (minimum viable operating loop)
2. **Tester** (add when acceptance/regression coverage becomes bottleneck)
3. **Architect** (add when interface/design churn starts causing rework)
4. **Auditor** (add for periodic deep risk review and governance hardening)

## Mapping To Existing Company Setup

- Current CEO agent can operate as `Lead` behaviorally.
- Add separate Builder/Reviewer agents with `cwd=/workspace` for implementation and review.
- Wire each agent's `instructionsFilePath` to the corresponding role file.
