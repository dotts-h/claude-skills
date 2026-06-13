#!/usr/bin/env bash
# eval-04 (quality): both CI flavors skip docs-only changes via paths-ignore on
# the push AND pull_request triggers, and the workflow guard still passes (the
# skip is a sibling key, not a feature-branch push trigger).
set -euo pipefail
PLUGIN_ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
fail() { echo "EVAL FAIL: $*" >&2; exit 1; }

check_flavor() {
  flavor="$1"
  T="$(mktemp -d)"; trap 'rm -rf "$T"' RETURN
  git init -q -b main "$T"
  printf 'lint:\n\ttrue\ntest:\n\ttrue\n' > "$T/Makefile"

  "$PLUGIN_ROOT/scripts/install-recipe.sh" \
    --recipe "$PLUGIN_ROOT/recipes/quality" --target "$T" --tier S \
    --answer project_name=acme --answer "build_system=$flavor" >/dev/null

  ci="$T/.github/workflows/ci.yml"
  [ -f "$ci" ] || fail "$flavor: ci.yml not installed"
  # paths-ignore must appear under BOTH triggers (exactly two occurrences).
  n=$(grep -c 'paths-ignore:' "$ci" || true)
  [ "$n" -eq 2 ] || fail "$flavor: expected paths-ignore on both push & pull_request (got $n)"
  grep -q 'docs/\*\*' "$ci" || fail "$flavor: docs/** not in paths-ignore"
  # The guard must not mistake paths-ignore for a feature-branch push trigger.
  ( cd "$T" && bash scripts/check-workflows.sh >/dev/null ) \
    || fail "$flavor: check-workflows.sh failed on a paths-ignore'd workflow"
}

check_flavor make
check_flavor npm

echo "PASS: quality eval-04 (docs-only CI skip on both flavors; guard still green)"
