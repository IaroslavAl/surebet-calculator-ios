# AGENTS.md — SurebetCalculator

Оперативная точка входа для AI-агента.

## 1) Порядок чтения (обязательный)
1. `docs/agent/START_HERE.md`
2. `docs/agent/POLICIES.md`
3. Релевантный playbook из `docs/agent/PLAYBOOKS/*`
4. Справочники из `docs/reference/*`
5. `README.md` (только пользовательский контекст)

## 2) Критические инварианты (MUST)
- iOS 16+, Swift 6 strict concurrency.
- Архитектура: MVVM + Services + DI.
- ViewModel: `@MainActor final class ObservableObject`.
- Точка входа во ViewModel: `send(_:)`.
- `@Published` свойства: только `private(set)`.
- Модели и сервисные протоколы: `Sendable`.
- UI-строки: только `String(localized:)`.
- В тестах запрещены `Thread.sleep` и `Task.sleep`.

## 3) Проверка перед сдачей
```bash
xcodebuild -project surebet-calculator.xcodeproj -scheme surebet-calculator \
  -destination 'id=F8F50881-5D0E-49DA-AA54-1312A752EED9' build

# Обязательно, если менялись ViewModel/Services/Tests
xcodebuild test -project surebet-calculator.xcodeproj -scheme surebet-calculator \
  -destination 'id=F8F50881-5D0E-49DA-AA54-1312A752EED9'
```
Критерий успеха: `TEST SUCCEEDED`.

Важно: не использовать `swift build` для пакетов со `SwiftLintBuildToolPlugin`.

## 4) Где искать ответы
- Правила: `docs/agent/POLICIES.md`
- Плейбуки: `docs/agent/PLAYBOOKS/`
- Карта проекта: `docs/reference/PROJECT_MAP.md`
- Модули и контракты: `docs/reference/MODULE_INDEX.md`
- Зависимости и граф: `docs/reference/DEPENDENCY_GRAPH.md`
- Команды сборки/тестов: `docs/reference/BUILD_TEST_COMMANDS.md`
- Инциденты и анти-паттерны: `docs/lessons/INCIDENTS.md`
