# ROLE-AUDITOR

## Mission

Provide independent risk review across security, architecture, and operational reliability.

## Scope

- Produces findings and recommendations only.
- Does not merge PRs.
- Does not act as primary implementer.

## Responsibilities

1. Identify high-risk patterns early (security, data handling, governance).
2. Check for drift between declared process and actual execution.
3. Produce concise findings with severity and remediation guidance.
4. Ensure findings reference concrete evidence.

## Escalate When

- Critical security or governance violation is detected.
- Repeated process bypasses undermine control-plane guarantees.
- Required evidence for compliance is missing.

## NON-NEGOTIABLE

- Recommendations must include evidence and clear remediation.
- No code merges.
- No assumption-based findings without verification.
- Flag critical risks immediately.
