# AGENTS.md — SurebetCalculator

## Назначение
Краткий оперативный гайд для ИИ‑агента. Детальные правила и архитектура — в `docs/*`.

## Приоритет источников
1. `docs/rules/*`
2. `docs/architecture/*`
3. `docs/testing/*`
4. `docs/system/SYSTEM_CONTEXT.md`
5. `README.md`

## Быстрые факты
- iOS 16+, Swift 6 (strict concurrency)
- Архитектура: MVVM + Services + DI
- SPM монорепо: `SurebetCalculatorPackage/`
- Тесты: Swift Testing (`import Testing`)

## Обязательная проверка изменений
```bash
xcodebuild -project surebet-calculator.xcodeproj -scheme surebet-calculator \
  -destination 'id=F8F50881-5D0E-49DA-AA54-1312A752EED9' build

# Если менялись тесты или ViewModel/Services
xcodebuild test -project surebet-calculator.xcodeproj -scheme surebet-calculator \
  -destination 'id=F8F50881-5D0E-49DA-AA54-1312A752EED9'
```
Критерий успеха: `TEST SUCCEEDED`.

Важно: для пакетов со `SwiftLintBuildToolPlugin` не использовать `swift build`. Проверка — через `xcodebuild -resolvePackageDependencies` или сборку схемы.

## Критические правила (минимум)
- ViewModel: `@MainActor final class ObservableObject`, точка входа — `send(_:)`.
- `@Published` всегда `private(set)`.
- Модели и сервисные протоколы — `Sendable`.
- UI‑строки — только `String(localized:)`.
- Большие `View` дробить на компоненты.
- В тестах запрещён `Thread.sleep`/`Task.sleep`.

## Куда смотреть
- Системная карта: `docs/system/SYSTEM_CONTEXT.md`
- Код‑стиль: `docs/rules/CODING_STANDARDS.md`
- Архитектура и потоки: `docs/architecture/DATA_FLOW.md`
- Модули и зависимости: `docs/architecture/MODULES.md`
- Тестирование: `docs/testing/TESTING_STRATEGY.md`
- Уроки проекта: `docs/rules/PROJECT_LESSONS.md`
