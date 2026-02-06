import SwiftUI

/// ViewModel экрана настроек.
@MainActor
final class SettingsViewModel: ObservableObject {
    // MARK: - Properties

    @Published private(set) var selectedTheme: SettingsTheme = .system
    @Published private(set) var selectedLanguage: SettingsLanguage = .system

    @AppStorage(SettingsStorage.themeKey) private var themeRawValue = SettingsTheme.system.rawValue
    @AppStorage(SettingsStorage.languageKey) private var languageRawValue = SettingsLanguage.system.rawValue

    // MARK: - Initialization

    init() {
        selectedTheme = SettingsTheme(rawValue: themeRawValue) ?? .system
        selectedLanguage = SettingsLanguage(rawValue: languageRawValue) ?? .system
    }

    // MARK: - Public Methods

    enum Action {
        case selectTheme(SettingsTheme)
        case selectLanguage(SettingsLanguage)
    }

    func send(_ action: Action) {
        switch action {
        case let .selectTheme(theme):
            setTheme(theme)
        case let .selectLanguage(language):
            setLanguage(language)
        }
    }
}

// MARK: - Private Methods

private extension SettingsViewModel {
    func setTheme(_ theme: SettingsTheme) {
        guard selectedTheme != theme else { return }
        selectedTheme = theme
        themeRawValue = theme.rawValue
    }

    func setLanguage(_ language: SettingsLanguage) {
        guard language.isSelectable else { return }
        guard selectedLanguage != language else { return }
        selectedLanguage = language
        languageRawValue = language.rawValue
    }
}
