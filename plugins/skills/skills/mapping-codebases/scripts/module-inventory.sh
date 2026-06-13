#!/usr/bin/env bash
# module-inventory.sh [root] — list packages/modules with LOC and exported symbols.
# Language-aware (Go / TS-JS / Python). Read-only. The raw material for the module table.
set -uo pipefail
root="${1:-.}"

echo "=== Go packages ==="
if find "$root" -name '*.go' -not -path '*/vendor/*' | grep -q .; then
  # directories containing .go files, with LOC and exported (Capitalized) decls
  find "$root" -name '*.go' -not -path '*/vendor/*' -not -name '*_test.go' -printf '%h\n' \
    | sort -u | while read -r d; do
      loc=$(cat "$d"/*.go 2>/dev/null | wc -l)
      exp=$(grep -hcE '^(func|type|var|const) [A-Z]' "$d"/*.go 2>/dev/null | paste -sd+ - | bc 2>/dev/null || echo "?")
      printf "  %-32s %5s LOC  %s exported\n" "${d#"$root"/}" "$loc" "$exp"
    done
else echo "  (none)"; fi

echo; echo "=== TS/JS modules (src dirs) ==="
find "$root" -type f \( -name '*.ts' -o -name '*.tsx' -o -name '*.js' \) \
  -not -path '*/node_modules/*' -printf '%h\n' 2>/dev/null | sort | uniq -c | sort -rn | head -25 \
  | awk '{printf "  %-40s %s files\n", $2, $1}' || echo "  (none)"

echo; echo "=== Python packages ==="
find "$root" -name '__init__.py' -not -path '*/.venv/*' -printf '%h\n' 2>/dev/null \
  | sort -u | sed 's/^/  /' || echo "  (none)"

echo; echo "=== entry points ==="
grep -rlE 'func main\(\)' "$root" --include='*.go' 2>/dev/null | grep -v _test | sed 's/^/  go:  /'
grep -rlE '"(main|start|dev)":' "$root"/package.json 2>/dev/null | sed 's/^/  npm: /'
