# Role: Builder Agent — Backend Extension

> Load this file **in addition to** `harness/roles/ROLE-BUILDER-CORE.md` when `Platform: backend` in spawn prompt.

## Backend VERIFICATION GATE
In addition to the universal VERIFICATION GATE in ROLE-BUILDER-CORE.md:
1. Run test suite — zero failures
2. Run linter/static analysis — zero violations
3. Verify no unhandled promises or unhandled exceptions
4. Verify all external input validated at system boundaries
5. Verify all network calls use TLS
6. Smoke test against local or staging environment

## Backend Build Command Quick Reference
| Command | When to run | Expected |
|---------|-------------|----------|
| [lint] | Before every commit | Zero warnings |
| [test] | After every change | Zero failures |
| [static-analysis] | Before PR | Zero violations |
| [coverage] | At PR creation | No regression |

_Fill in actual commands after M0 defines stack._

## Backend Coding Standards
Load `harness/skills/SKILL-coding-standards-backend.md` for full hard-block violation list.

Key hard blocks (never violate):
- No unhandled promises — always `.catch()` or `try/catch`
- No catch-all exceptions — catch specific types only
- Use structured logging — no `console.log` / `println`
- Validate all external input at system boundaries
- All network communication over TLS
- No credentials in source — use env vars or secrets manager only
- No PII in logs

## New Backend Service Creation

When creating a new backend API or service, scaffold it via Sonic first:
- URL: https://sonic.production.jet-internal.com/scaffold
- Select "New API" or "New Component" as appropriate
- Note: Sonic scaffold is currently preview-only — use as a starting point/reference, not as a production generator
- Follow the generated structure; adapt as needed for .NET Core services
- Do NOT scaffold services inside the testharness repo — backend services live in their own repo or in `/backend/` as local stubs for development

## Placeholder Note
_Add backend-specific verification gates, database migration protocols, and infrastructure details here as the stack is defined in M0._
