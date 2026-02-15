import Foundation
import Testing
@testable import Root
@testable import AnalyticsManager
@testable import ReviewHandler
@testable import FeatureToggles

@MainActor
@Suite(.serialized)
struct RootViewModelTests {
    // MARK: - Helpers

    func createViewModel(
        analyticsService: AnalyticsService? = nil,
        reviewService: ReviewService? = nil,
        delay: Delay? = nil,
        featureFlags: FeatureFlags? = nil,
        rootStateStore: RootStateStore = UserDefaultsRootStateStore()
    ) -> RootViewModel {
        RootViewModel(
            analyticsService: analyticsService ?? MockAnalyticsService(),
            reviewService: reviewService ?? MockReviewService(),
            delay: delay ?? ImmediateDelay(),
            featureFlags: featureFlags ?? makeFeatureFlags(),
            rootStateStore: rootStateStore
        )
    }

    func makeFeatureFlags(
        onboarding: Bool = true,
        reviewPrompt: Bool = true
    ) -> FeatureFlags {
        FeatureFlags(
            onboarding: onboarding,
            reviewPrompt: reviewPrompt
        )
    }

    func clearTestUserDefaults() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: RootConstants.onboardingIsShownKey)
        defaults.removeObject(forKey: RootConstants.requestReviewWasShownKey)
        defaults.removeObject(forKey: RootConstants.numberOfOpeningsKey)
    }

    func awaitAsyncTasks() async {
        await Task.yield()
    }

    // MARK: - Onboarding

    @Test
    func shouldShowOnboardingWhenNotShown() {
        clearTestUserDefaults()
        let viewModel = createViewModel()

        #expect(viewModel.shouldShowOnboarding == true)
    }

    @Test
    func shouldShowOnboardingWhenAlreadyShown() {
        clearTestUserDefaults()
        let viewModel = createViewModel()
        viewModel.send(.updateOnboardingShown(true))

        #expect(viewModel.shouldShowOnboarding == false)
    }

    @Test
    func shouldShowOnboardingWhenFeatureDisabled() {
        clearTestUserDefaults()
        let viewModel = createViewModel(
            featureFlags: makeFeatureFlags(onboarding: false)
        )
        let defaults = UserDefaults.standard

        #expect(viewModel.shouldShowOnboarding == false)
        #expect(viewModel.isOnboardingShown == true)
        #expect(defaults.object(forKey: RootConstants.onboardingIsShownKey) == nil)

        viewModel.send(.updateOnboardingShown(true))

        #expect(defaults.object(forKey: RootConstants.onboardingIsShownKey) == nil)
    }

    @Test
    func showOnboardingViewSetsAnimation() {
        clearTestUserDefaults()
        let viewModel = createViewModel()

        viewModel.send(.showOnboardingView)

        #expect(viewModel.shouldShowOnboardingWithAnimation == true)
    }

    // MARK: - Navigation

    @Test
    func mainMenuRouteRequestedAppendsNavigationPath() {
        clearTestUserDefaults()
        let viewModel = createViewModel()

        viewModel.send(.mainMenuRouteRequested(.section(.calculator)))

        #expect(viewModel.navigationPath == [.mainMenu(.section(.calculator))])
    }

    @Test
    func mainMenuRouteRequestedDoesNotDuplicateTopRoute() {
        clearTestUserDefaults()
        let viewModel = createViewModel()

        viewModel.send(.mainMenuRouteRequested(.section(.settings)))
        viewModel.send(.mainMenuRouteRequested(.section(.settings)))

        #expect(viewModel.navigationPath == [.mainMenu(.section(.settings))])
    }

    @Test
    func setNavigationPathSynchronizesBackNavigationState() {
        clearTestUserDefaults()
        let viewModel = createViewModel()
        viewModel.send(.mainMenuRouteRequested(.section(.calculator)))
        viewModel.send(.mainMenuRouteRequested(.section(.instructions)))

        viewModel.send(.setNavigationPath([.mainMenu(.section(.calculator))]))

        #expect(viewModel.navigationPath == [.mainMenu(.section(.calculator))])
    }

    @Test
    func setNavigationPathWhenSameValueDoesNotMutateState() {
        clearTestUserDefaults()
        let viewModel = createViewModel()
        let path: [AppRoute] = [.mainMenu(.section(.calculator))]

        viewModel.send(.setNavigationPath(path))
        viewModel.send(.setNavigationPath(path))

        #expect(viewModel.navigationPath == path)
    }

    // MARK: - Presentation

    @Test
    func setAlertPresentedWhenSameValueDoesNotMutateState() {
        clearTestUserDefaults()
        let viewModel = createViewModel()

        viewModel.send(.setAlertPresented(false))
        #expect(viewModel.alertIsPresented == false)

        viewModel.send(.setAlertPresented(true))
        #expect(viewModel.alertIsPresented == true)

        viewModel.send(.setAlertPresented(true))
        #expect(viewModel.alertIsPresented == true)
    }

    // MARK: - Lifecycle

    @Test
    func rootLifecycleStartedTriggersInitialOrchestration() {
        clearTestUserDefaults()
        let analytics = MockAnalyticsService()
        let viewModel = createViewModel(
            analyticsService: analytics,
            featureFlags: makeFeatureFlags(reviewPrompt: false)
        )

        viewModel.send(.rootLifecycleStarted)

        #expect(viewModel.shouldShowOnboardingWithAnimation == true)
        #expect(analytics.logEventCallCount == 1)
        #expect(analytics.lastEvent == .appOpened(sessionNumber: 1))
    }

    // MARK: - Review

    @Test
    func showRequestReviewWhenFeatureDisabled() async {
        clearTestUserDefaults()
        let viewModel = createViewModel(
            featureFlags: makeFeatureFlags(reviewPrompt: false)
        )
        viewModel.send(.updateOnboardingShown(true))
        viewModel.send(.onAppear)
        viewModel.send(.onAppear)

        viewModel.send(.showRequestReview)
        await awaitAsyncTasks()

        #expect(viewModel.alertIsPresented == false)
        #expect(UserDefaults.standard.bool(forKey: RootConstants.requestReviewWasShownKey) == false)
    }

    @Test
    func handleReviewNoClosesAlertAndLogsAnalytics() {
        clearTestUserDefaults()
        let mockAnalytics = MockAnalyticsService()
        let viewModel = createViewModel(analyticsService: mockAnalytics)
        viewModel.send(.setAlertPresented(true))

        viewModel.send(.handleReviewNo)

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

    @Test
    func handleReviewYesClosesAlertCallsServiceAndLogsAnalytics() async {
        clearTestUserDefaults()
        let mockAnalytics = MockAnalyticsService()
        let mockReview = MockReviewService()
        let viewModel = createViewModel(
            analyticsService: mockAnalytics,
            reviewService: mockReview
        )
        viewModel.send(.setAlertPresented(true))

        viewModel.send(.handleReviewYes)
        await awaitAsyncTasks()

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

    @Test
    func requestReviewTitleReturnsLocalizedString() {
        clearTestUserDefaults()
        let viewModel = createViewModel()

        let title = viewModel.requestReviewTitle(locale: Locale(identifier: "en"))
        #expect(!title.isEmpty)
        #expect(title != "review_request_title")
    }
}
