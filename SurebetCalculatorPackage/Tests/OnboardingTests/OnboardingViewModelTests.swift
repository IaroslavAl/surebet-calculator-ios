@testable import Onboarding
import Testing

@MainActor
struct OnboardingViewModelTests {
    @Test
    func setCurrentPage() {
        // Given
        let viewModel = OnboardingViewModel()

        // When
        viewModel.send(.setCurrentPage(1))

        // Then
        #expect(viewModel.currentPage == 1)
    }

    @Test
    func setCurrentPageWhenCurrentPageIsOutOfRange() {
        // Given
        let viewModel = OnboardingViewModel()

        // When
        viewModel.send(.setCurrentPage(100))

        // Then
        #expect(viewModel.currentPage == 0)
        #expect(viewModel.onboardingIsShown)
    }

    @Test
    func dismiss() {
        // Given
        let viewModel = OnboardingViewModel()

        // When
        viewModel.send(.dismiss)

        // Then
        #expect(viewModel.onboardingIsShown)
    }

    // MARK: - Edge Cases

    /// Тест установки отрицательной страницы
    @Test
    func setCurrentPageWhenNegative() {
        // Given
        let viewModel = OnboardingViewModel()

        // When
        viewModel.send(.setCurrentPage(-1))

        // Then
        // Должно вызвать dismiss, так как индекс не входит в диапазон
        #expect(viewModel.onboardingIsShown == true)
    }

    /// Тест установки страницы равной максимальной
    @Test
    func setCurrentPageWhenEqualToMax() {
        // Given
        let viewModel = OnboardingViewModel()
        let maxPage = viewModel.pages.count - 1

        // When
        viewModel.send(.setCurrentPage(maxPage))

        // Then
        #expect(viewModel.currentPage == maxPage)
        #expect(viewModel.onboardingIsShown == false)
    }

    /// Тест установки страницы больше максимальной
    @Test
    func setCurrentPageWhenGreaterThanMax() {
        // Given
        let viewModel = OnboardingViewModel()
        let maxPage = viewModel.pages.count

        // When
        viewModel.send(.setCurrentPage(maxPage))

        // Then
        // Должно вызвать dismiss
        #expect(viewModel.onboardingIsShown == true)
    }

    /// Тест установки страницы на граничное значение (0)
    @Test
    func setCurrentPageWhenZero() {
        // Given
        let viewModel = OnboardingViewModel()
        viewModel.send(.setCurrentPage(1))

        // When
        viewModel.send(.setCurrentPage(0))

        // Then
        #expect(viewModel.currentPage == 0)
        #expect(viewModel.onboardingIsShown == false)
    }

    /// Тест проверки состояния после dismiss
    @Test
    func dismissSetsOnboardingIsShown() {
        // Given
        let viewModel = OnboardingViewModel()
        viewModel.send(.setCurrentPage(1))

        // When
        viewModel.send(.dismiss)

        // Then
        #expect(viewModel.onboardingIsShown == true)
        // currentPage должен остаться прежним
        #expect(viewModel.currentPage == 1)
    }

    // MARK: - Analytics Tests

    /// Тест события onboarding_started при инициализации
    @Test
    func analyticsWhenOnboardingStarted() {
        // Given
        let mockAnalytics = MockOnboardingAnalytics()

        // When
        _ = OnboardingViewModel(analytics: mockAnalytics)

        // Then
        #expect(mockAnalytics.eventCallCount >= 1)
        #expect(mockAnalytics.events.contains(.onboardingStarted))
    }

