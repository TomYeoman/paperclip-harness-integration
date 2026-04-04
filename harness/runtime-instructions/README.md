# Runtime Instruction Entrypoints

These files are per-agent instruction entrypoints used by Paperclip `instructionsFilePath`.

Purpose:

- keep runtime instruction bundles narrow per role
- avoid giving every agent the whole `harness/roles/` directory as its bundle root
- preserve shared governance via `harness/AGENTS.md`

Pattern:

- each role has `harness/runtime-instructions/<role>/AGENTS.md`
- that file points to shared core + one role contract
