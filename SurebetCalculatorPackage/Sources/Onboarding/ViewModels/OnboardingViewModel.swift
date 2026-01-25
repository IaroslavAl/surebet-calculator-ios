import AnalyticsManager
import Foundation

@MainActor
final class OnboardingViewModel: ObservableObject {
    // MARK: - Properties

    @Published private(set) var currentPage: Int
    @Published private(set) var onboardingIsShown: Bool
    let pages: [OnboardingPage]

    private let analyticsService: AnalyticsService

    // MARK: - Initialization

    init(analyticsService: AnalyticsService = AnalyticsManager()) {
        self.currentPage = 0
        self.onboardingIsShown = false
        self.pages = OnboardingPage.createPages()
        self.analyticsService = analyticsService

        logOnboardingStarted()
        logPageViewed(index: 0)
    }

    // MARK: - Public Methods

    enum ViewAction {
        case setCurrentPage(Int)
        case dismiss
        case skip
    }

    func send(_ action: ViewAction) {
        switch action {
        case let .setCurrentPage(index):
            setCurrentPage(index)
        case .dismiss:
            dismiss()
        case .skip:
            skip()
        }
    }
}

// MARK: - Private Methods

private extension OnboardingViewModel {
    func setCurrentPage(_ index: Int) {
        if pages.indices.contains(index) {
            currentPage = index
            logPageViewed(index: index)
        } else {
            completeOnboarding()
        }
    }

    func dismiss() {
        completeOnboarding()
    }

    func skip() {
        analyticsService.log(event: .onboardingSkipped(lastPageIndex: currentPage))
        onboardingIsShown = true
    }

    func completeOnboarding() {
        analyticsService.log(event: .onboardingCompleted(pagesViewed: currentPage + 1))
        onboardingIsShown = true
    }

    // MARK: - Analytics

    func logOnboardingStarted() {
        analyticsService.log(event: .onboardingStarted)
    }

    func logPageViewed(index: Int) {
        guard pages.indices.contains(index) else { return }
        let page = pages[index]
        analyticsService.log(event: .onboardingPageViewed(pageIndex: index, pageTitle: page.image))
    }
}
