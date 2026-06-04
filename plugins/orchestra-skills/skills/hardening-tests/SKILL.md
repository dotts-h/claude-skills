---
name: hardening-tests
description: Audits and hardens an existing test suite (the SDET role) — finds coverage gaps, weak assertions, flaky and non-deterministic tests, and missing edge/property/fuzz cases, then strengthens them. Use this whenever the user asks to review, harden, validate, or improve test quality, hunt flakes, check coverage, or before trusting a suite to gate a release. Do not write product code here — only strengthen tests.
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# Hardening tests (SDET)

A passing suite isn't a good suite. Tests can pass while asserting nothing, miss whole
branches, or flake under load. This skill attacks the suite the way reality will, and
strengthens whatever gives. It never adds product code — its only output is stronger tests.

## What to check (in rough priority order)
1. **Coverage gaps** — which branches/packages are untested. Use the project's coverage
   tooling; treat the floor as a floor, not a target. Find the *untested edge*, not the %.
2. **Assertion strength** — would the test fail if the behavior were wrong? The sharpest
   tool here is **mutation testing**: deliberately break the code and see if a test catches
   it. Tests that pass against broken code are guarding nothing.
   See [references/mutation-testing.md](references/mutation-testing.md).
3. **Flakes & non-determinism** — run hot, under `-race`, many times. A test that fails 1
   in 20 will fail in CI at the worst moment. See [references/flake-hunting.md](references/flake-hunting.md).
4. **Missing edge / property / fuzz** — invariants deserve property/fuzz tests, not just
   examples (pricing totality is already fuzzed here; extend the pattern).
   See [references/assertion-strength.md](references/assertion-strength.md).
5. **Unguarded fixed bugs** — cross-check `docs/REGRESSIONS.md`: every fixed bug should
   name a guard. Missing ones are the highest-value tests to add.

## Scripts (deterministic, repetitive — run them)
```bash
scripts/flake-hunt.sh ./internal/web 20   # run a package N times under -race; report any failure
scripts/mutation-run.sh ./internal/telemetry  # run the mutation tester if installed; else explain setup
```

## Boundaries
`practicing-tdd` and `authoring-tests` *create* tests; this skill *attacks and strengthens*
them. If hardening reveals a real product bug (not just a weak test), file it via
`tracking-issues` and let TDD fix it — don't fix product code from here.

## Why mutation testing earns its keep
Coverage says a line *ran*; mutation testing says a line is *checked*. A suite can have
90% coverage and still let you delete a `!` without a single failure. Mutation testing is
how you find those silent passes — it's the closest thing to an objective test-quality score.
