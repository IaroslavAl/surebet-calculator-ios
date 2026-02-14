# MODULE INDEX

Краткие контракты модулей и их ответственность.

## Root
- Public API:
  - `Root.view(container:)`
  - `AppContainer.live(userDefaults:)`
- Роль: композиция модулей, data-driven push navigation (`NavigationStack(path:)`) и orchestration onboarding/review.
- Важные файлы:
  - `SurebetCalculatorPackage/Sources/Root/Root.swift`
  - `SurebetCalculatorPackage/Sources/Root/DI/AppContainer.swift`
  - `SurebetCalculatorPackage/Sources/Root/RootView.swift`
  - `SurebetCalculatorPackage/Sources/Root/RootViewModel.swift`

## FeatureToggles
- Public API:
  - `FeatureKey`
  - `FeatureFlags`
  - `FeatureFlagsProvider`
  - `DefaultFeatureFlagsProvider`
  - `FeatureFlagOverrideStore`
- Роль: единый источник фич-флагов (launch arguments + persisted overrides в `UserDefaults`) и подготовка к управлению из debug menu.
- Поведение: `DefaultFeatureFlagsProvider` делает snapshot на старте; после изменения override требуется переинициализация зависимостей (обычно перезапуск экрана/приложения).

## MainMenu
- Public API:
  - `MainMenuSection`
  - `MainMenuRoute`
  - `MainMenu.view(onRouteRequested:)`
  - `MainMenu.instructionsView()`
- Роль: первый экран-меню с route events; push-destination orchestration выполняется в `Root`.

## SurebetCalculator
- Public API:
  - `SurebetCalculator.Dependencies`
  - `SurebetCalculator.view(dependencies:)`
- Роль: состояние калькулятора, выбор режима расчета, бизнес-логика.

## Onboarding
- Public API: `Onboarding.view(onboardingIsShown:analytics:)`.
- Роль: flow онбординга, аналитика шагов и завершения.

## Settings
- Public API:
  - `Settings.Dependencies`
  - `Settings.view(dependencies:)`
  - `ThemeStore`, `UserDefaultsThemeStore`
  - `LanguageStoreAdapter`
- Роль: тема/язык и соответствующее хранение состояния.

## ReviewHandler
- Public API: `ReviewHandler.requestReview()`.
- Роль: изолированный вызов системного review prompt.

## AnalyticsManager
- Public API: `AnalyticsService`, `AnalyticsManager`, `AnalyticsEvent`.
- Роль: типобезопасные события и адаптер к AppMetrica.

## DesignSystem
- Public API: `DesignSystem` + токены/базовые компоненты.
- Роль: единые визуальные константы и адаптивные helper-ы.

## Правило изменений контрактов
Если меняется public API модуля:
1. Обновить этот файл.
2. Обновить релевантный playbook.
3. Добавить ADR при изменении архитектурного решения.

Последнее обновление: 2026-02-14
