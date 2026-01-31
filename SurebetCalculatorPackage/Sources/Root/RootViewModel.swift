import AnalyticsManager
import Banner
import Foundation
import ReviewHandler
import SurebetCalculator
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

    // MARK: - Initialization

    init(
        analyticsService: AnalyticsService = AnalyticsManager(),
        reviewService: ReviewService = ReviewHandler()
    ) {
        self.analyticsService = analyticsService
        self.reviewService = reviewService
    }

    // MARK: - Public Methods

    enum Action {
        case onAppear
        case showOnboardingView
        case showRequestReview
        case showFullscreenBanner
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
        !onboardingIsShown
    }

    /// Проверяет, нужно ли показать onboarding с анимацией
    var shouldShowOnboardingWithAnimation: Bool {
        shouldShowOnboarding && isAnimation
    }

    /// Возвращает текущее состояние onboarding
    var isOnboardingShown: Bool {
        onboardingIsShown
    }

    /// Заголовок для запроса отзыва
    var requestReviewTitle: String {
        RootLocalizationKey.reviewRequestTitle.localized
    }

    /// Проверяет, доступен ли fullscreen баннер для показа
    var fullscreenBannerIsAvailable: Bool {
        onboardingIsShown && requestReviewWasShown && numberOfOpenings.isMultiple(of: 3)
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
        if fullscreenBannerIsAvailable, Banner.isBannerFullyCached {
            fullscreenBannerIsPresented = true
        }
    }

    func requestReviewIfNeeded() {
#if !DEBUG
        Task {
            try await Task.sleep(nanoseconds: AppConstants.Delays.reviewRequest)
            if !requestReviewWasShown, numberOfOpenings >= 2, onboardingIsShown {
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
        onboardingIsShown = value
    }
}
