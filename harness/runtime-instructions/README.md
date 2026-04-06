# Runtime Instruction Entrypoints

These files are per-agent instruction entrypoints used by Paperclip `instructionsFilePath`.

Purpose:

- keep runtime instruction bundles narrow per role
- avoid giving every agent the whole `harness/roles/` directory as its bundle root
- preserve shared governance via `harness/AGENTS.md`

Pattern:

- each role has `harness/runtime-instructions/<role>/AGENTS.md`
- that file points to shared core + one role contract

Available entrypoints:

- `ceo/AGENTS.md`
- `builder/AGENTS.md`
- `reviewer/AGENTS.md`
- `tester/AGENTS.md`
- `architect/AGENTS.md`
- `auditor/AGENTS.md`
- `pm/AGENTS.md`
- `qe/AGENTS.md`
- `contract-tester/AGENTS.md`
- `integration-tester/AGENTS.md`
- `security-researcher/AGENTS.md`
- `security-reviewer/AGENTS.md`

Entrypoint rule:

- every entrypoint must require reads of `/workspace/harness/AGENTS.md` and exactly one role contract file.
- runtime entrypoints must rely on canonical sources (see `/workspace/harness/CANONICAL-SOURCES.md`) and must not treat human-reference architecture docs as authoritative.
