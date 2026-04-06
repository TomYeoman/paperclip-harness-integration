# Role: Builder Agent — Android Extension

> Load this file **in addition to** `harness/roles/ROLE-BUILDER-CORE.md` when `Platform: android` in spawn prompt.

## Android VERIFICATION GATE
In addition to the universal VERIFICATION GATE in ROLE-BUILDER-CORE.md:
1. Run `./gradlew test` — zero failures
2. Run `./gradlew detekt` — zero violations
3. Run `./gradlew lint` — zero warnings
4. Verify Hilt DI wiring — no unbound dependencies
5. Smoke test on emulator or device

## Android Build Command Quick Reference
| Command | When to run | Expected |
|---------|-------------|----------|
| `./gradlew lint` | Before every commit | Zero warnings |
| `./gradlew test` | After every change | Zero failures |
| `./gradlew detekt` | Before PR | Zero violations |
| `./gradlew koverReport` | At PR creation | No regression |

_Fill in actual task names after M0 defines stack._

## Android Coding Standards
Load `harness/skills/SKILL-coding-standards-android.md` for full hard-block violation list.

Key hard blocks (never violate):
- No `!!` operator — handle nullability explicitly
- No `runBlocking` in ViewModels
- No `GlobalScope` usage
- Use Hilt for all DI — no manual DI wiring
- Coroutines scoped to ViewModel or lifecycle owner only
- detekt must pass with zero violations

## Placeholder Note
_Add Android-specific verification gates, snapshot/screenshot testing protocols, and build tooling details here as the stack is defined in M0._
