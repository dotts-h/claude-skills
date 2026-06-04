# Antipatterns catalog

Each entry: the smell, why it costs, the fix. Ordered by how much it hurts this codebase.

## Seam leak (highest cost here)
**Smell:** importing the real SDK (`github.com/github/copilot-sdk/go`) anywhere but
`internal/copilot/SDKClient`. **Cost:** breaks the "UI testable without a network" guarantee —
the whole reason the seam exists. **Fix:** add the behavior to `SDKClient` as a normalized
`Event`, consume the `Event` in the UI.

## Punted error
**Smell:** `_ = doThing()`, swallowing an error, or returning it raw with no surfacing path.
**Cost:** failures vanish silently (this repo already had a dead `EvError` path — a real bug).
**Fix:** surface it — end the turn, show the user, or wrap with context. Solve, don't punt.

## Impure core
**Smell:** `telemetry`/`ctxforge`/`config` importing the network, the SDK, or the HTTP layer.
**Cost:** the domain stops being unit-testable in isolation. **Fix:** invert the dependency;
pass data in, return data out.

## Voodoo constants
**Smell:** `timeout := 47` with no reason. **Cost:** no one can safely change it. **Fix:** name
it and comment the reasoning, or derive it.

## Inconsistent terminology
**Smell:** the same concept called three things (`ctx`/`context`/`window`). **Cost:** readers
and greps miss things. **Fix:** pick one term; this repo already fixed "ctx"→"context".

## Nondeterminism where determinism is promised
**Smell:** ranging a map then asserting/serializing order; unsorted de-dup in `Compile`/pricing.
**Cost:** breaks reproducibility (a contract) and flakes tests. **Fix:** sort; add a test if you
touch ordering.

## Premature abstraction / too many options
**Smell:** a config knob or interface with one caller; "you could use A or B or C". **Cost:**
surface area with no payoff. **Fix:** inline it; provide one default with an escape hatch.
