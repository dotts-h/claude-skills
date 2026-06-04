#!/usr/bin/env bash
# flake-hunt.sh <pkg> [runs] — run a Go package repeatedly under -race and -shuffle to
# surface flakes/races. Exits non-zero on the first failing run (that's a flake).
set -uo pipefail
pkg="${1:-./...}"; runs="${2:-20}"
[ -d /home/ori913/go-install/go/bin ] && export PATH="$PATH:/home/ori913/go-install/go/bin"

echo "flake-hunt: $pkg × $runs (race + shuffle)"
fail=0
for i in $(seq 1 "$runs"); do
  if ! go test "$pkg" -race -shuffle=on -count=1 >/tmp/flake.$$ 2>&1; then
    echo "FAIL on run $i:"; sed 's/^/  /' /tmp/flake.$$; fail=1; break
  fi
  printf "."
done
echo
rm -f /tmp/flake.$$
[ "$fail" -eq 0 ] && echo "no flake in $runs runs" || echo "flake detected — see output above"
exit $fail
