# Data Flow

## MVVM Architecture

```
View (SwiftUI) → ViewModel (@MainActor, ObservableObject) → Service (Protocol)
                     ↓
              @Published state
                     ↓
                View updates
```

### Роли компонентов

| Слой | Ответственность | Property Wrappers |
|------|-----------------|-------------------|
| **View** | UI-рендеринг, передача действий | `@StateObject`, `@EnvironmentObject` |
| **ViewModel** | Состояние, бизнес-логика | `@Published private(set)`, `@AppStorage` |
| **Service** | Чистая логика без состояния | Protocol + struct, `Sendable` |

---

## ViewAction Pattern

Все действия пользователя проходят через единый `send(_ action:)`:

```swift
enum ViewAction {
    case selectRow(RowType)
    case addRow
    case setTextFieldText(FocusableField, String)
    case clearAll
}

func send(_ action: ViewAction) {
    switch action {
    case let .selectRow(row): select(row)
    case .addRow: addRow()
    case let .setTextFieldText(field, text):
        set(field, text: text)
        calculate()  // → Service
    case .clearAll: clearAll()
    }
}
```

**Преимущества:** единая точка входа, типобезопасность, тестируемость.

---

## Dependency Injection

Constructor Injection с дефолтными значениями:

```swift
init(
    analyticsService: AnalyticsService = AnalyticsManager(),
    reviewService: ReviewService = ReviewHandler()
) {
    self.analyticsService = analyticsService
    self.reviewService = reviewService
}
```

**Правила:**
- Параметр = протокол, дефолт = реализация
- `private let` для хранения
- Тесты передают Mock

---

## State Management

| Wrapper | Где | Когда |
|---------|-----|-------|
| `@Published private(set)` | ViewModel | Состояние для UI |
| `@StateObject` | Корневой View | Создание/владение ViewModel |
| `@ObservedObject` | ViewModifier | Наблюдение без владения |
| `@EnvironmentObject` | Child View | Доступ через иерархию |
| `@AppStorage` | ViewModel | Персистентное (UserDefaults) |
| `@Binding` | Child View | Двусторонняя связь |
| `@FocusState` | View | Управление фокусом |

**Binding из ViewModel:**
```swift
Binding(
    get: { viewModel.isOnboardingShown },
    set: { viewModel.updateOnboardingShown($0) }
)
```

---

## Banner Network Flow

```
App Launch → .task { Banner.fetchBanner() }
    ↓
GET /banner → BannerModel → UserDefaults
    ↓
GET imageURL → Data → UserDefaults
    ↓
Banner.isBannerFullyCached → true
    ↓
FullscreenBannerView ← UIImage(data:)
```

### Стратегия кэширования

| Событие | Действие |
|---------|----------|
| Новый `imageURL` | Скачать изображение |
| URL не изменился | Использовать кэш |
| Ошибка сети | Очистить весь кэш |

```swift
func isBannerFullyCached() -> Bool {
    getBannerFromDefaults() != nil && getStoredBannerImageData() != nil
}
```

---

## Analytics Flow

```swift
// Типобезопасные параметры
analyticsService.log(
    name: "RequestReview",
    parameters: ["enjoying_calculator": .bool(true)]
)
```

**Каталог событий:**

| Событие | Где | Параметры |
|---------|-----|-----------|
| `RequestReview` | RootViewModel | `enjoying_calculator: Bool` |
| `OpenedBanner(\(id))` | FullscreenBannerView | — |
| `ClosedBanner(\(id))` | FullscreenBannerView | — |

**Правила:**
- DI через init, не статические методы
- `#if !DEBUG` — только в Release
- `AnalyticsParameterValue` enum для типобезопасности

---

## Navigation

Условный рендеринг вместо NavigationPath:

```swift
var body: some View {
    Group {
        if viewModel.isOnboardingShown {
            calculatorView
        } else {
            onboardingView
        }
    }
}
```

**Overlays:**
```swift
.overlay {
    if viewModel.fullscreenBannerIsPresented {
        Banner.fullscreenBannerView(isPresented: $viewModel.fullscreenBannerIsPresented)
            .transition(.move(edge: .bottom))
    }
}
```
