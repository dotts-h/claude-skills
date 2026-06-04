# Design tokens (the project's design memory)

Tokens are the named, reused values that make a UI consistent: colors, spacing, type sizes, radii,
shadows, motion. Persist them so choices don't drift between sessions — that persistence is what keeps
a long-lived UI coherent. Store them two ways: CSS custom properties (used by the app) + a short
`docs/DESIGN.md` (the human-readable rationale + contrast table).

## Token set (extend the existing palette, don't replace blindly)
```css
:root {
  /* color — keep the brand, add shades for hierarchy & states */
  --accent: #d98c5f;          /* terracotta — primary action, used sparingly */
  --accent-strong: #c2724a;
  --blue: #6ea8fe;            /* copilot blue — info/links */
  --bg: #0e1116; --surface: #171b22; --surface-2: #1f242d;
  --text: #e6e9ef; --muted: #aab2c0; --dim: #7c8696;  /* --dim passes AA on --bg */

  /* spacing scale */
  --s1:4px; --s2:8px; --s3:12px; --s4:16px; --s6:24px; --s8:32px;

  /* type scale */
  --t-sm:.8125rem; --t-base:.9375rem; --t-lg:1.125rem; --t-xl:1.5rem;
  --lh-body:1.5; --lh-tight:1.25;

  /* radii, shadow, motion */
  --r1:6px; --r2:10px;
  --shadow-1:0 1px 2px rgba(0,0,0,.3); --shadow-2:0 6px 20px rgba(0,0,0,.35);
  --ease:cubic-bezier(.2,.7,.2,1); --dur:140ms;
}
@media (prefers-reduced-motion: reduce){ :root{ --dur:0ms; } }
```

## Rules
- **Use tokens, never one-off values.** A stray `#888` or `margin: 7px` is the drift you're preventing.
- **Every text/bg pair has a known contrast ratio** — keep the table in `docs/DESIGN.md` so a11y is
  designed in, not discovered later. (`--dim` on `--bg` must clear AA; that's why the off-glyph fix used it.)
- **Add shades, don't multiply hues.** Hierarchy comes from shades of few hues, not many colors.

## docs/DESIGN.md outline
Palette + shades · contrast table · spacing/type scales · component notes (cards, buttons, forms,
statusline) · motion rules · "voice" (the one or two things that make this UI distinctive).
