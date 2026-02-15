# Surebet Calculator

![Surebet Calculator Demo](SurebetCalculator.gif)

iOS-приложение для расчета surebet-стратегий (вилок): распределяет ставки по исходам так, чтобы при валидных коэффициентах получить гарантированный положительный результат.

## Что умеет приложение
- Расчет для 2-20 исходов.
- Несколько сценариев ввода: через общую ставку, через выбранную строку или через сумму строк.
- Расчет прибыли и дохода по каждому исходу.
- Онбординг, настройки темы/языка, аналитика событий и review prompt.

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

UI-тесты:
```bash
xcodebuild test -project surebet-calculator.xcodeproj -scheme surebet-calculator \
  -testPlan surebet-calculator-ui-tests \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest'
```

## CI parity (локально перед PR)
```bash
./scripts/ci/secret_scan.sh
./scripts/ci/swiftlint_ci.sh
./scripts/ci/xcode_ci.sh build
./scripts/ci/xcode_ci.sh test
./scripts/ci/xcode_ci.sh test-ui
./scripts/validate-docs.sh
```

## Конфигурация и секреты
- Ключ AppMetrica не хранится в коде/схемах. Источник: `AppMetricaApiKey` в `Info.plist` (через build setting `APPMETRICA_API_KEY`) или env `APPMETRICA_API_KEY`/`AppMetrica_Key` при запуске.
- Если ключ не задан, приложение запускается без активации AppMetrica.
- Для проверки репозитория на hardcoded секреты используйте `./scripts/ci/secret_scan.sh`.
- Для CI добавьте секрет `APPMETRICA_API_KEY` (например, в GitHub Actions Secrets). `scripts/ci/xcode_ci.sh` использует его через environment variable (без хранения в репозитории/схеме).

Пример release-архива с подстановкой ключа (для CI):
```bash
xcodebuild -project surebet-calculator.xcodeproj -scheme surebet-calculator \
  -configuration Release -destination 'generic/platform=iOS' \
  APPMETRICA_API_KEY="$APPMETRICA_API_KEY" \
  archive -archivePath build/surebet-calculator.xcarchive
```

## Зависимости
Источник версий: `SurebetCalculatorPackage/Package.swift`.

- AppMetrica SDK
- SwiftLint (Build Tool Plugin)

## Важно
Для этого проекта не использовать `swift build` (из-за `SwiftLintBuildToolPlugin`).
