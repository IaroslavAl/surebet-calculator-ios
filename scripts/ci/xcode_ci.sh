#!/usr/bin/env bash
set -euo pipefail

ACTION="${1:-}"

if [[ "$ACTION" != "build" && "$ACTION" != "test" ]]; then
  echo "Usage: $0 <build|test>"
  exit 1
fi

PROJECT="surebet-calculator.xcodeproj"
SCHEME="surebet-calculator"
DERIVED_DATA_PATH="${DERIVED_DATA_PATH:-${RUNNER_TEMP:-/tmp}/DerivedData}"
COMMON_FLAGS=(
  -skipPackagePluginValidation
  -skipMacroValidation
)

xcodebuild \
  -resolvePackageDependencies \
  -project "$PROJECT" \
  "${COMMON_FLAGS[@]}"

SIMULATOR_LINE="$( (xcrun simctl list devices available || true) | sed -n 's/^[[:space:]]*\(iPhone[^()]* ([-A-F0-9]\{36\})\).*/\1/p' | head -n1 )"
SIMULATOR_ID="$(echo "$SIMULATOR_LINE" | sed -n 's/.*(\([-A-F0-9]\{36\}\)).*/\1/p')"

if [[ -z "$SIMULATOR_ID" ]]; then
  echo "No available iPhone simulator found."
  xcrun simctl list devices available || true
  exit 1
fi

echo "Using simulator: $SIMULATOR_LINE"

xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  "${COMMON_FLAGS[@]}" \
  -destination "id=$SIMULATOR_ID" \
  -derivedDataPath "$DERIVED_DATA_PATH" \
  "$ACTION"
