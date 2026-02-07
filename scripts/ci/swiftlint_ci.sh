#!/usr/bin/env bash
set -euo pipefail

if ! command -v swiftlint >/dev/null 2>&1; then
  echo "SwiftLint is not installed. Installing via Homebrew..."
  brew install swiftlint
fi

swiftlint version
(
  cd SurebetCalculatorPackage
  swiftlint lint Sources Tests
)
