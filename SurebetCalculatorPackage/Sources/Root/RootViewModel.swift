import AnalyticsManager
import Banner
import Foundation
import ReviewHandler
import SwiftUI

/// ViewModel для управления состоянием и бизнес-логикой RootView
@MainActor
final class RootViewModel: ObservableObject {
    // MARK: - Properties

    @Published var alertIsPresented = false
    @Published var fullscreenBannerIsPresented = false
    @Published private(set) var isAnimation = false

    @AppStorage("onboardingIsShown") private var onboardingIsShown = false
    @AppStorage("1.7.0") private var requestReviewWasShown = false
    @AppStorage("numberOfOpenings") private var numberOfOpenings = 0

    // MARK: - Initialization

    init() {}

    // MARK: - Public Methods

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
        "Do you like the app?"
    }

    /// Обработка появления экрана
    func onAppear() {
        numberOfOpenings += 1
    }

    /// Показывает onboarding view с анимацией
    func showOnboardingView() {
        withAnimation {
            isAnimation = true
        }
    }

    /// Проверяет и показывает fullscreen баннер, если доступен
    func showFullscreenBanner() {
        if fullscreenBannerIsAvailable, Banner.isBannerFullyCached {
            fullscreenBannerIsPresented = true
        }
    }

    /// Проверяет, доступен ли fullscreen баннер для показа
    var fullscreenBannerIsAvailable: Bool {
        onboardingIsShown && requestReviewWasShown && numberOfOpenings.isMultiple(of: 3)
    }

    /// Проверяет и показывает запрос отзыва, если условия выполнены
    func showRequestReview() {
#if !DEBUG
        Task {
            try await Task.sleep(nanoseconds: NSEC_PER_SEC * 1)
            if !requestReviewWasShown, numberOfOpenings >= 2, onboardingIsShown {
                alertIsPresented = true
                requestReviewWasShown = true
            }
        }
#endif
    }

    /// Обработка ответа "Нет" на запрос отзыва
    func handleReviewNo() {
        alertIsPresented = false
        AnalyticsManager.log(name: "RequestReview", parameters: ["enjoying_calculator": .bool(false)])
    }

    /// Обработка ответа "Да" на запрос отзыва
    func handleReviewYes() async {
        alertIsPresented = false
        await ReviewHandler.requestReview()
        AnalyticsManager.log(name: "RequestReview", parameters: ["enjoying_calculator": .bool(true)])
    }

    /// Обновляет состояние onboarding после его показа
    func updateOnboardingShown(_ value: Bool) {
        onboardingIsShown = value
    }
}
