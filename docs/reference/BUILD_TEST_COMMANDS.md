# BUILD AND TEST COMMANDS

Каноничные команды проверки проекта.

## Resolve dependencies
```bash
xcodebuild -resolvePackageDependencies -project surebet-calculator.xcodeproj
```

## Build
```bash
xcodebuild -project surebet-calculator.xcodeproj -scheme surebet-calculator \
  -destination 'id=F8F50881-5D0E-49DA-AA54-1312A752EED9' build
```

## Tests
```bash
xcodebuild test -project surebet-calculator.xcodeproj -scheme surebet-calculator \
  -destination 'id=F8F50881-5D0E-49DA-AA54-1312A752EED9'
```

## CI parity commands (recommended before PR)
```bash
./scripts/ci/swiftlint_ci.sh
./scripts/ci/xcode_ci.sh build
./scripts/ci/xcode_ci.sh test
./scripts/validate-docs.sh
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

## Ограничения
- Не использовать `swift build` (из-за `SwiftLintBuildToolPlugin`).

## Связанные документы
- `docs/reference/CI_RULES.md`

Последнее обновление: 2026-02-07
