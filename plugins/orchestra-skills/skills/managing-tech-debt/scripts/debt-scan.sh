#!/usr/bin/env bash
# debt-scan.sh [root] — harvest debt candidates from the code: TODO/FIXME/HACK markers,
# skipped/pending tests, and known-gap notes. Read-only. Output feeds the register.
set -uo pipefail
root="${1:-.}"

echo "=== TODO / FIXME / HACK / XXX ==="
grep -rnE 'TODO|FIXME|HACK|XXX' "$root" \
  --include='*.go' --include='*.ts' --include='*.js' --include='*.html' 2>/dev/null \
  | grep -v node_modules | sed 's/^/  /' | head -60 || echo "  (none)"

echo; echo "=== skipped / pending tests ==="
grep -rnE 't\.Skip\(|t\.Skipf\(|test\.skip\(|\.fixme\(|xit\(|describe\.skip' "$root" \
  --include='*.go' --include='*.ts' 2>/dev/null | grep -v node_modules | sed 's/^/  /' || echo "  (none)"

echo; echo "=== known-gap markers in docs ==="
grep -rniE 'known gap|deferred|not yet (built|guarded)|revisit|tech debt' "$root"/docs 2>/dev/null \
  | sed 's/^/  /' | head -40 || echo "  (none)"

echo; echo "=== summary ==="
n=$(grep -rEc 'TODO|FIXME|HACK|XXX' "$root" --include='*.go' --include='*.ts' 2>/dev/null | grep -v ':0' | grep -v node_modules | wc -l)
echo "  files with debt markers: $n"
