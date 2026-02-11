public enum FeatureKey: String, CaseIterable, Sendable {
    case onboarding
    case survey
    case reviewPrompt
    case bannerFetch
    case fullscreenBanner
}

extension FeatureKey {
    var enableLaunchArgument: String {
        switch self {
        case .onboarding:
            return "-enableOnboarding"
        case .survey:
            return "-enableSurvey"
        case .reviewPrompt:
            return "-enableReviewPrompt"
        case .bannerFetch:
            return "-enableBannerFetch"
        case .fullscreenBanner:
            return "-enableFullscreenBanner"
        }
    }

    var disableLaunchArgument: String {
        switch self {
        case .onboarding:
            return "-disableOnboarding"
        case .survey:
            return "-disableSurvey"
        case .reviewPrompt:
            return "-disableReviewPrompt"
        case .bannerFetch:
            return "-disableBannerFetch"
        case .fullscreenBanner:
            return "-disableFullscreenBanner"
        }
    }

    var overrideStorageKey: String {
        "feature_override_\(rawValue)"
    }
}
