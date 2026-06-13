# Exploratory findings report

Write to `docs/qa/exploratory-<YYYY-MM-DD>.md`. Rank by severity so the reader knows what to
fix first. Each finding must be reproducible and carry evidence — a finding no one can reproduce
gets ignored.

```markdown
# Exploratory QA — <date>

Scope: <what you swept> · Build: <commit> · Phases run: 1 + 2

## Summary
<2-3 sentences: overall health, the headline issues>

## Findings
### F1 — <short title>  ·  severity: high|med|low
- **Where:** route/screen/flow
- **Repro:** exact steps (or the probe command)
- **Expected vs actual:** …
- **Evidence:** docs/qa/assets/F1.png / log snippet
- **Home:** issue #NN (tracking-issues) · regression test (authoring-tests) if it must not return

### F2 — …
```

## After writing
- File each finding via `tracking-issues` (group related ones under an epic).
- For anything that must never regress, hand the repro to `authoring-tests` to become a
  permanent e2e/api test.
- Record any surprising root cause as a gotcha via `logging-learnings`.
