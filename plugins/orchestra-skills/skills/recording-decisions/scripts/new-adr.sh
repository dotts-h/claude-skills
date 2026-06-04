#!/usr/bin/env bash
# new-adr.sh "<decision title>" [adr-dir]
# Allocates the next zero-padded ADR number, writes a seeded MADR-lite file,
# and prints its path. Deterministic: number = max existing + 1.
set -euo pipefail

title="${1:-}"
dir="${2:-docs/adr}"
if [ -z "$title" ]; then
  echo "usage: new-adr.sh \"<decision title>\" [adr-dir]" >&2
  exit 2
fi
mkdir -p "$dir"

# Highest existing NNNN- prefix, default 0.
last=0
for f in "$dir"/[0-9][0-9][0-9][0-9]-*.md; do
  [ -e "$f" ] || continue
  n=$(basename "$f" | cut -c1-4)
  n=$((10#$n))
  [ "$n" -gt "$last" ] && last=$n
done
next=$(printf "%04d" $((last + 1)))

# kebab-case slug from the title.
slug=$(printf '%s' "$title" \
  | tr '[:upper:]' '[:lower:]' \
  | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//')
path="$dir/${next}-${slug}.md"
today=$(date -u +%Y-%m-%d)

cat > "$path" <<EOF
# ${next}. ${title}

- Status: proposed
- Date: ${today}
- Deciders:
- Related:

## Context

## Considered options

-
-

## Decision

## Consequences

- Positive:
- Negative / cost we accept:
- Follow-ups:
EOF

echo "$path"
