@testable import Onboarding

/// Мок для OnboardingAnalytics для использования в тестах
/// Хранит историю вызовов для проверки в тестах
final class MockOnboardingAnalytics: OnboardingAnalytics, @unchecked Sendable {
    enum Event: Equatable {
        case onboardingStarted
        case onboardingPageViewed(pageIndex: Int, pageID: String)
        case onboardingCompleted(pagesViewed: Int)
        case onboardingSkipped(lastPageIndex: Int)
    }

    private(set) var events: [Event] = []

    var eventCallCount: Int {
        events.count
    }

    func onboardingStarted() {
        events.append(.onboardingStarted)
    }

    func onboardingPageViewed(pageIndex: Int, pageID: String) {
        events.append(.onboardingPageViewed(pageIndex: pageIndex, pageID: pageID))
    }

    func onboardingCompleted(pagesViewed: Int) {
        events.append(.onboardingCompleted(pagesViewed: pagesViewed))
    }

    func onboardingSkipped(lastPageIndex: Int) {
        events.append(.onboardingSkipped(lastPageIndex: lastPageIndex))
    }
}
