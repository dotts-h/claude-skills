---
name: registering-contracts
description: Generates and maintains docs/CONTRACTS.md — a registry of the stable promises between components, namely interfaces, event/message vocabularies, HTTP routes, data schemas, and invariants. Use this whenever adding or changing an API, interface, event type, route, or persisted schema, or when the user asks to document, audit, or check contracts or the boundary between two components — even if they call it something else.
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# Registering contracts

A contract is a promise one component makes to another: a function signature, an
event name and shape, a route, a JSON schema, an invariant. Collecting them in one
registry makes changing them *deliberate* — you can see who depends on a promise
before you break it. This is different from the codebase map (which says where code
*is*); contracts are what code *guarantees*.

## When to use
- Adding/changing an interface, event, route, or persisted schema.
- Auditing whether code still matches its documented promises (drift check).
- Onboarding: understanding the wire/API surface without reading every file.

## Workflow
0. **Scaffold if missing** — create the registry skeleton on first use:
   ```bash
   scripts/ensure-doc.sh        # idempotent; no-op if docs/CONTRACTS.md exists
   ```
1. Extract the surface deterministically:
   ```bash
   scripts/extract-interfaces.sh
   ```
   It greps interfaces, route registrations, and event/SSE names so the registry is
   built from the code, not memory.
2. Record each contract using [references/contract-entry-template.md](references/contract-entry-template.md):
   for every entry capture **producer, consumer, shape, and stability**.
3. Cover these contract *kinds* (skip any the repo doesn't have):
   interfaces/seams · event vocabularies (and any normalization table) · HTTP routes
   · SSE/websocket message names · config/persisted JSON schemas · **invariants**
   (determinism, totality, escaping — the promises that aren't a signature).
4. Run the drift check and resolve disagreements:
   see [references/detecting-drift.md](references/detecting-drift.md). When the code
   changed on purpose, update the registry; when it changed by accident, that's a bug —
   file it via `tracking-issues`.
5. Link each contract to the ADR that set it (if any) and to `CODEBASE_MAP.md`.

## Why "stability" matters
Marking a contract `stable | internal | experimental` tells future-you whether a
change is a breaking change. A stable contract with external consumers deserves an
ADR before it changes; an internal one can move freely.

## This repo
Three tables already exist, scattered — consolidate them here and keep them current:
the `copilot.Client` interface (ARCHITECTURE.md), the **SDK-event → normalized `Event`**
table, and the **normalized `Event` → SSE fragment** table (WEB_UI_PLAN.md), plus the
HTTP routes and the invariants (`Forge.Compile` determinism, pricing totality, all
model text HTML-escaped).
