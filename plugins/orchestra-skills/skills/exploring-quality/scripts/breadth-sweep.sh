#!/usr/bin/env bash
# breadth-sweep.sh [base] [routes-file] — phase-1 HTTP probe: status sweep + a couple of
# malformed POSTs. Prints one line per probe; anything surprising is a finding. Needs a
# running server (see launch-demo.sh). Read-only against the app except for demo POSTs.
set -uo pipefail
base="${1:-http://127.0.0.1:8765}"
routes="${2:-}"

probe() { # method path
  local code; code=$(curl -s -o /dev/null -w '%{http_code}' -X "$1" "$base$2" 2>/dev/null || echo "ERR")
  printf "  %-4s %-30s -> %s\n" "$1" "$2" "$code"
}

echo "=== GET sweep ==="
if [ -n "$routes" ] && [ -f "$routes" ]; then
  while read -r p; do [ -n "$p" ] && probe GET "$p"; done < "$routes"
else
  for p in / /events /page/telemetry /page/skills /page/agents /page/models /page/settings /help; do probe GET "$p"; done
fi

echo; echo "=== malformed POSTs (expect clean 4xx, not 500) ==="
probe POST /send                       # empty body
curl -s -o /dev/null -w '  POST /send (junk) -> %{http_code}\n' \
  -X POST -d 'prompt=%ZZ&x=<script>' "$base/send" 2>/dev/null || echo "  POST /send -> ERR"
probe POST /perm/does-not-exist
probe POST /abort
