#!/usr/bin/env bash
# ensure-doc.sh [path] — create docs/TECH_DEBT.md with the canonical header if it
# does not exist. Idempotent: prints "exists" and does nothing if already present.
# Run as step 1 so Read/Edit on the register never fail on first use.
set -euo pipefail
path="${1:-docs/TECH_DEBT.md}"
if [ -e "$path" ]; then
  echo "exists: $path"
  exit 0
fi
mkdir -p "$(dirname "$path")"
cat > "$path" <<'EOF'
# Tech-debt register

> Tracked, prioritized shortcuts and gaps. Severity = impact if it bites. Effort = cost to fix.
> Interest = ongoing cost of leaving it. Rank by interest × likelihood.

| # | Item | Location | Sev | Effort | Interest | Links | Trigger to pay down |
|---|------|----------|-----|--------|----------|-------|---------------------|
EOF
echo "created: $path"
