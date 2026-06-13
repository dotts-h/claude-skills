#!/usr/bin/env bash
# axe-scan.sh [base-url] — run axe-core accessibility checks against the running app across
# its main pages/states. Uses the e2e/ Playwright + @axe-core/playwright already vendored.
# Needs a running server (see exploring-quality/scripts/launch-demo.sh). Read-only.
set -uo pipefail
base="${1:-http://127.0.0.1:8765}"

if [ -d e2e ] && [ -f e2e/tests/a11y.spec.ts ]; then
  echo "+ running the existing axe a11y suite against $base"
  ( cd e2e && BASE_URL="$base" npx playwright test tests/a11y.spec.ts )
  exit $?
fi

cat <<EOF
No e2e/tests/a11y.spec.ts found. To scan ad hoc, install @axe-core/playwright and run axe on each
state (landing, telemetry, skills, agents, models, settings, help) plus the inline forms (permission,
plan, ask, elicitation). Assert zero WCAG 2 A/AA violations. Save violations as findings with screenshots.
EOF
