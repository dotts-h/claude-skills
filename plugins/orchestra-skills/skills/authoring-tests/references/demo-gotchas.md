# Demo-mode gotchas (this repo's browser suite)

The Playwright suite runs against the offline demo server (`./my-orchestra -demo`), and the
demo is **one shared in-memory session** with `workers: 1`, `fullyParallel: false`. That has
two consequences every browser test must respect.

## 1. Counters accumulate — assert relatively
Per-session counters (messages sent, tools used) add up across the *whole* suite, not per
test. So never assert a fixed value:
```ts
// WRONG: expect(count).toBe(1)
const before = await readCount();
await sendMessage();
await expect.poll(readCount).toBeGreaterThan(before);  // RIGHT
```

## 2. The demo must be self-contained — seed what you drive
Anything a test interacts with (forge skills/agents rows, models, reasoning effort) has to be
seeded in `-demo` mode, in memory — never assumed to exist on disk. A local `forge.json` can
mask this locally and then fail in CI (it did once — see REGRESSIONS #7). If a test needs a
row, make `seedForge()`/the demo driver create it.

## Why it's set up this way
A single deterministic session keeps the SSE transport and htmx swaps reproducible for the
browser layer. The trade-off is the shared-state rule above — cheap to honor once you know it.
