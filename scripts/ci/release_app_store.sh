#!/usr/bin/env bash
set -euo pipefail

PROJECT="surebet-calculator.xcodeproj"
SCHEME="surebet-calculator"
CONFIGURATION="Release"
COMMON_FLAGS=(
  -skipPackagePluginValidation
  -skipMacroValidation
)

TEMP_ROOT="${RUNNER_TEMP:-/tmp}"
ARCHIVE_PATH="${ARCHIVE_PATH:-${TEMP_ROOT}/surebet-calculator.xcarchive}"
EXPORT_PATH="${EXPORT_PATH:-${TEMP_ROOT}/export}"
KEYCHAIN_PATH="${TEMP_ROOT}/appstore-signing.keychain-db"
CERTIFICATE_PATH="${TEMP_ROOT}/distribution.p12"
PROFILE_PATH="${TEMP_ROOT}/appstore.mobileprovision"
PROFILE_PLIST_PATH="${TEMP_ROOT}/appstore-profile.plist"
ASC_KEY_PATH="${TEMP_ROOT}/AuthKey_${APP_STORE_CONNECT_KEY_ID:-missing}.p8"
EXPORT_OPTIONS_PATH="${TEMP_ROOT}/ExportOptions.plist"

required_vars=(
  APP_STORE_CONNECT_KEY_ID
  APP_STORE_CONNECT_ISSUER_ID
  APP_STORE_CONNECT_API_KEY
  IOS_DISTRIBUTION_CERT_BASE64
  IOS_DISTRIBUTION_CERT_PASSWORD
  IOS_PROVISIONING_PROFILE_BASE64
  KEYCHAIN_PASSWORD
)

missing_vars=()
for var_name in "${required_vars[@]}"; do
  if [[ -z "${!var_name:-}" ]]; then
    missing_vars+=("$var_name")
  fi
done

