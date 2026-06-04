---
name: recording-decisions
description: Creates and maintains Architecture Decision Records (MADR-lite — context, options, decision, consequences) under docs/adr/. Use when a non-trivial technical decision is made or reversed, or when asked to record, revisit, supersede, or list architectural decisions.
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# Recording decisions (ADRs)

Capture each significant decision as a numbered, immutable record so the *why* survives.

## When to use
- A non-trivial choice was made (a library, a boundary, a protocol, a hard cut).
- A past decision is being reversed → **supersede**, never edit history.
- Someone asks "why did we do X" / "record this decision" / "list the ADRs".

## Workflow
1. Read `docs/CONVENTIONS.md` (if present) for repo facts; check `docs/adr/` exists.
2. Allocate the next number and stamp the template:
   ```bash
   scripts/new-adr.sh "Use htmx over a SPA framework"
   ```
   This prints the path of a new `docs/adr/NNNN-kebab-title.md` seeded from `references/madr-template.md`.
3. Fill the sections. One decision per file. Keep it tight (a screenful).
4. Set `Status: proposed` until accepted; then `accepted`.
5. To reverse a decision: create a new ADR, set the old one's status to
   `superseded by NNNN` and the new one's to `supersedes MMMM`. Run
   `scripts/relink.sh MMMM NNNN` to write both links.
6. Update the index: `scripts/reindex.sh` regenerates `docs/adr/README.md`.
7. Cross-link: reference the ADR from `docs/CONTRACTS.md`, `docs/TECH_DEBT.md`,
   or the issue/learning it relates to.

## Rules
- **Immutable once accepted.** Correct via a superseding ADR, not an edit.
- **One decision per record.** Split if you're tempted to record two.
- Numbering is monotonic and zero-padded (`0001`). Never reuse a number.
- No time-bound phrasing ("for now"); state the decision and its consequences.

## Reference
- Template + section guidance: [references/madr-template.md](references/madr-template.md)
- MADR vs Nygard, and when to prefer each: [references/styles.md](references/styles.md)

## This repo
Backfill the decisions already argued in the docs/memory but never recorded:
htmx-over-SPA, the hard-cut TUI removal, the generic `bridge[T]`, cookie-keyed
multi-session, and Go-as-language. Migrate the decision content out of
`docs/WEB_UI_PLAN.md` into ADRs and leave the plan pointing at them.
