# Surebet Calculator

![Surebet Calculator Demo](SurebetCalculator.gif)

**Surebet Calculator** — iOS‑приложение для расчёта сурбетов (вилок): распределяет ставки по исходам так, чтобы обеспечить прибыль при валидных коэффициентах.

## ✨ Возможности
- 2–20 исходов для расчёта.
- Автоматический выбор метода вычислений:
  - по общей ставке,
  - по конкретной строке,
  - по сумме ставок в строках.
- Расчёт процента прибыли и дохода по каждому исходу.
- Онбординг на 3 шага.
- Inline и fullscreen‑баннеры.
- Запрос отзывов (Release‑only, после 2‑го запуска).
- Аналитика событий (AppMetrica).
- Адаптация под iPhone/iPad и локализация через `.xcstrings`.

## 🧭 Архитектура
- MVVM + Services + DI.
- Swift 6 (strict concurrency), `Sendable` для моделей и сервисов.
- SPM монорепо: `SurebetCalculatorPackage/`.
- Единственный публичный продукт — `Root`.

## 🧩 Модули
- `Root` — входная точка и координация модулей.
- `MainMenu` — экран меню и переходы по разделам.
- `Settings` — настройки темы и языка.
- `SurebetCalculator` — калькулятор и бизнес‑логика.
- `Banner` — inline/fullscreen баннеры, сеть и кэш.
- `Onboarding` — онбординг.
- `ReviewHandler` — запрос отзывов.
- `AnalyticsManager` — типобезопасная аналитика.

## ⚙️ Сборка и запуск

**Требования:** Xcode 15+, Swift 6.0, iOS 16+.

```bash
# Сборка
xcodebuild -project surebet-calculator.xcodeproj -scheme surebet-calculator \
  -destination 'id=F8F50881-5D0E-49DA-AA54-1312A752EED9' build

# Тесты
xcodebuild test -project surebet-calculator.xcodeproj -scheme surebet-calculator \
  -destination 'id=F8F50881-5D0E-49DA-AA54-1312A752EED9'
```

Важно: для пакетов со `SwiftLintBuildToolPlugin` не использовать `swift build`. Проверка — через `xcodebuild -resolvePackageDependencies` или сборку схемы.

## 🧪 Тестирование
- Framework: Swift Testing (`import Testing`).
- Unit/Integration тесты — в `SurebetCalculatorPackage/Tests`.
- UI‑тесты — в `SurebetCalculatorUITests/`.

## 🌍 Локализация
- String Catalogs (`.xcstrings`).
- Основные файлы:
  - `SurebetCalculatorPackage/Sources/SurebetCalculator/Resources/Localizable.xcstrings`
  - `SurebetCalculatorPackage/Sources/Onboarding/Resources/Localizable.xcstrings`
  - `SurebetCalculatorPackage/Sources/MainMenu/Resources/Localizable.xcstrings`
  - `SurebetCalculatorPackage/Sources/Root/Resources/Localizable.xcstrings`

## 📚 Документация для разработки
- `AGENTS.md` — инструкция для ИИ‑агентов.
- `docs/system/SYSTEM_CONTEXT.md` — системная карта.
- `docs/rules/CODING_STANDARDS.md` — код‑стиль.
- `docs/architecture/DATA_FLOW.md` — потоки данных.
- `docs/architecture/MODULES.md` — модули и зависимости.
- `docs/testing/TESTING_STRATEGY.md` — тестирование.
- `docs/rules/PROJECT_LESSONS.md` — уроки проекта.

## 📦 Зависимости
Единственный источник версий: `SurebetCalculatorPackage/Package.swift`.

- AppMetrica SDK
- SDWebImageSwiftUI
- SwiftLint (Build Tool Plugin)
