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

### Типобезопасные события

Все события аналитики определены в `AnalyticsEvent` enum:

```swift
// Использование типобезопасного события
analyticsService.log(event: .reviewResponse(enjoyingApp: true))
analyticsService.log(event: .bannerClicked(bannerId: "123", bannerType: .fullscreen))
analyticsService.log(event: .calculatorRowAdded(rowCount: 3))
```

### Каталог событий

| Категория | Событие | Где | Параметры |
|-----------|---------|-----|-----------|
| **Onboarding** | `onboarding_started` | OnboardingViewModel | — |
| | `onboarding_page_viewed` | OnboardingViewModel | `page_index: Int`, `page_title: String` |
| | `onboarding_completed` | OnboardingViewModel | `pages_viewed: Int` |
| | `onboarding_skipped` | OnboardingViewModel | `last_page_index: Int` |
| **Calculator** | `calculator_row_added` | SurebetCalculatorViewModel | `row_count: Int` |
| | `calculator_row_removed` | SurebetCalculatorViewModel | `row_count: Int` |
| | `calculator_cleared` | SurebetCalculatorViewModel | — |
| | `calculation_performed` | SurebetCalculatorViewModel | `row_count: Int`, `profit_percentage: Double` |
| **Banner** | `banner_viewed` | BannerView, FullscreenBannerView | `banner_id: String`, `banner_type: String` |
| | `banner_clicked` | BannerView, FullscreenBannerView | `banner_id: String`, `banner_type: String` |
| | `banner_closed` | BannerView, FullscreenBannerView | `banner_id: String`, `banner_type: String` |
| **Review** | `review_prompt_shown` | RootViewModel | — |
| | `review_response` | RootViewModel | `enjoying_app: Bool` |
| **App** | `app_opened` | RootViewModel | `session_number: Int` |

### Правила

- **DI через init:** Всегда используй `AnalyticsService` протокол через DI, не статические методы
- **Типобезопасность:** Используй `AnalyticsEvent` enum вместо строковых названий
- **Параметры:** Все параметры типобезопасны через `AnalyticsParameterValue`
- **Release only:** `#if !DEBUG` — события логируются только в Release сборке
- **Названия:** События в snake_case для AppMetrica (автоматически из enum)

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
