# TEST_COVERAGE_ROADMAP.md

## 1. Executive Summary

### Текущее покрытие тестами (Coverage Audit)

**Хорошо покрыто:**
- ✅ `Calculator` — базовые сценарии расчета (total, row, none, invalid coefficient, multiple rows)
- ✅ `SurebetCalculatorViewModel` — основные действия (selectRow, setTextFieldText, clear, calculation methods)
- ✅ `OnboardingViewModel` — базовые сценарии (setCurrentPage, dismiss)

**Частично покрыто:**
- ⚠️ `SurebetCalculatorViewModel` — отсутствуют тесты для `addRow`, edge cases для `removeRow`, тесты concurrency
- ⚠️ `OnboardingViewModel` — отсутствуют edge cases

**Полностью отсутствует покрытие:**
- ❌ `DefaultCalculationService` — нет тестов
- ❌ `AnalyticsManager` / `AnalyticsService` — нет тестов и моков
- ❌ `BannerService` — нет тестов и моков
- ❌ `ReviewService` / `ReviewHandler` — нет тестов и моков
- ❌ `RootViewModel` — нет тестов
- ❌ `Double.formatToString()` — нет тестов
- ❌ `String.formatToDouble()` — нет тестов
- ❌ `String.isValidDouble()` — нет тестов
- ❌ `String.isNumberNotNegative()` — нет тестов
- ❌ Edge cases для `Calculator` (нулевые ставки, отрицательные коэффициенты, деление на ноль)
- ❌ Интеграционные тесты (Root -> Calculator flow)
- ❌ UI тесты (Happy Path, Edge Cases)

### Соответствие правилам проекта

Этот план учитывает:
- **`rules.mdc`**: SOLID принципы, Swift 6 Concurrency, Dependency Injection, MainActor isolation
- **`project_lessons.md`**: Правила создания моков, проверка зависимостей тестового таргета, MainActor в тестах, использование структур вместо больших кортежей

---

## 2. Test Strategy Guidelines

### Подход к мокам

**Стратегия:**
- Использовать ручные моки (hand-written mocks) вместо библиотек
- Все моки должны соответствовать протоколам сервисов
- Моки должны быть `Sendable` для Swift 6 concurrency
- Моки должны хранить историю вызовов для проверки в тестах

**Библиотеки:**
- Не используем внешние библиотеки для моков (Swift Testing не требует их)
- Используем нативный Swift Testing framework

**Правила создания моков:**
1. Проверять зависимости тестового таргета в `Package.swift` перед созданием моков
2. Не создавать моки для модулей, которые не являются зависимостями тестового таргета
3. Использовать структуры вместо кортежей с более чем 2 элементами (правило SwiftLint `large_tuple`)

**Пример структуры мока:**
```swift
final class MockService: ServiceProtocol, @unchecked Sendable {
    var callCount = 0
    var lastInput: InputType?
    var result: ResultType?
    
    func method(input: InputType) -> ResultType {
        callCount += 1
        lastInput = input
        return result ?? defaultResult
    }
}
```

### Стратегия тестирования Concurrency (Swift 6)

**Правила:**
1. Если тестируемый класс помечен `@MainActor`, тестовый класс тоже должен быть помечен `@MainActor`
2. Для async методов использовать `await` в тестах
3. Использовать `Task` для тестирования асинхронных операций
4. Проверять `Sendable` конформность всех моделей данных
5. Использовать `@unchecked Sendable` для моков, если необходимо

**Пример:**
```swift
@MainActor
struct ViewModelTests {
    @Test
    func asyncMethod() async {
        let viewModel = ViewModel()
        await viewModel.asyncAction()
        #expect(viewModel.state == .expected)
    }
}
```

### Правила именования тестов

**Формат:** `func <что_тестируем>When<условие>()`

**Примеры:**
- `func selectRowWhenRowIsSelected()` — тест выбора строки, когда строка уже выбрана
- `func calculateTotalWhenCoefficientIsInvalid()` — тест расчета, когда коэффициент невалиден
- `func setTextFieldTextWhenSelectedRowIsNone()` — тест установки текста, когда ничего не выбрано

**Структура теста (Given-When-Then):**
```swift
@Test
func example() {
    // Given
    let component = Component()
    
    // When
    component.action()
    
    // Then
    #expect(component.state == .expected)
}
```

---

## 3. Implementation Plan (Checklist)

### Phase 1: Core Logic & Services

#### 1.1 Extensions Tests
- [x] `Double.formatToString()` — тесты форматирования чисел
  - [x] Положительные числа
  - [x] Отрицательные числа
  - [x] Ноль
  - [x] Большие числа
  - [x] Числа с дробной частью
  - [x] Процентный формат (`isPercent: true`)
  - [x] Локализация (ru_RU)

