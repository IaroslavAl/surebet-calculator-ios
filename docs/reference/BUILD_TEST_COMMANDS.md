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

## Когда запускать что
- Всегда: `build`.
- Обязательно `test`, если изменялись:
  - ViewModel,
  - Service,
  - test-код,
  - код в потоках/конкурентности,
  - контракт публичного API модулей.

## Ограничения
- Не использовать `swift build` (из-за `SwiftLintBuildToolPlugin`).

Последнее обновление: 2026-02-06
