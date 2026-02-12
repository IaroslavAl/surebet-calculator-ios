import SwiftUI

/// ViewModel экрана настроек.
@MainActor
final class SettingsViewModel: ObservableObject {
    // MARK: - Properties

    @Published private(set) var selectedTheme: SettingsTheme = .system
    private let themeStore: any ThemeStore

    // MARK: - Initialization

    init(themeStore: any ThemeStore) {
        self.themeStore = themeStore
        selectedTheme = themeStore.loadTheme()
    }

    // MARK: - Public Methods

    enum Action {
        case selectTheme(SettingsTheme)
    }

    func send(_ action: Action) {
        switch action {
        case let .selectTheme(theme):
            setTheme(theme)
        }
    }
}

// MARK: - Private Methods

private extension SettingsViewModel {
    func setTheme(_ theme: SettingsTheme) {
        guard selectedTheme != theme else { return }
        selectedTheme = theme
        themeStore.saveTheme(theme)
    }
}
