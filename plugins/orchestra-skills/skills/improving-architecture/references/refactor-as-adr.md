# Sizing a refactor as an ADR

A structural improvement is a decision with consequences, so record it like one. This keeps the
"why" attached to the change and gives the team a place to disagree *before* the work.

## The shape
- **Context:** the coupling/drift you found, with evidence (the `deps-check` hit, the doc-vs-code gap).
- **Considered options:** always include "leave it as-is" and state its cost — sometimes the honest
  answer is "the debt is cheaper than the fix right now".
- **Decision:** the structural change, scoped.
- **Consequences:** what improves, what it costs, what tests/contracts/conventions it touches.

## Then route it
- Write the ADR with `recording-decisions`.
- If it's real, schedulable work → add a `managing-tech-debt` item linking the ADR, with effort/interest.
- If it's a small, safe boundary correction → do it now, test-first (`practicing-tdd`), and update
  `CODEBASE_MAP.md`/`CONTRACTS.md`.

## Keep refactors reversible and small
Prefer a sequence of small, behavior-preserving steps (each green) over one big-bang restructure.
The seam-based design here makes that easy: change one side behind the interface, keep the tests green.
