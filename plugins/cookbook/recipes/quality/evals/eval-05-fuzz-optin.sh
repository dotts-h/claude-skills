#!/usr/bin/env bash
# eval-05 (quality): the fuzz-smoke workflow is OFF by default and installs only
# when fuzz_enabled=yes — carrying the bound command and a single-run trigger the
# workflow guard accepts.
set -euo pipefail
PLUGIN_ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
fail() { echo "EVAL FAIL: $*" >&2; exit 1; }

# --- default: no fuzz workflow ------------------------------------------------
OFF="$(mktemp -d)"; trap 'rm -rf "$OFF"' EXIT
git init -q -b main "$OFF"
printf 'lint:\n\ttrue\ntest:\n\ttrue\n' > "$OFF/Makefile"
"$PLUGIN_ROOT/scripts/install-recipe.sh" \
  --recipe "$PLUGIN_ROOT/recipes/quality" --target "$OFF" --tier M \
  --answer project_name=acme >/dev/null
[ -f "$OFF/.github/workflows/fuzz.yml" ] && fail "fuzz.yml installed without opt-in" || true

# --- opt-in: fuzz workflow with the bound command -----------------------------
ON="$(mktemp -d)"; trap 'rm -rf "$OFF" "$ON"' EXIT
git init -q -b main "$ON"
printf 'lint:\n\ttrue\ntest:\n\ttrue\n' > "$ON/Makefile"
"$PLUGIN_ROOT/scripts/install-recipe.sh" \
  --recipe "$PLUGIN_ROOT/recipes/quality" --target "$ON" --tier M \
  --answer project_name=acme --answer fuzz_enabled=yes \
  --answer 'fuzz_command=go test ./internal/x -run x -fuzz Fz -fuzztime 10s' >/dev/null

fz="$ON/.github/workflows/fuzz.yml"
[ -f "$fz" ] || fail "fuzz.yml not installed under opt-in"
grep -q 'fuzz Fz -fuzztime 10s' "$fz" || fail "bound fuzz_command not rendered"
# A leftover recipe placeholder is `{{word}}`; GitHub's `${{ github.ref }}` (spaces,
# a dot) is not one and must survive untouched.
grep -qE '\{\{[A-Za-z_]+\}\}' "$fz" && fail "unrendered recipe placeholder left in fuzz.yml" || true
grep -q 'github.ref' "$fz" || fail "GitHub expression \${{ github.ref }} was mangled"
# Both ci.yml and fuzz.yml must pass the single-run guard.
( cd "$ON" && bash scripts/check-workflows.sh >/dev/null ) \
  || fail "check-workflows.sh rejected the fuzz workflow"

echo "PASS: quality eval-05 (fuzz off by default; opt-in renders command + passes guard)"
