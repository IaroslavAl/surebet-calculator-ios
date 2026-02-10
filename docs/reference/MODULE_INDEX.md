# MODULE INDEX

Краткие контракты модулей и их ответственность.

## Root
- Public API: `Root.view()`.
- Роль: композиция модулей, onboarding/review/fullscreen-banner/survey orchestration.
- Важные файлы:
  - `SurebetCalculatorPackage/Sources/Root/Root.swift`
  - `SurebetCalculatorPackage/Sources/Root/RootView.swift`
  - `SurebetCalculatorPackage/Sources/Root/RootViewModel.swift`

## MainMenu
- Public API: `MainMenu.view(calculatorAnalytics:)`.
- Роль: первый экран и переходы в разделы.

## SurebetCalculator
- Public API: `SurebetCalculator.view(analytics:)`.
- Роль: состояние калькулятора, выбор режима расчета, бизнес-логика.

## Banner
- Public API:
  - `Banner.bannerView`
  - `Banner.fullscreenBannerView(isPresented:)`
  - `Banner.fetchBanner()`
  - `Banner.isBannerFullyCached`
- Роль: inline/fullscreen баннеры, сеть `/banner`, кэш модели и изображения.

## Survey
- Public API:
  - `Survey.sheet(survey:onSubmit:onClose:)`
  - `SurveyService`, `RemoteSurveyService`, `MockSurveyService`
  - `SurveyModel`, `SurveySubmission`
- Роль: in-app опросы, динамические поля, валидация required/optional, mock/remote data source.

## Onboarding
- Public API: `Onboarding.view(onboardingIsShown:analytics:)`.
- Роль: flow онбординга, аналитика шагов и завершения.

## Settings
- Public API: `Settings.view()`.
- Роль: тема/язык и соответствующее хранение состояния.

## ReviewHandler
- Public API: `ReviewHandler.requestReview()`.
- Роль: изолированный вызов системного review prompt.

## AnalyticsManager
- Public API: `AnalyticsService`, `AnalyticsManager`, `AnalyticsEvent`.
- Роль: типобезопасные события и адаптер к AppMetrica (включая survey events).

## DesignSystem
- Public API: `DesignSystem` + токены/базовые компоненты.
- Роль: единые визуальные константы и адаптивные helper-ы.

## Правило изменений контрактов
Если меняется public API модуля:
1. Обновить этот файл.
2. Обновить релевантный playbook.
3. Добавить ADR при изменении архитектурного решения.

Последнее обновление: 2026-02-06
