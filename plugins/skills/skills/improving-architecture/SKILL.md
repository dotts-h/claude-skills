---
name: improving-architecture
description: Assesses architecture for module boundaries, coupling, dependency direction, and drift from stated design goals, then proposes structural improvements as ADRs. Use this whenever the user wants to evaluate or refactor architecture, resolve cross-cutting coupling, fix a layering violation, or plan a structural change — anything bigger than line-level cleanup. Record the decision; don't restructure silently.
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# Improving architecture

Architecture is the set of decisions that are expensive to reverse: who depends on whom, where
the boundaries are, what stays pure. This skill evaluates those decisions against how the code
*actually* looks today, finds the drift, and proposes structural changes — always as an ADR,
because a structural change without a recorded rationale is how the next person undoes it by accident.

## How to assess
1. Read the map and contracts first: `docs/CODEBASE_MAP.md`, `docs/CONTRACTS.md`, and the design
   goals in `docs/ARCHITECTURE.md`. You're checking reality against intent.
2. Check **dependency direction** deterministically:
   ```bash
   scripts/deps-check.sh        # forbidden imports + a per-package import summary
   ```
   The rule here: UI never imports the SDK; domain packages stay dependency-free.
   See [references/dependency-rules.md](references/dependency-rules.md).
3. Look for **coupling smells** — a change that forces edits in three packages, a "god" struct,
   a boundary that leaks types. See [references/coupling-smells.md](references/coupling-smells.md).
4. Detect **drift**: places where the docs claim one thing and the code does another (e.g. the
   docs still say "single in-memory session" while `Hub` is cookie-keyed multi-session). Drift is
   either a doc bug (fix the doc) or an architecture bug (propose the fix).

## Propose as an ADR
Size each improvement as a decision: context (the coupling/drift), options (including "leave it"),
the choice, and consequences. Use `recording-decisions` to write it. Then, if it's real work to
be scheduled, hand it to `managing-tech-debt`; if it's a quick correct-the-boundary, do it test-first
via `practicing-tdd`. See [references/refactor-as-adr.md](references/refactor-as-adr.md).

## Boundaries
This skill is **structural**: boundaries, coupling, dependency direction, drift. Line/function
patterns are `auditing-code-quality`; the prioritized ledger of what to fix is `managing-tech-debt`;
the recorded decision is `recording-decisions`. Architecture proposes → ADR records → debt schedules.

## Why record even small structural changes
A boundary moved "just because it seemed cleaner" with no ADR looks like an accident to the next
reader, who may move it back. The ADR is what makes a structural decision *stick*.
