---
name: logging-learnings
description: Maintains a running learnings + dead-ends log (docs/REGRESSIONS.md or LEARNINGS.md) — fixed bugs with their guarding test, approaches that were tried and failed (and what to do instead), and non-obvious gotchas. Use this whenever a bug is fixed, an approach is abandoned, a surprising gotcha is discovered, or the user says "log this", "we already tried that", or "so we don't do this again" — even without those exact words.
allowed-tools: Read, Write, Edit, Grep, Glob
---

# Logging learnings & dead-ends

Teams re-break the same things and re-try the same dead-ends because the knowledge
lives in someone's memory, not the repo. This log is the cure: a durable record of
what broke (and the test that now guards it) and what we tried that didn't work (and
why), so the next person — or the next agent — doesn't pay the cost twice.

## When to use
- **After fixing a bug** — record it with its guarding test (this is the core rule).
- **After abandoning an approach** — record the dead-end and the "instead", while
  the reasoning is fresh. This is the half teams usually lose.
- When you hit a non-obvious gotcha (a test-harness quirk, a platform footgun).

## Workflow
0. **Scaffold if missing** — create the log with its canonical registers on first use:
   ```bash
   scripts/ensure-doc.sh        # idempotent; no-op if docs/REGRESSIONS.md exists
   ```
1. Pick the register (see [references/entry-templates.md](references/entry-templates.md)):
   **Fixed** (symptom · root cause · fix · guarding test) or
   **Dead-ends** (what we tried · why it failed · what to do instead) or
   **Gotchas**.
2. Write the entry. Keep the *root cause* sharper than the symptom — the symptom is
   what you saw, the root cause is what you learned.
3. **Enforce the guard rule:** a fix that lands without a test goes under
   "Known gaps" until one exists. A bug log whose only proof is "I checked manually"
   is a bug waiting to come back. Hand the missing guard to `practicing-tdd`/`hardening-tests`.
4. Cross-link: an entry that came from a decision links its ADR; a known gap that
   becomes scheduled work links its `tracking-issues` issue / `managing-tech-debt` item.

## Why dead-ends are worth writing
A recorded dead-end is the highest-leverage entry in the whole log: it stops a future
agent from spending hours rediscovering that, say, "putting the reducer client-side
duplicates state — don't." Always pair it with the *instead*, or it reads as a ban
with no exit.

## This repo
`docs/REGRESSIONS.md` already exists and is excellent — keep its rule ("every entry
names the test that guards it") and its "Testing notes" gotchas. Add a **Dead-ends**
register (the roadmap memory has several: client-side reducer, dual-frontend, CDN
htmx) and keep feeding "Known gaps" until each has a guard.
