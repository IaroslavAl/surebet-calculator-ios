import Foundation
import FeatureToggles
import Testing
@testable import Root
@testable import SurebetCalculator
@testable import AnalyticsManager
@testable import ReviewHandler

/// Интеграционные тесты для проверки взаимодействия модулей
@MainActor
@Suite(.serialized)
struct IntegrationTests {
    // MARK: - Helper Methods

    /// Очищает UserDefaults для тестовых ключей
    func clearTestUserDefaults() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "onboardingIsShown")
        defaults.removeObject(forKey: "1.7.0")
        defaults.removeObject(forKey: "numberOfOpenings")
    }

    func createRootViewModel(
        analyticsService: AnalyticsService? = nil,
        reviewService: ReviewService? = nil
    ) -> RootViewModel {
        RootViewModel(
            analyticsService: analyticsService ?? MockAnalyticsService(),
            reviewService: reviewService ?? MockReviewService(),
            delay: ImmediateDelay(),
            featureFlags: FeatureFlags(
                onboarding: true,
                survey: false,
                reviewPrompt: true,
                bannerFetch: true,
                fullscreenBanner: true
            )
        )
    }

    func awaitAsyncTasks() async {
        await Task.yield()
    }

    // MARK: - Root -> Calculator Flow

    /// Тест полного flow: RootViewModel -> SurebetCalculatorViewModel -> CalculationService
    @Test
    func rootToCalculatorFlowWhenInitialized() {
        // Given
        clearTestUserDefaults()
        let rootViewModel = createRootViewModel()

        // When
        // Инициализация завершена

        // Then
        // RootViewModel готов к работе
        #expect(rootViewModel.shouldShowOnboarding == !rootViewModel.isOnboardingShown)

        // Проверяем, что можем создать SurebetCalculatorViewModel
        let calculatorViewModel = SurebetCalculatorViewModel()
        #expect(calculatorViewModel.selectedNumberOfRows == .two)
        #expect(calculatorViewModel.selection == .total)
    }

    /// Тест передачи данных между модулями через CalculationService
    @Test
    func dataFlowThroughCalculationService() {
        // Given
        let calculatorViewModel = SurebetCalculatorViewModel(selection: .none)

        // When
        calculatorViewModel.send(.setTextFieldText(.rowCoefficient(RowID(rawValue: 0)), "2.5"))
        calculatorViewModel.send(.setTextFieldText(.rowCoefficient(RowID(rawValue: 1)), "2.0"))
        calculatorViewModel.send(.setTextFieldText(.rowBetSize(RowID(rawValue: 0)), "500"))
        calculatorViewModel.send(.setTextFieldText(.rowBetSize(RowID(rawValue: 1)), "500"))

        // Then
        // Проверяем, что данные передались через CalculationService
        #expect(calculatorViewModel.total.betSize == "1000")
        #expect(calculatorViewModel.rowsById[RowID(rawValue: 0)]?.coefficient == "2.5")
        #expect(calculatorViewModel.rowsById[RowID(rawValue: 0)]?.betSize == "500")
        #expect(calculatorViewModel.rowsById[RowID(rawValue: 1)]?.coefficient == "2.0")
        #expect(calculatorViewModel.rowsById[RowID(rawValue: 1)]?.betSize == "500")
    }

    /// Тест обновления UI при изменении состояния
    @Test
    func uiUpdateWhenStateChanges() {
        // Given
        let calculatorViewModel = SurebetCalculatorViewModel()

        // When
        calculatorViewModel.send(.selectRow(.row(RowID(rawValue: 0))))

        // Then
        #expect(calculatorViewModel.selection == .row(RowID(rawValue: 0)))
        #expect(calculatorViewModel.rowsById[RowID(rawValue: 0)]?.isON == true)
    }

    /// Тест MainActor isolation для инициализации обоих ViewModel
    @Test
    func mainActorIsolationWhenInitializingViewModels() async {
        // Given & When
        clearTestUserDefaults()
        // Оба ViewModel должны инициализироваться на MainActor
        let rootViewModel = createRootViewModel()
        let calculatorViewModel = SurebetCalculatorViewModel()

        // Then
        // Проверяем, что нет дедлоков и оба ViewModel работают
        #expect(rootViewModel.shouldShowOnboarding == !rootViewModel.isOnboardingShown)
        #expect(calculatorViewModel.selectedNumberOfRows == .two)

        // Проверяем, что можем выполнить действия на MainActor
        await MainActor.run {
            rootViewModel.send(.onAppear)
            calculatorViewModel.send(.addRow)
        }

        // Проверяем, что действия выполнились корректно
        #expect(calculatorViewModel.selectedNumberOfRows == .three)
    }

    /// Тест полного flow: RootViewModel -> SurebetCalculatorViewModel -> CalculationService -> результат
    @Test
    func fullFlowFromRootToCalculation() {
        // Given
        clearTestUserDefaults()
        let rootViewModel = createRootViewModel()
        rootViewModel.send(.updateOnboardingShown(true))
        let calculatorViewModel = SurebetCalculatorViewModel()

        // When
        // Пользователь вводит данные в калькулятор
        calculatorViewModel.send(.setTextFieldText(.totalBetSize, "1000"))
        calculatorViewModel.send(.setTextFieldText(.rowCoefficient(RowID(rawValue: 0)), "2.0"))
        calculatorViewModel.send(.setTextFieldText(.rowCoefficient(RowID(rawValue: 1)), "2.0"))

        // Then
        // Проверяем, что расчет выполнен через CalculationService
        #expect(calculatorViewModel.total.betSize == "1000")
        #expect(calculatorViewModel.rowsById[RowID(rawValue: 0)]?.coefficient == "2.0")
        #expect(calculatorViewModel.rowsById[RowID(rawValue: 1)]?.coefficient == "2.0")

        // Проверяем, что RootViewModel готов показать калькулятор
        #expect(rootViewModel.isOnboardingShown == true)
    }

    // MARK: - Services Integration

    /// Тест сквозной аналитики: RootViewModel -> AnalyticsService
    @Test
    func analyticsIntegrationWhenReviewNo() {
        // Given
        clearTestUserDefaults()
        let mockAnalytics = MockAnalyticsService()
        let rootViewModel = createRootViewModel(analyticsService: mockAnalytics)

        // When
        rootViewModel.send(.handleReviewNo)

        // Then
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

    /// Тест сквозной аналитики: RootViewModel -> AnalyticsService при согласии на отзыв
    @Test
    func analyticsIntegrationWhenReviewYes() async {
        // Given
        clearTestUserDefaults()
        let mockAnalytics = MockAnalyticsService()
        let rootViewModel = createRootViewModel(analyticsService: mockAnalytics)

        // When
        rootViewModel.send(.handleReviewYes)
        await awaitAsyncTasks()

        // Then
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

    /// Тест бизнес-правила: 3 запуска приложения -> ReviewService.requestReview()
    @Test
    func reviewServiceTriggerAfterThreeOpenings() async {
        // Given
        clearTestUserDefaults()
        let mockReview = MockReviewService()
        let rootViewModel = createRootViewModel(reviewService: mockReview)

        // Устанавливаем начальные условия
        rootViewModel.send(.updateOnboardingShown(true))
        UserDefaults.standard.set(true, forKey: "1.7.0") // requestReviewWasShown = true

        // When
        // Симулируем 3 запуска приложения
        rootViewModel.send(.onAppear) // 1
        rootViewModel.send(.onAppear) // 2
        rootViewModel.send(.onAppear) // 3

        // Then
        // Проверяем, что fullscreenBannerIsAvailable == true (numberOfOpenings % 3 == 0)
        #expect(rootViewModel.fullscreenBannerIsAvailable == true)

        // Проверяем, что при вызове handleReviewYes ReviewService вызывается
        rootViewModel.send(.handleReviewYes)
        await awaitAsyncTasks()
        #expect(mockReview.requestReviewCallCount == 1)
    }

    /// Тест бизнес-правила: ReviewService вызывается при handleReviewYes
    @Test
    func reviewServiceCalledWhenHandleReviewYes() async {
        // Given
        clearTestUserDefaults()
        let mockReview = MockReviewService()
        let rootViewModel = createRootViewModel(reviewService: mockReview)

        // When
        rootViewModel.send(.handleReviewYes)
        await awaitAsyncTasks()

        // Then
        #expect(mockReview.requestReviewCallCount == 1)
        #expect(mockReview.lastRequestReviewTime != nil)
    }
}
