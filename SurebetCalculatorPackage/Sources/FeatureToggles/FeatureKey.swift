public enum FeatureKey: String, CaseIterable, Sendable {
    case onboarding
    case reviewPrompt
}

extension FeatureKey {
    var enableLaunchArgument: String {
        switch self {
        case .onboarding:
            return "-enableOnboarding"
        case .reviewPrompt:
            return "-enableReviewPrompt"
        }
    }

    var disableLaunchArgument: String {
        switch self {
        case .onboarding:
            return "-disableOnboarding"
        case .reviewPrompt:
            return "-disableReviewPrompt"
        }
    }

    var overrideStorageKey: String {
        "feature_override_\(rawValue)"
    }
}
