# Surebet Calculator

![Surebet Calculator Demo](SurebetCalculator.gif)

iOS-приложение для расчета surebet-стратегий (вилок): распределяет ставки по исходам так, чтобы при валидных коэффициентах получить гарантированный положительный результат.

## Что умеет приложение
- Расчет для 2-20 исходов.
- Несколько сценариев ввода: через общую ставку, через выбранную строку или через сумму строк.
- Расчет прибыли и дохода по каждому исходу.
- Онбординг, настройки темы/языка, аналитика событий, баннеры и review prompt.

## Технологии
- iOS 16+
- Swift 6 (strict concurrency)
- SwiftUI
- Архитектура: MVVM + Services + DI
- Монорепозиторий на Swift Package Manager (`SurebetCalculatorPackage/`)

## Структура проекта
- `SurebetCalculator/` — app target.
- `SurebetCalculatorPackage/` — бизнес-модули и unit/integration тесты.
- `SurebetCalculatorUITests/` — UI-тесты.

## Сборка
```bash
xcodebuild -project surebet-calculator.xcodeproj -scheme surebet-calculator \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' build
```

## Тесты
```bash
xcodebuild test -project surebet-calculator.xcodeproj -scheme surebet-calculator \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest'
```

## Зависимости
Источник версий: `SurebetCalculatorPackage/Package.swift`.

- AppMetrica SDK
- SDWebImageSwiftUI
- SwiftLint (Build Tool Plugin)

## Важно
Для этого проекта не использовать `swift build` (из-за `SwiftLintBuildToolPlugin`).
