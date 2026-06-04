# MADR-lite template

Copy this into `docs/adr/NNNN-kebab-title.md` (the `new-adr.sh` script does it for you).

```markdown
# NNNN. <short decision title>

- Status: proposed | accepted | superseded by NNNN | supersedes MMMM
- Date: YYYY-MM-DD
- Deciders: <names/handles>
- Related: <ADRs, CONTRACTS entries, issues, PRs>

## Context

What forces are at play — technical, product, constraints? State the problem in
2–5 sentences. Link evidence. No solution yet.

## Considered options

- **Option A** — one line.
- **Option B** — one line.
- **Option C** — one line.

## Decision

We chose **Option X** because … (the deciding trade-off, stated plainly).

## Consequences

- Positive: …
- Negative / cost we accept: …
- Follow-ups: new conventions, tech-debt items, or tests this creates.
```

## Section rules
- **Context** is solution-free; **Decision** names exactly one option.
- **Considered options** must include the one you rejected and *why* — that is the
  value an ADR adds over a commit message.
- **Consequences** is where you link the convention (`docs/CONVENTIONS.md`),
  debt (`docs/TECH_DEBT.md`), or guard test this decision spawns.

## Status lifecycle
`proposed` → `accepted` → (later) `superseded by NNNN`. An accepted ADR's
Context/Decision text is never edited; only its Status line changes when superseded.
