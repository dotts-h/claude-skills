#!/usr/bin/env bash
# launch-demo.sh [addr] — build and start the offline demo server for exploratory runs.
# Run with & to background it; stop with the printed PID. (Won't work inside a sandbox
# that blocks binds — run locally or in CI.)
set -uo pipefail
addr="${1:-127.0.0.1:8765}"
[ -d /home/ori913/go-install/go/bin ] && export PATH="$PATH:/home/ori913/go-install/go/bin"

if [ -f Makefile ] && grep -qE '^build:' Makefile; then make build; else go build -o bin/my-orchestra ./cmd/my-orchestra; fi
echo "starting demo on http://$addr  (Ctrl-C / kill to stop)"
exec ./bin/my-orchestra -demo -addr "$addr"
