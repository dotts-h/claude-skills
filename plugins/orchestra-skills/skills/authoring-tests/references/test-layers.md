# What belongs in each layer

Put each assertion at the cheapest layer that can prove it. A thing provable in a Go unit
test should not be an e2e test — e2e is slow and flakier, spend it only on what needs a browser.

## e2e (Playwright, browser)
Real htmx swaps, the live SSE stream, focus/keyboard, responsive layout, multi-step user
flows. If it needs a DOM and a real network round-trip, it's e2e. Split by concern
(this repo: `e2e.spec.ts`, plus `ux.spec.ts` for layout/interaction).

## api / contract (Go, `api_test.go`)
The HTTP wire contract without a browser: content-types, output escaping / XSS, cookie
hardening, per-session isolation, the SSE greeting, malformed-payload tolerance. Fast and
deterministic — prefer this over e2e whenever a browser isn't required.

## perf
Two flavors: Go **benchmarks** (`bench_test.go`) for render/reducer hot paths and a
**concurrent multi-session load** test under `-race`; and Playwright **perf** assertions for
page-level latency budgets. Keep budgets generous enough not to flake on CI hardware.

## a11y (Playwright + axe-core)
WCAG 2.1/2.2 A/AA: run axe on each page/state, assert no A/AA violations. Catches contrast,
labels, roles, focus order. Pair with `designing-ui-ux` when fixing what it finds.

## Rule of thumb
unit/seam (practicing-tdd) → api/contract → e2e → perf/a11y. Climb only when the lower layer
can't express the thing you need to prove.
