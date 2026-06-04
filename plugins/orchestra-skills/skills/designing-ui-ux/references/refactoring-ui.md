# UI craft: the Refactoring-UI lens

Most "looks amateur" comes from a handful of fixable things. Work through these; they compound.

## Visual hierarchy
- Establish importance with **size, weight, and color** — not just size. De-emphasize secondary text
  with a lighter weight or muted color rather than shrinking everything.
- Give the primary action on each screen clear visual dominance; everything else recedes.
- Labels are supporting actors — often a smaller, muted label above a prominent value reads best.

## Spacing & layout
- Use a **spacing scale** (e.g. 4/8/12/16/24/32), not arbitrary pixels. Consistent rhythm is the single
  biggest "designed" signal.
- Give elements room; cramped UIs read as low-quality. White space is not wasted space.
- Align to a grid; establish a max content width so lines don't sprawl.

## Typography
- Pick a **type scale** (don't freestyle sizes). Limit to 2–3 weights.
- Generous line-height for body (~1.5); tighter for headings. Cap line length (~60–75 chars).
- A **distinctive** typeface sets tone — avoid defaulting to the same system stack everything uses if
  you want a brand voice. Keep it legible; distinctive ≠ illegible.

## Color
- Define a palette with **multiple shades** per hue (not one), so you can build hierarchy and states.
- Use a saturated accent sparingly for the primary action; greys carry most of the UI.
- Ensure every text/background pair meets contrast (ties into WCAG).

## Depth & motion
- Subtle shadows for elevation; match light direction; don't over-shadow flat content.
- Motion should be quick, purposeful, and respect `prefers-reduced-motion`. Animate to explain a
  change (a card entering, a status updating), not to decorate.

## The point
None of these need a framework — they're tokens and CSS. Consistency across them (one spacing scale,
one type scale, one palette with shades) is what reads as "great" rather than "fine".
