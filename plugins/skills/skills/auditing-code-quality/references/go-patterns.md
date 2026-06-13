# Go patterns worth keeping

General Go idioms this project leans on. Most are enforced by `golangci-lint`/`go vet`; the
ones below are the judgment calls a linter can't make.

## Errors
- Wrap with context at boundaries: `fmt.Errorf("dial client: %w", err)`. The `%w` keeps the
  chain inspectable.
- Return errors; don't log-and-continue in library code. The caller decides.
- Handle the error where you have the context to do something useful, not where it's convenient.

## Interfaces
- Define interfaces at the **consumer**, keep them small (the `copilot.Client` seam is the model:
  five methods, exactly what the UI needs).
- Accept interfaces, return concrete types.

## Concurrency
- Guard shared state with a mutex *or* confine it to one goroutine; don't mix.
- Channels for handoff/signaling, not as a general data structure.
- Anything concurrent gets a `-race` test (mirror the 16×100 meter test).

## Construction & purity
- Constructors validate and return `(T, error)` when construction can fail.
- Keep domain packages dependency-free; push I/O to the edges.

## Tables over branches
- Table-driven tests and table-driven logic (a `map[string]rate`) beat long switch ladders for
  anything that grows by data rather than behavior.

## Naming
- Short names for short scopes, descriptive for package-level. Exported = Capitalized and
  documented with a `// Name ...` comment. Consistent verbs (`Add`/`Remove`/`Toggle`).
