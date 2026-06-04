#!/usr/bin/env bash
# reindex.sh [adr-dir]
# Regenerates <adr-dir>/README.md as a table of all ADRs (number, title, status).
# Deterministic: sorted by number.
set -euo pipefail
dir="${1:-docs/adr}"
out="$dir/README.md"
mkdir -p "$dir"

{
  echo "# Architecture Decision Records"
  echo
  echo "One decision per file (MADR-lite). Superseded records keep their file; their status points forward."
  echo
  echo "| # | Decision | Status |"
  echo "|---|----------|--------|"
  for f in $(ls "$dir"/[0-9][0-9][0-9][0-9]-*.md 2>/dev/null | sort); do
    num=$(basename "$f" | cut -c1-4)
    title=$(grep -m1 '^# ' "$f" | sed -E 's/^# [0-9]+\. //')
    status=$(grep -m1 '^- Status:' "$f" | sed -E 's/^- Status:[[:space:]]*//')
    rel=$(basename "$f")
    echo "| ${num} | [${title}](${rel}) | ${status} |"
  done
} > "$out"

echo "$out"
