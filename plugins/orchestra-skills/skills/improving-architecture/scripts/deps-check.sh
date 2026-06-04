#!/usr/bin/env bash
# deps-check.sh [module-root] — verify dependency direction. Flags forbidden imports and
# prints each internal package's imports for an eyeball pass. Uses `go list` if available,
# falls back to grep. Read-only.
set -uo pipefail
root="${1:-.}"
[ -d /home/ori913/go-install/go/bin ] && export PATH="$PATH:/home/ori913/go-install/go/bin"

echo "=== FORBIDDEN: SDK imported outside internal/copilot ==="
# Match the quoted import path only, so display strings that merely mention the SDK
# (e.g. a settings page showing "github/copilot-sdk/go") aren't flagged.
grep -rnE '"github\.com/github/copilot-sdk' "$root/internal" --include='*.go' 2>/dev/null \
  | grep -v 'internal/copilot' | grep -v _test | sed 's/^/  VIOLATION  /' || true
echo "  (none above = clean)"

echo; echo "=== FORBIDDEN: pure core importing net/http or the SDK ==="
for pkg in telemetry ctxforge config convo; do
  [ -d "$root/internal/$pkg" ] || continue
  bad=$(grep -rnE '"net/http"|copilot-sdk' "$root/internal/$pkg" --include='*.go' 2>/dev/null | grep -v _test)
  [ -n "$bad" ] && echo "  VIOLATION in $pkg:" && echo "$bad" | sed 's/^/    /'
done
echo "  (none above = clean)"

echo; echo "=== import summary per internal package (eyeball direction) ==="
if command -v go >/dev/null 2>&1 && [ -f "$root/go.mod" ]; then
  mod=$(awk '/^module /{print $2}' "$root/go.mod")
  ( cd "$root" && go list -deps -f '{{if .Module}}{{.ImportPath}}{{end}}' ./internal/... 2>/dev/null \
      | grep "$mod/internal" | sort -u | sed 's/^/  /' ) || echo "  (go list failed; use grep view)"
else
  echo "  (go not available — inspect imports manually)"
fi
