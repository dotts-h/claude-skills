# Detecting contract drift

Drift = code and the registry disagree. The registry is only trustworthy if you
catch drift, so run these checks when contracts might have moved.

## Cheap checks (grep-level)
- **Routes:** every path in code appears in the Routes table and vice-versa.
  `scripts/extract-interfaces.sh` lists both; diff them by eye or pipe to `comm`.
- **Event names:** every `event:`/SSE name emitted in code has a registry row.
- **Interface methods:** the method set in the registry matches the `type X interface`.

## What to do with a finding
1. **Intentional change** (someone added a route on purpose) → update the registry,
   and if the contract was `stable`, make sure there's an ADR for the change.
2. **Accidental change** (a renamed event no one updated downstream) → that's a bug;
   file it via `tracking-issues` and let `practicing-tdd` add the guard.
3. **New invariant with no guard** → hand to `hardening-tests`.

## Make it routine
A drift check is most valuable in review of a PR that touches a boundary. Suggest
wiring `scripts/extract-interfaces.sh` output into the PR description or a CI note so
contract changes are visible, not silent.
