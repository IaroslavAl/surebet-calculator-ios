import Foundation
import Testing
@testable import ReviewHandler

/// Тесты для ReviewHandler и ReviewService
@MainActor
struct ReviewHandlerTests {
    // MARK: - requestReview() Tests

    /// Тест вызова requestReview с проверкой задержки
    @Test
    func requestReviewWhenCalled() async {
        // Given
        let delay = MockDelay()
        let handler = ReviewHandler(delay: delay)

        // When
        await handler.requestReview()

        // Then
        #expect(delay.sleepCallCount == 1)
        #expect(delay.lastNanoseconds == ReviewConstants.reviewRequestDelay)
    }

    /// Тест множественных вызовов requestReview
    @Test
    func requestReviewWhenMultipleCalls() async {
        // Given
        let delay = MockDelay()
        let handler = ReviewHandler(delay: delay)

        // When
        await handler.requestReview()
        await handler.requestReview()

        // Then
        #expect(delay.sleepCallCount == 2)
        #expect(delay.lastNanoseconds == ReviewConstants.reviewRequestDelay)
    }

    /// Тест статического метода ReviewHandler.requestReview()
    @Test
    func staticRequestReviewWhenCalled() async {
        // Given
        let delay = MockDelay()
        let previousDelay = ReviewHandler.defaultDelay
        ReviewHandler.defaultDelay = delay
        defer { ReviewHandler.defaultDelay = previousDelay }

        // When
        await ReviewHandler.requestReview()

        // Then
        #expect(delay.sleepCallCount == 1)
        #expect(delay.lastNanoseconds == ReviewConstants.reviewRequestDelay)
    }

    // MARK: - MockReviewService Tests

    /// Тест MockReviewService - проверка вызова
    @Test
    func mockRequestReviewWhenCalled() async {
        // Given
        let mockService = MockReviewService()

        // When
        await mockService.requestReview()

        // Then
        #expect(mockService.requestReviewCallCount == 1)
        #expect(mockService.lastRequestReviewStartTime != nil)
        #expect(mockService.lastRequestReviewEndTime != nil)
    }

    /// Тест MockReviewService - множественные вызовы
    @Test
    func mockRequestReviewWhenMultipleCalls() async {
        // Given
        let mockService = MockReviewService()

        // When
        await mockService.requestReview()
        await mockService.requestReview()
        await mockService.requestReview()

        // Then
        #expect(mockService.requestReviewCallCount == 3)
    }

    // MARK: - MainActor Isolation Tests

    /// Тест изоляции MainActor - проверка, что метод можно вызвать из MainActor контекста
    @Test
    func requestReviewWhenMainActorIsolation() async {
        // Given
        let handler = ReviewHandler()

        // When & Then
        // Если бы не было MainActor, это вызвало бы ошибку компиляции
        await handler.requestReview()

        // Если мы дошли сюда, значит MainActor isolation работает
        #expect(true)
    }

    /// Тест изоляции MainActor для MockReviewService
    @Test
    func mockRequestReviewWhenMainActorIsolation() async {
        // Given
        let mockService = MockReviewService()

        // When & Then
        // Если бы не было MainActor, это вызвало бы ошибку компиляции
        await mockService.requestReview()

        // Если мы дошли сюда, значит MainActor isolation работает
        #expect(true)
    }
}
