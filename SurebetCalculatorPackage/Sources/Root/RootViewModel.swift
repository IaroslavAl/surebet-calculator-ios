import AnalyticsManager
import FeatureToggles
import Foundation
import MainMenu
import ReviewHandler
import SwiftUI

/// ViewModel для управления состоянием и бизнес-логикой RootView
@MainActor
final class RootViewModel: ObservableObject {
    private enum SessionStartReason: String {
        case initialLaunch = "initial_launch"
        case foregroundFromBackground = "foreground_from_background"
        case foregroundFromInactive = "foreground_from_inactive"
        case foregroundFromUnknown = "foreground_from_unknown"
    }

    private enum SessionEndReason: String {
        case enteredBackground = "entered_background"
        case enteredInactive = "entered_inactive"
    }

    private enum ReviewAnswer: String {
        case yes = "yes"
        case noAnswer = "no"
    }

    private enum AnalyticsValues {
        static let feedbackSourceMainMenu = "main_menu"
    }

    // MARK: - Properties

    @Published private(set) var alertIsPresented = false
    @Published private(set) var onboardingAnimationIsEnabled = false
    @Published private(set) var navigationPath: [AppRoute] = []

    private var onboardingIsShown: Bool
    private var sessionNumber: Int
    private var currentScenePhase: ScenePhase?
    private var activeSessionID: String?
    private var activeSessionStartedAt: Date?
    private var reviewPromptTask: Task<Void, Never>?

    private let analyticsService: AnalyticsService
    private let reviewService: ReviewService
    private let delay: Delay
    private let featureFlags: FeatureFlags
    private let rootStateStore: RootStateStore

    // MARK: - Initialization

    init(
        analyticsService: AnalyticsService,
        reviewService: ReviewService,
        delay: Delay,
        featureFlags: FeatureFlags,
        rootStateStore: RootStateStore
    ) {
        self.analyticsService = analyticsService
        self.reviewService = reviewService
        self.delay = delay
        self.featureFlags = featureFlags
        self.rootStateStore = rootStateStore
        onboardingIsShown = rootStateStore.onboardingIsShown()
        sessionNumber = rootStateStore.sessionNumber()
    }

    // MARK: - Public Methods

    enum Action {
        case rootLifecycleStarted
        case scenePhaseChanged(ScenePhase)
        case mainMenuRouteRequested(MainMenuRoute)
        case mainMenuFeedbackRequested
        case handleReviewNo
        case handleReviewYes
        case updateOnboardingShown(Bool)
        case setAlertPresented(Bool)
        case setNavigationPath([AppRoute])
    }

    func send(_ action: Action) {
        if handleLifecycleAndNavigationAction(action) {
            return
        }
        if handleReviewAction(action) {
            return
        }
        handlePresentationAction(action)
    }

    /// Проверяет, нужно ли показать onboarding
    var shouldShowOnboarding: Bool {
        featureFlags.onboarding && !onboardingIsShown
    }

    /// Проверяет, нужно ли показать onboarding с анимацией
    var shouldShowOnboardingWithAnimation: Bool {
        shouldShowOnboarding && onboardingAnimationIsEnabled
    }

    /// Возвращает текущее состояние onboarding
    var isOnboardingShown: Bool {
        onboardingIsShown || !featureFlags.onboarding
    }

    /// Заголовок для запроса отзыва.
    func requestReviewTitle(locale: Locale) -> String {
        RootLocalizationKey.reviewRequestTitle.localized(locale)
    }
}

// MARK: - Private Methods

private extension RootViewModel {
    var requestReviewWasShown: Bool {
        get { rootStateStore.requestReviewWasShown() }
        set { rootStateStore.setRequestReviewWasShown(newValue) }
    }

    @discardableResult
    func handleLifecycleAndNavigationAction(_ action: Action) -> Bool {
        switch action {
        case .rootLifecycleStarted:
            handleRootLifecycleStarted()
            return true
        case let .scenePhaseChanged(phase):
            handleScenePhaseChanged(phase)
            return true
        case let .mainMenuRouteRequested(route):
            handleMainMenuRouteRequested(route)
            return true
        case .mainMenuFeedbackRequested:
            handleMainMenuFeedbackRequested()
            return true
        default:
            return false
        }
    }

    @discardableResult
    func handleReviewAction(_ action: Action) -> Bool {
        switch action {
        case .handleReviewNo:
            handleReviewNoInternal()
            return true
        case .handleReviewYes:
            Task { await handleReviewYesInternal() }
            return true
        case let .updateOnboardingShown(value):
            updateOnboardingShownInternal(value)
            return true
        default:
            return false
        }
    }

