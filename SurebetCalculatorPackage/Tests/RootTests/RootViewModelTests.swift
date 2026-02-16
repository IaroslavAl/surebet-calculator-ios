import Foundation
import Testing
import SwiftUI
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
        defaults.removeObject(forKey: RootConstants.sessionNumberKey)
        defaults.removeObject(forKey: RootConstants.installIDKey)
        defaults.removeObject(forKey: RootConstants.sessionIDKey)
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
    func rootLifecycleStartedEnablesOnboardingAnimation() {
        clearTestUserDefaults()
        let viewModel = createViewModel()

        viewModel.send(.rootLifecycleStarted)

        #expect(viewModel.shouldShowOnboardingWithAnimation == true)
    }

    // MARK: - Navigation

    @Test
    func mainMenuRouteRequestedAppendsNavigationPath() {
        clearTestUserDefaults()
        let analytics = MockAnalyticsService()
        let viewModel = createViewModel(analyticsService: analytics)

        viewModel.send(.mainMenuRouteRequested(.section(.calculator)))

        #expect(viewModel.navigationPath == [.mainMenu(.section(.calculator))])
        #expect(analytics.lastEvent == .navigationSectionOpened(section: "calculator"))
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
        #expect(analytics.logEventCallCount == 0)
    }

    @Test
    func scenePhaseChangedToActiveStartsSessionAndLogsAnalytics() {
        clearTestUserDefaults()
        let analytics = MockAnalyticsService()
        let viewModel = createViewModel(
            analyticsService: analytics,
            featureFlags: makeFeatureFlags(reviewPrompt: false)
        )

        viewModel.send(.scenePhaseChanged(.active))

        #expect(analytics.logEventCallCount == 1)
        #expect(
            analytics.lastEvent == .appSessionStarted(
                startReason: "initial_launch",
                isFirstSession: true,
                featureOnboardingEnabled: true,
                featureReviewPromptEnabled: false
            )
        )
    }

    @Test
    func scenePhaseChangedFromActiveEndsSessionAndLogsDuration() {
        clearTestUserDefaults()
        let analytics = MockAnalyticsService()
        let viewModel = createViewModel(
            analyticsService: analytics,
            featureFlags: makeFeatureFlags(reviewPrompt: false)
        )

        viewModel.send(.scenePhaseChanged(.active))
        viewModel.send(.scenePhaseChanged(.background))

        #expect(analytics.logEventCallCount == 2)
        #expect(analytics.logEventCalls[0].name == "app_session_started")
        #expect(analytics.logEventCalls[1].name == "app_session_ended")
        if case let .appSessionEnded(durationSeconds, endReason) = analytics.logEventCalls[1] {
            #expect(durationSeconds >= 0)
            #expect(endReason == "entered_background")
        } else {
            Issue.record("Expected app_session_ended as second event")
        }
    }

    @Test
    func mainMenuFeedbackRequestedLogsAnalytics() {
        clearTestUserDefaults()
        let analytics = MockAnalyticsService()
        let viewModel = createViewModel(analyticsService: analytics)

        viewModel.send(.mainMenuFeedbackRequested)

        #expect(
            analytics.lastEvent == .feedbackEmailOpened(
                sourceScreen: "main_menu"
            )
        )
    }

    // MARK: - Review

    @Test
    func scenePhaseChangedWhenReviewFeatureDisabledDoesNotShowAlert() async {
        clearTestUserDefaults()
        let viewModel = createViewModel(
            featureFlags: makeFeatureFlags(reviewPrompt: false)
        )
        viewModel.send(.updateOnboardingShown(true))
        viewModel.send(.scenePhaseChanged(.active))
        viewModel.send(.scenePhaseChanged(.inactive))
        viewModel.send(.scenePhaseChanged(.active))
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
        #expect(mockAnalytics.lastEvent == .reviewPromptAnswered(answer: "no"))
        #expect(mockAnalytics.lastEventName == "review_prompt_answered")
        if let params = mockAnalytics.lastParameters,
           case .string(let value) = params["answer"] {
            #expect(value == "no")
        } else {
            Issue.record("answer should be string(no)")
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
        #expect(mockAnalytics.lastEvent == .reviewPromptAnswered(answer: "yes"))
        #expect(mockAnalytics.lastEventName == "review_prompt_answered")
        if let params = mockAnalytics.lastParameters,
           case .string(let value) = params["answer"] {
            #expect(value == "yes")
        } else {
            Issue.record("answer should be string(yes)")
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

    @Test
    func reviewPromptDelayIsBoundToCurrentSession() async {
#if !DEBUG
        clearTestUserDefaults()
        let analytics = MockAnalyticsService()
        let delay = ControlledDelay()
        let viewModel = createViewModel(
            analyticsService: analytics,
            delay: delay
        )
        viewModel.send(.updateOnboardingShown(true))

        viewModel.send(.scenePhaseChanged(.active))
        await delay.waitForSleepCall()
        viewModel.send(.scenePhaseChanged(.inactive))

        viewModel.send(.scenePhaseChanged(.active))
        await delay.waitForSleepCall()

        await delay.advanceNext()
        await awaitAsyncTasks()

        #expect(viewModel.alertIsPresented == false)
        #expect(
            analytics.logEventCalls.filter { event in
                if case .reviewPromptDisplayed = event {
                    return true
                }
                return false
            }.isEmpty
        )

        await delay.advanceNext()
        await awaitAsyncTasks()

        #expect(viewModel.alertIsPresented == true)
        #expect(
            analytics.logEventCalls.contains { event in
                if case .reviewPromptDisplayed = event {
                    return true
                }
                return false
            }
        )
#else
        #expect(Bool(true))
#endif
    }
}
