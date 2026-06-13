---
name: practicing-tdd
description: Drives development test-first — write a failing test, make it pass with the smallest change, refactor, then run the project's gates. Use this whenever implementing a feature, fixing a bug, or changing behavior in a codebase that has (or should have) tests, especially when the user says "add", "implement", "fix", or "change" and expects working, tested code. Prefer this over writing code first.
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# Practicing TDD

Test-first isn't ceremony — it's the cheapest way to (a) pin down what "done" means
before you build, and (b) get a regression guard for free. Write the test that would
have caught the bug, *then* make it pass.

## The loop (copy this checklist into your reply and tick it off)
```
- [ ] Read docs/CONVENTIONS.md for the gate commands + test layout
- [ ] Write the smallest failing test that expresses the desired behavior
- [ ] Run it — confirm it fails for the right reason (red)
- [ ] Write the minimum code to pass (green)
- [ ] Refactor with the test green
- [ ] Run the full gates (lint + race + coverage)
- [ ] If this was a bug: hand the guard to logging-learnings
```

## Where to write the test
Test through the **seam**, not the implementation — tests coupled to internals break
on every refactor. In this repo that means driving behavior through the `copilot.Client`
interface with `MockClient` and asserting on normalized `Event`s / rendered fragments,
not on private fields. See [references/testing-through-the-seam.md](references/testing-through-the-seam.md).

Use **table-driven tests** for anything with edge cases (unknown models, empty forge,
malformed input) — it's the idiom here and it makes the gaps obvious.
See [references/red-green-refactor.md](references/red-green-refactor.md) for the rhythm.

## Run the gates
```bash
scripts/gate.sh        # detects + runs the project's test/lint gate (go / npm)
```
Don't call something "done" before the gates are green. In this repo the gate is
`make lint && make test` (gofmt + vet + golangci-lint, then `go test ./... -race -cover`
against the 65% floor). Go toolchain: `export PATH=$PATH:/home/ori913/go-install/go/bin`.

## Boundaries
This skill writes the **unit/seam tests that drive code**. The browser/api/perf layers
are `authoring-tests`; *attacking and strengthening* an existing suite is `hardening-tests`.
Keep TDD at the unit/seam level and those three never collide.

## Why "fails for the right reason" matters
A test that passes before you write the code, or fails because of a typo rather than the
missing behavior, guards nothing. Always watch it go red for the intended reason first.
