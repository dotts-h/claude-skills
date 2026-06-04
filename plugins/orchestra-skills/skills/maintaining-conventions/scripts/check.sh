#!/usr/bin/env bash
# check.sh — warn if commands referenced in docs/CONVENTIONS.md don't resolve to
# real Makefile targets / package scripts. Best-effort, non-fatal.
set -uo pipefail
conv="docs/CONVENTIONS.md"
[ -f "$conv" ] || { echo "no $conv yet" >&2; exit 0; }

# Make targets that CONVENTIONS mentions as `make X`.
grep -oE 'make [a-zA-Z0-9_-]+' "$conv" | awk '{print $2}' | sort -u | while read -r t; do
  if [ -f Makefile ] && grep -qE "^$t:" Makefile; then
    echo "ok    make $t"
  else
    echo "WARN  make $t  (not a Makefile target)"
  fi
done