- [x] `String.formatToDouble()` — тесты парсинга строк
  - [x] Валидные числа (с запятой, с точкой)
  - [x] Невалидные строки
  - [x] Пустая строка
  - [x] Локализация (ru_RU)

- [x] `String.isValidDouble()` — тесты валидации
  - [x] Валидные числа
  - [x] Невалидные строки
  - [x] Пустая строка
  - [x] Отрицательные числа

- [x] `String.isNumberNotNegative()` — тесты проверки неотрицательности
  - [x] Положительные числа
  - [x] Ноль
  - [x] Отрицательные числа
  - [x] Невалидные строки

#### 1.2 Calculator Edge Cases
- [x] Нулевые коэффициенты
- [x] Отрицательные коэффициенты
- [x] Нулевые ставки
- [x] Отрицательные ставки
- [x] Пустые строки коэффициентов (уже покрыто в invalidCoefficient)
- [x] Деление на ноль (защита от краша)
- [x] Очень большие числа (overflow protection)
- [x] Очень маленькие числа (precision)
- [x] Граничные значения (5, 10 строк)

#### 1.3 DefaultCalculationService
- [x] Тест вызова Calculator с корректными параметрами
- [x] Тест передачи результата Calculator в ViewModel
- [x] Тест обработки nil результатов

#### 1.4 SurebetCalculatorViewModel Additional Tests
- [x] `addRow()` — добавление строки
  - [x] Когда количество строк < 10
  - [x] Когда количество строк = 10 (не должно добавляться)
  - [x] Проверка обновления `selectedNumberOfRows`

- [x] `removeRow()` — удаление строки (edge cases)
  - [x] Когда удаляемая строка была выбрана (deselect)
  - [x] Когда удаляемая строка содержала данные (clear)
  - [x] Когда количество строк = 2 (не должно удаляться)
  - [x] Проверка вызова `calculate()` после удаления

- [x] Concurrency тесты
  - [x] Тест изоляции MainActor
  - [x] Тест параллельных вызовов `send()`
  - [x] Тест обновления `@Published` свойств

### Phase 2: Services & Managers

#### 2.1 AnalyticsManager / AnalyticsService
- [x] Создать `MockAnalyticsService`
- [x] Тест `log(name:parameters:)` — проверка вызова AppMetrica
- [x] Тест типобезопасных параметров (string, int, double, bool)
- [x] Тест DEBUG режима (не должен вызывать AppMetrica)
- [x] Тест статического метода `AnalyticsManager.log()`
- [x] Тест конвертации `AnalyticsParameterValue` в `Any`

#### 2.2 BannerService
- [x] Создать `MockBannerService`
- [x] Тест `fetchBannerAndImage()` — async метод
- [x] Тест `fetchBanner()` — возврат модели баннера
- [x] Тест `saveBannerToDefaults()` — сохранение в UserDefaults
- [x] Тест `getBannerFromDefaults()` — получение из UserDefaults
- [x] Тест `clearBannerFromDefaults()` — очистка UserDefaults
- [x] Тест `downloadImage(from:)` — async загрузка изображения
- [x] Тест `getStoredBannerImageData()` — получение данных изображения
- [x] Тест `getStoredBannerImageURL()` — получение URL изображения
- [x] Тест `isBannerFullyCached()` — проверка кэширования
- [x] Тест обработки ошибок (network errors, invalid URLs)

#### 2.3 ReviewService / ReviewHandler
- [x] Создать `MockReviewService`
- [x] Тест `requestReview()` — async метод с задержкой
- [x] Тест MainActor isolation
- [x] Тест задержки в 1 секунду
- [x] Тест вызова системного API запроса отзыва

### Phase 3: ViewModels

#### 3.1 RootViewModel
- [x] Создать моки: `MockAnalyticsService`, `MockReviewService`
- [x] Тест `shouldShowOnboarding` — проверка флага `onboardingIsShown`
- [x] Тест `shouldShowOnboardingWithAnimation` — проверка анимации
- [x] Тест `isOnboardingShown` — получение состояния
- [x] Тест `onAppear()` — увеличение `numberOfOpenings`
- [x] Тест `showOnboardingView()` — установка `isAnimation = true`
- [x] Тест `showFullscreenBanner()` — показ баннера при выполнении условий
- [x] Тест `fullscreenBannerIsAvailable` — проверка условий (onboarding shown, review shown, openings % 3 == 0)
- [x] Тест `showRequestReview()` — показ запроса отзыва
  - [x] Когда `requestReviewWasShown == false`
  - [x] Когда `numberOfOpenings >= 2`
  - [x] Когда `onboardingIsShown == true`
  - [x] Проверка задержки
  - [x] DEBUG режим (не должен показывать)
