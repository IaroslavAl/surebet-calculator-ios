import SwiftUI

/// ViewModel экрана настроек.
@MainActor
final class SettingsViewModel: ObservableObject {
    // MARK: - Properties

    @Published private(set) var selectedTheme: SettingsTheme = .system
    private let themeStore: any ThemeStore
    private let analytics: any SettingsAnalytics

    // MARK: - Initialization

    init(
        themeStore: any ThemeStore,
        analytics: any SettingsAnalytics = NoopSettingsAnalytics()
    ) {
        self.themeStore = themeStore
        self.analytics = analytics
        selectedTheme = themeStore.loadTheme()
    }

    // MARK: - Public Methods

    enum Action {
        case selectTheme(SettingsTheme)
        case languageChanged(from: SettingsLanguage, toLanguage: SettingsLanguage)
    }

    func send(_ action: Action) {
        switch action {
        case let .selectTheme(theme):
            setTheme(theme)
        case let .languageChanged(from, toLanguage):
            trackLanguageChanged(from: from, toLanguage: toLanguage)
        }
    }
}

// MARK: - Private Methods

private extension SettingsViewModel {
    func setTheme(_ theme: SettingsTheme) {
        guard selectedTheme != theme else { return }
        selectedTheme = theme
        themeStore.saveTheme(theme)
        analytics.settingsThemeChanged(theme: theme)
    }

    func trackLanguageChanged(from: SettingsLanguage, toLanguage: SettingsLanguage) {
        guard from != toLanguage else { return }
        analytics.settingsLanguageChanged(from: from, toLanguage: toLanguage)
    }
}
