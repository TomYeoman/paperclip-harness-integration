# Skill: Web / TypeScript + React Coding Standards

Load this skill when: spawning a Builder or Reviewer for web work, or reviewing a web PR.

## Hard-Block Violations (treat as CODE RULES violations — BLOCK immediately)
- [ ] `any` type — use specific types, `unknown` with type narrowing, or a named interface
- [ ] Non-null assertion `!` (e.g. `someValue!`) without a preceding type guard or null check
- [ ] `console.log` / `console.error` / `console.warn` in production code — use project logger
- [ ] React hooks rules violated: hooks called conditionally, in loops, or outside component/hook
- [ ] `useEffect` with missing or incorrect dependency array (`// eslint-disable-line react-hooks/exhaustive-deps` without explanation comment is a hard block)
- [ ] Direct DOM mutation (e.g. `document.getElementById`) inside a React component — use refs or state
- [ ] `@ts-ignore` without an explanation comment on the same line
- [ ] `@ts-nocheck` anywhere in production code
- [ ] Unhandled promise rejection — every `async` function or `.then()` chain must have `.catch()` or be awaited in a `try/catch`

## ESLint
Run ESLint before every commit. Zero violations required.
```bash
npx eslint . --max-warnings 0
```
Project `.eslintrc` takes precedence.

## TypeScript
- `strict: true` in `tsconfig.json` — no relaxing strictness flags
- No implicit `any` — `noImplicitAny: true` enforced by strict mode
- Prefer `interface` over `type` for object shapes; use `type` for unions and intersections

## React
- Functional components only — no class components in new code
- Custom hooks for reusable stateful logic (filename prefix `use`)
- Props interfaces named `[ComponentName]Props`
- No prop drilling past 2 levels — use context or state management

## Testing
- Jest + React Testing Library for unit/component tests
- Test behaviour not implementation (query by role/label, not by CSS class or test ID except as last resort)
- No snapshot tests of large component trees — snapshot only small, stable leaf components

## Strings
- All user-facing strings via i18n keys — no hardcoded English strings in JSX/TSX

## Merge Ownership
Builder opens PR in web repo. Reviewer does adversarial review. Human (PO) merges in GitHub UI. No agent runs `gh pr merge`. No agent runs `gh pr review --approve`.
