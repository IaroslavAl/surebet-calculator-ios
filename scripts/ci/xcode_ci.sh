#!/usr/bin/env bash
set -euo pipefail

ACTION="${1:-}"

if [[ "$ACTION" != "build" && "$ACTION" != "test" && "$ACTION" != "test-ui" ]]; then
  echo "Usage: $0 <build|test|test-ui>"
  exit 1
fi

PROJECT="surebet-calculator.xcodeproj"
SCHEME="surebet-calculator"
DERIVED_DATA_PATH="${DERIVED_DATA_PATH:-${RUNNER_TEMP:-/tmp}/DerivedData}"
COMMON_FLAGS=(
  -skipPackagePluginValidation
  -skipMacroValidation
)
XCODE_BUILD_SETTINGS=()

if [[ -n "${APPMETRICA_API_KEY:-}" ]]; then
  if [[ "${GITHUB_ACTIONS:-}" == "true" ]]; then
    echo "::add-mask::${APPMETRICA_API_KEY}"
  fi
  XCODE_BUILD_SETTINGS+=("APPMETRICA_API_KEY=${APPMETRICA_API_KEY}")
  echo "APPMETRICA_API_KEY is provided and will be passed to xcodebuild."
else
  echo "APPMETRICA_API_KEY is not set. Build will use default project value."
fi

RESOLVE_CMD=(
  xcodebuild
  -resolvePackageDependencies
  -project "$PROJECT"
  "${COMMON_FLAGS[@]}"
)
"${RESOLVE_CMD[@]}"

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

XCODE_ACTION="$ACTION"
TEST_PLAN_NAME=""
if [[ "$ACTION" == "test-ui" ]]; then
  XCODE_ACTION="test"
  TEST_PLAN_NAME="surebet-calculator-ui-tests"
fi

if [[ -n "$TEST_PLAN_NAME" ]]; then
  BUILD_CMD=(
    xcodebuild
    -project "$PROJECT"
    -scheme "$SCHEME"
    "${COMMON_FLAGS[@]}"
    -testPlan "$TEST_PLAN_NAME"
    -destination "$SIMULATOR_DESTINATION"
    -derivedDataPath "$DERIVED_DATA_PATH"
  )
else
  BUILD_CMD=(
    xcodebuild
    -project "$PROJECT"
    -scheme "$SCHEME"
    "${COMMON_FLAGS[@]}"
    -destination "$SIMULATOR_DESTINATION"
    -derivedDataPath "$DERIVED_DATA_PATH"
  )
fi

if [[ ${#XCODE_BUILD_SETTINGS[@]} -gt 0 ]]; then
  BUILD_CMD+=("${XCODE_BUILD_SETTINGS[@]}")
fi
BUILD_CMD+=("$XCODE_ACTION")

"${BUILD_CMD[@]}"
