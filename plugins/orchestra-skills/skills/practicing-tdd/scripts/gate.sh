#!/usr/bin/env bash
# gate.sh — detect and run the project's lint+test gate. Repetitive every TDD cycle,
# so it's worth one script. Honors a Makefile first, then falls back per ecosystem.
set -uo pipefail

# Make Go toolchain available if it's in the known custom location.
[ -d /home/ori913/go-install/go/bin ] && export PATH="$PATH:/home/ori913/go-install/go/bin"

run() { echo "+ $*"; "$@"; }

if [ -f Makefile ] && grep -qE '^test:' Makefile; then
  grep -qE '^lint:' Makefile && run make lint
  run make test
  exit $?
fi

if [ -f go.mod ]; then
  run gofmt -l ./cmd ./internal 2>/dev/null
  run go vet ./...
  run go test ./... -race -count=1 -cover
  exit $?
fi

if [ -f package.json ]; then
  npm run lint --if-present
  npm test --if-present
  exit $?
fi

echo "gate.sh: no recognized build (Makefile/go.mod/package.json)" >&2
exit 1
