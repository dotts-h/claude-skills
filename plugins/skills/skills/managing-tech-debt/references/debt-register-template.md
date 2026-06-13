# TECH_DEBT.md template

```markdown
# Tech-debt register

> Tracked, prioritized shortcuts and gaps. Severity = impact if it bites. Effort = cost to fix.
> Interest = ongoing cost of leaving it. Rank by interest × likelihood.

| # | Item | Location | Sev | Effort | Interest | Links | Trigger to pay down |
|---|------|----------|-----|--------|----------|-------|---------------------|
| 1 | Statusline token/credit totals are meter-global, not per-session | internal/web statusline | low | M | low | — | when multi-session matters |
| 2 | Docs say "single in-memory session"; Hub is multi-session | docs/ARCHITECTURE.md, README | low | S | med | ADR-000N | next docs pass |
| 3 | Markdown not rendered (richtext = escape+<br> only) | render.go | med | M | med | issue #NN | when chat readability is prioritized |
```

## Field rules
- **Sev / Effort / Interest:** keep a coarse scale (low/med/high or S/M/L) — false precision wastes
  time. The relative ranking is what matters.
- **Trigger:** the condition that should make you pay it down ("when X is prioritized", "before Y
  ships"). Debt with no trigger tends to live forever.
- **Links:** ADR (why the shortcut), issue (when scheduled), PR (when paid). An item with none is a
  floating note — attach it to something.

## Lifecycle
`open` → (scheduled: link an issue) → `paid` (strike through or move to a "Paid" section with the PR).
Don't delete paid items immediately; the history of what debt you carried and cleared is useful.
