#!/usr/bin/env bash
# mutation-run.sh <pkg> — run a mutation tester if available; otherwise print how to set
# one up and suggest a manual mutation pass. Non-fatal so it can guide rather than block.
set -uo pipefail
pkg="${1:-./...}"
[ -d /home/ori913/go-install/go/bin ] && export PATH="$PATH:/home/ori913/go-install/go/bin"

if command -v gremlins >/dev/null 2>&1; then
  echo "+ gremlins run $pkg"; exec gremlins run "$pkg"
elif command -v go-mutesting >/dev/null 2>&1; then
  echo "+ go-mutesting $pkg"; exec go-mutesting "$pkg"
else
  cat <<'EOF'
No mutation tester installed. Install one:
  go install github.com/go-gremlins/gremlins/cmd/gremlins@latest
  # or
  go install github.com/avito-tech/go-mutesting/cmd/go-mutesting@latest

Or do a manual pass: pick the 3-5 most important functions, introduce one fault each
(flip a comparison, drop a !, return zero), run the package tests, confirm a test fails,
then revert. A surviving mutant marks an assertion to strengthen.
EOF
  exit 0
fi
