# Playwright agent workflow: plan → generate → heal

Three stages, each independently runnable. All build on the browser's accessibility tree
(semantic, structured) rather than screenshots/pixels — which is why the resulting tests are
stable. The bundled `playwright-cli` skill exposes the driving commands.

## 1. Plan (explore → spec)
Run the **seed test** first (it lands the app in the state every scenario starts from:
navigation, any login, flags). Then explore the feature and write a human-readable spec to
`specs/<feature>.plan.md` — application overview, scenarios, steps, expected results. Always
write the spec to a file; it's the contract the generator consumes.

## 2. Generate (spec → test)
Turn the spec into Playwright test files under `e2e/tests/`. Verify selectors and assertions
*live* as you go (drive the page, confirm the element exists, then write the locator). Keep a
roughly one-to-one mapping between spec scenarios and tests. Generated tests may have initial
errors — that's expected; the healer fixes them.

## 3. Heal (fix failures)
Run the test; if it fails, replay the failing steps, inspect the current UI for the equivalent
element/flow, and patch (locator update, wait adjustment, data fix). Re-run until green — or,
if the functionality is genuinely broken, mark it and file a bug via `tracking-issues` rather
than forcing a green.

## Setup
`npx playwright init-agents --loop=claude` writes the agent definitions (regenerate after a
Playwright upgrade to pick up new tools). The seed test lives at `e2e/tests/seed.spec.ts`.

## Why this beats hand-writing
Planning separates "what to test" (human-readable, reviewable) from "how" (selectors,
waits), and the heal loop absorbs the normal churn of a live UI — so the suite keeps passing
through refactors instead of needing a rewrite.
