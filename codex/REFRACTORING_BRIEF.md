# Codex Refactoring Brief

## 1. Общий контекст проекта

* iOS-приложение, iOS 16+
* Swift 6, strict concurrency **включён**
* Архитектура: **MVVM + Services + DI**
* SPM monorepo

**Источник правды (приоритет):**

1. `docs/rules/*`
2. `docs/architecture/*`
3. `SYSTEM_CONTEXT.md`

Любые изменения должны соответствовать этим документам. Если есть конфликт — следовать им, а не предположениям Codex.

---

## 2. Архитектурные правила (обязательные)

### 2.1 ViewModel

* Только `@MainActor final class : ObservableObject`
* Все observable-свойства:

  ```swift
  @Published private(set) var state: State
  ```
* ViewModel **не содержит** UIKit / SwiftUI типов
* Любые действия пользователя — только через:

  ```swift
  func send(_ action: Action)
  ```

### 2.2 View → ViewModel

* **Запрещено:** `$viewModel.property`
* **Разрешено:** только

  ```swift
  Binding(
    get: { viewModel.value },
    set: { viewModel.send(.valueChanged($0)) }
  )
  ```

### 2.3 Data Flow

* View → `send(ViewAction)`
* ViewModel:

  * обрабатывает action
  * вызывает сервисы
  * обновляет state
* View **никогда** не вызывает сервисы напрямую

---

## 3. Dependency Injection (DI)

* Только **constructor injection**
* Тип параметра — **протокол**
* Default value — **production-реализация**
* Хранение зависимостей:

  ```swift
  private let service: SomeServiceProtocol
  ```

Пример:

```swift
init(service: SomeServiceProtocol = SomeService()) {
  self.service = service
}
```

---

## 4. Swift 6 Concurrency (строго)

### 4.1 ViewModel

* Всегда `@MainActor`
* Никаких `DispatchQueue.main.async`

### 4.2 Модели

* Все value-типы → `Sendable`
* Reference-типы — только если есть:

  * side-effects
  * cache
  * SDK / system API

### 4.3 Сервисы

* Протоколы сервисов → `Sendable`
* Реализации:

  * `struct` — по умолчанию
  * `class` / `actor` — только при необходимости

⚠️ **Запрещено:** «лечить» `Sendable` warnings через SwiftLint или игнорирование.

---

## 5. Модули и зависимости

* Модули образуют **DAG**
* Циклические зависимости **запрещены**
* Изменения не должны нарушать граф модулей, описанный в `MODULES.md`

---

## 6. Локализация

* **Строгий запрет** хардкода строк
* Только:

  ```swift
  String(localized: "key")
  ```
* Использовать `.xcstrings`
* UI-тексты, accessibility, errors — всё локализуется

---

## 7. Стиль и scope

### 7.1 Production code (`Sources/`)

* Вспомогательная логика — через:

  ```swift
  private extension Type { ... }
  ```
* Минимальный `internal` scope

### 7.2 Tests (`Tests/`)

* Допустимы `private func helpers()`
* Production-код не должен становиться `internal` ради тестов

---

## 8. Тестирование

### 8.1 Фреймворк

* Только **Swift Testing**

  ```swift
  import Testing
  @Test
  #expect(...)
  ```

### 8.2 Concurrency в тестах

* Если ViewModel `@MainActor` → тесты тоже `@MainActor`

### 8.3 Shared state

* При использовании `UserDefaults`:

  ```swift
  @Suite(.serialized)
  ```

### 8.4 MockURLProtocol

* **Запрещено:** один глобальный `requestHandler`
* **Обязательно:** registry по full URL (`URL.absoluteString`)
* Registry должен быть потокобезопасным (lock / actor)

Причина: параллельные тесты и race conditions.

---

## 9. Правила рефакторинга

* Только **behavior-preserving refactor**, если не указано иное
* Маленькие итерации (один модуль / одна проблема)
* Удалять код **только если точно не используется** (проверка usages)
* В конце каждой итерации:

  * список изменённых файлов
  * краткое объяснение "почему"

---

## 10. Валидация (обязательна после каждой итерации)

### Build

```bash
xcodebuild -project surebet-calculator.xcodeproj \
  -scheme surebet-calculator \
  -destination 'id=F8F50881-5D0E-49DA-AA54-1312A752EED9' build
```

### Tests (если менялись VM / Services / Tests)

```bash
xcodebuild test -project surebet-calculator.xcodeproj \
  -scheme surebet-calculator \
  -destination 'id=F8F50881-5D0E-49DA-AA54-1312A752EED9'
```

⚠️ Не использовать `swift build` для пакетов со SwiftLint Build Tool Plugin.

---

## 11. Формат работы Codex

Для каждой задачи Codex должен:

1. Сначала проанализировать нарушения правил
2. Сделать минимальные изменения
3. Не расширять область задачи
4. Выдать:

   * список файлов
   * краткое обоснование решений

**Codex — инструмент рефакторинга, не архитектор.**