    func handlePresentationAction(_ action: Action) {
        switch action {
        case let .setAlertPresented(isPresented):
            guard alertIsPresented != isPresented else { return }
            alertIsPresented = isPresented
        case let .setNavigationPath(path):
            guard navigationPath != path else { return }
            navigationPath = path
        default:
            break
        }
    }

    func handleRootLifecycleStarted() {
        enableOnboardingAnimation()
    }

    func enableOnboardingAnimation() {
        onboardingAnimationIsEnabled = true
    }

    func handleScenePhaseChanged(_ phase: ScenePhase) {
        guard currentScenePhase != phase else { return }

        let previousPhase = currentScenePhase
        currentScenePhase = phase

        switch phase {
        case .active:
            startSessionIfNeeded(startReason: sessionStartReason(previousPhase: previousPhase).rawValue)
        case .background, .inactive:
            if previousPhase == .active {
                endSessionIfNeeded(endReason: sessionEndReason(nextPhase: phase).rawValue)
            }
        @unknown default:
            break
        }
    }

    func startSessionIfNeeded(startReason: String) {
        guard activeSessionStartedAt == nil else { return }

        sessionNumber += 1
        rootStateStore.setSessionNumber(sessionNumber)
        let sessionID = UUID().uuidString
        rootStateStore.setSessionID(sessionID)
        activeSessionID = sessionID
        activeSessionStartedAt = Date()

        analyticsService.log(
            event: .appSessionStarted(
                startReason: startReason,
                isFirstSession: sessionNumber == 1,
                featureOnboardingEnabled: featureFlags.onboarding,
                featureReviewPromptEnabled: featureFlags.reviewPrompt
            )
        )

        requestReviewIfNeeded(sessionID: sessionID)
    }

    func endSessionIfNeeded(endReason: String) {
        guard let startedAt = activeSessionStartedAt else { return }
        reviewPromptTask?.cancel()
        reviewPromptTask = nil
        activeSessionStartedAt = nil
        activeSessionID = nil

        let durationSeconds = max(0, Int(Date().timeIntervalSince(startedAt)))
        analyticsService.log(
            event: .appSessionEnded(
                durationSeconds: durationSeconds,
                endReason: endReason
            )
        )
        rootStateStore.setSessionID(nil)
    }

    func requestReviewIfNeeded(sessionID: String) {
        guard featureFlags.reviewPrompt else { return }
#if !DEBUG
        reviewPromptTask?.cancel()
        let scheduledSessionNumber = sessionNumber
        reviewPromptTask = Task {
            await delay.sleep(nanoseconds: RootConstants.reviewRequestDelay)
            guard !Task.isCancelled else { return }
            guard activeSessionID == sessionID else { return }
            if !requestReviewWasShown,
               scheduledSessionNumber >= 2,
               isOnboardingShown,
               activeSessionStartedAt != nil {
                alertIsPresented = true
                requestReviewWasShown = true
                analyticsService.log(event: .reviewPromptDisplayed)
            }
        }
#endif
    }

    func handleReviewNoInternal() {
        alertIsPresented = false
        analyticsService.log(event: .reviewPromptAnswered(answer: ReviewAnswer.noAnswer.rawValue))
    }

    func handleReviewYesInternal() async {
        alertIsPresented = false
        await reviewService.requestReview()
        analyticsService.log(event: .reviewPromptAnswered(answer: ReviewAnswer.yes.rawValue))
    }

    func updateOnboardingShownInternal(_ value: Bool) {
        guard featureFlags.onboarding else {
            return
        }
        onboardingIsShown = value
        rootStateStore.setOnboardingIsShown(value)
    }

    func handleMainMenuRouteRequested(_ route: MainMenuRoute) {
        if case let .section(section) = route {
            analyticsService.log(event: .navigationSectionOpened(section: section.rawValue))
        }
        let appRoute = AppRoute.mainMenu(route)
        if navigationPath.last != appRoute {
            navigationPath.append(appRoute)
        }
    }

    func handleMainMenuFeedbackRequested() {
        analyticsService.log(
            event: .feedbackEmailOpened(
                sourceScreen: AnalyticsValues.feedbackSourceMainMenu
            )
        )
    }

    private func sessionStartReason(previousPhase: ScenePhase?) -> SessionStartReason {
        switch previousPhase {
        case .none:
            return .initialLaunch
        case .background:
            return .foregroundFromBackground
        case .inactive:
            return .foregroundFromInactive
        case .active:
            return .foregroundFromUnknown
        @unknown default:
            return .foregroundFromUnknown
        }
    }

    private func sessionEndReason(nextPhase: ScenePhase) -> SessionEndReason {
        switch nextPhase {
        case .background:
            return .enteredBackground
        case .inactive:
            return .enteredInactive
        case .active:
            return .enteredInactive
        @unknown default:
            return .enteredInactive
        }
    }
}
