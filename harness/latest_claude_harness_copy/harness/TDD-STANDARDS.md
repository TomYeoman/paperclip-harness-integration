# TDD Standards

> **Warning**: Your training data contains a lot of bad TDD. Tests that test implementation details (call counts, method names, internal state) are a liability — they break on every refactor and give false confidence. The standards below exist to prevent this.

## The Chain
spec → interface → failing test → implementation → CI green

Test first. Always. No exceptions unless the interface doesn't exist yet (Architect must provide it first).

## Test at Export Boundary
Write one test suite per exported interface, not per class.

**Right:** Test the behavior visible through the public interface.
**Wrong:** Test every internal class, every private method, every state mutation.

If you can delete a class and rewrite it from scratch without breaking tests, your tests are correct.

## Structure-Insensitive Tests
Tests must survive structural refactoring:
- Renaming private methods → no test breaks
- Splitting one class into two → no test breaks
- Changing internal data structures → no test breaks

If renaming `calculateTotal` (private) breaks a test, that test is testing structure. Fix the test.

## Fakes Over Mocks
Mocks test call sequences (structure). Fakes test behavior (output given input).

**Fake pattern (adapt to project language):**
```kotlin
// Kotlin example — adapt to actual project language
class FakeUserRepository : UserRepository {
    private val users = mutableMapOf<String, User>()
    var saveCallCount = 0  // allowed: observable for contract tests only

    override fun save(user: User) {
        saveCallCount++
        users[user.id] = user
    }

    override fun findById(id: String): User? = users[id]
    override fun findAll(): List<User> = users.values.toList()
}
```

**Contract test pattern:**
Run the same test suite against both Fake and real implementation:
```kotlin
abstract class UserRepositoryContractTest {
    abstract fun createRepository(): UserRepository

    @Test
    fun `saved user can be retrieved by id`() {
        val repo = createRepository()
        val user = User("1", "Alice")
        repo.save(user)
        assertEquals(user, repo.findById("1"))
    }
}

class FakeUserRepositoryTest : UserRepositoryContractTest() {
    override fun createRepository() = FakeUserRepository()
}

class RealUserRepositoryTest : UserRepositoryContractTest() {
    override fun createRepository() = RealUserRepository(testDatabase())
}
```

## The Gear-Down Pattern
For complex algorithms that are hard to test at the boundary:
1. Gear down: write lower-level unit tests for the algorithm in isolation
2. Implement the algorithm to pass the unit tests
3. Write a higher-level boundary test that covers the same behavior
4. Delete the lower-level scaffolding tests — the boundary test now covers it

The gear-down tests are temporary scaffolding. Delete them when you're done. They are not long-term tests.

## Test Desiderata
Every test must be:
- **Fast** — milliseconds, not seconds. No network, no disk, no sleep.
- **Isolated** — no shared state between tests. Order-independent.
- **Deterministic** — same result every run. No randomness without seeded RNG.
- **Readable** — test name is the spec. Body is obvious. No comments needed.
- **Behavior-focused** — tests what the system does, not how it does it.

## Multiplatform Test Organization
For Kotlin Multiplatform projects:
- `commonTest/` — shared business logic tests using `kotlin.test`
- `androidTest/` — Android-specific implementations using JUnit 4/5 runner
- `iosTest/` — iOS platform tests using XCTest runner (via kotlin.test bridge)
- `jsTest/` — JS tests using Karma (browser) or Node runner
- `jvmTest/` — JVM-specific tests using JUnit runner

`expect/actual` test utilities:
```kotlin
// commonTest — declare expected test utility
expect fun <T> runTest(block: suspend () -> T): T

// androidTest/jvmTest — actual implementation
actual fun <T> runTest(block: suspend () -> T): T = runBlocking { block() }

// iosTest — actual implementation
actual fun <T> runTest(block: suspend () -> T): T = runBlocking { block() }
```

_Adapt these to the actual project stack after M0 defines it._

## Anti-Patterns

**Reflection-based tests:**
```kotlin
// WRONG — uses reflection to access private field
val field = UserViewModel::class.java.getDeclaredField("_state")
field.isAccessible = true
assertEquals(expected, field.get(viewModel))

// RIGHT — test observable output
viewModel.doSomething()
assertEquals(expected, viewModel.state.value)
```

**Forced synchrony hacks:**
```kotlin
// WRONG — sleep-based synchronization
viewModel.loadData()
Thread.sleep(1000)
assertEquals(expected, viewModel.state.value)

// RIGHT — use test coroutine dispatcher or fake clock
```

**Trivially-passing assertions:**
```kotlin
// WRONG — always passes, tests nothing
assertNotNull(result)

// RIGHT — test actual value
assertEquals(User("alice", "alice@example.com"), result)
```

**Mocking everything:**
```kotlin
// WRONG — verifying call counts tests structure
verify(mockRepo).save(any())

// RIGHT — verify behavior through observable state
assertEquals(1, fakeRepo.stored.size)
assertEquals(expectedUser, fakeRepo.stored[0])
```
