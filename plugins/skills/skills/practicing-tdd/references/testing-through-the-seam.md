# Testing through the seam (this repo)

The architecture exists to make behavior testable without a network or a browser. Lean
on it — tests that go through the seam are fast, deterministic, and survive refactors.

## The seam
`copilot.Client` is the boundary. Two implementations:
- `SDKClient` — the only code that imports the real SDK; normalizes SDK events → `Event`.
- `MockClient` — in-memory; records `Send`/`Abort`, lets a test push arbitrary `Event`s.

## Pattern: drive the UI reducer with synthetic events
```go
mock := copilot.NewMockClient()
srv := web.New(deps{Client: mock, ...})
mock.Emit(copilot.Event{Kind: copilot.EvMessageDelta, Text: "hi"})
// assert on the rendered fragment / convo.State — not on private fields
```
You're testing the *contract* (event in → fragment out), so the test doesn't care how
the reducer is implemented. That's why it survives refactors.

## What to assert on
- Normalized `Event`s (for `SDKClient` mapping tests: every SDK event → expected `Event`).
- `convo.State` / rendered HTML fragments (for reducer tests).
- Public method effects (`MockClient.SentCount()`, recorded modes), never internals.

## Determinism
`Forge.Compile` and pricing are deterministic by design — assert exact output and add a
test if you touch ordering or rates. Concurrency-sensitive code (the meter, the SSE hub)
gets a `-race` test with many goroutines; mirror the existing 16×100 meter test.
