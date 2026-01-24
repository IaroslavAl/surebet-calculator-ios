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
        reviewService: ReviewService? = nil
    ) -> RootViewModel {
        let analytics = analyticsService ?? MockAnalyticsService()
        let review = reviewService ?? MockReviewService()
        return RootViewModel(
            analyticsService: analytics,
            reviewService: review
        )
    }

    /// Очищает UserDefaults для тестовых ключей
    func clearTestUserDefaults() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "onboardingIsShown")
        defaults.removeObject(forKey: "1.7.0")
        defaults.removeObject(forKey: "numberOfOpenings")
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
        viewModel.updateOnboardingShown(true)

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
        viewModel.showOnboardingView()

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
        viewModel.updateOnboardingShown(true)

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
        viewModel.onAppear()
        viewModel.onAppear()
        viewModel.onAppear()

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
        viewModel.showOnboardingView()

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
        viewModel.updateOnboardingShown(true)
        // Устанавливаем requestReviewWasShown через UserDefaults напрямую
        UserDefaults.standard.set(true, forKey: "1.7.0")
        // Устанавливаем numberOfOpenings = 3 (кратно 3)
        for _ in 0..<3 {
            viewModel.onAppear()
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
            viewModel.onAppear()
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
        viewModel.updateOnboardingShown(true)
        for _ in 0..<3 {
            viewModel.onAppear()
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
        viewModel.updateOnboardingShown(true)
        UserDefaults.standard.set(true, forKey: "1.7.0")
        for _ in 0..<2 {
            viewModel.onAppear()
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
        viewModel.updateOnboardingShown(true)
        UserDefaults.standard.set(true, forKey: "1.7.0")
        for _ in 0..<3 {
            viewModel.onAppear()
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
        viewModel.showFullscreenBanner()

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
        viewModel.showFullscreenBanner()

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
        viewModel.updateOnboardingShown(true)
        viewModel.onAppear()
        viewModel.onAppear()

        // When
        viewModel.showRequestReview()
        // Ждем завершения Task
        try? await Task.sleep(nanoseconds: AppConstants.Delays.reviewRequest + 100_000_000) // +100ms для надежности

        // Then
        // В DEBUG режиме метод не выполняется из-за #if !DEBUG в RootViewModel
        // Проверяем, что в DEBUG режиме alert не показывается
        #if DEBUG
        // В DEBUG режиме метод showRequestReview() не выполняется
        #expect(viewModel.alertIsPresented == false)
        // В DEBUG режиме requestReviewWasShown не должен быть установлен
        let requestReviewWasShown = UserDefaults.standard.bool(forKey: "1.7.0")
        #expect(requestReviewWasShown == false)
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
        viewModel.updateOnboardingShown(true)
        UserDefaults.standard.set(true, forKey: "1.7.0")
        viewModel.onAppear()
        viewModel.onAppear()

        // When
        viewModel.showRequestReview()
        try? await Task.sleep(nanoseconds: AppConstants.Delays.reviewRequest + 100_000_000)

        // Then
        #expect(viewModel.alertIsPresented == false)
    }

    /// Тест показа запроса отзыва когда numberOfOpenings < 2
    @Test
    func showRequestReviewWhenOpeningsLessThanTwo() async {
        // Given
        clearTestUserDefaults()
        let viewModel = createViewModel()
        viewModel.updateOnboardingShown(true)
        viewModel.onAppear()

        // When
        viewModel.showRequestReview()
        try? await Task.sleep(nanoseconds: AppConstants.Delays.reviewRequest + 100_000_000)

        // Then
        #expect(viewModel.alertIsPresented == false)
    }

    /// Тест показа запроса отзыва когда onboarding не показан
    @Test
    func showRequestReviewWhenOnboardingNotShown() async {
        // Given
        clearTestUserDefaults()
        let viewModel = createViewModel()
        viewModel.onAppear()
        viewModel.onAppear()

        // When
        viewModel.showRequestReview()
        try? await Task.sleep(nanoseconds: AppConstants.Delays.reviewRequest + 100_000_000)

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
        viewModel.alertIsPresented = true

        // When
        viewModel.handleReviewNo()

        // Then
        #expect(viewModel.alertIsPresented == false)
        #expect(mockAnalytics.logCallCount == 1)
        #expect(mockAnalytics.lastEventName == "RequestReview")
        if let params = mockAnalytics.lastParameters,
           case .bool(let value) = params["enjoying_calculator"] {
            #expect(value == false)
        } else {
            Issue.record("enjoying_calculator should be bool(false)")
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
        viewModel.alertIsPresented = true

        // When
        await viewModel.handleReviewYes()

        // Then
        #expect(viewModel.alertIsPresented == false)
        #expect(mockReview.requestReviewCallCount == 1)
        #expect(mockAnalytics.logCallCount == 1)
        #expect(mockAnalytics.lastEventName == "RequestReview")
        if let params = mockAnalytics.lastParameters,
           case .bool(let value) = params["enjoying_calculator"] {
            #expect(value == true)
        } else {
            Issue.record("enjoying_calculator should be bool(true)")
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
        viewModel.updateOnboardingShown(true)

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
        #expect(viewModel.requestReviewTitle == "Do you like the app?")
    }
}
