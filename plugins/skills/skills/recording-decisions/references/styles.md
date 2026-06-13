# ADR styles: MADR-lite vs Nygard

Both are one-decision-per-file markdown. Pick one per repo and stay consistent.

## Nygard (minimal)
Sections: **Title · Status · Context · Decision · Consequences**. Best when
decisions are simple and you want the lowest ceremony. No explicit options list.

## MADR (this skill's default)
Adds **Considered options** (with the rejected ones and why). Best when the
value is in the trade-off, not just the outcome — which is most architectural
decisions worth recording. Full MADR also has "Pros/Cons per option" and
"Confirmation"; we drop those for the lite variant to keep ADRs to a screenful.

## When to add a section back
- Add **Pros/Cons per option** when a decision is contested and you want the
  debate captured.
- Add **Confirmation** (how we'll verify the decision holds) when the decision
  has a measurable success criterion — link the guard test there.

## Don't
- Don't turn an ADR into a design doc. If it grows past ~1 screen, the design
  belongs in `docs/` and the ADR just records the choice and links to it.
- Don't record reversible, low-stakes choices (formatting, naming a variable).
  ADRs are for decisions that are expensive to revisit.
