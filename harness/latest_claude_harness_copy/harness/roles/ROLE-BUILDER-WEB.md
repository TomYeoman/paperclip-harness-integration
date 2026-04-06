# Role: Builder Agent — Web Extension

> Load this file **in addition to** `harness/roles/ROLE-BUILDER-CORE.md` when `Platform: web` in spawn prompt.

## Web VERIFICATION GATE
In addition to the universal VERIFICATION GATE in ROLE-BUILDER-CORE.md:
1. Run `npm test` (or equivalent) — zero failures
2. Run `npm run lint` — zero violations
3. Run type check — zero TypeScript errors
4. Verify no `console.log` left in production code
5. Smoke test in browser

## Web Build Command Quick Reference
| Command | When to run | Expected |
|---------|-------------|----------|
| `npm run lint` | Before every commit | Zero warnings |
| `npm test` | After every change | Zero failures |
| `npm run typecheck` | Before PR | Zero violations |
| `npm run coverage` | At PR creation | No regression |

_Fill in actual commands after M0 defines stack._

## Web Coding Standards
Load `harness/skills/SKILL-coding-standards-web.md` for full hard-block violation list.

Key hard blocks (never violate):
- No `any` type in TypeScript — use proper types
- No non-null assertions (`!`) without justification
- No `console.log` — use project logger
- Follow React hooks rules — ESLint rules-of-hooks must pass
- ESLint must pass with zero violations
- Jest tests required for all new logic

## Placeholder Note
_Add web-specific verification gates, browser compatibility requirements, and build tooling details here as the stack is defined in M0._
