# Coupling & drift smells

Structural problems show up as patterns, not single lines. These are the ones worth hunting.

## Coupling smells
- **Shotgun change:** one logical change forces edits across many packages. The concept is spread
  too thin — consider consolidating it behind one type/boundary.
- **Leaky boundary:** a package exposes its internal types across a seam (callers depend on a struct
  they shouldn't see). Narrow the interface to what the consumer needs.
- **God struct:** one type accumulates unrelated responsibilities (state + rendering + I/O). Split by
  responsibility; this repo deliberately kept the web `Server` = "the old Model minus rendering".
- **Cyclic-ish dependencies:** package A needs B needs A (often hidden via a shared third). Invert
  with an interface at the consumer.
- **Feature envy:** code in package A spends its time reaching into B's data. The behavior probably
  belongs in B.

## Drift smells (docs vs code)
- Docs describe an older shape (e.g. "single in-memory session" vs the multi-session `Hub`).
- A contract in `CONTRACTS.md` no longer matches the signature.
- A design goal in `ARCHITECTURE.md` that the code quietly stopped honoring.

## What to do
Each smell becomes either a doc fix (cheap, do it) or an ADR-sized proposal (record the trade-off).
Don't refactor a boundary in the same breath you find it — propose first, so the change is a decision,
not a reflex.
