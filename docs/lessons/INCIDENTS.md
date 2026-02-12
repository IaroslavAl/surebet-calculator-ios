# INCIDENTS AND LESSONS

Формат записи:
- Дата
- Симптом
- Корневая причина
- Исправление
- Guardrail (правило на будущее)

## 2026-02-10 — AttributeGraph cycle и фриз меню при переходе в раздел
- Симптом: на iOS 16 после нажатия на любой раздел в главном меню экран визуально оставался в меню, а интерфейс переставал реагировать; в логах повторялось `AttributeGraph: cycle detected ...`.
- Корневая причина: root-side effect (`sectionOpened` и дальнейшая orchestration) запускался из destination `.onAppear` внутри `NavigationLink`; в этом же цикле происходили публикации UI-состояния (sheet/alert), что приводило к рекурсивной переоценке графа SwiftUI. Дополнительно ситуацию усугубляли no-op публикации одинаковых значений через `set*Presented`.
- Исправление: перенос события открытия раздела на источник взаимодействия (tap по карточке через `simultaneousGesture`), сохранение стабильного владения `ObservableObject` через контейнеры с `@StateObject`, добавление guard `newValue != currentValue` в action-сеттеры UI-флагов.
- Guardrail: не запускать root orchestration из destination `.onAppear` для экранов, открываемых через `NavigationLink`; в биндинговых action-сеттерах всегда фильтровать no-op присваивания.

## 2026-02-12 — Повторяющиеся non-fatal AttributeGraph cycles в Root оркестрации
- Симптом: в runtime-консоли повторяются сообщения вида `AttributeGraph: cycle detected through attribute ...`, но без гарантированного фриза UI.
- Корневая причина: пересечение нескольких root-side effect потоков в одном жизненном цикле экрана (navigation tap + sheet/overlay/alert + lifecycle-trigger), из-за чего SwiftUI получает re-entrant обновления графа в пределах одной транзакции. Дополнительный шум возникает, когда несколько lifecycle hooks (`onAppear`) дергают orchestration-путь одновременно.
- Исправление: централизовать root orchestration через единый entry-point действия, публиковать presentation-state только через `send(_:)` action-сеттеры с no-op guard, запускать чувствительные к навигации presentation-изменения только после отделения от tap/navigation цикла (`Task.yield()`/короткая задержка).
- Guardrail:
  - диагностировать цикл через symbolic breakpoint `AG::Graph::print_cycle` и backtrace, а не по номеру `attribute`;
  - не смешивать в одном транзакционном шаге push-навигацию и принудительный показ sheet/overlay;
  - для root lifecycle использовать один trigger c внутренним fan-out, вместо набора независимых `onAppear`.

## 2026-02-01 — Потеря transition при закрытии онбординга
- Симптом: `.move(edge: .bottom)` работал нестабильно.
- Корневая причина: анимировался контейнер, а не overlay-слой.
- Исправление: базовый экран всегда в иерархии, transition только на слое онбординга.
- Guardrail: не анимировать целый контейнер для локального перехода overlay.

## 2026-02-08 — AttributeGraph cycle и зависание интерактивности после онбординга
- Симптом: после закрытия онбординга меню визуально показывается, но нажатия не работают; в логах повторяется `AttributeGraph: cycle detected ...`.
- Корневая причина: `SurebetCalculatorViewModel` создавался прямо в `NavigationLink` destination builder, из-за чего на iOS 16 destination переинициализировался и запускал цикл обновлений SwiftUI.
- Исправление: вынести владение VM в отдельный container view с `@StateObject`, а в `SurebetCalculatorView` использовать `@ObservedObject`.
- Guardrail: для экранов, открываемых через `NavigationLink`, не создавать `ObservableObject` напрямую в destination builder; владелец VM должен быть стабильным (`@StateObject` в контейнере).

## 2026-02-08 — Severe hang на iPhone при вводе в калькулятор
- Симптом: на iPhone фиксировались зависания интерфейса на несколько секунд (`Severe Hang`, `Gesture: System gesture gate timed out`), особенно во время ввода в поля и пересчета строк.
- Корневая причина: перегрузка main thread в hot-path ввода: синхронный `calculate()` в `send(_:)` на каждое нажатие, лишние пересчеты при no-op, избыточные `@Published`-апдейты root ViewModel и повторный парсинг/повторные проходы в калькуляторе.
- Исправление: оставить ViewModel на `@MainActor`, но сократить нагрузку: убрать лишние `@Published` из внутреннего состояния, добавить short-circuit для no-op действий до `calculate()`, оптимизировать `Calculator` через кэш коэффициентов и суммы обратных коэффициентов в рамках одного расчета, убрать лишний callback в `TextField`-биндинге.
- Guardrail: `@MainActor`-изоляция ViewModel допустима и обязательна, но обработчики частых UI-событий должны быть константно-легкими и не инициировать повторные вычисления/перерисовки без фактической смены состояния.

## 2026-01-27 — Race condition в MockURLProtocol
- Симптом: флаки сетевых тестов.
- Корневая причина: глобальный handler перезаписывался параллельно.
- Исправление: потокобезопасный реестр по `URL.absoluteString`.
- Guardrail: уникальные полные URL и отсутствие shared глобального mutable handler.

## 2026-01-27 — Неверная стратегия подавления Sendable warning
- Симптом: попытка глушить `sendable` через SwiftLint.
- Корневая причина: warning компилятора Swift, не линтера.
- Исправление: корректная Sendable-конформность типов.
- Guardrail: сначала определять источник warning (compiler vs linter).

## 2026-01-24 — Нестабильность accessibilityIdentifier в UI-тестах
- Симптом: XCUITest не находил кастомные элементы.
- Корневая причина: идентификатор не всегда пробрасывался на нужный UI-элемент.
- Исправление: поиск по тексту кнопки/иконке.
- Guardrail: в UI-тестах выбирать самый стабильный локатор.

## 2026-01-24 — UIDevice в nonisolated контексте Swift 6
- Симптом: ошибка actor-изоляции.
- Корневая причина: `UIDevice.current` требует MainActor.
- Исправление: обертка с `nonisolated(unsafe)` и `MainActor.assumeIsolated`.
- Guardrail: явно документировать UI-зависимые nonisolated workaround.
