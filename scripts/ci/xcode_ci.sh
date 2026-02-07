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

SIMULATOR_DESTINATION="${SIMULATOR_DESTINATION:-}"
if [[ -z "$SIMULATOR_DESTINATION" ]]; then
  SIMULATOR_SELECTION="$(
    (xcrun simctl list devices available || true) | awk '
      /^-- iOS [0-9.]+ --$/ {
        os=$0
        sub(/^-- iOS /, "", os)
        sub(/ --$/, "", os)
        next
      }
      /^[[:space:]]*iPhone/ && /\([A-Fa-f0-9-]{36}\)/ {
        name=$0
        sub(/^[[:space:]]*/, "", name)
        sub(/ \([A-Fa-f0-9-]{36}\).*/, "", name)
        if (os != "") {
          print name "|" os
          exit
        }
      }
    '
  )"

  SIMULATOR_NAME="${SIMULATOR_SELECTION%%|*}"
  SIMULATOR_OS="${SIMULATOR_SELECTION#*|}"

  if [[ -z "$SIMULATOR_NAME" || -z "$SIMULATOR_OS" || "$SIMULATOR_SELECTION" == "$SIMULATOR_NAME" ]]; then
    echo "No available iPhone simulator found."
    xcrun simctl list devices available || true
    exit 1
  fi

  SIMULATOR_DESTINATION="platform=iOS Simulator,name=$SIMULATOR_NAME,OS=$SIMULATOR_OS"
fi

echo "Using destination: $SIMULATOR_DESTINATION"

xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  "${COMMON_FLAGS[@]}" \
  -destination "$SIMULATOR_DESTINATION" \
  -derivedDataPath "$DERIVED_DATA_PATH" \
  "$ACTION"
