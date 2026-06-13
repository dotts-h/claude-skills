# Implementing in the htmx app

Keep the architecture: the server renders HTML, streams fragments over SSE, and htmx swaps them. Design
changes are CSS + template changes, almost never new client state. Don't reach for a framework.

## Where things live
- **Styles:** `internal/web/static/app.css` — put tokens in `:root`, style by class.
- **Markup:** `internal/web/templates/fragments.html` (named fragments) + `index.html` (shell, SSE
  listeners). Render helpers in `render.go`/`pages.go` execute these templates.
- **Escaping:** all model text goes through `html/template`/`esc()` — never inject raw model output into
  your new markup (XSS). The one custom path is `richtext` (escape + `\n`→`<br>`).

## Patterns
- **Restyle without re-architecting:** most polish is class/token changes in `app.css` — no Go change.
- **New structural element:** add/adjust a named fragment; keep the SSE event→fragment contract intact
  (coordinate with `registering-contracts` if you change a fragment id an OOB swap targets).
- **Rich widget (markdown, statusline):** a small vanilla-JS island or web component over the committed
  turn is the right tool — render on commit, keep the streaming `#cur` plain. This was the explicit plan
  for markdown; it does not require React/Tailwind.
- **Motion:** CSS transitions keyed to token `--dur`/`--ease`; gate on `prefers-reduced-motion`.

## Don't break the streaming model
Streamed tokens are wrapped in spans to preserve whitespace; very high-frequency deltas are coalesced.
If you restyle the live message area, keep the append fast-path intact (don't force a full re-render per token).

## Verify after editing
Run `gofmt`/`go build` if you touched templates wired through Go, then the browser checks
(`axe-scan.sh`, `screenshot-states.sh`) and the existing e2e/a11y suite. A visual change with a green
a11y run and a clean before/after is a shippable change.
