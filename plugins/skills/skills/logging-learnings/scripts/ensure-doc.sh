#!/usr/bin/env bash
# ensure-doc.sh [path] — create docs/REGRESSIONS.md with the three canonical
# registers if it does not exist. Idempotent: prints "exists" and does nothing if
# already present. Run as step 1 so Read/Edit never fail on first use.
set -euo pipefail
path="${1:-docs/REGRESSIONS.md}"
if [ -e "$path" ]; then
  echo "exists: $path"
  exit 0
fi
mkdir -p "$(dirname "$path")"
cat > "$path" <<'EOF'
# Learnings & dead-ends

> Closed history: bugs we fixed (each with its guard test), approaches we tried and
> abandoned (with what to do instead), and gotchas that bit us. Open obligations live
> in TECH_DEBT.md, not here.

## 1. Fixed (bugs with guards)

> Every entry names the test that now guards it.

| # | Symptom | Root cause | Fix | Guarding test(s) |
|---|---------|-----------|-----|------------------|

## 2. Dead-ends (what not to retry)

> Pair every dead-end with an **Instead**. A dead-end without an exit is just a ban.

## 3. Gotchas (things that bit us)

## Known gaps (fixed behavior, not yet guarded)

> Move an item out the moment its guard test lands.
EOF
echo "created: $path"
