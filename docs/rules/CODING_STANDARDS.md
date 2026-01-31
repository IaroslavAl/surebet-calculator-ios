# Coding Standards

## Swift 6 Concurrency

| Паттерн | Применение | Пример |
|---------|-----------|--------|
| `@MainActor class` | ViewModel | `@MainActor final class RootViewModel: ObservableObject` |
| `@MainActor protocol` | UI-сервисы | `@MainActor protocol ReviewService: Sendable` |
| `Sendable struct` | Модели, pure services | `struct Row: Equatable, Sendable` |
| `@MainActor class` / `actor` | Сервисы с UI/side-effects/кэшем | `@MainActor final class ReviewHandler: ReviewService` |
| `@unchecked Sendable` | Struct с URLSession/UserDefaults | `struct Service: BannerService, @unchecked Sendable` |
| `nonisolated(unsafe)` | Read-only системные свойства | `nonisolated(unsafe) static var isIPad` |

**Правила:**
- Все ViewModel — `@MainActor final class: ObservableObject`
- Единственная точка входа во ViewModel из View и тестов — `send(_:)`. Все остальные методы ViewModel должны быть `private`/`fileprivate` и вызываться только внутри ViewModel.
- Для раннего выхода (early return) предпочитать `guard` (когда это повышает читаемость), избегать каскада `if { return }`.
- Все модели данных — `Sendable`
- Все сервисные протоколы — `Sendable`
- Реализации сервисов: value type preferred; class допустимы при SDK/UI/side-effects/кэше (см. `docs/architecture/DATA_FLOW.md`)
- `nonisolated(unsafe)` только для UIDevice workaround

---

## Naming Conventions

### Файлы

| Категория | Паттерн | Пример |
|-----------|---------|--------|
| Public API модуля | `ModuleName.swift` | `Banner.swift` |
| ViewModel | `ModuleNameViewModel.swift` | `RootViewModel.swift` |
| View | `ModuleNameView.swift` | `SurebetCalculatorView.swift` |
| Service протокол | `ServiceName.swift` | `CalculationService.swift` |
| Service реализация | `DefaultServiceName.swift` | `DefaultCalculationService.swift` |
| Extension | `Type+Feature.swift` | `View+Device.swift` |
| Mock | `MockServiceName.swift` | `MockCalculationService.swift` |

### Типы и свойства

```swift
// Boolean — is/has/should/can prefix
var isON: Bool
var shouldShowOnboarding: Bool

// Коллекции — множественное число
var rows: [Row]

// @Published — ВСЕГДА private(set)
@Published private(set) var total: TotalRow

// Методы — глагол в начале
func send(_ action: ViewAction)
func calculate()
```

---

## Folder Structure

```
Sources/ModuleName/
├── ModuleName.swift           # Public API (enum с static func view())
├── ModuleNameConstants.swift
├── Models/
├── ViewModels/
├── Views/
│   ├── Buttons/
│   └── Components/
├── Calculator/                # Бизнес-логика (optional)
├── Extensions/
├── Styles/
└── Resources/
    ├── Assets.xcassets/
    └── Localizable.xcstrings
```

---

## MARK Sections

**ViewModel:**
```swift
// MARK: - Properties
// MARK: - Initialization
// MARK: - Public Methods
// MARK: - Private Methods (через private extension)
```

**View:**
```swift
// MARK: - Properties
// MARK: - Body
// MARK: - Private Methods (через private extension)
```

---

## Code Style

| Правило | Пример |
|---------|--------|
| `private extension` вместо private методов (production) | `private extension SomeView { }` |
| Init с параметрами на отдельных строках | `init(\n  param1,\n  param2\n)` |
| Enum для констант | `AppConstants.Padding.large` |
| WORKAROUND комментарии | `// WORKAROUND: описание + ссылка` |

---

## Scope: Production vs Tests

**Production (Sources):** приватная логика — через `private extension`.
```swift
final class FeatureViewModel {
    func send(_ action: Action) { ... }
}

private extension FeatureViewModel {
    func calculate() { ... }
}
```

**Tests (Tests):** допускается `private func` для helper-методов.
```swift
@MainActor
struct FeatureTests {
    private func makeViewModel() -> FeatureViewModel { FeatureViewModel() }
}
```

**Scope-правило:** `private extension` обязательно для `Sources/`, но не требуется для `Tests/`. В тестах предпочитаем простые `private func` helpers, чтобы не раздувать шаблон. См. `docs/testing/TESTING_STRATEGY.md`.

---

## Bindings

- **Правило:** Binding из ViewModel — через `Binding(get:set:)`, не `$viewModel.prop`.

```swift
Binding(
    get: { viewModel.isOnboardingShown },
    set: { viewModel.updateOnboardingShown($0) }
)
```

---

## Localization

- **Формат:** String Catalogs (`.xcstrings`)
- **Языки:** EN (source), RU
- **API:** `String(localized: "Key")`

```swift
// Правильно
Text(String(localized: "Done"))

// Неправильно — хардкод
Text("Done")
```

---

## Git Conventions

### Ветки
```
<тип>/<описание-через-дефисы>

feature/add-user-settings
fix/calculator-total-calculation
refactor/extract-banner-service
docs/update-readme
test/add-viewmodel-tests
```

### Коммиты (Conventional Commits)
```
<тип>: <описание на русском>

feat: добавить экран настроек
fix: исправить расчёт итоговой суммы
refactor: вынести логику баннера в сервис
docs: обновить README
test: добавить тесты для RootViewModel
```

**Правила:**
- Описание с маленькой буквы
- Без точки в конце
- Повелительное наклонение
- До 50 символов

---

## Documentation

- **Язык:** Русский
- **Формат:** Swift Doc (`///`)
- **Содержание:** Описывать *почему*, а не *что*

```swift
/// Сервис работы с баннерами.
/// Обеспечивает инверсию зависимостей для тестирования.
public protocol BannerService: Sendable {
    /// Загружает баннер и изображение с сервера.
    func fetchBannerAndImage() async throws
}
```
