# AGENTS.md — SurebetCalculator

## TL;DR
Проект: iOS 16+ / Swift 6 (strict concurrency), архитектура MVVM + Services + DI, SPM monorepo.
Источники правды по правилам и архитектуре см. в docs/*.
Если есть противоречия — приоритет у `docs/rules/*` и `docs/architecture/*`.

## Как проверять изменения (обязательно)
1) Сборка:
   xcodebuild -project surebet-calculator.xcodeproj -scheme surebet-calculator \
     -destination 'id=F8F50881-5D0E-49DA-AA54-1312A752EED9' build

2) Тесты (если менялись тесты или VM/Services):
   xcodebuild test -project surebet-calculator.xcodeproj -scheme surebet-calculator \
     -destination 'id=F8F50881-5D0E-49DA-AA54-1312A752EED9'

Критерий: TEST SUCCEEDED.

Важно: для пакетов со SwiftLintBuildToolPlugin не использовать `swift build`,
а использовать xcodebuild -resolvePackageDependencies / сборку схемы.

## Код-стиль и архитектура (коротко)
- ViewModel: @MainActor final class ObservableObject
- @Published всегда private(set)
- Модели: Sendable
- Сервисные протоколы: Sendable
- Локализация: только String(localized:), без хардкода
- Большие View дробить на компоненты

## Тесты
- Framework: Swift Testing (import Testing)
- Если VM @MainActor — тесты тоже @MainActor
- Shared state (UserDefaults) — @Suite(.serialized)
- MockURLProtocol: потокобезопасный registry по full URL, без глобального handler

## Документация
- Язык: русский
- Для публичного API: Swift Doc (///) с объяснением “почему”, а не “что”

## Ссылки (источники правды)
- System context: docs/system/SYSTEM_CONTEXT.md
- Coding standards: docs/rules/CODING_STANDARDS.md
- Testing strategy: docs/testing/TESTING_STRATEGY.md
- Lessons learned: docs/rules/PROJECT_LESSONS.md
- Data flow: docs/architecture/DATA_FLOW.md
- Modules: docs/architecture/MODULES.md
