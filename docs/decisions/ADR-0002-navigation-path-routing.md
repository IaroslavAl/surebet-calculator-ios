# ADR-0002: Data-Driven Navigation Path в Root

## Контекст
- В проекте уже зафиксированы инциденты с `NavigationLink` на iOS 16 (`AttributeGraph cycle`) при пересечении push-навигации и root orchestration side-effects.
- Источник переходов был распределен: `MainMenu` одновременно и инициировал переход, и строил destination, из-за чего усложнялись тесты и расширение маршрутов.
- Требование: обеспечить надежную передачу контекста между экранами, предсказуемое поведение на iOS 16+, и масштабируемую навигацию для среднего проекта без отказа от текущего SwiftUI стека.

## Решение
- Оставить `NavigationStack`, но перейти на data-driven модель c типизированным path.
- Ввести route-контракты:
  - `MainMenuRoute` (public, модуль `MainMenu`);
  - `AppRoute` (internal, модуль `Root`).
- Источник правды push-навигации хранить в `RootViewModel`:
  - `@Published private(set) var navigationPath: [AppRoute]`;
  - переходы только через `send(.mainMenuRouteRequested(...))`;
  - синхронизация back/pop через `send(.setNavigationPath(...))`.
- Перенести destination factory в `RootView` через `.navigationDestination(for:)`.
- Сделать `MainMenu` pure UI-источником route events:
  - удалить `MainMenu.Dependencies`;
  - убрать `NavigationLink` из production-кода меню;
  - оставить только `onRouteRequested`.
- Push-маршруты и presentation-state (`sheet`/`overlay`/`alert`) держать раздельно.
- Централизовать lifecycle orchestration root-экрана через единый action `rootLifecycleStarted`.

## Последствия
- Плюсы:
  - навигация становится state-driven и детерминированной;
  - проще тестировать переходы/попы/защиту от дублей path;
  - снижен риск re-entrant обновлений, связанных с destination lifecycle;
  - `MainMenu` освобожден от feature-зависимостей и лучше масштабируется.
- Минусы:
  - больше routing/wiring-кода в `Root`;
  - breaking change API модуля `MainMenu`;
  - добавляется слой route-моделей, который нужно поддерживать в актуальном состоянии.

## Альтернативы
- **Оставить `NavigationLink` и усилить guard-правила**: меньше изменений, но хуже масштабирование и сохраняются lifecycle-риски.
- **UIKit Coordinator (`UINavigationController`)**: максимальный контроль, но избыточно для текущего масштаба и хуже согласуется с существующим SwiftUI/MVVM стеком.
- **Единое дерево route для push + modal**: выше унификация, но неоправданная сложность для первой итерации.
