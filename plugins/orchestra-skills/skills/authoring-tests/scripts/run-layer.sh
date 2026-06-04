#!/usr/bin/env bash
# run-layer.sh <e2e|api|a11y|ux|perf> — build the binary and run one test layer.
# api/perf(Go) run via go test; the browser layers run via Playwright against the demo.
set -uo pipefail
layer="${1:-e2e}"
[ -d /home/ori913/go-install/go/bin ] && export PATH="$PATH:/home/ori913/go-install/go/bin"

case "$layer" in
  api)  exec go test ./internal/web -run 'API|Contract' -count=1 -v ;;
  perf) exec go test ./internal/web -run x -bench . -benchmem ;;
  e2e|a11y|ux)
    [ -f Makefile ] && grep -qE '^e2e:' Makefile && { exec make e2e; }
    ( cd e2e && npx playwright test "tests/${layer}.spec.ts" ) ;;
  *) echo "usage: run-layer.sh <e2e|api|a11y|ux|perf>" >&2; exit 2 ;;
esac
