# Mutation testing

The idea: introduce a small fault (a "mutant") into the code — flip `<` to `<=`, drop a
`!`, return zero — and re-run the tests. If they still pass, that mutant "survived",
meaning no test actually checks that behavior. Surviving mutants are your weak spots.

## Go
- **gremlins** (`github.com/go-gremlins/gremlins`): `gremlins run ./...`. Reports killed
  vs surviving mutants per file.
- **go-mutesting** (`github.com/avito-tech/go-mutesting`): alternative; `go-mutesting ./...`.

If neither is installed, don't punt — set it up or do a **manual mutation pass**: pick the
3–5 most important functions (here: `telemetry.Price`, `Forge.Compile`, the SDK→Event
mapping), hand-edit one fault each, run the package tests, and confirm a test fails. Revert.
A function whose mutant survives needs a sharper assertion.

## How to use the results
- A surviving mutant in critical logic → add/strengthen the assertion that should have
  caught it. Re-run; confirm the mutant now dies.
- Don't chase 100% mutation score — chase coverage of the logic that *matters* (pricing
  totality, determinism, event normalization correctness).
- Record any genuinely surprising survivor as a gotcha via `logging-learnings`.

## Where it pays off most in this repo
`internal/telemetry` (pricing math — already fuzzed, good mutant target) and
`internal/copilot` (every SDK event must map to the right normalized event — a mutant that
swaps two cases should be killed by the mapping tests).
