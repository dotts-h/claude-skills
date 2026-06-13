#!/usr/bin/env bash
# screenshot-states.sh [base-url] [outdir] — capture the main pages at desktop + tablet + mobile
# widths for before/after design comparison. Uses the bundled playwright-cli. Needs a running server.
set -uo pipefail
base="${1:-http://127.0.0.1:8765}"
out="${2:-docs/qa/assets/shots-$(date -u +%Y%m%dT%H%M%S)}"
mkdir -p "$out"

pages=("/" "/page/telemetry" "/page/skills" "/page/agents" "/page/models" "/page/settings" "/help")
widths=("1280 800" "834 1112" "390 844")

pw() { npx --no-install playwright-cli "$@" 2>/dev/null || playwright-cli "$@"; }

pw open "$base" >/dev/null || { echo "playwright-cli not available or server down" >&2; exit 1; }
for w in "${widths[@]}"; do
  set -- $w; pw resize "$1" "$2" >/dev/null
  for p in "${pages[@]}"; do
    pw goto "$base$p" >/dev/null
    name=$(echo "$p" | sed 's#[/]#_#g; s/^_//; s/^$/home/'); [ -z "$name" ] && name=home
    pw screenshot --filename="$out/${name}_${1}x${2}.png" >/dev/null
    echo "  $out/${name}_${1}x${2}.png"
  done
done
pw close >/dev/null
echo "saved to $out"
