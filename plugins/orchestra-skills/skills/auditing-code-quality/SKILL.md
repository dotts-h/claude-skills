---
name: auditing-code-quality
description: Reviews code against a patterns/antipatterns catalog — Go idioms plus this project's pure-core/thin-edges and seam discipline, error handling, naming, and simplicity — and proposes focused cleanups. Use this whenever the user asks to review code quality, enforce coding standards, spot antipatterns, or clean up a diff for clarity. It complements the built-in /code-review (bug-finding) and /simplify (mechanical cleanup) rather than duplicating them.
allowed-tools: Read, Edit, Bash, Grep, Glob
---

# Auditing code quality

This skill is the project's *standards reference plus an opinionated style pass*. It's not a
bug hunter and not a mechanical simplifier — those are the built-in `/code-review` and
`/simplify`. It answers a different question: "does this code follow the patterns that keep
this codebase clean, and where does it drift into the antipatterns we avoid?"

## How to run a pass
1. Scope to a diff or a package (don't audit the whole tree unprompted).
2. Scan for known smells deterministically first:
   ```bash
   scripts/smells.sh ./internal/web   # seam leaks, punted errors, naming drift
   ```
3. Read it against the catalogs:
   [references/antipatterns-catalog.md](references/antipatterns-catalog.md),
   [references/go-patterns.md](references/go-patterns.md),
   [references/project-idioms.md](references/project-idioms.md).
4. Propose **minimal, specific** diffs with the *why* — "this leaks the SDK past the seam,
   which breaks the testability guarantee" beats "use a cleaner pattern".

## The catalog, in one breath
The non-negotiables here: the SDK is imported **only** by `SDKClient` (the seam is the whole
design); `telemetry`/`ctxforge`/`config` stay dependency-free; errors are **surfaced, not
punted**; output is deterministic where promised; names are consistent. Everything else is
judgment — explain the trade-off, don't mandate.

## Boundaries (so you don't step on the built-ins)
- **Bugs / correctness** → `/code-review`. If you spot a real bug, name it and defer the deep
  hunt there.
- **Mechanical reuse/simplify** → `/simplify`. Don't re-do its job.
- **Structure / module boundaries** → `improving-architecture` (this skill is line/function level).
- **Test quality** → `hardening-tests`.

## Why "explain the why" is the rule here
Heavy-handed "always/never" review comments age badly and get ignored. A reviewer (human or
agent) follows a standard when they understand the cost of breaking it. Lead with the
consequence; the rule follows naturally.
