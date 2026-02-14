import AnalyticsManager
import FeatureToggles
import Foundation
import MainMenu
import ReviewHandler
import SwiftUI

/// ViewModel для управления состоянием и бизнес-логикой RootView
@MainActor
final class RootViewModel: ObservableObject {
    // MARK: - Properties

    @Published private(set) var alertIsPresented = false
    @Published private(set) var isAnimation = false
    @Published private(set) var navigationPath: [AppRoute] = []

    private var onboardingIsShown: Bool
    private var numberOfOpenings: Int

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
        numberOfOpenings = rootStateStore.numberOfOpenings()
    }

    // MARK: - Public Methods

    enum Action {
        case rootLifecycleStarted
        case onAppear
        case showOnboardingView
        case showRequestReview
        case mainMenuRouteRequested(MainMenuRoute)
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
        shouldShowOnboarding && isAnimation
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
        case .onAppear:
            handleOnAppear()
            return true
        case .showOnboardingView:
            enableOnboardingAnimation()
            return true
        case .showRequestReview:
            requestReviewIfNeeded()
            return true
        case let .mainMenuRouteRequested(route):
            handleMainMenuRouteRequested(route)
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

    func handleOnAppear() {
        numberOfOpenings += 1
        rootStateStore.setNumberOfOpenings(numberOfOpenings)
        analyticsService.log(event: .appOpened(sessionNumber: numberOfOpenings))
    }

    func handleRootLifecycleStarted() {
        handleOnAppear()
        enableOnboardingAnimation()
        requestReviewIfNeeded()
    }

    func enableOnboardingAnimation() {
        isAnimation = true
    }

    func requestReviewIfNeeded() {
        guard featureFlags.reviewPrompt else { return }
#if !DEBUG
        Task {
            await delay.sleep(nanoseconds: RootConstants.reviewRequestDelay)
            if !requestReviewWasShown, numberOfOpenings >= 2, isOnboardingShown {
                alertIsPresented = true
                requestReviewWasShown = true
                analyticsService.log(event: .reviewPromptShown)
            }
        }
#endif
    }

    func handleReviewNoInternal() {
        alertIsPresented = false
        analyticsService.log(event: .reviewResponse(enjoyingApp: false))
    }

    func handleReviewYesInternal() async {
        alertIsPresented = false
        await reviewService.requestReview()
        analyticsService.log(event: .reviewResponse(enjoyingApp: true))
    }

    func updateOnboardingShownInternal(_ value: Bool) {
        guard featureFlags.onboarding else {
            return
        }
        onboardingIsShown = value
        rootStateStore.setOnboardingIsShown(value)
    }

    func handleMainMenuRouteRequested(_ route: MainMenuRoute) {
        let appRoute = AppRoute.mainMenu(route)
        if navigationPath.last != appRoute {
            navigationPath.append(appRoute)
        }
    }
}
