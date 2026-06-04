#!/usr/bin/env bash
# extract-interfaces.sh [root] — surface the contract surface from code so the
# registry is built from reality. Read-only. Go-focused with generic fallbacks.
set -uo pipefail
root="${1:-.}"
inc="--include=*.go"

echo "=== interfaces (type X interface) ==="
grep -rnE 'type [A-Z][A-Za-z0-9]* interface' "$root" $inc 2>/dev/null \
  | grep -v _test | sed 's/^/  /' || echo "  (none)"

echo; echo "=== HTTP route registrations ==="
grep -rnE '\.(Handle|HandleFunc|Get|Post|Put|Delete)\(|mux\.Handle' "$root" $inc 2>/dev/null \
  | grep -v _test | sed -E 's/^/  /' || echo "  (none)"

echo; echo "=== SSE / event names emitted ==="
# common patterns: event: "name", SSE "event:" writes, or Ev* enum values
grep -rnoE '"(event:[a-zA-Z-]+|[a-z][a-z-]+)"' "$root" $inc 2>/dev/null \
  | grep -iE 'event|sse|delta|tool|perm|cost|ctx|status' | sed 's/^/  /' | sort -u | head -40 || echo "  (none)"

echo; echo "=== normalized event constants (Ev*) ==="
grep -rnoE 'Ev[A-Z][A-Za-z]+' "$root" $inc 2>/dev/null | grep -v _test \
  | awk -F: '{print $NF}' | sort -u | sed 's/^/  /' || echo "  (none)"

echo; echo "=== exported config/forge structs (persisted schema candidates) ==="
grep -rnE 'type [A-Z][A-Za-z0-9]* struct' "$root" $inc 2>/dev/null \
  | grep -iE 'config|forge|skill|agent|instruction|server|spec' | grep -v _test | sed 's/^/  /' || echo "  (none)"
