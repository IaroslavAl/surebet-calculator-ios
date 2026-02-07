#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

required_files=(
  "AGENTS.md"
  "docs/agent/START_HERE.md"
  "docs/agent/POLICIES.md"
  "docs/reference/PROJECT_MAP.md"
  "docs/reference/MODULE_INDEX.md"
  "docs/reference/DEPENDENCY_GRAPH.md"
  "docs/reference/BUILD_TEST_COMMANDS.md"
  "docs/reference/CI_RULES.md"
  "docs/lessons/INCIDENTS.md"
  "README.md"
)

missing=0
for file in "${required_files[@]}"; do
  if [[ ! -f "$file" ]]; then
    echo "[ERROR] Missing required documentation file: $file"
    missing=1
  fi
done

if [[ $missing -ne 0 ]]; then
  exit 1
fi

if ! grep -q "docs/agent/START_HERE.md" AGENTS.md; then
  echo "[ERROR] AGENTS.md must point to docs/agent/START_HERE.md"
  exit 1
fi

if grep -R --line-number "TODO:" docs AGENTS.md README.md >/dev/null 2>&1; then
  echo "[ERROR] Documentation contains TODO markers"
  grep -R --line-number "TODO:" docs AGENTS.md README.md || true
  exit 1
fi

echo "[OK] Documentation structure is valid"
