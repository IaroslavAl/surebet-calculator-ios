import SwiftUI

/// Публичная точка входа модуля Settings.
public enum Settings {
    /// Экран настроек приложения.
    @MainActor
    public static func view() -> some View {
        SettingsContainerView()
    }
}

@MainActor
private struct SettingsContainerView: View {
    @StateObject private var viewModel = SettingsViewModel()

    var body: some View {
        SettingsView(viewModel: viewModel)
    }
}
