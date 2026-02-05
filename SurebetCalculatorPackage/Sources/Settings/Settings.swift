import SwiftUI

/// Публичная точка входа модуля Settings.
public enum Settings {
    /// Экран настроек приложения.
    @MainActor
    public static func view() -> some View {
        SettingsView(viewModel: SettingsViewModel())
    }
}
