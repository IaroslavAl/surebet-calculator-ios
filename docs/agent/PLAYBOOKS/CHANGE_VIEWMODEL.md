# PLAYBOOK: CHANGE VIEWMODEL

## Когда использовать
- Любые изменения в `*ViewModel.swift`.

## Шаги
1. Подтвердить инварианты:
   - `@MainActor final class ObservableObject`
   - единый публичный вход `send(_:)`
   - `@Published private(set)`.
2. Добавить/изменить `Action` в `send(_:)`, а не вызывать private-методы из View.
3. Проверить изоляцию actor-контекста и `Sendable` для зависимостей.
4. Если меняется состояние UI, обновить/добавить тесты ViewModel.
5. Запустить `build` + `test`.

## Чеклист PR
- Нет новых публичных mutating-методов помимо `send(_:)`.
- Нет прямых `Binding`-мутаций внутри ViewModel API.
- Тесты покрывают новые ветки в `send(_:)`.
