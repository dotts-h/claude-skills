#!/usr/bin/env bash
# harvest.sh — surface existing convention signals so CONVENTIONS.md is built
# from reality, not invented. Read-only.
set -uo pipefail

echo "=== Makefile targets ==="
[ -f Makefile ] && grep -E '^[a-zA-Z0-9_-]+:' Makefile | sed 's/:.*//' | sort -u || echo "(none)"

echo; echo "=== package.json scripts ==="
[ -f package.json ] && sed -n '/"scripts"/,/}/p' package.json || echo "(none)"

echo; echo "=== lint config ==="
ls .golangci.yml .golangci.yaml .eslintrc* .prettierrc* ruff.toml 2>/dev/null || echo "(none)"

echo; echo "=== CI workflows (gate hints) ==="
if [ -d .github/workflows ]; then
  for f in .github/workflows/*.y*ml; do
    [ -e "$f" ] || continue
    echo "--- $f"
    grep -iE 'run:|cover|race|fuzz|lint|test|build' "$f" | sed 's/^[[:space:]]*/  /' | head -20
  done
else echo "(none)"; fi

echo; echo "=== CONTRIBUTING.md rules ==="
[ -f CONTRIBUTING.md ] && grep -E '^[-*0-9]' CONTRIBUTING.md | head -40 || echo "(none)"

echo; echo "=== existing CLAUDE.md ==="
[ -f CLAUDE.md ] && wc -l CLAUDE.md || echo "(none)"
