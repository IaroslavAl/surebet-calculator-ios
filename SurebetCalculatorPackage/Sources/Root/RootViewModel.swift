import AnalyticsManager
import Banner
import Foundation
import ReviewHandler
import SwiftUI

/// ViewModel для управления состоянием и бизнес-логикой RootView
@MainActor
final class RootViewModel: ObservableObject {
    // MARK: - Properties

    @Published private(set) var alertIsPresented = false
    @Published private(set) var fullscreenBannerIsPresented = false
    @Published private(set) var isAnimation = false

    @AppStorage("onboardingIsShown") private var onboardingIsShown = false
    @AppStorage("1.7.0") private var requestReviewWasShown = false
    @AppStorage("numberOfOpenings") private var numberOfOpenings = 0

    private let analyticsService: AnalyticsService
    private let reviewService: ReviewService
    private let delay: Delay
    private let isOnboardingEnabled: Bool
    private let bannerFetcher: @Sendable () async -> Void
    private let bannerCacheChecker: @Sendable () -> Bool

    private var bannerFetchTask: Task<Void, Never>?

    // MARK: - Initialization

    init(
        analyticsService: AnalyticsService = AnalyticsManager(),
        reviewService: ReviewService = ReviewHandler(),
        delay: Delay = SystemDelay(),
        isOnboardingEnabled: Bool = true,
        bannerFetcher: @escaping @Sendable () async -> Void = { try? await Banner.fetchBanner() },
        bannerCacheChecker: @escaping @Sendable () -> Bool = { Banner.isBannerFullyCached }
    ) {
        self.analyticsService = analyticsService
        self.reviewService = reviewService
        self.delay = delay
        self.isOnboardingEnabled = isOnboardingEnabled
        self.bannerFetcher = bannerFetcher
        self.bannerCacheChecker = bannerCacheChecker

        if !isOnboardingEnabled {
            onboardingIsShown = true
        }
    }

    // MARK: - Public Methods

    enum Action {
        case onAppear
        case showOnboardingView
        case showRequestReview
        case showFullscreenBanner
        case fetchBanner
        case handleReviewNo
        case handleReviewYes
        case updateOnboardingShown(Bool)
        case setAlertPresented(Bool)
        case setFullscreenBannerPresented(Bool)
    }

    func send(_ action: Action) {
        switch action {
        case .onAppear:
            handleOnAppear()
        case .showOnboardingView:
            enableOnboardingAnimation()
        case .showRequestReview:
            requestReviewIfNeeded()
        case .showFullscreenBanner:
            showFullscreenBannerIfAvailable()
        case .fetchBanner:
            fetchBannerIfNeeded()
        case .handleReviewNo:
            handleReviewNoInternal()
        case .handleReviewYes:
            Task { await handleReviewYesInternal() }
        case let .updateOnboardingShown(value):
            updateOnboardingShownInternal(value)
        case let .setAlertPresented(isPresented):
            alertIsPresented = isPresented
        case let .setFullscreenBannerPresented(isPresented):
            fullscreenBannerIsPresented = isPresented
        }
    }

    /// Проверяет, нужно ли показать onboarding
    var shouldShowOnboarding: Bool {
        isOnboardingEnabled && !onboardingIsShown
    }

    /// Проверяет, нужно ли показать onboarding с анимацией
    var shouldShowOnboardingWithAnimation: Bool {
        shouldShowOnboarding && isAnimation
    }

    /// Возвращает текущее состояние onboarding
    var isOnboardingShown: Bool {
        onboardingIsShown || !isOnboardingEnabled
    }

    /// Заголовок для запроса отзыва.
    func requestReviewTitle(locale: Locale) -> String {
        RootLocalizationKey.reviewRequestTitle.localized(locale)
    }

    /// Проверяет, доступен ли fullscreen баннер для показа
    var fullscreenBannerIsAvailable: Bool {
        isOnboardingShown && requestReviewWasShown && numberOfOpenings.isMultiple(of: 3)
    }
}

// MARK: - Private Methods

private extension RootViewModel {
    func handleOnAppear() {
        numberOfOpenings += 1
        analyticsService.log(event: .appOpened(sessionNumber: numberOfOpenings))
    }

    func enableOnboardingAnimation() {
        isAnimation = true
    }

    func showFullscreenBannerIfAvailable() {
        guard RootConstants.isBannerFetchEnabled, fullscreenBannerIsAvailable else { return }
        guard bannerCacheChecker() else { return }
        fullscreenBannerIsPresented = true
    }

    func requestReviewIfNeeded() {
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
        guard isOnboardingEnabled else {
            onboardingIsShown = true
            return
        }
        onboardingIsShown = value
    }

    func fetchBannerIfNeeded() {
        guard RootConstants.isBannerFetchEnabled, bannerFetchTask == nil else { return }
        bannerFetchTask = Task { @MainActor [weak self] in
            guard let self else { return }
            let bannerFetcher = self.bannerFetcher
            let fetchTask = Task.detached(priority: .utility) {
                await bannerFetcher()
            }
            await fetchTask.value
            self.bannerFetchTask = nil
        }
    }
}
