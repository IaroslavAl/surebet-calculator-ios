import Foundation

@MainActor
final class OnboardingViewModel: ObservableObject {
    // MARK: - Properties

    @Published private(set) var currentPage: Int
    @Published private(set) var onboardingIsShown: Bool
    @Published private(set) var pages: [OnboardingPage]

    private let analytics: OnboardingAnalytics

    // MARK: - Initialization

    init(
        locale: Locale = .current,
        analytics: OnboardingAnalytics = NoopOnboardingAnalytics()
    ) {
        self.currentPage = 0
        self.onboardingIsShown = false
        self.pages = OnboardingPage.createPages(locale: locale)
        self.analytics = analytics

        logOnboardingStarted()
        logPageViewed(index: 0)
    }

    // MARK: - Public Methods

    enum ViewAction {
        case setCurrentPage(Int)
        case dismiss
        case skip
        case updateLocale(Locale)
    }

    func send(_ action: ViewAction) {
        switch action {
        case let .setCurrentPage(index):
            setCurrentPage(index)
        case .dismiss:
            dismiss()
        case .skip:
            skip()
        case let .updateLocale(locale):
            updateLocale(locale)
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
        analytics.onboardingSkipped(lastPageIndex: currentPage)
        onboardingIsShown = true
    }

    func completeOnboarding() {
        analytics.onboardingCompleted(pagesViewed: currentPage + 1)
        onboardingIsShown = true
    }

    func updateLocale(_ locale: Locale) {
        pages = OnboardingPage.createPages(locale: locale)
    }

    // MARK: - Analytics

    func logOnboardingStarted() {
        analytics.onboardingStarted()
    }

    func logPageViewed(index: Int) {
        guard pages.indices.contains(index) else { return }
        let page = pages[index]
        analytics.onboardingPageViewed(pageIndex: index, pageTitle: page.image)
    }
}
