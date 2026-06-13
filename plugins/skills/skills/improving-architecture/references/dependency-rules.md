# Dependency rules (this repo)

Dependency direction is the backbone of the architecture. When it's right, layers are testable
and swappable; when it's violated, everything tangles. Check these explicitly.

## The rules
1. **`internal/web` (UI) never imports the SDK.** It depends only on `copilot.Client`. New runtime
   behavior goes through `SDKClient`. This is the seam, and it's the most important rule.
2. **Domain packages are dependency-free:** `telemetry`, `ctxforge`, `config` import only the stdlib
   and each other's data — never `net/http`, never the SDK.
3. **Direction points inward:** edges (`cmd`, `web`, `copilot/SDKClient`) depend on the core, never
   the reverse. The core doesn't know the HTTP layer or the SDK exist.
4. **`convo` is UI-agnostic:** the transcript reducer renders from data; it doesn't import `web`.

## How to verify
`scripts/deps-check.sh` flags forbidden imports and prints each internal package's imports so you
can eyeball the direction. A clean run means the layering still holds.

## When a rule needs to bend
Sometimes a genuine need pushes against a rule (e.g. a new event type the UI must react to). The
answer is almost always "add it to the seam as a normalized `Event`", not "import the SDK in the
UI". If you truly need to change a rule, that's an ADR — the rule was a decision, so changing it is too.
