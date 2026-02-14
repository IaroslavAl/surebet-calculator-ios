import Foundation
import Testing
@testable import FeatureToggles

@Suite(.serialized)
struct DefaultFeatureFlagsProviderTests {
    @Test
    func releaseDefaultsWhenNoOverrides() {
        let (suiteName, defaults) = makeIsolatedDefaults()
        defer { cleanupDefaults(suiteName: suiteName) }

        let provider = DefaultFeatureFlagsProvider(
            launchArguments: [],
            userDefaults: defaults
        )

        #expect(provider.snapshot() == .releaseDefaults)
        #expect(provider.isEnabled(.onboarding) == false)
        #expect(provider.isEnabled(.reviewPrompt) == true)
    }

    @Test
    func launchArgumentsOverrideDefaults() {
        let (suiteName, defaults) = makeIsolatedDefaults()
        defer { cleanupDefaults(suiteName: suiteName) }

        let provider = DefaultFeatureFlagsProvider(
            launchArguments: [
                "-enableOnboarding",
                "-enableReviewPrompt",
                "-disableReviewPrompt",
            ],
            userDefaults: defaults
        )

        #expect(provider.isEnabled(.onboarding) == true)
        // disable wins over enable for deterministic conflict resolution
        #expect(provider.isEnabled(.reviewPrompt) == false)
    }

    @Test
    func persistedOverridesHaveHighestPriority() {
        let (suiteName, defaults) = makeIsolatedDefaults()
        defer { cleanupDefaults(suiteName: suiteName) }

        FeatureFlagOverrideStore.set(false, for: .onboarding, userDefaults: defaults)
        FeatureFlagOverrideStore.set(true, for: .reviewPrompt, userDefaults: defaults)

        let provider = DefaultFeatureFlagsProvider(
            launchArguments: [
                "-enableOnboarding",
                "-disableReviewPrompt",
            ],
            userDefaults: defaults
        )

        #expect(provider.isEnabled(.onboarding) == false)
        #expect(provider.isEnabled(.reviewPrompt) == true)
    }

    @Test
    func resetFeatureOverridesLaunchArgumentClearsPersistedValues() {
        let (suiteName, defaults) = makeIsolatedDefaults()
        defer { cleanupDefaults(suiteName: suiteName) }

        FeatureFlagOverrideStore.set(true, for: .onboarding, userDefaults: defaults)
        FeatureFlagOverrideStore.set(false, for: .reviewPrompt, userDefaults: defaults)

        let provider = DefaultFeatureFlagsProvider(
            launchArguments: ["-resetFeatureOverrides"],
            userDefaults: defaults
        )

        #expect(FeatureFlagOverrideStore.value(for: .onboarding, userDefaults: defaults) == nil)
        #expect(FeatureFlagOverrideStore.value(for: .reviewPrompt, userDefaults: defaults) == nil)
        #expect(provider.snapshot() == .releaseDefaults)
    }

    private func makeIsolatedDefaults() -> (suiteName: String, defaults: UserDefaults) {
        let suiteName = "feature-toggles-tests-\(UUID().uuidString)"
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            fatalError("Failed to create isolated UserDefaults suite: \(suiteName)")
        }
        defaults.removePersistentDomain(forName: suiteName)
        return (suiteName, defaults)
    }

    private func cleanupDefaults(suiteName: String) {
        UserDefaults.standard.removePersistentDomain(forName: suiteName)
    }
}
