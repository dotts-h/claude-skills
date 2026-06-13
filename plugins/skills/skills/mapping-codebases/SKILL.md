---
name: mapping-codebases
description: Generates and maintains docs/CODEBASE_MAP.md — module layout, entry points, the primary data-flow path, and architectural seams. Use this whenever onboarding to a repo, after a structural change (new package, moved boundary, renamed entry point), or when the user asks to map, diagram, explain, or document how the codebase is organized or "where things live" — even if they don't say the word "map".
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# Mapping codebases

A codebase map answers "where does X live and how does data move" in one screen, so
a fresh agent (or teammate) can navigate without re-deriving the structure every time.

## When to use
- Onboarding a repo with no `docs/CODEBASE_MAP.md`.
- After adding/moving a package or changing an entry point — the map drifts fast.
- When asked where something lives, how a request flows, or to explain the layout.

## Workflow
1. Inventory the modules deterministically (don't eyeball a large tree):
   ```bash
   scripts/module-inventory.sh
   ```
   It lists packages with LOC and exported symbols (Go/TS/Python-aware) — the raw
   material for the module table.
2. Trace the **primary data path** end to end and write it as an arrow chain. The
   point is to capture the spine of the system, because that's what newcomers follow.
   *(This repo: `cmd → web/Hub → copilot.Client → SDKClient → Events() → convo reducer → SSE fragments`.)*
3. Identify **seams** (the interfaces where layers meet and could be swapped/mocked)
   and mark which packages are *pure core* vs *thin edges* — that distinction is the
   single most useful thing a map conveys about a clean architecture.
4. Write `docs/CODEBASE_MAP.md` from [references/map-template.md](references/map-template.md).
5. Link out, don't duplicate: point to `docs/ARCHITECTURE.md` for depth and
   `docs/CONTRACTS.md` for the exact signatures. The map is the index, not the encyclopedia.

## Keep it honest
A map that lies is worse than none. When code and map disagree, fix the map — and if
the drift reveals a structural problem (a layer importing something it shouldn't),
hand that to `improving-architecture`, don't quietly absorb it.

## This repo
Seed the module table from the existing `docs/ARCHITECTURE.md#module-map` (it already
lists `cmd`, `internal/web`, `convo`, `copilot`, `ctxforge`, `telemetry`, `config`).
The central seam is `copilot.Client`; the purity rule is "pure core, thin edges".
