---
name: designing-ui-ux
description: Audits and improves both UX (Nielsen/Krug heuristics, information architecture, user flows, WCAG accessibility) and UI (visual hierarchy, design tokens, typography, spacing, color, motion — Refactoring-UI principles), then implements the changes in the app's HTML/CSS and verifies them in a real browser. Use this whenever the user wants the interface to look or feel better, more modern, more usable, or more accessible — "make the UI nicer", "the UX feels off", "improve the design", "fix accessibility" — even if they don't name a specific screen.
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# Designing UI & UX

A frontend is the product, for most users. This skill makes one *good → great* across both
disciplines: **UX** (can people understand and complete what they came to do?) and **UI** (does it
look considered, consistent, and modern?). It doesn't stop at a report — it implements the change
and verifies it in a browser, because design that isn't shipped is just an opinion.

## The loop: Audit → Design → Implement → Verify
Work in that order; each stage feeds the next. Copy this checklist:
```
- [ ] Audit UX (heuristics + flows) and UI (hierarchy + a11y) — severity-scored findings
- [ ] Design: consolidate/extend the design tokens; decide the changes
- [ ] Implement in app.css + templates (keep it htmx, no framework)
- [ ] Verify in the browser: axe-core + responsive widths + before/after screenshots
- [ ] File anything deferred via tracking-issues; lock a11y wins with authoring-tests
```

### 1. Audit
- **UX:** apply Nielsen's 10 heuristics + Krug's "don't make me think", score each issue by severity.
  Look at real flows (send a message, approve a permission, switch model), not just static screens.
  See [references/ux-heuristics.md](references/ux-heuristics.md).
- **Accessibility:** WCAG 2.2 POUR — run axe-core on each meaningful state (modals/inline forms hide
  regressions), check contrast, labels, focus order, keyboard paths.
  See [references/wcag-pour.md](references/wcag-pour.md).
- **UI:** visual hierarchy, spacing rhythm, type scale, color use, depth/shadow, motion — the
  Refactoring-UI lens. See [references/refactoring-ui.md](references/refactoring-ui.md).

### 2. Design with tokens (so it doesn't drift)
Consolidate decisions into a **design-token set** (color, spacing scale, type scale, radii, shadows,
motion) persisted as CSS custom properties + a short `docs/DESIGN.md` — the project's design memory.
Reuse tokens instead of inventing one-off values; that consistency *is* the polish.
See [references/design-tokens.md](references/design-tokens.md).

### 3. Implement
Edit `internal/web/static/app.css` and `internal/web/templates/` (and `index.html`). Keep the
architecture: server-rendered htmx + SSE, no framework rewrite. For a genuinely rich widget (markdown,
a statusline), a small vanilla-JS island/web component is fine — a framework is not.
See [references/htmx-implementation.md](references/htmx-implementation.md).

### 4. Verify
```bash
scripts/axe-scan.sh http://127.0.0.1:8765        # a11y on each page/state
scripts/screenshot-states.sh                     # before/after across pages + widths
```
A change isn't done until axe is clean (no new A/AA violations), the existing a11y test stays green,
and the before/after screenshots show the intended improvement.

## Boundaries
This skill *designs and implements*. `exploring-quality` *finds* problems (and shares the browser
driver); `authoring-tests` *locks in* a11y/visual fixes as tests. Persisted tokens live in
`docs/DESIGN.md`, not `CONVENTIONS.md` (which is process, not aesthetics).

## This repo — starting point
Palette: terracotta accent `#d98c5f`, copilot blue `#6ea8fe`, slate chrome. Stylesheet:
`internal/web/static/app.css`. a11y baseline already enforced in `e2e/tests/a11y.spec.ts` (axe, no
A/AA violations) — don't regress it. Known UI gaps to target: markdown rendering, statusline density,
responsive topbar, and overall "good but not great" polish. A modern, restrained, *distinctive* look
beats a generic one — avoid defaulting to the same system fonts and flat gray cards everything uses.
