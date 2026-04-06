# Roles Rollout Plan

This directory defines runtime-agnostic role contracts for harness execution.

## Files

- `ROLE-LEAD.md`
- `ROLE-ARCHITECT.md`
- `ROLE-BUILDER.md`
- `ROLE-REVIEWER.md`
- `ROLE-TESTER.md`
- `ROLE-AUDITOR.md`
- `ROLE-PM.md`
- `ROLE-QE.md`
- `ROLE-CONTRACT-TESTER.md`
- `ROLE-INTEGRATION-TESTER.md`
- `ROLE-SECURITY-RESEARCHER.md`
- `ROLE-SECURITY-REVIEWER.md`

## Recommended Activation Order

1. **Lead + Builder + Reviewer** (minimum viable operating loop)
2. **Tester** (add when acceptance/regression coverage becomes bottleneck)
3. **Architect** (add when interface/design churn starts causing rework)
4. **Auditor** (add for periodic deep risk review and governance hardening)

## Expanded Parity Set

`HARNESS_ROLE_SET=parity` provisions an expanded role catalog for ADR-003 parity testing:

- PM
- QE
- Contract Tester
- Integration Tester
- Security Researcher
- Security Reviewer

Parity mode is opt-in. Existing `minimal`, `core`, and `full` role set behavior remains unchanged.

## Mapping To Existing Company Setup

- Current CEO agent can operate as `Lead` behaviorally.
- Add separate Builder/Reviewer agents with `cwd=/workspace` for implementation and review.
- Wire each agent's `instructionsFilePath` to the corresponding role file.
- In parity mode, runtime entrypoints live under `harness/runtime-instructions/<role>/AGENTS.md` for one-core-plus-one-role loading.
