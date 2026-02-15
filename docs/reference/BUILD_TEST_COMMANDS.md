# BUILD AND TEST COMMANDS

Каноничные команды проверки проекта.

## Resolve dependencies
```bash
xcodebuild -resolvePackageDependencies -project surebet-calculator.xcodeproj
```

## Build
```bash
xcodebuild -project surebet-calculator.xcodeproj -scheme surebet-calculator \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' build
```

## Tests
```bash
xcodebuild test -project surebet-calculator.xcodeproj -scheme surebet-calculator \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest'
```
По умолчанию запускается package test plan (`SurebetCalculatorPackage/Tests/surebet-calculator.xctestplan`), включая `FeatureTogglesTests`.

## UI Tests
```bash
xcodebuild test -project surebet-calculator.xcodeproj -scheme surebet-calculator \
  -testPlan surebet-calculator-ui-tests \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest'
```

Через скрипт:
```bash
./scripts/ci/xcode_ci.sh test-ui
```

## CI parity commands (recommended before PR)
```bash
./scripts/ci/swiftlint_ci.sh
./scripts/ci/secret_scan.sh
./scripts/ci/xcode_ci.sh build
./scripts/ci/xcode_ci.sh test
./scripts/ci/xcode_ci.sh test-ui
./scripts/validate-docs.sh
```

`scripts/ci/xcode_ci.sh` автоматически использует `APPMETRICA_API_KEY`, если переменная окружения задана.

## Release archive (CI-friendly)
```bash
xcodebuild -project surebet-calculator.xcodeproj -scheme surebet-calculator \
  -configuration Release -destination 'generic/platform=iOS' \
  APPMETRICA_API_KEY="$APPMETRICA_API_KEY" \
  archive -archivePath build/surebet-calculator.xcarchive
```

## Когда запускать что
- Всегда: `build`.
- Обязательно `test`, если изменялись:
  - ViewModel,
  - Service,
  - test-код,
  - код в потоках/конкурентности,
  - контракт публичного API модулей.
- Перед PR рекомендуется запускать CI parity commands.
- `test-ui` запускать при изменениях в UI, accessibility identifiers и сценариях онбординга/навигации.

## Ограничения
- Не использовать `swift build` (из-за `SwiftLintBuildToolPlugin`).

## Связанные документы
- `docs/reference/CI_RULES.md`

Последнее обновление: 2026-02-15
