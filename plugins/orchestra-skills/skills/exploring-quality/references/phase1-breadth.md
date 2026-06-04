# Phase 1 — breadth sweeps

Goal: touch as much of the surface as cheaply as possible and collect anomalies. Headless,
scripted, fast. You're not proving correctness here — you're finding *where* to look in phase 2.

## Build the surface inventory
From the code, enumerate: HTTP routes (method + path), SSE event names, forms and their fields,
slash-commands, and any state-changing POSTs. `scripts/surface-inventory.sh` does this for the
Go/htmx app; adapt the greps for other stacks.

## Probes worth running
- **Status sweep:** GET/HEAD every route; flag anything not in its expected status class.
- **Malformed payloads:** POST each form/endpoint with missing fields, wrong types, oversized
  values, and junk; a 500 (vs a clean 4xx) is a finding.
- **Escaping:** submit `<script>`/`"`/`&` into any field that echoes back; confirm it renders
  escaped (this app routes all model text through `html/template`, but user inputs are worth probing).
- **SSE behavior:** open `/events`, fire rapid actions, watch for stalls, dropped frames, or
  missing flush.
- **Headers:** check content-type, cache-control, cookie flags (HttpOnly/SameSite) on the
  endpoints that set them.

## Collect, don't fix
Each anomaly → one line: `route/action · what you sent · what you expected · what happened`.
Rank by surprise. The ranked list is the entry point to phase 2; don't start fixing yet, or
you'll lose breadth.
