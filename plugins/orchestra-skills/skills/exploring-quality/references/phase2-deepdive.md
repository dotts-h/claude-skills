# Phase 2 — browser deep-dive

Goal: take the leads from phase 1 (and your own instinct) into the real browser and find the
bugs a status sweep can't see — broken interactions, confusing states, races, visual breakage,
accessibility failures.

## Drive the browser
Use the bundled `playwright-cli` / Playwright MCP. Work from **accessibility-tree snapshots**
(`playwright-cli snapshot`) rather than screenshots for interaction — it's semantic and stable.
Take real **screenshots** only as *evidence* for a finding.

```bash
playwright-cli open http://127.0.0.1:8765
playwright-cli snapshot                 # see the tree + refs
playwright-cli fill e5 "hello" --submit # drive a flow
playwright-cli snapshot                 # observe the result
playwright-cli screenshot --filename=docs/qa/assets/finding-3.png
```

## What to exercise (this app)
The interactive surfaces are where the interesting bugs live: streaming + type-ahead queueing,
the permission approve/reject inline form, plan-mode review, ask_user/elicitation dialogs,
slash-command autocomplete, model/effort switching, abort mid-turn. Try them in unusual orders
(abort while queued; switch model mid-stream; submit an empty elicitation).

## Accessibility as you go
Run axe-core on each meaningful state (not just the landing page) — modals/inline forms are
where a11y regressions hide. Hand fixes to `designing-ui-ux`.

## Curiosity is the method
The script can't tell you "this state is confusing" or "I expected the button to do X". When
something feels off, follow it — that hunch is exactly what exploratory testing exists to capture.
Every confirmed oddity becomes a finding with a screenshot.
