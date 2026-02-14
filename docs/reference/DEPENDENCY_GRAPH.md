# DEPENDENCY GRAPH

Источник: `SurebetCalculatorPackage/Package.swift`.

```mermaid
graph TD
    Root --> SurebetCalculator
    Root --> MainMenu
    Root --> Onboarding
    Root --> Settings
    Root --> ReviewHandler
    Root --> FeatureToggles
    Root --> AnalyticsManager
    Root --> DesignSystem
    Root --> AppMetricaCore

    MainMenu --> DesignSystem

    SurebetCalculator --> DesignSystem

    Onboarding --> DesignSystem
    Settings --> DesignSystem

    AnalyticsManager --> AppMetricaCore
```

## Внешние зависимости
- `appmetrica-sdk-ios` (`AppMetricaCore`)
- `SwiftLint` (`SwiftLintBuildToolPlugin`)

## Правила
- Любые изменения зависимостей сначала в `Package.swift`.
- Нельзя добавлять неиспользуемые пакетные зависимости.
- Для всех targets подключать SwiftLint plugin консистентно.

Последнее обновление: 2026-02-14
