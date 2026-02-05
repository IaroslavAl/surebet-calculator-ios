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

| Слой | Ответственность | Типичные свойства |
|---|---|---|
| **View** | UI‑рендеринг, отправка действий | `@StateObject`, `@EnvironmentObject` |
| **ViewModel** | Состояние, бизнес‑логика | `@Published private(set)`, `@AppStorage` |
| **Service** | Логика + side‑effects | Protocol + `Sendable` |

## ViewAction Pattern

Все пользовательские действия проходят через `send(_:)`:

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
        calculate()
    case .clearAll: clearAll()
    }
}
```

## Dependency Injection

Constructor Injection с дефолтами:

```swift
init(
    analyticsService: AnalyticsService = AnalyticsManager(),
    reviewService: ReviewService = ReviewHandler()
)
```

Правило: параметр — протокол, дефолт — реализация.

## State Management

| Wrapper | Где | Когда |
|---|---|---|
| `@Published private(set)` | ViewModel | Состояние для UI |
| `@StateObject` | Корневой View | Владение VM |
| `@EnvironmentObject` | Child View | Доступ через иерархию |
| `@AppStorage` | ViewModel | Персистентное состояние |
| `@FocusState` | View | Фокус полей |

Binding из ViewModel — через `Binding(get:set:)` (см. `docs/rules/CODING_STANDARDS.md`).

## Banner Flow (кратко)
- На старте приложения — `fetchBanner()`.
- Кэшируется модель баннера и изображение в `UserDefaults`.
- `isBannerFullyCached` истинно только если кэш есть и для модели, и для изображения.
- При сетевой ошибке кэш очищается целиком.

## Analytics Flow (кратко)
- Источник правды: `AnalyticsEvent` в `AnalyticsManager`.
- Логирование только в Release (`#if !DEBUG`).
- Параметры — типобезопасные (`AnalyticsParameterValue`).

## Navigation
- Навигация через условный рендеринг в Root.
- Полноэкранные баннеры — через `.overlay` и `.transition(.move(edge: .bottom))`.
