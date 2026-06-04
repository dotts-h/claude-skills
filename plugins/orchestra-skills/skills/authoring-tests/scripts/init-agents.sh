#!/usr/bin/env bash
# init-agents.sh — install/refresh the Playwright planner/generator/healer agent
# definitions for the claude loop. Run once, and again after a Playwright upgrade.
set -uo pipefail
dir="${1:-e2e}"
cd "$dir" 2>/dev/null || { echo "no $dir/ dir" >&2; exit 1; }
echo "+ npx playwright init-agents --loop=claude (in $dir)"
npx playwright init-agents --loop=claude
