# CONTRACTS.md structure

```markdown
# Contracts registry

> The stable promises between components. Changing a `stable` entry is a breaking
> change — record an ADR first.

## Interfaces / seams
### `copilot.Client`
- **Producer:** internal/copilot (SDKClient, MockClient)
- **Consumer:** internal/web
- **Shape:** `CreateSession(ctx,spec)(string,err)` · `Send(...)` · `Abort(...)` · `Events() <-chan Event` · `Close()`
- **Stability:** stable — the central seam; ADR-000N.

## Event vocabularies
### SDK event → normalized Event
| SDK event | normalized | carries |
|-----------|-----------|---------|
| ...       | ...       | ...     |

## Routes
| Method | Path | Handler | Returns |
|--------|------|---------|---------|
| GET    | /events | SSE hub | text/event-stream |

## Persisted schemas
### forge.json
- Kinds: Skill · Instruction · Agent · MCPServer (each slug id + Validate()).
- Invariant: unique ids per kind; agents reference only real skills.

## Invariants (promises that aren't signatures)
- `Forge.Compile(agentID)` is deterministic (stable sort, ordered de-dup).
- Pricing is total: non-negative, never NaN for non-negative token inputs.
- All model-produced text is HTML-escaped before render.
```

## Per-entry rules
- **Shape** is copy-pasteable (real signature / real field names), not prose.
- **Stability** ∈ {stable, internal, experimental}. Default new contracts to
  `internal` until something outside the package depends on them.
- An invariant needs a **guard** (a test/fuzz/property). Name it, or flag it for
  `hardening-tests` to add.
