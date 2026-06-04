#!/usr/bin/env bash
# surface-inventory.sh [root] — enumerate the testable surface for breadth probing:
# routes, SSE events, forms, slash-commands. Read-only. Tuned for the Go/htmx app.
set -uo pipefail
root="${1:-.}"

echo "=== routes (method + path) ==="
grep -rnoE '(Handle|HandleFunc)\("[^"]+"' "$root" --include='*.go' 2>/dev/null \
  | grep -v _test | sed -E 's/.*"([^"]+)".*/  \1/' | sort -u || echo "  (none)"

echo; echo "=== SSE event names ==="
grep -rnoE 'event: ?[a-z][a-z-]+' "$root" --include='*.go' --include='*.html' 2>/dev/null \
  | sed -E 's/.*event: ?//' | sort -u | sed 's/^/  /' || echo "  (none)"

echo; echo "=== forms + fields (templates) ==="
grep -rnoE 'name="[a-zA-Z0-9_.-]+"' "$root" --include='*.html' 2>/dev/null \
  | sed -E 's/.*name="([^"]+)".*/  \1/' | sort -u | head -40 || echo "  (none)"

echo; echo "=== slash commands ==="
grep -rnoE '"/[a-z]+"' "$root" --include='*.go' 2>/dev/null | grep -v _test \
  | sed -E 's/.*"(\/[a-z]+)".*/  \1/' | sort -u | head -40 || echo "  (none)"
