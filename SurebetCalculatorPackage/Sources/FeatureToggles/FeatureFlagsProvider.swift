public protocol FeatureFlagsProvider: Sendable {
    func snapshot() -> FeatureFlags
    func isEnabled(_ key: FeatureKey) -> Bool
}

public extension FeatureFlagsProvider {
    func isEnabled(_ key: FeatureKey) -> Bool {
        snapshot()[key]
    }
}
