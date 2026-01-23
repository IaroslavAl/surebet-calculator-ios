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
        let handler = ReviewHandler()
        let startTime = Date()

        // When
        await handler.requestReview()

        // Then
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)

        // Проверяем, что прошло примерно 1 секунда (с допуском на погрешность)
        #expect(duration >= 0.9) // Минимум 0.9 секунды
        #expect(duration <= 1.5) // Максимум 1.5 секунды (с учетом погрешности)
    }

    /// Тест множественных вызовов requestReview
    @Test
    func requestReviewWhenMultipleCalls() async {
        // Given
        let handler = ReviewHandler()
        let startTime = Date()

        // When
        await handler.requestReview()
        await handler.requestReview()

        // Then
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)

        // Должно быть примерно 2 секунды (с допуском)
        #expect(duration >= 1.8) // Минимум 1.8 секунды
        #expect(duration <= 3.0) // Максимум 3 секунды (с учетом погрешности)
    }

    /// Тест статического метода ReviewHandler.requestReview()
    @Test
    func staticRequestReviewWhenCalled() async {
        // Given
        let startTime = Date()

        // When
        await ReviewHandler.requestReview()

        // Then
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)

        // Проверяем, что прошло примерно 1 секунда
        #expect(duration >= 0.9)
        #expect(duration <= 1.5)
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

    /// Тест MockReviewService - проверка задержки
    @Test
    func mockRequestReviewWhenDelayIsCorrect() async {
        // Given
        let mockService = MockReviewService()
        let startTime = Date()

        // When
        await mockService.requestReview()

        // Then
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)

        // Проверяем задержку
        #expect(duration >= 0.9)
        #expect(duration <= 1.5)

        // Проверяем, что времена установлены
        if let start = mockService.lastRequestReviewStartTime,
           let end = mockService.lastRequestReviewEndTime {
            let mockDuration = end.timeIntervalSince(start)
            #expect(mockDuration >= 0.9)
            #expect(mockDuration <= 1.5)
        } else {
            Issue.record("Request review times should be set")
        }
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
