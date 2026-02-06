# Coding Standards

Документ‑источник правил код‑стиля. Не дублирует тестовые и архитектурные детали.

## Swift 6 Concurrency

| Паттерн | Применение | Пример |
|---|---|---|
| `@MainActor final class` | ViewModel | `@MainActor final class RootViewModel: ObservableObject` |
| `@MainActor protocol` | UI‑сервисы | `@MainActor protocol ReviewService: Sendable` |
| `Sendable struct` | Модели, pure services | `struct Row: Equatable, Sendable` |
| `actor` | Shared mutable state | `actor Cache { }` |
| `@unchecked Sendable` | Для URLSession/UserDefaults | `struct Service: @unchecked Sendable` |
| `nonisolated(unsafe)` | Только для UIDevice workaround | `nonisolated(unsafe) static var isIPad` |

**Ключевые правила:**
- Все ViewModel — `@MainActor final class: ObservableObject`.
- Модели и сервисные протоколы — `Sendable`.
- Реализации сервисов: value type по умолчанию, `class/actor` только при SDK/UI/side‑effects/кэше.

## ViewModel и DI
- Единственная точка входа во ViewModel из View и тестов — `send(_:)`.
- Все прочие методы ViewModel должны быть `private`/`fileprivate`.
- View не создаёт ViewModel с зависимостями; сборка — в factory/entry‑point.
- `@Published` всегда `private(set)`.

## Bindings
- Binding из ViewModel — через `Binding(get:set:)`, не `$viewModel.prop`.
- Не передавать Binding в ViewModel как `wrappedValue` и `set`.
- Для presentation state допускается адаптер на уровне entry‑point.

## Локализация
- Только String Catalogs (`.xcstrings`).
- В UI использовать `String(localized:)`.
- Хардкод строк запрещён.

## Naming Conventions

### Файлы
| Категория | Паттерн | Пример |
|---|---|---|
| Public API модуля | `ModuleName.swift` | `Banner.swift` |
| ViewModel | `ModuleNameViewModel.swift` | `RootViewModel.swift` |
| View | `ModuleNameView.swift` | `SurebetCalculatorView.swift` |
| Service протокол | `ServiceName.swift` | `CalculationService.swift` |
| Service реализация | `DefaultServiceName.swift` | `DefaultCalculationService.swift` |
| Extension | `Type+Feature.swift` | `View+Device.swift` |
| Mock | `MockServiceName.swift` | `MockCalculationService.swift` |

### Типы и свойства
- Boolean: префиксы `is/has/should/can`.
- Коллекции — множественное число.
- Методы — глагол в начале.

## Структура модулей (рекомендуемая)
```
Sources/ModuleName/
├── ModuleName.swift
├── ModuleNameConstants.swift
├── Models/
├── ViewModels/
├── Views/
├── Extensions/
├── Styles/
└── Resources/
    ├── Assets.xcassets/
    └── Localizable.xcstrings
```

## Code Style
- `private extension` для приватной логики в `Sources/`.
- Инициализаторы с параметрами на отдельных строках.
- Константы группировать через `enum/struct`.
- WORKAROUND комментарии формата `// WORKAROUND: описание + ссылка`.

## TODO и техдолг
- Используем только формат `TODO:` / `FIXME:` с кратким описанием причины.
- Перед релизом и перед закрытием задачи проверяем `TODO` в изменённых файлах.
- В проекте включено предупреждение SwiftLint для `todo`.

**MARK‑порядок:**
- ViewModel: `Properties → Initialization → Public Methods → Private Methods`.
- View: `Properties → Body → Private Methods`.

## Git Conventions

**Ветки:** `<тип>/<описание-через-дефисы>`
- `feature/add-user-settings`
- `fix/calculator-total-calculation`
- `docs/update-readme`

**Коммиты (Conventional Commits):** `<тип>: <описание на русском>`
- Описание: с маленькой буквы, без точки, повелительное наклонение, до 50 символов.

## Документация
- Вся документация и комментарии — на русском.
- Публичный API документировать через Swift Doc (`///`) с объяснением «почему».
