# 🧠 System Context — SurebetCalculator

> **Master Context** для LLM-агентов. Компактный обзор с ссылками на детали.

---

## Quick Facts

| | |
|---|---|
| **Swift** | 6.0 (strict concurrency) |
| **iOS** | 16.0+ |
| **Architecture** | MVVM + Service + DI |
| **Package Manager** | SPM (SurebetCalculatorPackage/) |
| **Testing** | Swift Testing (`import Testing`) |

---

## Project Structure

```
SurebetCalculator/           # iOS App target
SurebetCalculatorPackage/    # SPM монорепозиторий
├── Sources/
│   ├── Root/                # Entry point, координация
│   ├── SurebetCalculator/   # Бизнес-логика калькулятора
│   ├── Banner/              # Баннеры (сеть + кэш)
│   ├── Onboarding/          # Онбординг
│   ├── ReviewHandler/       # Запрос отзывов
│   └── AnalyticsManager/    # AppMetrica обёртка
└── Tests/
```

---

## Module Dependencies

```
Root ─┬─► SurebetCalculator ─► Banner
      ├─► Banner ─► AnalyticsManager
      ├─► Onboarding
      ├─► ReviewHandler
      └─► AnalyticsManager ─► AppMetricaCore
```

**📖 Детали:** [architecture/MODULES.md](architecture/MODULES.md)

---

## Core Patterns

### MVVM + ViewAction

```swift
// View
viewModel.send(.selectRow(.row(0)))

// ViewModel
@MainActor final class ViewModel: ObservableObject {
    @Published private(set) var rows: [Row]
    
    func send(_ action: ViewAction) { ... }
}

// Service
protocol CalculationService: Sendable { ... }
```

### Dependency Injection

```swift
init(
    analyticsService: AnalyticsService = AnalyticsManager(),  // Protocol = param
    reviewService: ReviewService = ReviewHandler()            // Impl = default
)
```

**📖 Детали:** [architecture/DATA_FLOW.md](architecture/DATA_FLOW.md)

---

## Swift 6 Concurrency

| Компонент | Атрибут |
|-----------|---------|
| ViewModel | `@MainActor final class` |
| Модели | `struct: Sendable` |
| Сервисы | `protocol: Sendable` |
| UIDevice workaround | `nonisolated(unsafe)` |

**📖 Детали:** [rules/CODING_STANDARDS.md](rules/CODING_STANDARDS.md)

---

## External Dependencies

| Библиотека | Назначение |
|------------|------------|
| AppMetrica SDK 5.11+ | Аналитика |
| SDWebImageSwiftUI 3.1+ | Загрузка изображений |
| SwiftLint 0.59+ | Линтер |

---

## Key Files

| Что | Где |
|-----|-----|
| App entry | `SurebetCalculator/SurebetCalculatorApp.swift` |
| Root coordinator | `Sources/Root/RootView.swift` |
| Calculator logic | `Sources/SurebetCalculator/Calculator/` |
| Banner service | `Sources/Banner/Service.swift` |
| Package config | `SurebetCalculatorPackage/Package.swift` |

---

## Coding Standards (Summary)

- **@Published** — всегда `private(set)`
- **Binding** — через `Binding(get:set:)`, не `$viewModel.prop`
- **Локализация** — `String(localized:)`, никакого хардкода
- **Git** — `feat: описание на русском` (Conventional Commits)

**📖 Детали:** [rules/CODING_STANDARDS.md](rules/CODING_STANDARDS.md)

---

## Testing (Summary)

- **Framework:** Swift Testing (`@Test`, `#expect`)
- **MainActor:** `@MainActor` на тесте если ViewModel MainActor
- **Shared state:** `@Suite(.serialized)` для UserDefaults
- **Mocks:** Hand-written, `@unchecked Sendable`

**📖 Детали:** [testing/TESTING_STRATEGY.md](testing/TESTING_STRATEGY.md)

---

## Documentation Index

| Файл | Содержимое |
|------|------------|
| **[rules/CODING_STANDARDS.md](rules/CODING_STANDARDS.md)** | Swift 6, naming, Git, локализация |
| **[architecture/DATA_FLOW.md](architecture/DATA_FLOW.md)** | MVVM, DI, State, Analytics, Navigation |
| **[architecture/MODULES.md](architecture/MODULES.md)** | Описание модулей и API |
| **[testing/TESTING_STRATEGY.md](testing/TESTING_STRATEGY.md)** | Тесты, моки, паттерны |
| **[../project_lessons.md](../project_lessons.md)** | База знаний об ошибках |

---

## Build Commands

```bash
# Сборка
xcodebuild -project surebet-calculator.xcodeproj \
    -scheme surebet-calculator \
    -destination 'id=F8F50881-5D0E-49DA-AA54-1312A752EED9' \
    build

# Тесты
xcodebuild test -project surebet-calculator.xcodeproj \
    -scheme surebet-calculator \
    -testPlan surebet-calculator
```

---

*Последнее обновление: 2026-01-25*
