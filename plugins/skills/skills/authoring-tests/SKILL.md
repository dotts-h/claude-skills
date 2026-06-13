---
name: authoring-tests
description: Writes and enhances the higher test layers — end-to-end (Playwright), API/contract, performance/benchmark, and accessibility tests. Use this whenever a feature needs browser, integration, api, perf, or a11y coverage, when the user asks to add or extend e2e/api/perf tests, or after exploratory QA surfaces a behavior worth locking in. For unit/seam tests written test-first, use practicing-tdd instead.
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# Authoring tests (e2e · api · perf · a11y)

These are the layers that prove the system works the way a user (or a caller) actually
hits it — through a real browser, over HTTP, under load, with assistive tech. They catch
what unit tests can't: htmx swaps, the live SSE transport, focus/keyboard behavior, wire
contracts, and latency.

## Pick the layer
| Layer | Proves | Lives in |
|-------|--------|----------|
| e2e | real browser flows, htmx swaps, SSE | `e2e/tests/*.spec.ts` |
| api/contract | content-types, escaping/XSS, cookies, isolation, malformed-payload tolerance | `internal/web/api_test.go` |
| perf | render/reducer hot paths; page latency | `internal/web/bench_test.go` + Playwright perf |
| a11y | WCAG 2.1/2.2 A/AA via axe-core | `e2e/tests/a11y.spec.ts` |
See [references/test-layers.md](references/test-layers.md) for what belongs where.

## Browser tests: plan → generate → heal
Don't hand-write brittle selectors. Follow the Playwright agent workflow (the bundled
`playwright-cli` skill provides the tooling): **explore → write a spec → generate the test →
heal until green**. See [references/playwright-agents.md](references/playwright-agents.md).
```bash
scripts/init-agents.sh            # one-time: npx playwright init-agents --loop=claude
scripts/run-layer.sh e2e          # build demo + run a layer (e2e|api|a11y|ux|perf)
```

## Locator discipline (so tests don't rot)
Prefer role and test-id locators and web-first assertions (`expect(locator).toBeVisible()`)
over CSS/text and over `waitForTimeout`. Hard waits are the main reason e2e suites flake;
the framework's standards live in `governing-qa-framework`.

## The demo gotcha (this repo)
The browser suite runs against one shared in-memory demo session (`workers: 1`). Per-session
counters accumulate across the whole run, so assert **relatively** (read → act → assert it
increased), never a fixed value, and seed anything a test drives (forge rows, models) in
`-demo` mode — don't assume it's on disk. See [references/demo-gotchas.md](references/demo-gotchas.md).

## Boundaries
This skill *writes* the higher layers. `practicing-tdd` owns unit/seam; `hardening-tests`
strengthens any suite; `governing-qa-framework` owns the harness config/standards, not the
individual tests. When exploratory QA finds a bug, this is where the keeper regression lands.
