# System Context — SurebetCalculator

Карта проекта для ИИ‑агента. Если есть противоречия, приоритет у `docs/rules/*` и `docs/architecture/*`.

## Быстрые факты

| | |
|---|---|
| **Swift** | 6.0 (strict concurrency) |
| **iOS** | 16.0+ |
| **Архитектура** | MVVM + Services + DI |
| **Package Manager** | SPM (монорепо в `SurebetCalculatorPackage/`) |
| **Тесты** | Swift Testing (`import Testing`) |

## Структура репозитория
- `SurebetCalculator/` — iOS app target
- `SurebetCalculatorPackage/` — Sources и Tests модулей
- `SurebetCalculatorUITests/` — UI‑тесты

## Модули (кратко)
- `Root` — entry point и координация
- `SurebetCalculator` — бизнес‑логика калькулятора
- `Banner` — баннеры (сеть, кэш, UI)
- `Onboarding` — онбординг
- `ReviewHandler` — запрос отзывов
- `AnalyticsManager` — типобезопасная аналитика

Подробнее: `docs/architecture/MODULES.md`.

## Ключевые точки входа

| Назначение | Файл |
|---|---|
| App entry | `SurebetCalculator/SurebetCalculatorApp.swift` |
| Root UI | `SurebetCalculatorPackage/Sources/Root/RootView.swift` |
| Root VM | `SurebetCalculatorPackage/Sources/Root/RootViewModel.swift` |
| Calculator logic | `SurebetCalculatorPackage/Sources/SurebetCalculator/Calculator/` |
| Banner service | `SurebetCalculatorPackage/Sources/Banner/` |
| Package config | `SurebetCalculatorPackage/Package.swift` |

## Архитектура и паттерны (очень коротко)
- MVVM + `send(_:)` как единая точка входа во ViewModel.
- DI через `init`: параметр = протокол, дефолт = реализация.
- UI‑состояние через `@Published private(set)`.
- Аналитика — только через `AnalyticsEvent`.

Подробнее: `docs/architecture/DATA_FLOW.md` и `docs/rules/CODING_STANDARDS.md`.

## Источники правды в коде
- Версии зависимостей: `SurebetCalculatorPackage/Package.swift`.
- Навигация и условия показа: `RootView`/`RootViewModel`.
- Каталог аналитики: `AnalyticsManager/AnalyticsEvent`.

---

Последнее обновление: 2026-02-05
