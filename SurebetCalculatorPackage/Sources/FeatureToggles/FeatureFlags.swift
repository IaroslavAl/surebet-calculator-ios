public struct FeatureFlags: Sendable, Equatable {
    public let onboarding: Bool
    public let survey: Bool
    public let reviewPrompt: Bool
    public let bannerFetch: Bool
    public let fullscreenBanner: Bool

    public init(
        onboarding: Bool,
        survey: Bool,
        reviewPrompt: Bool,
        bannerFetch: Bool,
        fullscreenBanner: Bool
    ) {
        self.onboarding = onboarding
        self.survey = survey
        self.reviewPrompt = reviewPrompt
        self.bannerFetch = bannerFetch
        self.fullscreenBanner = fullscreenBanner
    }

    public subscript(_ key: FeatureKey) -> Bool {
        switch key {
        case .onboarding:
            onboarding
        case .survey:
            survey
        case .reviewPrompt:
            reviewPrompt
        case .bannerFetch:
            bannerFetch
        case .fullscreenBanner:
            fullscreenBanner
        }
    }

    public static let releaseDefaults = FeatureFlags(
        onboarding: false,
        survey: true,
        reviewPrompt: true,
        bannerFetch: true,
        fullscreenBanner: true
    )
}
