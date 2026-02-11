import Foundation

public enum FeatureToggles {
    public static func makeDefaultProvider(
        launchArguments: [String] = ProcessInfo.processInfo.arguments,
        userDefaults: UserDefaults = .standard
    ) -> DefaultFeatureFlagsProvider {
        DefaultFeatureFlagsProvider(
            launchArguments: launchArguments,
            userDefaults: userDefaults
        )
    }
}
