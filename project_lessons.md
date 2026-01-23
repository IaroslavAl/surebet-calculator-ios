# project_lessons.md

## 2026-01-23
- **Ошибка:** `swift build` как "проверка совместимости" для iOS-пакета с `SwiftLintBuildToolPlugin` даёт ложные падения из-за валидации платформ внутри SwiftLint при кросс-сборке.
- **Решение:** В качестве проверки для 1.1 использовать `xcodebuild -resolvePackageDependencies` (эквивалент Xcode "Resolve Package Versions") и держать iOS deployment target консистентным между app target и SPM `platforms`.
- **Урок:** Для пакетов, где `SwiftLint` подключён как build-tool plugin, "валидность" проверяем через Xcode-resolve/сборку схемы, а не через `swift build --triple`.

- **Правило:** Для проверки компиляции использовать симулятор iPhone 17 Pro iOS 26.2 (23C54) с идентификатором `F8F50881-5D0E-49DA-AA54-1312A752EED9`. Команда: `xcodebuild -project surebet-calculator.xcodeproj -scheme surebet-calculator -destination 'id=F8F50881-5D0E-49DA-AA54-1312A752EED9' build`

