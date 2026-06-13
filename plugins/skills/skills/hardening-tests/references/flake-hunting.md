# Flake hunting

A flake is a test that passes or fails depending on timing, ordering, or shared state.
Flakes erode trust in the whole suite, so hunt them deliberately rather than waiting for
CI to surface them at random.

## How to surface them
- **Repeat under race:** `go test -race -count=20 ./pkg` — re-runs N times; any single
  failure is a flake (or a real race). `scripts/flake-hunt.sh` wraps this.
- **Shuffle order:** `go test -shuffle=on ./pkg` — catches tests that depend on execution
  order or leaked global state.
- **Parallel pressure:** ensure concurrency tests actually run parallel writers (mirror the
  16×100 meter test); a race that needs load won't show at `-count=1`.

## Common root causes & fixes
- **`time.Sleep` / fixed waits** → replace with polling on a condition (`waitFor(...)`) or,
  in browser tests, web-first assertions. Sleeps are the #1 source of flake.
- **Shared mutable state across tests** → isolate per-test; reset or construct fresh.
- **Goroutine drains asserted too early** → poll a thread-safe accessor (this repo's queue
  tests already do this: `SentCount()`/`waitFor`).
- **Ordering assumptions on maps/sets** → sort before asserting; determinism is a contract here.

## After fixing
Re-run the hunt to confirm the fix holds, and record the cause + fix in `logging-learnings`
(the "Gotchas" register) so the same flake pattern isn't reintroduced elsewhere.
