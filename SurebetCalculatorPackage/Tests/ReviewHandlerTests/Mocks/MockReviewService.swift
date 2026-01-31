import Foundation
@testable import ReviewHandler

/// Мок для ReviewService для использования в тестах
/// Хранит историю вызовов для проверки в тестах
@MainActor
final class MockReviewService: ReviewService, @unchecked Sendable {
    // MARK: - Properties

    /// Количество вызовов метода requestReview
    var requestReviewCallCount = 0

    /// Время последнего вызова requestReview
    var lastRequestReviewTime: Date?

    /// Время начала последнего вызова requestReview
    var lastRequestReviewStartTime: Date?

    /// Время завершения последнего вызова requestReview
    var lastRequestReviewEndTime: Date?

    // MARK: - ReviewService

    func requestReview() async {
        requestReviewCallCount += 1
        lastRequestReviewStartTime = Date()

        lastRequestReviewTime = Date()
        lastRequestReviewEndTime = Date()
    }
}
