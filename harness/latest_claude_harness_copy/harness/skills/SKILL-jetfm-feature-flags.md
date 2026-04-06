# Skill: JetFM Feature Flag Protocol

Load this skill when: implementing any new user-facing feature.

## Rule

Every new feature must be gated behind a JetFM feature flag. No feature ships directly to users without a kill switch.

## JetFM API

Endpoint: `GET https://features.api.justeattakeaway.com/config/v1/{scope}/{environment}`
No authentication required.
Returns a JSON config snapshot with a `features[]` array.
Supports ETag caching (304 Not Modified).

Response shape:

```json
{
  "features": [
    {
      "key": "scope::feature-name",
      "valueType": "bool | string | int | composite",
      "defaultValueRules": [{ "restrictions": {}, "value": "<typed-value>" }],
      "evaluationLogic": {}
    }
  ]
}
```

## Builder Protocol

### Step 0 — Verify flag exists (flag existence gate)

Before writing any code, verify the flag exists in JetFM:

```bash
curl -s "https://features.api.justeattakeaway.com/config/v1/{scope}/{environment}" \
  | jq -e '.features[] | select(.key == "{scope}::{flag-key}") | .key'
```

Empty output = flag does not exist. Create it in JetFM first. Include result in DISCOVERY block.

### Step 1 — Create the flag in JetFM

- Key format: `{scope}::{feature-name}` (e.g. `jetconnect::rewe-tcs-scalable`)
- Default value: **OFF** (`false` for bool) in all environments
- Description must reference the ticket number

### Step 2 — Initialise a flag client

Fetch the config snapshot from `{baseURL}/config/v1/{scope}/{environment}`.
Cache in memory; refresh periodically (background timer/goroutine recommended).
No auth needed — plain HTTP GET.
See Language Examples for your stack.

### Step 3 — Gate code at the feature entry point

One flag check per feature, at the entry point (controller/handler/use-case) — not deep in utilities.
Preserve existing behaviour when flag is OFF.

### Step 4 — Default OFF confirmed

Flag defaults `false`/OFF in dev, staging, production.
State in PR body: `Flag default: OFF`

### Step 5 — Enable via Sonic after deploy

Enable in target environment via Sonic dashboard after merge + deploy.
Never hardcode flag values.

## Flag Existence Gate — DISCOVERY Integration

Add `FLAG-CHECK` to your DISCOVERY block for any feature-flagged work:

```
DISCOVERY: [TASK-ID]
READ: [files read]
UNDERSTAND: [2-3 sentences]
FLAG-CHECK: verified {scope}::{flag-key} exists in {environment} ✓
UNKNOWNS: [list or NONE]
PLAN: [checklist]
R: yes | blocked:[reason]
```

If flag missing: `blocked: flag {scope}::{flag-key} not found in JetFM — needs creation`

## Language Examples

### Go (go-kit SDK)

```bash
go get github.com/flypay/go-kit/v5/pkg/featureflag/jetfm
```

```go
import "github.com/flypay/go-kit/v5/pkg/featureflag/jetfm"

// Init (production)
client, err := jetfm.NewClient(jetfm.WithBackgroundRefresh())

// Evaluate
enabled, ok := client.Flag("scope::feature-key").Bool(targetID, attrs)
if ok && enabled {
    // new path
} else {
    // existing behaviour
}

// Test (no network)
client, _ := jetfm.NewClient(jetfm.WithLocalFile("./testdata/flags.json"))
```

Minimal test fixture (`testdata/flags.json`):

```json
{
  "features": [
    {
      "key": "scope::feature-key",
      "valueType": "bool",
      "defaultValueRules": [{ "restrictions": {}, "value": true }]
    }
  ]
}
```

### .NET (HttpClient-based)

```csharp
// Inject IFeatureFlagClient via DI (see REWE backend for reference implementation)

// Evaluate
bool enabled = await featureFlagClient.IsEnabledAsync("feature-key", cancellationToken);
if (enabled)
{
    // new path
}
else
{
    // existing behaviour
}

// Test (use FakeFeatureFlagClient — see REWE backend for reference implementation)
var fake = new FakeFeatureFlagClient().WithFlag("feature-key", enabled: true);
```

## Testing

Language-agnostic principle:

- Use a local fixture or a fake/stub — never a mock, never hardcode `true`/`false` directly
- Test both the enabled path and the disabled path (flag OFF must preserve existing behaviour)
- No network calls in unit tests

## PR Checklist (required in every PR body that introduces a new feature flag)

```
- [ ] Flag verified to exist: curl -s ".../config/v1/{scope}/{env}" | jq '.features[] | select(.key == "{scope}::{key}")'
- [ ] Flag key: {scope}::{flag-key}
- [ ] Flag default: OFF
- [ ] Feature gated at entry point (not deep in utilities)
- [ ] Existing behaviour preserved when flag is off
- [ ] Client uses background refresh (production) or local fixture/fake (tests)
- [ ] Tests cover both enabled and disabled paths
- [ ] Enable path: Sonic dashboard
```

## Anti-Patterns

| Anti-pattern | Why it is wrong |
|---|---|
| Shipping feature code without a flag | No kill switch |
| Defaulting flag to true | Feature is live before intentionally enabled |
| Multiple flag checks for one feature | Inconsistent states; gate at entry point only |
| Hardcoding flag value in tests | Masks real evaluation; use fixture/fake |
| Checking the flag inside utility or repository | Ownership belongs to feature layer |
| Using LaunchDarkly for new flags | Deprecated — use JetFM |
| Gating code without verifying flag exists first | Flag may be missing; always run Step 0 |
| Omitting background refresh in long-running services | Config becomes stale after initial load |

## Out of Scope

JetFM flag creation UI and Sonic dashboard configuration — tracked separately.
