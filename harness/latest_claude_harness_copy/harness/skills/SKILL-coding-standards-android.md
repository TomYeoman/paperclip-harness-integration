# Skill: Android / Kotlin Coding Standards

Load this skill when: spawning a Builder or Reviewer for Android work, or reviewing an Android PR.

## Hard-Block Violations (treat as CODE RULES violations — BLOCK immediately)
- [ ] `!!` (non-null assertion operator) — use `?: return`, `?: throw`, or safe-call chain
- [ ] `runBlocking` in ViewModel, Fragment, Activity, or any lifecycle-aware component — coroutines only in `viewModelScope` or `lifecycleScope`
- [ ] `GlobalScope` usage — always scope coroutines to a lifecycle owner
- [ ] `Thread.sleep` in production code
- [ ] Direct `new` instantiation of a class that should be injected via Hilt — use `@Inject constructor` and Hilt modules
- [ ] `lateinit var` on a field that is never guaranteed to be initialised before use
- [ ] Mutable `LiveData` or `StateFlow` exposed from ViewModel (expose as `LiveData`/`StateFlow`, mutate via private `MutableLiveData`/`MutableStateFlow`)
- [ ] Accessing UI from a non-main thread

## Detekt
Run detekt before every commit. Zero violations required.
```bash
./gradlew detekt
```
Project detekt config at `config/detekt/detekt.yml` takes precedence for style rules.

## Dependency Injection
- Hilt for all DI — no manual `Dagger` component wiring in new code
- Every injectable class uses `@Inject constructor`
- Test fakes registered in `@TestInstallIn` modules

## Coroutines
- `viewModelScope` in ViewModels, `lifecycleScope` in Fragments/Activities
- `Dispatchers.IO` for I/O, `Dispatchers.Default` for CPU-bound work
- Never capture `Activity` or `Fragment` reference inside a coroutine that outlives the component

## Architecture
- ViewModel must not import `android.*` UI classes
- Repository pattern: ViewModel → Repository → DataSource
- No business logic in Fragment or Activity

## Testing
- Unit tests with `kotlinx-coroutines-test` and `TestCoroutineDispatcher`
- Use fakes over mocks — see `harness/TDD-STANDARDS.md`
- Instrumented tests only for UI; unit tests for everything else

## Strings
- All user-facing strings in `res/values/strings.xml` — no hardcoded strings in Kotlin code

## Merge Ownership
Builder opens PR in Android repo. Reviewer does adversarial review. Human (PO) merges in GitHub UI. No agent runs `gh pr merge`. No agent runs `gh pr review --approve`.
