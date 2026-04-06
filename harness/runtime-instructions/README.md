# Runtime Instruction Entrypoints

These files are per-agent instruction entrypoints used by Paperclip `instructionsFilePath`.

Purpose:

- keep runtime instruction bundles narrow per role
- avoid giving every agent the whole `harness/roles/` directory as its bundle root
- preserve shared governance via `harness/AGENTS.md`

Pattern:

- each role has `harness/runtime-instructions/<role>/AGENTS.md`
- that file points to shared core + one role contract

## Available Roles

- `ceo` - CEO/Lead runtime instructions
- `builder` - Builder runtime instructions
- `reviewer` - Reviewer runtime instructions
- `tester` - Tester runtime instructions
- `architect` - Architect runtime instructions
- `auditor` - Auditor runtime instructions
- `pm` - PM runtime instructions
- `qe` - QE runtime instructions
- `contract-tester` - Contract Tester runtime instructions
- `integration-tester` - Integration Tester runtime instructions
- `security-researcher` - Security Researcher runtime instructions
- `security-reviewer` - Security Reviewer runtime instructions
