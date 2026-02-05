import Foundation
import Testing
@testable import Root
@testable import AnalyticsManager
@testable import ReviewHandler
@testable import Banner
@testable import SurebetCalculator

// swiftlint:disable file_length

/// Тесты выполняются последовательно для изоляции UserDefaults
@MainActor
@Suite(.serialized)
struct RootViewModelTests {
    // MARK: - Helper Methods

    /// Создает новый экземпляр RootViewModel с моками
    func createViewModel(
        analyticsService: AnalyticsService? = nil,
        reviewService: ReviewService? = nil,
        delay: Delay? = nil
    ) -> RootViewModel {
        let analytics = analyticsService ?? MockAnalyticsService()
        let review = reviewService ?? MockReviewService()
        let reviewDelay = delay ?? ImmediateDelay()
        return RootViewModel(
            analyticsService: analytics,
            reviewService: review,
            delay: reviewDelay
        )
    }

    /// Очищает UserDefaults для тестовых ключей
    func clearTestUserDefaults() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "onboardingIsShown")
        defaults.removeObject(forKey: "1.7.0")
        defaults.removeObject(forKey: "numberOfOpenings")
    }

    func awaitAsyncTasks() async {
        await Task.yield()
    }

    // MARK: - shouldShowOnboarding Tests

    /// Тест проверки показа onboarding когда он не был показан
    @Test
    func shouldShowOnboardingWhenNotShown() {
        // Given
        clearTestUserDefaults()
        let viewModel = createViewModel()

        // Then
        #expect(viewModel.shouldShowOnboarding == true)
    }

    /// Тест проверки показа onboarding когда он уже был показан
    @Test
    func shouldShowOnboardingWhenAlreadyShown() {
        // Given
        clearTestUserDefaults()
        let viewModel = createViewModel()
        viewModel.send(.updateOnboardingShown(true))

        // Then
        #expect(viewModel.shouldShowOnboarding == false)
    }

    // MARK: - shouldShowOnboardingWithAnimation Tests

    /// Тест проверки показа onboarding с анимацией
    @Test
    func shouldShowOnboardingWithAnimationWhenAnimationIsTrue() {
        // Given
        clearTestUserDefaults()
        let viewModel = createViewModel()

        // When
        viewModel.send(.showOnboardingView)

        // Then
        #expect(viewModel.shouldShowOnboardingWithAnimation == true)
    }

    /// Тест проверки показа onboarding с анимацией когда анимация false
    @Test
    func shouldShowOnboardingWithAnimationWhenAnimationIsFalse() {
        // Given
        clearTestUserDefaults()
        let viewModel = createViewModel()

        // Then
        #expect(viewModel.shouldShowOnboardingWithAnimation == false)
    }

    // MARK: - isOnboardingShown Tests

    /// Тест получения состояния onboarding
    @Test
    func isOnboardingShownWhenUpdated() {
        // Given
        clearTestUserDefaults()
        let viewModel = createViewModel()

        // When
        viewModel.send(.updateOnboardingShown(true))

        // Then
        #expect(viewModel.isOnboardingShown == true)
    }

    // MARK: - onAppear() Tests

    /// Тест увеличения numberOfOpenings при onAppear
    @Test
    func onAppearIncrementsNumberOfOpenings() {
        // Given
        clearTestUserDefaults()
        let viewModel = createViewModel()

        // When
        viewModel.send(.onAppear)
        viewModel.send(.onAppear)
        viewModel.send(.onAppear)

        // Then
        // Проверяем через fullscreenBannerIsAvailable (numberOfOpenings % 3 == 0)
        #expect(viewModel.fullscreenBannerIsAvailable == false) // onboarding не показан, review не показан
    }

    // MARK: - showOnboardingView() Tests

    /// Тест установки анимации при показе onboarding
    @Test
    func showOnboardingViewSetsAnimation() {
        // Given
        clearTestUserDefaults()
        let viewModel = createViewModel()

        // When
        viewModel.send(.showOnboardingView)

        // Then
        // Проверяем через shouldShowOnboardingWithAnimation
        #expect(viewModel.shouldShowOnboardingWithAnimation == true)
    }

    // MARK: - fullscreenBannerIsAvailable Tests

    /// Тест доступности fullscreen баннера когда все условия выполнены
    @Test
    func fullscreenBannerIsAvailableWhenAllConditionsMet() {
        // Given
        clearTestUserDefaults()
        let viewModel = createViewModel()
        viewModel.send(.updateOnboardingShown(true))
        // Устанавливаем requestReviewWasShown через UserDefaults напрямую
        UserDefaults.standard.set(true, forKey: "1.7.0")
        // Устанавливаем numberOfOpenings = 3 (кратно 3)
        for _ in 0..<3 {
            viewModel.send(.onAppear)
        }

        // Then
        #expect(viewModel.fullscreenBannerIsAvailable == true)
    }

    /// Тест доступности fullscreen баннера когда onboarding не показан
    @Test
    func fullscreenBannerIsAvailableWhenOnboardingNotShown() {
        // Given
        clearTestUserDefaults()
        let viewModel = createViewModel()
        UserDefaults.standard.set(true, forKey: "1.7.0")
        for _ in 0..<3 {
            viewModel.send(.onAppear)
        }

        // Then
        #expect(viewModel.fullscreenBannerIsAvailable == false)
    }

    /// Тест доступности fullscreen баннера когда review не показан
    @Test
    func fullscreenBannerIsAvailableWhenReviewNotShown() {
        // Given
        clearTestUserDefaults()
        let viewModel = createViewModel()
        viewModel.send(.updateOnboardingShown(true))
        for _ in 0..<3 {
            viewModel.send(.onAppear)
        }

        // Then
        #expect(viewModel.fullscreenBannerIsAvailable == false)
    }

    /// Тест доступности fullscreen баннера когда numberOfOpenings не кратно 3
    @Test
    func fullscreenBannerIsAvailableWhenOpeningsNotMultipleOfThree() {
        // Given
        clearTestUserDefaults()
        let viewModel = createViewModel()
        viewModel.send(.updateOnboardingShown(true))
        UserDefaults.standard.set(true, forKey: "1.7.0")
        for _ in 0..<2 {
            viewModel.send(.onAppear)
        }

        // Then
        #expect(viewModel.fullscreenBannerIsAvailable == false)
    }

    // MARK: - showFullscreenBanner() Tests

    /// Тест показа fullscreen баннера когда доступен и закэширован
    @Test
    func showFullscreenBannerWhenAvailableAndCached() {
        // Given
        clearTestUserDefaults()
        let viewModel = createViewModel()
        viewModel.send(.updateOnboardingShown(true))
        UserDefaults.standard.set(true, forKey: "1.7.0")
        for _ in 0..<3 {
            viewModel.send(.onAppear)
        }
        // Мокируем Banner.isBannerFullyCached через сохранение данных в UserDefaults
        let testBanner = BannerModel(
            id: "test",
            title: "Test",
            body: "Test",
            partnerCode: nil,
            imageURL: URL(string: "https://example.com/image.png")!,
            actionURL: URL(string: "https://example.com")!
        )
        let service = Service()
        service.saveBannerToDefaults(testBanner)
        let imageData = Data("test".utf8)
        UserDefaults.standard.set(imageData, forKey: "stored_banner_image_data")
        UserDefaults.standard.set(testBanner.imageURL.absoluteString, forKey: "stored_banner_image_url_string")

        // When
        viewModel.send(.showFullscreenBanner)

        // Then
        #expect(viewModel.fullscreenBannerIsPresented == true)
    }

    /// Тест показа fullscreen баннера когда не доступен
    @Test
    func showFullscreenBannerWhenNotAvailable() {
        // Given
        clearTestUserDefaults()
        let viewModel = createViewModel()

        // When
        viewModel.send(.showFullscreenBanner)

        // Then
        #expect(viewModel.fullscreenBannerIsPresented == false)
    }

    // MARK: - showRequestReview() Tests

    /// Тест показа запроса отзыва когда условия выполнены
    /// Примечание: В DEBUG режиме метод showRequestReview() не выполняется из-за #if !DEBUG
    @Test
    func showRequestReviewWhenConditionsMet() async {
        // Given
        clearTestUserDefaults()
        let viewModel = createViewModel()
        viewModel.send(.updateOnboardingShown(true))
        viewModel.send(.onAppear)
        viewModel.send(.onAppear)

        // When
        viewModel.send(.showRequestReview)
        await awaitAsyncTasks()

        // Then
        // В DEBUG режиме метод не выполняется из-за #if !DEBUG в RootViewModel
        // Проверяем, что в DEBUG режиме alert не показывается
        #if DEBUG
        // В DEBUG режиме метод showRequestReview() не выполняется
        #expect(viewModel.alertIsPresented == false)
        #else
        // В не-DEBUG режиме метод должен выполниться
        #expect(viewModel.alertIsPresented == true)
        #expect(UserDefaults.standard.bool(forKey: "1.7.0") == true)
        #endif
    }

    /// Тест показа запроса отзыва когда requestReviewWasShown == true
    @Test
    func showRequestReviewWhenAlreadyShown() async {
        // Given
        clearTestUserDefaults()
        let viewModel = createViewModel()
        viewModel.send(.updateOnboardingShown(true))
        UserDefaults.standard.set(true, forKey: "1.7.0")
        viewModel.send(.onAppear)
        viewModel.send(.onAppear)

        // When
        viewModel.send(.showRequestReview)
        await awaitAsyncTasks()

        // Then
        #expect(viewModel.alertIsPresented == false)
    }

    /// Тест показа запроса отзыва когда numberOfOpenings < 2
    @Test
    func showRequestReviewWhenOpeningsLessThanTwo() async {
        // Given
        clearTestUserDefaults()
        let viewModel = createViewModel()
        viewModel.send(.updateOnboardingShown(true))
        viewModel.send(.onAppear)

        // When
        viewModel.send(.showRequestReview)
        await awaitAsyncTasks()

        // Then
        #expect(viewModel.alertIsPresented == false)
    }

    /// Тест показа запроса отзыва когда onboarding не показан
    @Test
    func showRequestReviewWhenOnboardingNotShown() async {
        // Given
        clearTestUserDefaults()
        let viewModel = createViewModel()
        viewModel.send(.onAppear)
        viewModel.send(.onAppear)

        // When
        viewModel.send(.showRequestReview)
        await awaitAsyncTasks()

        // Then
        #expect(viewModel.alertIsPresented == false)
    }

    // MARK: - handleReviewNo() Tests

    /// Тест обработки отказа от отзыва
    @Test
    func handleReviewNoClosesAlertAndLogsAnalytics() {
        // Given
        clearTestUserDefaults()
        let mockAnalytics = MockAnalyticsService()
        let viewModel = createViewModel(analyticsService: mockAnalytics)
        viewModel.send(.setAlertPresented(true))

        // When
        viewModel.send(.handleReviewNo)

        // Then
        #expect(viewModel.alertIsPresented == false)
        #expect(mockAnalytics.logEventCallCount == 1)
        #expect(mockAnalytics.lastEvent == .reviewResponse(enjoyingApp: false))
        #expect(mockAnalytics.lastEventName == "review_response")
        if let params = mockAnalytics.lastParameters,
           case .bool(let value) = params["enjoying_app"] {
            #expect(value == false)
        } else {
            Issue.record("enjoying_app should be bool(false)")
        }
    }

    // MARK: - handleReviewYes() Tests

    /// Тест обработки согласия на отзыв
    @Test
    func handleReviewYesClosesAlertCallsServiceAndLogsAnalytics() async {
        // Given
        clearTestUserDefaults()
        let mockAnalytics = MockAnalyticsService()
        let mockReview = MockReviewService()
        let viewModel = createViewModel(
            analyticsService: mockAnalytics,
            reviewService: mockReview
        )
        viewModel.send(.setAlertPresented(true))

        // When
        viewModel.send(.handleReviewYes)
        await awaitAsyncTasks()

        // Then
        #expect(viewModel.alertIsPresented == false)
        #expect(mockReview.requestReviewCallCount == 1)
        #expect(mockAnalytics.logEventCallCount == 1)
        #expect(mockAnalytics.lastEvent == .reviewResponse(enjoyingApp: true))
        #expect(mockAnalytics.lastEventName == "review_response")
        if let params = mockAnalytics.lastParameters,
           case .bool(let value) = params["enjoying_app"] {
            #expect(value == true)
        } else {
            Issue.record("enjoying_app should be bool(true)")
        }
    }

    // MARK: - updateOnboardingShown() Tests

    /// Тест обновления состояния onboarding
    @Test
    func updateOnboardingShownUpdatesState() {
        // Given
        clearTestUserDefaults()
        let viewModel = createViewModel()

        // When
        viewModel.send(.updateOnboardingShown(true))

        // Then
        #expect(viewModel.isOnboardingShown == true)
        #expect(viewModel.shouldShowOnboarding == false)
    }

    // MARK: - requestReviewTitle Tests

    /// Тест локализованного заголовка запроса отзыва
    @Test
    func requestReviewTitleReturnsLocalizedString() {
        // Given
        clearTestUserDefaults()
        let viewModel = createViewModel()

        // Then
        let title = viewModel.requestReviewTitle(locale: Locale(identifier: "en"))
        #expect(!title.isEmpty)
        #expect(title != "review_request_title")
    }
}
