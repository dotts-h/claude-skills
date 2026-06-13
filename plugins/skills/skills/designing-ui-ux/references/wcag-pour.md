# Accessibility: WCAG 2.2 (POUR)

Accessibility is a correctness property, not a nicety — and axe-core makes most of it checkable. Aim
for WCAG 2.1/2.2 level AA (the project already enforces no A/AA axe violations).

## POUR
- **Perceivable** — text alternatives for non-text; sufficient **contrast** (AA: 4.5:1 normal text,
  3:1 large/UI components); don't rely on color alone (pair the off-toggle glyph with shape, not just hue).
- **Operable** — full **keyboard** access (every action reachable + a visible focus ring); logical focus
  order; no keyboard traps; targets large enough; respect `prefers-reduced-motion`.
- **Understandable** — labels on inputs (`<label for>`/`aria-label`); consistent navigation; inline,
  specific error messages.
- **Robust** — valid semantic HTML and correct ARIA roles so assistive tech can parse it. Prefer native
  elements (`<button>`, `<nav>`) over div-with-role.

## Where regressions hide in this app
Inline/streamed content: the permission form, plan card, ask/elicitation dialogs, the autocomplete
menu. Run axe on those *states*, not just the landing page — they're injected after load.

## Common fixes (seen in this repo's history)
- Contrast: an "off" glyph using `--subtle` failed AA → use `--dim`. Keep a contrast table in DESIGN.md.
- Focus: ensure interactive elements are focusable and show a ring (tabindex/native elements).
- Guard the `hx-on::after-request` event-target check so dynamic regions don't break keyboard input.

## Verify
`scripts/axe-scan.sh` against the running demo; then keep `e2e/tests/a11y.spec.ts` green. A contrast or
label fix should also get a test row so it can't silently regress.
