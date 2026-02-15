#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

SCANNER="rg"
if ! command -v rg >/dev/null 2>&1; then
  SCANNER="grep"
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

readonly -a GREP_PATTERNS=(
  '(api[_-]?key|client[_-]?secret|private[_-]?key|access[_-]?token)[[:space:]]*[:=][[:space:]]*"([A-Za-z0-9_-]{20,}|[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})"'
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

collect_scan_files() {
  local path
  while IFS= read -r -d '' path; do
    case "$path" in
      .git/*|.build/*|DerivedData/*|*.png|*.jpg|*.gif|Package.resolved|*.xcresult/*)
        continue
        ;;
    esac
    printf '%s\0' "$path"
  done < <(git ls-files -z)
}

grep_scan() {
  local pattern="$1"
  local path
  local found=1
  while IFS= read -r -d '' path; do
    if grep -nIE --color=never -e "$pattern" "$path"; then
      found=0
    fi
  done < <(collect_scan_files)
  return "$found"
}

matches_found=0
if [[ "$SCANNER" == "rg" ]]; then
  for pattern in "${PATTERNS[@]}"; do
    if rg_with_globs "$pattern"; then
      matches_found=1
    fi
  done
else
  echo "ripgrep is unavailable, falling back to grep-based secret scan"
  for pattern in "${GREP_PATTERNS[@]}"; do
    if grep_scan "$pattern"; then
      matches_found=1
    fi
  done
fi

if [[ "$matches_found" -eq 1 ]]; then
  cat <<'MESSAGE'
Potential hardcoded secrets detected.
Move sensitive values to configuration (env/xcconfig/secret storage) and re-run the scan.
MESSAGE
  exit 1
fi

echo "No hardcoded secrets detected"
