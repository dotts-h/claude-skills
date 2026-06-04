# CODEBASE_MAP.md template

```markdown
# Codebase map

> One-screen orientation. Depth lives in ARCHITECTURE.md; exact signatures in CONTRACTS.md.

## Modules
| Package | Responsibility (one line) | Depends on | Pure? |
|---------|---------------------------|-----------|-------|
| cmd/... | entrypoint: wire + serve   | all       | edge  |
| ...     | ...                        | ...       | core  |

## Entry points
- `cmd/<app>/main.go` — flags, what it builds, how it starts.
- Tests: `make test`; app: `<run command>`.

## Primary data flow
`A → B → C → D` — one arrow chain, the spine of the system. Add a sentence per hop
only where the hop is non-obvious.

## Seams (where to mock / swap)
- `<Interface>` — between <layer> and <layer>; mocked by <Mock> in tests.

## Where things live (FAQ)
- "Pricing/cost?" → `internal/telemetry`
- "Where is X validated?" → ...
```

## Filling rules
- **Responsibility column is one line.** If you need two, the package may do too much.
- **"Pure?"** = does it import only the stdlib + its own domain (core), or does it
  touch the network/SDK/HTTP (edge)? This column makes dependency direction visible
  at a glance.
- The **FAQ** is the highest-value section for day-to-day use — seed it with the
  questions you actually had while reading the code.
