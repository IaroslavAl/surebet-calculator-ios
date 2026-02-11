import Foundation

public enum FeatureFlagOverrideStore: Sendable {
    public static func value(
        for key: FeatureKey,
        userDefaults: UserDefaults = .standard
    ) -> Bool? {
        let storageKey = key.overrideStorageKey
        guard userDefaults.object(forKey: storageKey) != nil else {
            return nil
        }
        return userDefaults.bool(forKey: storageKey)
    }

    public static func set(
        _ value: Bool?,
        for key: FeatureKey,
        userDefaults: UserDefaults = .standard
    ) {
        let storageKey = key.overrideStorageKey
        guard let value else {
            userDefaults.removeObject(forKey: storageKey)
            return
        }
        userDefaults.set(value, forKey: storageKey)
    }

    public static func reset(
        _ key: FeatureKey,
        userDefaults: UserDefaults = .standard
    ) {
        userDefaults.removeObject(forKey: key.overrideStorageKey)
    }

    public static func resetAll(userDefaults: UserDefaults = .standard) {
        for key in FeatureKey.allCases {
            userDefaults.removeObject(forKey: key.overrideStorageKey)
        }
    }

    public static func allOverrides(userDefaults: UserDefaults = .standard) -> [FeatureKey: Bool] {
        var result: [FeatureKey: Bool] = [:]
        for key in FeatureKey.allCases {
            if let value = value(for: key, userDefaults: userDefaults) {
                result[key] = value
            }
        }
        return result
    }
}
