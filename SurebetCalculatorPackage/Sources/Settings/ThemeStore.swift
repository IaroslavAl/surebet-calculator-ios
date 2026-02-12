import Foundation

public protocol ThemeStore: Sendable {
    func loadTheme() -> SettingsTheme
    func saveTheme(_ theme: SettingsTheme)
}

public struct UserDefaultsThemeStore: ThemeStore, @unchecked Sendable {
    private let userDefaults: UserDefaults

    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    public func loadTheme() -> SettingsTheme {
        let rawValue = userDefaults.string(forKey: SettingsStorage.themeKey)
            ?? SettingsTheme.system.rawValue
        return SettingsTheme(rawValue: rawValue) ?? .system
    }

    public func saveTheme(_ theme: SettingsTheme) {
        userDefaults.set(theme.rawValue, forKey: SettingsStorage.themeKey)
    }
}
