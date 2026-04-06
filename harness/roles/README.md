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

## Role Sets

- `minimal`: Builder + Reviewer
- `core`: Builder + Reviewer + Tester + Architect
- `full`: Builder + Reviewer + Tester + Architect + Auditor
- `parity`: All roles including PM, QE, Contract Tester, Integration Tester, Security Researcher, Security Reviewer

## Recommended Activation Order

1. **Lead + Builder + Reviewer** (minimum viable operating loop)
2. **Tester** (add when acceptance/regression coverage becomes bottleneck)
3. **Architect** (add when interface/design churn starts causing rework)
4. **Auditor** (add for periodic deep risk review and governance hardening)
5. **PM** (add when acceptance criteria management becomes critical)
6. **QE** (add when test strategy and coverage becomes a bottleneck)
7. **Contract/Integration Tester** (add when integration complexity grows)
8. **Security roles** (add when security governance is required)

## Mapping To Existing Company Setup

- Current CEO agent can operate as `Lead` behaviorally.
- Add separate Builder/Reviewer agents with `cwd=/workspace` for implementation and review.
- Wire each agent's `instructionsFilePath` to the corresponding role file.
