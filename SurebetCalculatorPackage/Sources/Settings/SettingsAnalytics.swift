import Foundation

public protocol SettingsAnalytics: Sendable {
    func settingsThemeChanged(theme: SettingsTheme)
    func settingsLanguageChanged(from: SettingsLanguage, toLanguage: SettingsLanguage)
}

public struct NoopSettingsAnalytics: SettingsAnalytics {
    public init() {}

    public func settingsThemeChanged(theme _: SettingsTheme) {}
    public func settingsLanguageChanged(from _: SettingsLanguage, toLanguage _: SettingsLanguage) {}
}
