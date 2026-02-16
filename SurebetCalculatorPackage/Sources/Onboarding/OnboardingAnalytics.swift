import Foundation

public protocol OnboardingAnalytics: Sendable {
    func onboardingStarted()
    func onboardingPageViewed(pageIndex: Int, pageID: String)
    func onboardingCompleted(pagesViewed: Int)
    func onboardingSkipped(lastPageIndex: Int)
}

public struct NoopOnboardingAnalytics: OnboardingAnalytics {
    public init() {}

    public func onboardingStarted() {}
    public func onboardingPageViewed(pageIndex _: Int, pageID _: String) {}
    public func onboardingCompleted(pagesViewed: Int) {}
    public func onboardingSkipped(lastPageIndex: Int) {}
}
