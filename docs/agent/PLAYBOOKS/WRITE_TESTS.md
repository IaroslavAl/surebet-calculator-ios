# PLAYBOOK: WRITE TESTS

## Когда использовать
- Добавление новых unit/integration тестов.

## Шаги
1. Использовать `import Testing`.
2. Если SUT `@MainActor`, пометить тестовый suite `@MainActor`.
3. Избегать `Thread.sleep`/`Task.sleep`.
4. Для времени/задержек использовать mock delay.
5. Для сети использовать `MockURLProtocol` с регистрацией по полному URL.
6. Проверять observable state через ожидаемые действия `send(_:)`.

## Чеклист PR
- Тесты детерминированы.
- Нет флаки логики ожиданий.
