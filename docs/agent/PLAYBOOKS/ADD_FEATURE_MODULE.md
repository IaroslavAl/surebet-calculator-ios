# PLAYBOOK: ADD FEATURE MODULE

## Когда использовать
- Добавление нового модуля в `Sources/`.

## Шаги
1. Добавить target в `SurebetCalculatorPackage/Package.swift`.
2. Подключить `SwiftLintBuildToolPlugin` к target.
3. Добавить зависимости только необходимые модулю.
4. Создать публичную точку входа `ModuleName.swift`.
5. Подключить модуль в потребитель (обычно `Root` или `MainMenu`).
6. Добавить test target при необходимости.
7. Обновить `docs/reference/MODULE_INDEX.md` и `docs/reference/DEPENDENCY_GRAPH.md`.

## Чеклист PR
- Нет циклических зависимостей.
- Публичный API минимален.
- Есть хотя бы smoke coverage тестами (если модуль содержит логику).
