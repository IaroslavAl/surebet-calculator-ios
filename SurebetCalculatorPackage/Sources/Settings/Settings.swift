import SwiftUI

/// Публичная точка входа модуля Settings.
public enum Settings {
    public struct Dependencies: Sendable {
        public let themeStore: any ThemeStore

        public init(themeStore: any ThemeStore) {
            self.themeStore = themeStore
        }
    }

    /// Экран настроек приложения.
    @MainActor
    public static func view(dependencies: Dependencies) -> some View {
        SettingsContainerView(dependencies: dependencies)
    }
}

@MainActor
private struct SettingsContainerView: View {
    @StateObject private var viewModel: SettingsViewModel

    init(dependencies: Settings.Dependencies) {
        _viewModel = StateObject(
            wrappedValue: SettingsViewModel(
                themeStore: dependencies.themeStore
            )
        )
    }

    var body: some View {
        SettingsView(viewModel: viewModel)
    }
}
