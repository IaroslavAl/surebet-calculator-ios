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
        reviewService: ReviewService? = nil,
        rootStateStore: RootStateStore = UserDefaultsRootStateStore()
    ) -> RootViewModel {
        RootViewModel(
            analyticsService: analyticsService ?? MockAnalyticsService(),
            reviewService: reviewService ?? MockReviewService(),
            delay: ImmediateDelay(),
            featureFlags: FeatureFlags(
                onboarding: true,
                reviewPrompt: true
            ),
            rootStateStore: rootStateStore
        )
    }

    func awaitAsyncTasks() async {
        await Task.yield()
    }

    // MARK: - Root -> Calculator Flow

    @Test
    func rootToCalculatorFlowWhenInitialized() {
        // Given
        clearTestUserDefaults()
        let rootViewModel = createRootViewModel()

        // Then
        #expect(rootViewModel.shouldShowOnboarding == !rootViewModel.isOnboardingShown)

        let calculatorViewModel = SurebetCalculatorViewModel(
            calculationService: DefaultCalculationService(),
            analytics: NoopCalculatorAnalytics(),
            delay: ImmediateCalculationAnalyticsDelay()
        )
        #expect(calculatorViewModel.selectedNumberOfRows == .two)
        #expect(calculatorViewModel.selection == .total)
    }

    @Test
    func dataFlowThroughCalculationService() {
        // Given
        let calculatorViewModel = SurebetCalculatorViewModel(
            selection: .none,
            calculationService: DefaultCalculationService(),
            analytics: NoopCalculatorAnalytics(),
            delay: ImmediateCalculationAnalyticsDelay()
        )

        // When
        calculatorViewModel.send(.setTextFieldText(.rowCoefficient(RowID(rawValue: 0)), "2.5"))
        calculatorViewModel.send(.setTextFieldText(.rowCoefficient(RowID(rawValue: 1)), "2.0"))
        calculatorViewModel.send(.setTextFieldText(.rowBetSize(RowID(rawValue: 0)), "500"))
        calculatorViewModel.send(.setTextFieldText(.rowBetSize(RowID(rawValue: 1)), "500"))

        // Then
        #expect(calculatorViewModel.total.betSize == "1000")
        #expect(calculatorViewModel.rowsById[RowID(rawValue: 0)]?.coefficient == "2.5")
        #expect(calculatorViewModel.rowsById[RowID(rawValue: 0)]?.betSize == "500")
        #expect(calculatorViewModel.rowsById[RowID(rawValue: 1)]?.coefficient == "2.0")
        #expect(calculatorViewModel.rowsById[RowID(rawValue: 1)]?.betSize == "500")
    }

    @Test
    func uiUpdateWhenStateChanges() {
        // Given
        let calculatorViewModel = SurebetCalculatorViewModel(
            calculationService: DefaultCalculationService(),
            analytics: NoopCalculatorAnalytics(),
            delay: ImmediateCalculationAnalyticsDelay()
        )

        // When
        calculatorViewModel.send(.selectRow(.row(RowID(rawValue: 0))))

        // Then
        #expect(calculatorViewModel.selection == .row(RowID(rawValue: 0)))
        #expect(calculatorViewModel.rowsById[RowID(rawValue: 0)]?.isON == true)
    }

    @Test
    func mainActorIsolationWhenInitializingViewModels() async {
        // Given & When
        clearTestUserDefaults()
        let rootViewModel = createRootViewModel()
        let calculatorViewModel = SurebetCalculatorViewModel(
            calculationService: DefaultCalculationService(),
            analytics: NoopCalculatorAnalytics(),
            delay: ImmediateCalculationAnalyticsDelay()
        )

        // Then
        #expect(rootViewModel.shouldShowOnboarding == !rootViewModel.isOnboardingShown)
        #expect(calculatorViewModel.selectedNumberOfRows == .two)

        await MainActor.run {
            rootViewModel.send(.onAppear)
            calculatorViewModel.send(.addRow)
        }

        #expect(calculatorViewModel.selectedNumberOfRows == .three)
    }

    @Test
    func fullFlowFromRootToCalculation() {
        // Given
        clearTestUserDefaults()
        let rootViewModel = createRootViewModel()
        rootViewModel.send(.updateOnboardingShown(true))
        let calculatorViewModel = SurebetCalculatorViewModel(
            calculationService: DefaultCalculationService(),
            analytics: NoopCalculatorAnalytics(),
            delay: ImmediateCalculationAnalyticsDelay()
        )

        // When
        calculatorViewModel.send(.setTextFieldText(.totalBetSize, "1000"))
        calculatorViewModel.send(.setTextFieldText(.rowCoefficient(RowID(rawValue: 0)), "2.0"))
        calculatorViewModel.send(.setTextFieldText(.rowCoefficient(RowID(rawValue: 1)), "2.0"))

        // Then
        #expect(calculatorViewModel.total.betSize == "1000")
        #expect(calculatorViewModel.rowsById[RowID(rawValue: 0)]?.coefficient == "2.0")
        #expect(calculatorViewModel.rowsById[RowID(rawValue: 1)]?.coefficient == "2.0")
        #expect(rootViewModel.isOnboardingShown == true)
    }

    // MARK: - Services Integration

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

private struct ImmediateCalculationAnalyticsDelay: CalculationAnalyticsDelay {
    func sleep(nanoseconds _: UInt64) async {}
}
