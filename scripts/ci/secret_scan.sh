#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

if ! command -v rg >/dev/null 2>&1; then
  echo "ripgrep (rg) is required for secret scanning"
  exit 1
fi

readonly -a GLOBS=(
  "!**/.git/**"
  "!**/.build/**"
  "!**/DerivedData/**"
  "!**/Package.resolved"
  "!**/*.xcresult/**"
  "!**/*.png"
  "!**/*.jpg"
  "!**/*.gif"
)

readonly -a PATTERNS=(
  '(?i)(api[_-]?key|client[_-]?secret|private[_-]?key|access[_-]?token)\s*[:=]\s*"([A-Za-z0-9_\-]{20,}|[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})"'
  'ghp_[A-Za-z0-9]{20,}'
  'sk_(live|test)_[A-Za-z0-9]{16,}'
  'xox[baprs]-[A-Za-z0-9-]{10,}'
  '-----BEGIN (RSA|EC|OPENSSH|PRIVATE) KEY-----'
)

rg_with_globs() {
  local pattern="$1"
  local -a cmd=(rg -n --hidden --pcre2 --regexp "$pattern")
  for glob in "${GLOBS[@]}"; do
    cmd+=(--glob "$glob")
  done
  "${cmd[@]}"
}

matches_found=0
for pattern in "${PATTERNS[@]}"; do
  if rg_with_globs "$pattern"; then
    matches_found=1
  fi
done

if [[ "$matches_found" -eq 1 ]]; then
  cat <<'MESSAGE'
Potential hardcoded secrets detected.
Move sensitive values to configuration (env/xcconfig/secret storage) and re-run the scan.
MESSAGE
  exit 1
fi

echo "No hardcoded secrets detected"
