# POLICIES

Обязательные правила для изменений в коде. Формат:
- `MUST` — строго обязательно.
- `SHOULD` — рекомендуется, отклонение требует причины.

## 1. Архитектура
- MUST: придерживаться `MVVM + Services + DI`.
- MUST: ViewModel — `@MainActor final class` + `ObservableObject`.
- MUST: единая публичная точка действий ViewModel — `send(_:)`.
- MUST: остальные mutating-методы ViewModel должны быть `private/fileprivate`.
- SHOULD: логику side-effects выносить в сервисы.

## 2. State и concurrency
- MUST: `@Published` поля во ViewModel только `private(set)`.
- MUST: модели и сервисные протоколы должны быть `Sendable`.
- SHOULD: реализации сервисов по умолчанию `struct`; `class/actor` только при обосновании.
- MUST: учитывать Swift 6 strict concurrency при API UIKit/Foundation.
- MUST: в action-сеттерах, которые вызываются из `Binding` (`set*Presented`, `set*Enabled` и т.п.), перед присваиванием проверять `newValue != currentValue`, чтобы не публиковать no-op обновления.
- MUST: в hot-path UI (например, ввод в `TextField`, частые `onChange`) не выполнять тяжелые синхронные вычисления на `MainActor` без short-circuit.
- MUST: перед запуском расчета из `send(_:)` проверять, что вход действительно изменился; no-op действия не должны запускать пересчет.
- SHOULD: не публиковать через `@Published` в root ViewModel состояние, которое не читается напрямую корневым View.
- SHOULD: в вычислениях избегать повторного парсинга/повторных проходов по одним и тем же данным в рамках одного действия.

## 3. UI и локализация
- MUST: UI-строки только через `String(localized:)`.
- MUST: не добавлять новые hardcoded user-facing строки.
- SHOULD: большие `View` декомпозировать на компоненты.

## 4. DI и границы слоев
- MUST: зависимости передаются через `init`.
- MUST: сигнатуры инициализаторов — протоколы, defaults — боевые реализации.
- MUST: View не собирает вручную сложные зависимости.
- MUST: для экранов, открываемых через `NavigationLink`, orchestration-события root-уровня (показ sheet/overlay, аналитические события входа в раздел) не запускать из destination `.onAppear`; источник — tap/navigation state на стороне экрана-источника.

## 5. Тестирование
- MUST: использовать `Swift Testing` (`import Testing`) для package-тестов.
- MUST: если SUT `@MainActor`, тесты тоже `@MainActor`.
- MUST: не использовать `Thread.sleep`/`Task.sleep` в тестах.
- SHOULD: для shared state (`UserDefaults`) использовать сериализацию suite.

## 6. Проверка изменений
- MUST: минимум `xcodebuild ... build`.
- MUST: при изменениях ViewModel/Services/Tests запускать `xcodebuild ... test`.
- MUST: успешный критерий — `TEST SUCCEEDED`.

## 7. Документация
- MUST: если меняется архитектурный контракт, обновить `docs/reference/MODULE_INDEX.md`.
- MUST: если меняется порядок сборки/проверок, обновить `docs/reference/BUILD_TEST_COMMANDS.md`.
- SHOULD: при архитектурном решении добавить ADR в `docs/decisions/`.

## 8. Source of truth
- Версии зависимостей: `SurebetCalculatorPackage/Package.swift`.
- Модульные контракты: `docs/reference/MODULE_INDEX.md`.
- Команды проверки: `docs/reference/BUILD_TEST_COMMANDS.md`.
- CI-контракт: `docs/reference/CI_RULES.md`.

## 9. CI
- MUST: использовать только GitHub-hosted runners.
- MUST: поддерживать обязательные проверки в CI:
  - `SwiftLint`,
  - `Build`,
  - `Unit Tests`,
  - `Validate Docs Structure`.
- MUST: при изменении CI-контракта обновлять `docs/reference/CI_RULES.md`.
- SHOULD: переиспользуемую CI-логику выносить в `scripts/ci/*`.

Последнее обновление: 2026-02-10
