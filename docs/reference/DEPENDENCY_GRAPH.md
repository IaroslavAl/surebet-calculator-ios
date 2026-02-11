# DEPENDENCY GRAPH

Источник: `SurebetCalculatorPackage/Package.swift`.

```mermaid
graph TD
    Root --> SurebetCalculator
    Root --> Banner
    Root --> MainMenu
    Root --> Onboarding
    Root --> Settings
    Root --> ReviewHandler
    Root --> Survey
    Root --> FeatureToggles
    Root --> AnalyticsManager
    Root --> DesignSystem
    Root --> AppMetricaCore

    MainMenu --> SurebetCalculator
    MainMenu --> Settings
    MainMenu --> DesignSystem

    SurebetCalculator --> Banner
    SurebetCalculator --> DesignSystem

    Banner --> AnalyticsManager
    Banner --> SDWebImageSwiftUI
    Banner --> DesignSystem

    Onboarding --> DesignSystem
    Settings --> DesignSystem
    Survey --> DesignSystem

    AnalyticsManager --> AppMetricaCore
```

## Внешние зависимости
- `appmetrica-sdk-ios` (`AppMetricaCore`)
- `SDWebImageSwiftUI`
- `SwiftLint` (`SwiftLintBuildToolPlugin`)

## Правила
- Любые изменения зависимостей сначала в `Package.swift`.
- Нельзя добавлять неиспользуемые пакетные зависимости.
- Для всех targets подключать SwiftLint plugin консистентно.

Последнее обновление: 2026-02-11
