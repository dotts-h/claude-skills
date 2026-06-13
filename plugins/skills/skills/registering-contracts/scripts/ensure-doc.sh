#!/usr/bin/env bash
# ensure-doc.sh [path] — create docs/CONTRACTS.md with the canonical skeleton if it
# does not exist. Idempotent: prints "exists" and does nothing if already present.
# Run as step 1 so Read/Edit never fail on first use.
set -euo pipefail
path="${1:-docs/CONTRACTS.md}"
if [ -e "$path" ]; then
  echo "exists: $path"
  exit 0
fi
mkdir -p "$(dirname "$path")"
cat > "$path" <<'EOF'
# CONTRACTS.md — stable promises between components

> A contract is a promise one component makes to another: an interface signature, an
> event name and shape, a route, a persisted schema, an invariant. This registry makes
> changing them deliberate. Stability: `stable` (needs an ADR to change) ·
> `internal` (move freely) · `experimental`. For each entry record producer, consumer,
> shape, and stability.

## 1. Interfaces / seams

## 2. Event vocabulary

## 3. HTTP routes

## 4. Persisted schemas

## 5. Invariants
EOF
echo "created: $path"
