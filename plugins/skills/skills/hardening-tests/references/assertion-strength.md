# Assertion strength, edge, property & fuzz

## Make assertions sharp
A strong assertion fails when the behavior is wrong and *only* then. Smells:
- Asserting `err == nil` but never checking the value produced.
- Asserting a substring when the exact output matters (or vice-versa).
- Golden tests with no one reading the golden — assert the property, not just "unchanged".

Ask of each test: "what single-character bug in the code would this catch?" If the answer
is "none", the assertion is decoration.

## Edge cases worth a row
Unknown/empty/zero inputs, boundary values, malformed payloads, upgrade-time backfill
(old config missing a new field), concurrency. This repo already tests several — extend
the table-driven sets rather than adding new test functions.

## Property tests
When a function has an invariant ("cost is never negative or NaN for non-negative tokens"),
assert the *property* over generated inputs, not a handful of examples. That's a stronger,
more honest guard than three hand-picked cases.

## Fuzz (Go native)
`func FuzzX(f *testing.F)` with seed corpus + `f.Fuzz(func(t, in){...})`. The pricing fuzz
target is the model: it asserts totality over arbitrary token inputs. Good fuzz targets are
parsers, normalizers, and math with invariants. Run in CI as a short smoke (`-fuzztime 20s`)
and longer locally when touching the logic.
