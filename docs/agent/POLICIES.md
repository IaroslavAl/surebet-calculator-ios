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

## 3. UI и локализация
- MUST: UI-строки только через `String(localized:)`.
- MUST: не добавлять новые hardcoded user-facing строки.
- SHOULD: большие `View` декомпозировать на компоненты.

## 4. DI и границы слоев
- MUST: зависимости передаются через `init`.
- MUST: сигнатуры инициализаторов — протоколы, defaults — боевые реализации.
- MUST: View не собирает вручную сложные зависимости.

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

Последнее обновление: 2026-02-06