if [[ ${#missing_vars[@]} -gt 0 ]]; then
  echo "Missing required environment variables: ${missing_vars[*]}"
  exit 1
fi

if [[ "${GITHUB_ACTIONS:-}" == "true" ]]; then
  for secret_name in \
    APP_STORE_CONNECT_KEY_ID \
    APP_STORE_CONNECT_ISSUER_ID \
    APP_STORE_CONNECT_API_KEY \
    IOS_DISTRIBUTION_CERT_BASE64 \
    IOS_DISTRIBUTION_CERT_PASSWORD \
    IOS_PROVISIONING_PROFILE_BASE64 \
    KEYCHAIN_PASSWORD \
    APPMETRICA_API_KEY; do
    if [[ -n "${!secret_name:-}" ]]; then
      echo "::add-mask::${!secret_name}"
    fi
  done
fi

decode_base64_to_file() {
  local input="$1"
  local output_path="$2"

  if base64 --help 2>&1 | grep -q -- '--decode'; then
    printf '%s' "$input" | base64 --decode > "$output_path"
  else
    printf '%s' "$input" | base64 -D > "$output_path"
  fi
}

bump_patch_version() {
  local version="$1"
  IFS='.' read -r major minor patch <<<"$version"

  if [[ -z "${major:-}" || -z "${minor:-}" || -z "${patch:-}" ]]; then
    echo "Invalid marketing version for auto bump: $version"
    exit 1
  fi

  if ! [[ "$major" =~ ^[0-9]+$ && "$minor" =~ ^[0-9]+$ && "$patch" =~ ^[0-9]+$ ]]; then
    echo "Marketing version must be numeric semantic version X.Y.Z: $version"
    exit 1
  fi

  local next_patch=$((patch + 1))
  echo "${major}.${minor}.${next_patch}"
}

cleanup() {
  rm -f "$CERTIFICATE_PATH" "$PROFILE_PATH" "$PROFILE_PLIST_PATH" "$ASC_KEY_PATH" "$EXPORT_OPTIONS_PATH"
  if security list-keychains -d user | tr -d '"' | grep -Fq "$KEYCHAIN_PATH"; then
    security delete-keychain "$KEYCHAIN_PATH" >/dev/null 2>&1 || true
  fi
}
trap cleanup EXIT

echo "Preparing signing assets"
rm -rf "$ARCHIVE_PATH" "$EXPORT_PATH"
mkdir -p "$EXPORT_PATH"

decode_base64_to_file "$IOS_DISTRIBUTION_CERT_BASE64" "$CERTIFICATE_PATH"
decode_base64_to_file "$IOS_PROVISIONING_PROFILE_BASE64" "$PROFILE_PATH"
printf '%s' "$APP_STORE_CONNECT_API_KEY" > "$ASC_KEY_PATH"
chmod 600 "$ASC_KEY_PATH"

security create-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH"
security set-keychain-settings -lut 21600 "$KEYCHAIN_PATH"
security unlock-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH"
EXISTING_KEYCHAINS="$(security list-keychains -d user | tr -d '\"')"
security list-keychains -d user -s "$KEYCHAIN_PATH" $EXISTING_KEYCHAINS
security default-keychain -d user -s "$KEYCHAIN_PATH"

security import "$CERTIFICATE_PATH" \
  -k "$KEYCHAIN_PATH" \
  -P "$IOS_DISTRIBUTION_CERT_PASSWORD" \
  -T /usr/bin/codesign \
  -T /usr/bin/security \
  -T /usr/bin/xcodebuild
security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k "$KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH"

mkdir -p "$HOME/Library/MobileDevice/Provisioning Profiles"
security cms -D -i "$PROFILE_PATH" > "$PROFILE_PLIST_PATH"
PROFILE_UUID="$(/usr/libexec/PlistBuddy -c 'Print UUID' "$PROFILE_PLIST_PATH")"
PROFILE_NAME="$(/usr/libexec/PlistBuddy -c 'Print Name' "$PROFILE_PLIST_PATH")"
PROFILE_TEAM_IDENTIFIER="$(/usr/libexec/PlistBuddy -c 'Print TeamIdentifier:0' "$PROFILE_PLIST_PATH")"
PROFILE_APP_IDENTIFIER="$(/usr/libexec/PlistBuddy -c 'Print Entitlements:application-identifier' "$PROFILE_PLIST_PATH")"
cp "$PROFILE_PATH" "$HOME/Library/MobileDevice/Provisioning Profiles/${PROFILE_UUID}.mobileprovision"

echo "Resolving project build settings"
BUILD_SETTINGS="$(xcodebuild -project "$PROJECT" -scheme "$SCHEME" -configuration "$CONFIGURATION" -showBuildSettings)"
CURRENT_MARKETING_VERSION="$(awk -F ' = ' '/ MARKETING_VERSION = / { print $2; exit }' <<<"$BUILD_SETTINGS" | tr -d '[:space:]')"
DEVELOPMENT_TEAM="$(awk -F ' = ' '/ DEVELOPMENT_TEAM = / { print $2; exit }' <<<"$BUILD_SETTINGS" | tr -d '[:space:]')"
BUNDLE_IDENTIFIER="$(awk -F ' = ' '/ PRODUCT_BUNDLE_IDENTIFIER = / { print $2; exit }' <<<"$BUILD_SETTINGS" | tr -d '[:space:]')"

if [[ -z "$CURRENT_MARKETING_VERSION" || -z "$DEVELOPMENT_TEAM" || -z "$BUNDLE_IDENTIFIER" ]]; then
  echo "Failed to resolve MARKETING_VERSION, DEVELOPMENT_TEAM or PRODUCT_BUNDLE_IDENTIFIER from build settings"
  exit 1
fi

if [[ "$PROFILE_TEAM_IDENTIFIER" != "$DEVELOPMENT_TEAM" ]]; then
  echo "Provisioning profile team mismatch. Profile team: $PROFILE_TEAM_IDENTIFIER, project team: $DEVELOPMENT_TEAM"
  exit 1
fi

EXPECTED_PROFILE_APP_IDENTIFIER="${PROFILE_TEAM_IDENTIFIER}.${BUNDLE_IDENTIFIER}"
if [[ "$PROFILE_APP_IDENTIFIER" == *"*" ]]; then
  PROFILE_APP_IDENTIFIER_PREFIX="${PROFILE_APP_IDENTIFIER%\*}"
  if [[ "$EXPECTED_PROFILE_APP_IDENTIFIER" != ${PROFILE_APP_IDENTIFIER_PREFIX}* ]]; then
    echo "Provisioning profile app identifier mismatch. Profile: $PROFILE_APP_IDENTIFIER, expected: $EXPECTED_PROFILE_APP_IDENTIFIER"
    exit 1
  fi
elif [[ "$PROFILE_APP_IDENTIFIER" != "$EXPECTED_PROFILE_APP_IDENTIFIER" ]]; then
  echo "Provisioning profile app identifier mismatch. Profile: $PROFILE_APP_IDENTIFIER, expected: $EXPECTED_PROFILE_APP_IDENTIFIER"
  exit 1
fi

TARGET_MARKETING_VERSION="$CURRENT_MARKETING_VERSION"
if [[ -n "${MARKETING_VERSION_INPUT:-}" ]]; then
  TARGET_MARKETING_VERSION="${MARKETING_VERSION_INPUT}"
elif [[ "${AUTO_BUMP_PATCH:-false}" == "true" ]]; then
  TARGET_MARKETING_VERSION="$(bump_patch_version "$CURRENT_MARKETING_VERSION")"
fi

if [[ "$TARGET_MARKETING_VERSION" != "$CURRENT_MARKETING_VERSION" ]]; then
  echo "Updating MARKETING_VERSION: $CURRENT_MARKETING_VERSION -> $TARGET_MARKETING_VERSION"
  xcrun agvtool new-marketing-version "$TARGET_MARKETING_VERSION"
else
  echo "Keeping MARKETING_VERSION: $CURRENT_MARKETING_VERSION"
fi

if [[ -n "${BUILD_NUMBER_OVERRIDE:-}" ]]; then
  TARGET_BUILD_NUMBER="${BUILD_NUMBER_OVERRIDE}"
  if ! [[ "$TARGET_BUILD_NUMBER" =~ ^[0-9]+$ ]]; then
    echo "Build number override must contain only digits: $TARGET_BUILD_NUMBER"
    exit 1
  fi
else
  if [[ -n "${GITHUB_RUN_NUMBER:-}" ]]; then
    # Keep default build numbers strictly increasing for App Store Connect.
    TARGET_BUILD_NUMBER="${GITHUB_RUN_NUMBER}.${GITHUB_RUN_ATTEMPT:-1}"
  else
    TARGET_BUILD_NUMBER="$(date +%s)"
  fi
fi

if ! [[ "$TARGET_BUILD_NUMBER" =~ ^[0-9]+(\.[0-9]+){0,2}$ ]]; then
  echo "Build number must be numeric (for example: 1234 or 1234.1): $TARGET_BUILD_NUMBER"
  exit 1
fi

echo "Updating CURRENT_PROJECT_VERSION to $TARGET_BUILD_NUMBER"
xcrun agvtool new-version -all "$TARGET_BUILD_NUMBER"

cat > "$EXPORT_OPTIONS_PATH" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>method</key>
  <string>app-store-connect</string>
  <key>signingStyle</key>
  <string>manual</string>
  <key>provisioningProfiles</key>
  <dict>
    <key>${BUNDLE_IDENTIFIER}</key>
    <string>${PROFILE_NAME}</string>
  </dict>
  <key>teamID</key>
  <string>${DEVELOPMENT_TEAM}</string>
  <key>uploadSymbols</key>
  <true/>
  <key>compileBitcode</key>
  <false/>
</dict>
</plist>
EOF

echo "Resolving package dependencies"
xcodebuild -resolvePackageDependencies -project "$PROJECT" "${COMMON_FLAGS[@]}"

echo "Archiving release build"
ARCHIVE_CMD=(
  xcodebuild
  -project "$PROJECT"
  -scheme "$SCHEME"
  -configuration "$CONFIGURATION"
  "${COMMON_FLAGS[@]}"
  -destination 'generic/platform=iOS'
  -archivePath "$ARCHIVE_PATH"
  -allowProvisioningUpdates
  -authenticationKeyPath "$ASC_KEY_PATH"
  -authenticationKeyID "$APP_STORE_CONNECT_KEY_ID"
  -authenticationKeyIssuerID "$APP_STORE_CONNECT_ISSUER_ID"
)
if [[ -n "${APPMETRICA_API_KEY:-}" ]]; then
  ARCHIVE_CMD+=("APPMETRICA_API_KEY=${APPMETRICA_API_KEY}")
fi
ARCHIVE_CMD+=(archive)
"${ARCHIVE_CMD[@]}"

echo "Exporting IPA"
xcodebuild -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportPath "$EXPORT_PATH" \
  -exportOptionsPlist "$EXPORT_OPTIONS_PATH"

IPA_PATH="$(find "$EXPORT_PATH" -maxdepth 1 -type f -name '*.ipa' -print -quit)"
if [[ -z "$IPA_PATH" ]]; then
  echo "IPA export failed: no .ipa found in $EXPORT_PATH"
  exit 1
fi

echo "Uploading IPA to App Store Connect"
export API_PRIVATE_KEYS_DIR
API_PRIVATE_KEYS_DIR="$(dirname "$ASC_KEY_PATH")"
xcrun altool \
  --upload-app \
  -f "$IPA_PATH" \
  -t ios \
  --apiKey "$APP_STORE_CONNECT_KEY_ID" \
  --apiIssuer "$APP_STORE_CONNECT_ISSUER_ID" \
  --show-progress

FINAL_BUILD_SETTINGS="$(xcodebuild -project "$PROJECT" -scheme "$SCHEME" -configuration "$CONFIGURATION" -showBuildSettings)"
FINAL_MARKETING_VERSION="$(awk -F ' = ' '/ MARKETING_VERSION = / { print $2; exit }' <<<"$FINAL_BUILD_SETTINGS" | tr -d '[:space:]')"
FINAL_BUILD_NUMBER="$(awk -F ' = ' '/ CURRENT_PROJECT_VERSION = / { print $2; exit }' <<<"$FINAL_BUILD_SETTINGS" | tr -d '[:space:]')"

echo "Release upload completed"
echo "MARKETING_VERSION=$FINAL_MARKETING_VERSION"
echo "CURRENT_PROJECT_VERSION=$FINAL_BUILD_NUMBER"
echo "IPA_PATH=$IPA_PATH"

if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
  {
    echo "## App Store Connect Release"
    echo
    echo "- MARKETING_VERSION: $FINAL_MARKETING_VERSION"
    echo "- CURRENT_PROJECT_VERSION: $FINAL_BUILD_NUMBER"
    echo "- IPA: $IPA_PATH"
  } >> "$GITHUB_STEP_SUMMARY"
fi
