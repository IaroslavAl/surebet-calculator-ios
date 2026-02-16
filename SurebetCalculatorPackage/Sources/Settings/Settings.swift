import SwiftUI

/// Публичная точка входа модуля Settings.
public enum Settings {
    public struct Dependencies: Sendable {
        public let themeStore: any ThemeStore
        public let analytics: any SettingsAnalytics

        public init(
            themeStore: any ThemeStore,
            analytics: any SettingsAnalytics = NoopSettingsAnalytics()
        ) {
            self.themeStore = themeStore
            self.analytics = analytics
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
                themeStore: dependencies.themeStore,
                analytics: dependencies.analytics
            )
        )
    }

    var body: some View {
        SettingsView(viewModel: viewModel)
    }
}
