# ADR-0001: Composition Root + Explicit Init DI

## Контекст
- Приложение масштабируется, а текущий DI был частично распределен по модулям:
  - часть зависимостей создавалась в `Root`, часть внутри feature entry points;
  - `RootViewModel` и `SettingsViewModel` использовали `@AppStorage`, что усложняло изоляцию и тестирование;
  - публичные `view()` entry points скрыто создавали прод-зависимости, что затрудняло контроль графа и эволюцию модулей.
- Требование: сохранить простоту и производительность, избежать service locator и runtime-магии.

## Решение
- Выбран подход `Composition Root + explicit constructor DI` без внешней DI-библиотеки.
- Введен единый контейнер `AppContainer` в `Root`:
  - `Root.view(container: AppContainer = .live())`;
  - сборка live-графа зависимостей централизована в `AppContainer.live(userDefaults:)`.
- Для feature entry points введены явные dependency-контракты:
  - `SurebetCalculator.Dependencies`;
  - `Settings.Dependencies`.
- ViewModel больше не создают прод-зависимости по умолчанию:
  - `RootViewModel`, `SettingsViewModel`, `SurebetCalculatorViewModel`.
- Persisted state для Root вынесен в `RootStateStore`, тема — в `ThemeStore`.

## Последствия
- Плюсы:
  - единая и предсказуемая сборка графа зависимостей;
  - выше тестопригодность (подмена storage/service через init);
  - низкий runtime overhead (без reflection/registry lookup);
  - прозрачные lifetime-границы (`singleton-like` infra + factory для VM).
- Минусы:
  - больше явного wiring-кода в контейнере;
  - при расширении модулей нужно поддерживать dependency-контракты в актуальном состоянии.

## Альтернативы
- **DI library/container** (Factory/Swinject): меньше wiring, но внешняя зависимость и больший runtime/концептуальный overhead.
- **Compile-time DI/codegen** (Needle): строгая проверка графа, но более высокая сложность внедрения и сопровождения.
- **Оставить текущее состояние**: быстрее в краткосроке, но рост техдолга и усложнение масштабирования/тестов.
