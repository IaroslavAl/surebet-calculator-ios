import Foundation

/// Default provider with one-time snapshot resolution on startup.
/// Priority: persisted override > launch arguments > code defaults.
public struct DefaultFeatureFlagsProvider: FeatureFlagsProvider, Sendable {
    private let resolvedFlags: FeatureFlags

    public init(
        launchArguments: [String] = ProcessInfo.processInfo.arguments,
        userDefaults: UserDefaults = .standard,
        defaults: FeatureFlags = .releaseDefaults,
        resetOverridesLaunchArgument: String = "-resetFeatureOverrides"
    ) {
        if launchArguments.contains(resetOverridesLaunchArgument) {
            FeatureFlagOverrideStore.resetAll(userDefaults: userDefaults)
        }

        resolvedFlags = FeatureFlags(
            onboarding: Self.resolveValue(
                for: .onboarding,
                launchArguments: launchArguments,
                userDefaults: userDefaults,
                defaults: defaults
            ),
            survey: Self.resolveValue(
                for: .survey,
                launchArguments: launchArguments,
                userDefaults: userDefaults,
                defaults: defaults
            ),
            reviewPrompt: Self.resolveValue(
                for: .reviewPrompt,
                launchArguments: launchArguments,
                userDefaults: userDefaults,
                defaults: defaults
            ),
            bannerFetch: Self.resolveValue(
                for: .bannerFetch,
                launchArguments: launchArguments,
                userDefaults: userDefaults,
                defaults: defaults
            ),
            fullscreenBanner: Self.resolveValue(
                for: .fullscreenBanner,
                launchArguments: launchArguments,
                userDefaults: userDefaults,
                defaults: defaults
            )
        )
    }

    public func snapshot() -> FeatureFlags {
        resolvedFlags
    }

    public func isEnabled(_ key: FeatureKey) -> Bool {
        resolvedFlags[key]
    }
}

private extension DefaultFeatureFlagsProvider {
    static func resolveValue(
        for key: FeatureKey,
        launchArguments: [String],
        userDefaults: UserDefaults,
        defaults: FeatureFlags
    ) -> Bool {
        if let overrideValue = FeatureFlagOverrideStore.value(for: key, userDefaults: userDefaults) {
            return overrideValue
        }

        if launchArguments.contains(key.disableLaunchArgument) {
            return false
        }

        if launchArguments.contains(key.enableLaunchArgument) {
            return true
        }

        return defaults[key]
    }
}
