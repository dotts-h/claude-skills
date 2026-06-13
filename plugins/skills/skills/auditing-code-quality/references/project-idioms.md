# Project idioms (my-orchestra)

The conventions specific to this repo. Treat a violation as a finding worth raising, but
explain the consequence — these exist for reasons documented in ARCHITECTURE.md / the ADRs.

## The seam is sacred
`internal/web` and the domain packages never import the SDK. New runtime behavior goes in
`SDKClient` as a normalized `Event`; new UI behavior is tested via `MockClient`. This is what
makes the reducer testable without a browser — the project's core design goal.

## Pure core, thin edges
`telemetry`, `ctxforge`, `config` are dependency-free and fully unit-tested with table-driven
edge cases. The SDK and HTTP/SSE transport stay at the boundary.

## Determinism is a contract
`Forge.Compile` (stable sort, ordered de-dup) and pricing are deterministic. If you touch
ordering or rates, add/extend a test — reproducibility is relied upon for snapshots.

## Atomic, validated persistence
Config/forge writes go through temp-file + rename and **validate before save**, rolling back
the in-memory state if validation fails. Never write a half-valid `forge.json`.

## Rendering
All model-produced text is escaped via `html/template`/`esc()` before render. The one custom
path (`richtext` = escape + `\n`→`<br>`) is deliberate; structural HTML is auto-escaped. A raw
write of model text is a finding (XSS surface).

## Workflow
Each increment: branch from `main`, test-first, `make lint && make test`, `--no-ff` merge,
push, delete the branch. A fixed bug names its guard test in `REGRESSIONS.md`.
