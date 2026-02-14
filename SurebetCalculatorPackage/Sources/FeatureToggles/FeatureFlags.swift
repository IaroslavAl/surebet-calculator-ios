public struct FeatureFlags: Sendable, Equatable {
    public let onboarding: Bool
    public let reviewPrompt: Bool

    public init(
        onboarding: Bool,
        reviewPrompt: Bool
    ) {
        self.onboarding = onboarding
        self.reviewPrompt = reviewPrompt
    }

    public subscript(_ key: FeatureKey) -> Bool {
        switch key {
        case .onboarding:
            onboarding
        case .reviewPrompt:
            reviewPrompt
        }
    }

    public static let releaseDefaults = FeatureFlags(
        onboarding: false,
        reviewPrompt: true
    )
}
