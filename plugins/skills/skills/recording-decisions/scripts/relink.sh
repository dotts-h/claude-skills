#!/usr/bin/env bash
# relink.sh <old-number> <new-number> [adr-dir]
# Marks <old> as superseded by <new> and <new> as superseding <old>, in place.
set -euo pipefail
old="${1:?old number}"; new="${2:?new number}"; dir="${3:-docs/adr}"
oldp=$(printf "%04d" "$((10#$old))"); newp=$(printf "%04d" "$((10#$new))")

oldf=$(ls "$dir/${oldp}-"*.md 2>/dev/null | head -1)
newf=$(ls "$dir/${newp}-"*.md 2>/dev/null | head -1)
[ -n "$oldf" ] && [ -n "$newf" ] || { echo "ADR file(s) not found" >&2; exit 1; }

sed -i -E "s/^- Status:.*/- Status: superseded by ${newp}/" "$oldf"
sed -i -E "s/^- Status:.*/- Status: accepted (supersedes ${oldp})/" "$newf"
echo "linked ${oldp} <- superseded by - ${newp}"
