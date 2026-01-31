import Foundation

public protocol OnboardingAnalytics: Sendable {
    func onboardingStarted()
    func onboardingPageViewed(pageIndex: Int, pageTitle: String)
    func onboardingCompleted(pagesViewed: Int)
    func onboardingSkipped(lastPageIndex: Int)
}

public struct NoopOnboardingAnalytics: OnboardingAnalytics {
    public init() {}

    public func onboardingStarted() {}
    public func onboardingPageViewed(pageIndex: Int, pageTitle: String) {}
    public func onboardingCompleted(pagesViewed: Int) {}
    public func onboardingSkipped(lastPageIndex: Int) {}
}
