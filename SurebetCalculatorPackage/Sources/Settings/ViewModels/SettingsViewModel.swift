import SwiftUI

/// ViewModel экрана настроек.
@MainActor
final class SettingsViewModel: ObservableObject {
    // MARK: - Properties

    @Published private(set) var selectedTheme: SettingsTheme = .system

    @AppStorage(SettingsStorage.themeKey) private var themeRawValue = SettingsTheme.system.rawValue

    // MARK: - Initialization

    init() {
        selectedTheme = SettingsTheme(rawValue: themeRawValue) ?? .system
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
        themeRawValue = theme.rawValue
    }
}
