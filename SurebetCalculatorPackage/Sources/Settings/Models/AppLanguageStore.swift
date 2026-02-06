import Combine
import Foundation

/// Хранилище выбранного языка приложения.
@MainActor
public final class AppLanguageStore: ObservableObject {
    @Published public private(set) var selectedLanguage: SettingsLanguage

    private let userDefaults: UserDefaults

    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        let stored = userDefaults.string(forKey: SettingsStorage.languageKey)
        selectedLanguage = SettingsLanguage(rawValue: stored ?? SettingsLanguage.system.rawValue) ?? .system
    }

    public var locale: Locale {
        selectedLanguage.locale
    }

    public func setLanguage(_ language: SettingsLanguage) {
        guard language.isSelectable else { return }
        guard selectedLanguage != language else { return }
        selectedLanguage = language
        userDefaults.set(language.rawValue, forKey: SettingsStorage.languageKey)
    }
}
