---
name: exploring-quality
description: Runs exploratory QA in two phases — phase 1 generates and runs many breadth probing scripts derived from the codebase (route/HTTP sweeps, smoke flows, malformed-input fuzzing) headless; phase 2 deep-dives the live app in a real browser via Playwright (MCP/CLI), following curiosity. Produces a ranked findings report. Use this whenever the user wants exploratory testing, a bug hunt, a pre-release sweep, or to "poke at the app and see what breaks".
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# Exploring quality (2-phase exploratory QA)

Scripted tests only find bugs you already imagined. Exploratory QA finds the rest — by
sweeping the surface broadly, then chasing the anomalies deep. Work in two phases: breadth
first (cheap, headless, many probes), then depth (a real browser, curiosity-led) on whatever
phase 1 flagged. The output is a findings report, not permanent tests — keepers get handed to
`authoring-tests`, bugs to `tracking-issues`.

## Phase 1 — breadth (scripted, headless)
Derive the app's surface from the code, then probe it widely and fast.
```bash
scripts/surface-inventory.sh        # routes, SSE events, forms, slash-commands from the code
scripts/launch-demo.sh &            # start the offline demo server
scripts/breadth-sweep.sh            # HTTP status sweep + malformed payloads + rapid SSE
```
Look for: non-2xx where you didn't expect it, 500s on malformed input, unescaped output,
slow paths, broken redirects, missing headers. Collect every anomaly with its repro.
See [references/phase1-breadth.md](references/phase1-breadth.md).

## Phase 2 — depth (real browser)
Take phase 1's leads (and your own curiosity) into the live browser via the bundled
`playwright-cli` / Playwright MCP. Drive real flows — streaming, type-ahead queueing,
permissions, plan mode, elicitation — using **accessibility-tree snapshots**, not pixels.
Run axe-core as you go, and **capture a screenshot for anything visual** so the finding has
evidence. See [references/phase2-deepdive.md](references/phase2-deepdive.md).

## Output: the findings report
Write a ranked report (`docs/qa/exploratory-<date>.md`) using
[references/findings-report.md](references/findings-report.md): each finding has severity, a
repro, evidence (screenshot/log), and a suggested home — a `tracking-issues` issue and, if it
should never regress, an `authoring-tests` test.

## Why two phases
Breadth without depth gives you a pile of status codes with no story; depth without breadth
means you deep-dive the first thing you see and miss the rest. Sweep wide to know *where* to
look, then look *hard* only there — that's how you cover a lot of surface without burning hours.

## This repo
The demo server (`./my-orchestra -demo`) and the vendored `playwright-cli` skill already exist.
Note the sandbox can't bind servers — run phases locally or in CI, not inside a restricted tool call.
