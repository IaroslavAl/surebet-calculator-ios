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

- **Ошибка:** При создании моков для тестов возникли проблемы:
  1. Моки для AnalyticsService, ReviewService и BannerService пытались импортировать модули, которые не являются зависимостями тестового таргета SurebetCalculatorTests
  2. Large Tuple Violation в MockCalculationService - кортеж с 4 элементами нарушал правило SwiftLint (максимум 2 элемента)
  3. Все тесты не компилировались из-за ошибок MainActor isolation - SurebetCalculatorViewModel помечен @MainActor, а тесты выполнялись в синхронном контексте
- **Решение:**
  1. Удалил неиспользуемые моки (MockAnalyticsService, MockReviewService, MockBannerService), так как они не нужны для текущих тестов и их модули не являются зависимостями тестового таргета
  2. Заменил кортеж на структуру `CalculateInput` для хранения входных данных вызова calculate
  3. Добавил `@MainActor` к тестовому классу `SurebetCalculatorViewModelTests`, чтобы все тесты выполнялись на главном потоке и имели доступ к MainActor-isolated свойствам и методам ViewModel
- **Урок:**
  1. При создании моков проверяй зависимости тестового таргета в Package.swift - не создавай моки для модулей, которые не являются зависимостями
  2. SwiftLint правило large_tuple ограничивает кортежи максимум 2 элементами - используй структуры для хранения большего количества данных
  3. Всегда проверяй сборку и линтер после создания моков
  4. Если ViewModel помечен @MainActor, тестовый класс тоже должен быть помечен @MainActor, иначе будут ошибки компиляции Swift 6 о MainActor isolation
  5. **КРИТИЧНО:** После любых изменений в тестах ОБЯЗАТЕЛЬНО проверяй компиляцию тестового таргета. Используй команду для сборки тестов или проверяй в Xcode, что тесты компилируются без ошибок. SwiftLint ошибки в тестах (type_body_length, file_length и т.д.) нужно исправлять или отключать через `// swiftlint:disable:next` (не blanket disable)
  6. **Правило:** Перед завершением задачи с тестами всегда проверяй компиляцию тестового таргета через Xcode или xcodebuild, не только основного проекта. Для тестов используй схему `SurebetCalculatorTests` в Xcode или проверяй через Product → Test
  7. **КРИТИЧНО:** После обновления тестов на Swift Testing или любых изменений в тестах ОБЯЗАТЕЛЬНО проверяй не только компиляцию, но и ВЫПОЛНЕНИЕ тестов. Используй команду `xcodebuild test -project surebet-calculator.xcodeproj -scheme surebet-calculator -destination 'id=F8F50881-5D0E-49DA-AA54-1312A752EED9'` для запуска всех тестов. Все тесты должны проходить успешно (TEST SUCCEEDED)
  7. **Ошибка:** UIDevice.current требует MainActor в Swift 6, но используется в nonisolated контексте (View+Device.swift, CalculatorTextFieldStyle и т.д.)
  8. **Решение:** Создать два свойства в Device:
     - `@MainActor static var isIPad: Bool` - для использования из MainActor контекста
     - `nonisolated(unsafe) static var isIPadUnsafe: Bool` - для использования из nonisolated контекста, используя `MainActor.assumeIsolated` для обхода проверки
  9. **Урок:** При использовании UIDevice.current в Swift 6 из nonisolated контекста нужно использовать `MainActor.assumeIsolated` внутри `nonisolated(unsafe)` свойства, так как UIDevice.current безопасен для чтения из любого контекста
