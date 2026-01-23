# project_lessons.md

## 2026-01-23
- **Ошибка:** `swift build` как "проверка совместимости" для iOS-пакета с `SwiftLintBuildToolPlugin` даёт ложные падения из-за валидации платформ внутри SwiftLint при кросс-сборке.
- **Решение:** В качестве проверки для 1.1 использовать `xcodebuild -resolvePackageDependencies` (эквивалент Xcode "Resolve Package Versions") и держать iOS deployment target консистентным между app target и SPM `platforms`.
- **Урок:** Для пакетов, где `SwiftLint` подключён как build-tool plugin, "валидность" проверяем через Xcode-resolve/сборку схемы, а не через `swift build --triple`.

- **Правило:** Для проверки компиляции использовать симулятор iPhone 17 Pro iOS 26.2 (23C54) с идентификатором `F8F50881-5D0E-49DA-AA54-1312A752EED9`. Команда: `xcodebuild -project surebet-calculator.xcodeproj -scheme surebet-calculator -destination 'id=F8F50881-5D0E-49DA-AA54-1312A752EED9' build`

## 2026-01-24
- **Ошибка:** После создания файлов констант проект не собирался из-за:
  1. Trailing whitespace в файлах констант (ворнинги линтера)
  2. Превышение длины строки (line_length violation)
  3. Отсутствие зависимости Onboarding от SurebetCalculator при использовании AppConstants
  4. Отсутствие вложенного enum Layout в AppConstants
- **Решение:**
  1. Удалил trailing whitespace из всех файлов констант
  2. Разбил длинные строки на несколько строк
  3. Создал отдельный OnboardingConstants.swift для модуля Onboarding (чтобы избежать циклических зависимостей)
  4. Добавил вложенный enum Layout в AppConstants для группировки Padding, Heights и CornerRadius
- **Урок:** 
  1. Всегда проверяй сборку проекта и ворнинги линтера перед коммитом
  2. При создании констант учитывай архитектуру модулей - не создавай циклических зависимостей
  3. Используй `read_lints` для проверки ворнингов линтера
  4. Проверяй сборку командой `xcodebuild` перед завершением задачи