- [x] Тест `handleReviewNo()` — обработка отказа
  - [x] Закрытие alert
  - [x] Логирование аналитики с `enjoying_calculator: false`
- [x] Тест `handleReviewYes()` — обработка согласия
  - [x] Закрытие alert
  - [x] Вызов `reviewService.requestReview()`
  - [x] Логирование аналитики с `enjoying_calculator: true`
- [x] Тест `updateOnboardingShown()` — обновление состояния onboarding
- [x] Тест `requestReviewTitle` — локализованный заголовок

#### 3.2 OnboardingViewModel (дополнительные тесты)
- [x] Edge cases для `setCurrentPage()`
  - [x] Отрицательные значения
  - [x] Значения больше максимального
  - [x] Граничные значения (0, max)
- [x] Тест `dismiss()` — проверка установки `onboardingIsShown = true`

### Phase 4: Integration Tests

#### 4.1 Root -> Calculator Flow
- [x] Тест полного flow: RootViewModel -> SurebetCalculatorViewModel -> CalculationService
- [x] Тест передачи данных между модулями
- [x] Тест обновления UI при изменении состояния

#### 4.2 Services Integration
- [x] Тест AnalyticsManager + RootViewModel
- [x] Тест ReviewService + RootViewModel

### Phase 5: UI Tests (если требуется)

#### 5.1 Happy Path
- [x] Запуск приложения
- [x] Показ онбординга для нового пользователя
- [x] Ввод данных в калькулятор
- [x] Расчет сурбета
- [x] Показ результата

#### 5.2 Edge Cases
- [x] Ввод невалидных данных
- [x] Очистка полей
- [x] Изменение количества строк
- [ ] Показ баннера (требует мокирования сетевых запросов)
- [ ] Запрос отзыва (требует мокирования системного API)

**Заметки по UI тестам:**
- Создан UI Test Target `SurebetCalculatorUITests` в основном проекте
- Добавлены accessibility identifiers в модули `SurebetCalculator` и `Onboarding`
- Реализованы тесты для Happy Path и Edge Cases
- Некоторые тесты требуют доработки из-за особенностей SwiftUI accessibility
- Тесты запускаются командой: `xcodebuild test -only-testing:SurebetCalculatorUITests`

---

## 4. Приоритеты

### Критичные (P0)
1. **Extensions Tests** — базовые утилиты используются везде
2. **Calculator Edge Cases** — защита от крашей и невалидных данных
3. **DefaultCalculationService** — основной сервис расчетов

### Высокие (P1)
4. **RootViewModel** — центральный ViewModel приложения
5. **AnalyticsManager** — критичная функциональность аналитики
6. **SurebetCalculatorViewModel Additional Tests** — дополнение существующих тестов

### Средние (P2)
7. **BannerService** — важная, но не критичная функциональность
8. **ReviewService** — важная, но не критичная функциональность
9. **Integration Tests** — проверка взаимодействия компонентов

### Низкие (P3)
10. **UI Tests** — можно отложить, если нет времени
11. **OnboardingViewModel Additional Tests** — базовое покрытие уже есть

---

## 5. Метрики успеха

### Целевые показатели покрытия
- **Unit Tests:** > 80% покрытие кода
- **Critical Paths:** 100% покрытие (Calculator, ViewModels, Services)
- **Edge Cases:** Все выявленные edge cases покрыты тестами

### Критерии готовности
- ✅ Все тесты компилируются без ошибок
- ✅ Все тесты проходят (`xcodebuild test` успешен)
- ✅ Нет ворнингов линтера (`read_lints` чист)
- ✅ Моки созданы для всех сервисов
- ✅ MainActor isolation проверена для всех ViewModels

---

## 6. Заметки

### Зависимости тестовых таргетов
Перед созданием моков проверить `Package.swift`:
- `SurebetCalculatorTests` зависит только от `SurebetCalculator`
- `OnboardingTests` зависит только от `Onboarding`
- Для тестирования `RootViewModel` может потребоваться создание нового тестового таргета `RootTests`

### Известные ограничения
- `AnalyticsManager` использует `#if !DEBUG` — тесты должны учитывать это
- `ReviewService` использует системный API — нужны моки
- `BannerService` использует сетевые запросы — нужны моки для URLSession

### Следующие шаги после выполнения плана
1. Настроить CI/CD для автоматического запуска тестов
2. Добавить coverage reporting (Xcode Code Coverage)
3. Настроить pre-commit hooks для проверки тестов
4. Документировать процесс добавления новых тестов

---

**Последнее обновление:** 2026-01-24
**Автор:** Lead iOS SDET
**Статус:** В работе
