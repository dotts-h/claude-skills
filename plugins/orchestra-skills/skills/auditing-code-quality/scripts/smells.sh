#!/usr/bin/env bash
# smells.sh [root] — grep for the high-cost antipatterns in this codebase. Read-only.
# Each hit is a candidate finding, not a guaranteed problem — read it in context.
set -uo pipefail
root="${1:-.}"
inc="--include=*.go"

echo "=== seam leak: SDK imported outside internal/copilot ==="
grep -rn 'github.com/github/copilot-sdk/go' "$root" $inc 2>/dev/null \
  | grep -v 'internal/copilot' | grep -v _test | sed 's/^/  /' || echo "  (clean)"

echo; echo "=== punted errors: _ = call() / blank error assign ==="
grep -rnE '(^|[^a-zA-Z])_ = [a-zA-Z].*\(' "$root" $inc 2>/dev/null | grep -v _test | sed 's/^/  /' | head -30 || echo "  (clean)"

echo; echo "=== impure core: domain packages importing http/sdk/net ==="
for pkg in telemetry ctxforge config; do
  hits=$(grep -rnE 'import|"net/http"|copilot-sdk' "$root/internal/$pkg" $inc 2>/dev/null | grep -E 'net/http|copilot-sdk' | grep -v _test)
  [ -n "$hits" ] && echo "  $pkg:" && echo "$hits" | sed 's/^/    /'
done
echo "  (done)"

echo; echo "=== map-range then order-sensitive use (nondeterminism smell) ==="
grep -rnE 'for .* := range .*[mM]ap|range [a-z]+s \{' "$root" $inc 2>/dev/null | grep -v _test | sed 's/^/  /' | head -15 || echo "  (none obvious)"

echo; echo "=== TODO/FIXME/HACK (hand to managing-tech-debt) ==="
grep -rnE 'TODO|FIXME|HACK|XXX' "$root" $inc 2>/dev/null | grep -v _test | wc -l | sed 's/^/  count: /'
