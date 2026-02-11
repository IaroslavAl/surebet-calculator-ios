# PROJECT MAP

Карта репозитория и точек входа.

## Корневые директории
- `SurebetCalculator/` — iOS app target (app entry).
- `SurebetCalculatorPackage/` — package с модулями и тестами.
- `SurebetCalculatorUITests/` — UI-тесты приложения.
- `docs/` — документация для агентов и разработчиков.

## Ключевые файлы
- App entry: `SurebetCalculator/SurebetCalculatorApp.swift`
- Package config: `SurebetCalculatorPackage/Package.swift`
- Root module API: `SurebetCalculatorPackage/Sources/Root/Root.swift`
- Root VM: `SurebetCalculatorPackage/Sources/Root/RootViewModel.swift`
- Calculator VM: `SurebetCalculatorPackage/Sources/SurebetCalculator/ViewModels/SurebetCalculatorViewModel.swift`

## Где что менять
- Навигация/оркестрация экранов: `Sources/Root/*`.
- Главное меню и маршруты разделов: `Sources/MainMenu/*`.
- Калькулятор и расчет: `Sources/SurebetCalculator/*`.
- Баннеры, сеть, кэш: `Sources/Banner/*`.
- Онбординг: `Sources/Onboarding/*`.
- Настройки языка/темы: `Sources/Settings/*`.
- Фича-флаги и overrides: `Sources/FeatureToggles/*`.
- In-app опросы: `Sources/Survey/*`.
- Review flow: `Sources/ReviewHandler/*`.
- Аналитика: `Sources/AnalyticsManager/*`.
- Дизайн-токены/базовые компоненты: `Sources/DesignSystem/*`.

## Тестовые директории
- `SurebetCalculatorPackage/Tests/RootTests/*`
- `SurebetCalculatorPackage/Tests/SurebetCalculatorTests/*`
- `SurebetCalculatorPackage/Tests/BannerTests/*`
- `SurebetCalculatorPackage/Tests/OnboardingTests/*`
- `SurebetCalculatorPackage/Tests/ReviewHandlerTests/*`
- `SurebetCalculatorPackage/Tests/AnalyticsManagerTests/*`
- `SurebetCalculatorPackage/Tests/SurveyTests/*`

Последнее обновление: 2026-02-11
