# Skill: Backend Coding Standards

Load this skill when: spawning a Builder or Reviewer for backend work, or reviewing a backend PR.

## Hard-Block Violations (treat as CODE RULES violations — BLOCK immediately)
- [ ] Unhandled promise rejection — every `async` function must `await` in `try/catch` or chain `.catch()`
- [ ] Broad catch-all `catch (e) {}` or `catch (e: any)` — catch specific error types only
- [ ] `console.log` / `console.error` / `console.warn` in production code — use project structured logger
- [ ] Credentials, API keys, or secrets hardcoded in source — use environment variables or secrets manager
- [ ] HTTP endpoint (no TLS) for any external call — all network over TLS
- [ ] External input not validated at system boundary — validate at controller/handler layer before passing to domain
- [ ] PII written to logs (user IDs in structured fields are OK; names, emails, payment data are not)
- [ ] `process.exit()` called in request handlers — throw an error and let the framework handle it

## Structured Logging
Use the project logger (not `console.*`). Every log entry must be structured (JSON-compatible fields):
```typescript
logger.info('order.created', { orderId, userId })   // OK — structured
logger.info(`order ${orderId} created by ${email}`) // WRONG — unstructured + PII
```

## Input Validation
All external inputs validated at system boundaries (HTTP request body, query params, path params, message queue payloads). Use project validation library (e.g. Zod, Joi, class-validator). Never trust unvalidated input inside domain layer.

## Error Handling
- Define and throw specific error types, not generic `Error`
- HTTP handlers return structured error responses — never leak stack traces to clients
- Wrap third-party library errors at the boundary before propagating

## Security
- All network calls over TLS — no plain HTTP
- No credentials in source code or committed config files — use env vars or a secrets manager
- Rate limiting on all public endpoints
- Authentication required on all non-public endpoints

## Testing
- Unit tests for domain/service logic
- Integration tests for repository layer hitting a real database (not mocks)
- Contract tests for external API integrations

## Merge Ownership
Builder opens PR in backend repo. Reviewer does adversarial review. Human (PO) merges in GitHub UI. No agent runs `gh pr merge`. No agent runs `gh pr review --approve`.