    /// Тест события onboarding_page_viewed при инициализации
    @Test
    func analyticsWhenOnboardingPageViewedOnInit() {
        // Given
        let mockAnalytics = MockOnboardingAnalytics()

        // When
        _ = OnboardingViewModel(analytics: mockAnalytics)

        // Then
        #expect(mockAnalytics.eventCallCount >= 2) // onboardingStarted + onboardingPageViewed
        #expect(mockAnalytics.events.contains { event in
            if case .onboardingPageViewed(let pageIndex, _) = event {
                return pageIndex == 0
            }
            return false
        })
    }

    /// Тест события onboarding_page_viewed при смене страницы
    @Test
    func analyticsWhenOnboardingPageViewedOnPageChange() {
        // Given
        let mockAnalytics = MockOnboardingAnalytics()
        let viewModel = OnboardingViewModel(analytics: mockAnalytics)
        let initialCallCount = mockAnalytics.eventCallCount

        // When
        viewModel.send(.setCurrentPage(1))

        // Then
        #expect(mockAnalytics.eventCallCount > initialCallCount)
        #expect(mockAnalytics.events.contains { event in
            if case .onboardingPageViewed(let pageIndex, _) = event {
                return pageIndex == 1
            }
            return false
        })
    }

    /// Тест параметров события onboarding_page_viewed
    @Test
    func analyticsWhenOnboardingPageViewedParameters() {
        // Given
        let mockAnalytics = MockOnboardingAnalytics()
        let viewModel = OnboardingViewModel(analytics: mockAnalytics)

        // When
        viewModel.send(.setCurrentPage(1))

        // Then
        let pageViewedEvents = mockAnalytics.events.compactMap { event -> (Int, String)? in
            if case .onboardingPageViewed(let pageIndex, let pageID) = event {
                return (pageIndex, pageID)
            }
            return nil
        }
        #expect(pageViewedEvents.contains { $0.0 == 1 })
        if let event = pageViewedEvents.first(where: { $0.0 == 1 }) {
            #expect(!event.1.isEmpty)
        }
    }

    /// Тест события onboarding_completed при dismiss
    @Test
    func analyticsWhenOnboardingCompletedOnDismiss() {
        // Given
        let mockAnalytics = MockOnboardingAnalytics()
        let viewModel = OnboardingViewModel(analytics: mockAnalytics)
        viewModel.send(.setCurrentPage(2))
        let initialCallCount = mockAnalytics.eventCallCount

        // When
        viewModel.send(.dismiss)

        // Then
        #expect(mockAnalytics.eventCallCount > initialCallCount)
        #expect(mockAnalytics.events.contains { event in
            if case .onboardingCompleted(let pagesViewed) = event {
                return pagesViewed == 3 // currentPage + 1
            }
            return false
        })
    }

    /// Тест события onboarding_completed при выходе за границы страниц
    @Test
    func analyticsWhenOnboardingCompletedOnOutOfRange() {
        // Given
        let mockAnalytics = MockOnboardingAnalytics()
        let viewModel = OnboardingViewModel(analytics: mockAnalytics)
        viewModel.send(.setCurrentPage(1))
        let initialCallCount = mockAnalytics.eventCallCount

        // When
        viewModel.send(.setCurrentPage(100))

        // Then
        #expect(mockAnalytics.eventCallCount > initialCallCount)
        #expect(mockAnalytics.events.contains { event in
            if case .onboardingCompleted(let pagesViewed) = event {
                return pagesViewed == 2 // currentPage (1) + 1
            }
            return false
        })
    }

    /// Тест события onboarding_skipped
    @Test
    func analyticsWhenOnboardingSkipped() {
        // Given
        let mockAnalytics = MockOnboardingAnalytics()
        let viewModel = OnboardingViewModel(analytics: mockAnalytics)
        viewModel.send(.setCurrentPage(2))
        let initialCallCount = mockAnalytics.eventCallCount

        // When
        viewModel.send(.skip)

        // Then
        #expect(mockAnalytics.eventCallCount > initialCallCount)
        #expect(mockAnalytics.events.contains { event in
            if case .onboardingSkipped(let lastPageIndex) = event {
                return lastPageIndex == 2
            }
            return false
        })
    }

    /// Тест параметров события onboarding_completed
    @Test
    func analyticsWhenOnboardingCompletedParameters() {
        // Given
        let mockAnalytics = MockOnboardingAnalytics()
        let viewModel = OnboardingViewModel(analytics: mockAnalytics)
        // Используем валидный индекс страницы
        let validPageIndex = min(2, viewModel.pages.count - 1)
        viewModel.send(.setCurrentPage(validPageIndex))

        // When
        viewModel.send(.dismiss)

        // Then
        // Проверяем последнее событие onboardingCompleted
        let lastCompletedEvent = mockAnalytics.events.reversed().first { event in
            if case .onboardingCompleted = event {
                return true
            }
            return false
        }
        #expect(lastCompletedEvent != nil)
        if case .onboardingCompleted(let pagesViewed) = lastCompletedEvent {
            #expect(pagesViewed == validPageIndex + 1)
        }
    }

    /// Тест параметров события onboarding_skipped
    @Test
    func analyticsWhenOnboardingSkippedParameters() {
        // Given
        let mockAnalytics = MockOnboardingAnalytics()
        let viewModel = OnboardingViewModel(analytics: mockAnalytics)
        viewModel.send(.setCurrentPage(1))

        // When
        viewModel.send(.skip)

        // Then
        let skippedEvents = mockAnalytics.events.compactMap { event -> Int? in
            if case .onboardingSkipped(let lastPageIndex) = event {
                return lastPageIndex
            }
            return nil
        }
        #expect(skippedEvents.contains(1))
    }
}
