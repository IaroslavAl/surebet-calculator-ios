import Foundation

/// Протокол для сервиса запроса отзывов.
/// Обеспечивает инверсию зависимостей и позволяет легко тестировать компоненты.
@MainActor
public protocol ReviewService: Sendable {
    /// Запрашивает отзыв пользователя с задержкой в 1 секунду.
    /// - Note: Метод должен вызываться из контекста MainActor
    func requestReview() async
}
