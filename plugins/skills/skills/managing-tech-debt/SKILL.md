---
name: managing-tech-debt
description: Maintains a prioritized tech-debt register (docs/TECH_DEBT.md) — catalogs shortcuts, gaps, and deferred work with severity, effort, and interest, ranks them, and links each to its ADR or issue. Use this whenever the user wants to record, review, prioritize, or plan paydown of technical debt, or when a shortcut is knowingly taken and should be tracked rather than forgotten.
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# Managing tech debt

Debt isn't bad — *untracked* debt is. A shortcut taken consciously, recorded with its cost, and
scheduled for paydown is a sound engineering trade. This skill keeps the ledger so debt is a
decision you revisit, not a surprise you trip over.

## The register
`docs/TECH_DEBT.md` — one row per item, using [references/debt-register-template.md](references/debt-register-template.md):
description · location · **severity** (impact if it bites) · **effort** (cost to fix) ·
**interest** (ongoing cost of leaving it) · linked ADR/issue · paydown trigger.

## Workflow
0. **Scaffold if missing** — create the register with its header on first use:
   ```bash
   scripts/ensure-doc.sh        # idempotent; no-op if docs/TECH_DEBT.md exists
   ```
1. **Gather candidates** from the places debt hides:
   ```bash
   scripts/debt-scan.sh        # TODO/FIXME/HACK + skipped tests + known-gap markers
   ```
   Also pull from `logging-learnings` "Known gaps", `improving-architecture` findings, and the
   roadmap's deferred items.
2. **Record** each with honest estimates. Vague debt ("clean up the web package") is unactionable —
   make it specific enough to schedule.
3. **Prioritize** by interest × likelihood-of-biting, not by what's annoying. See
   [references/prioritization.md](references/prioritization.md). High-interest, low-effort items are
   the obvious wins; high-effort, low-interest items may be fine to carry indefinitely.
4. **Link, don't orphan:** an item that came from a decision links its ADR; an item that's scheduled
   links its `tracking-issues` issue. When paid down, mark it done with the PR that did it.

## Boundaries
Debt = **open, prioritized obligations**. `logging-learnings` is closed history (what already
happened). `tracking-issues` is the actionable unit of work (a debt item spawns an issue when
scheduled). `improving-architecture` *finds* structural debt; this skill *ranks and tracks* it.

## Why interest is the key column
Severity tells you how bad it is *if* it bites; interest tells you what you pay *while it sits*.
A medium-severity item with high interest (slows every change) often beats a high-severity item that
rarely triggers. Ranking by interest is what turns a debt list into a paydown plan.

## This repo — seed items
The roadmap memory has ready candidates: markdown rendering (deferred), editable Settings, session
pick/continue, statusline totals being meter-global not per-session, and the multi-session doc drift.
