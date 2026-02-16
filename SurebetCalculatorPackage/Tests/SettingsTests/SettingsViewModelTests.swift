import Testing
@testable import Settings

@MainActor
struct SettingsViewModelTests {
    @Test
    func initLoadsThemeFromStore() {
        let store = MockThemeStore(initialTheme: .dark)
        let analytics = MockSettingsAnalytics()

        let viewModel = SettingsViewModel(
            themeStore: store,
            analytics: analytics
        )

        #expect(viewModel.selectedTheme == .dark)
        #expect(store.loadCallCount == 1)
    }

    @Test
    func selectThemePersistsToStore() {
        let store = MockThemeStore(initialTheme: .system)
        let analytics = MockSettingsAnalytics()
        let viewModel = SettingsViewModel(
            themeStore: store,
            analytics: analytics
        )

        viewModel.send(.selectTheme(.light))

        #expect(viewModel.selectedTheme == .light)
        #expect(store.savedThemes == [.light])
        #expect(analytics.events == [.themeChanged(theme: .light)])
    }

    @Test
    func selectSameThemeDoesNotPersistAgain() {
        let store = MockThemeStore(initialTheme: .system)
        let analytics = MockSettingsAnalytics()
        let viewModel = SettingsViewModel(
            themeStore: store,
            analytics: analytics
        )

        viewModel.send(.selectTheme(.system))

        #expect(store.savedThemes.isEmpty)
        #expect(analytics.events.isEmpty)
    }

    @Test
    func languageChangedTracksAnalytics() {
        let store = MockThemeStore(initialTheme: .system)
        let analytics = MockSettingsAnalytics()
        let viewModel = SettingsViewModel(
            themeStore: store,
            analytics: analytics
        )

        viewModel.send(.languageChanged(from: .english, toLanguage: .russian))

        #expect(
            analytics.events == [
                .languageChanged(from: .english, toLanguage: .russian)
            ]
        )
    }

    @Test
    func languageChangedWhenSameLanguageSkipsAnalytics() {
        let store = MockThemeStore(initialTheme: .system)
        let analytics = MockSettingsAnalytics()
        let viewModel = SettingsViewModel(
            themeStore: store,
            analytics: analytics
        )

        viewModel.send(.languageChanged(from: .english, toLanguage: .english))

        #expect(analytics.events.isEmpty)
    }
}

@MainActor
private final class MockThemeStore: ThemeStore, @unchecked Sendable {
    private(set) var loadCallCount = 0
    private(set) var savedThemes: [SettingsTheme] = []
    private var currentTheme: SettingsTheme

    init(initialTheme: SettingsTheme) {
        currentTheme = initialTheme
    }

    func loadTheme() -> SettingsTheme {
        loadCallCount += 1
        return currentTheme
    }

    func saveTheme(_ theme: SettingsTheme) {
        currentTheme = theme
        savedThemes.append(theme)
    }
}

@MainActor
private final class MockSettingsAnalytics: SettingsAnalytics, @unchecked Sendable {
    enum Event: Equatable {
        case themeChanged(theme: SettingsTheme)
        case languageChanged(from: SettingsLanguage, toLanguage: SettingsLanguage)
    }

    private(set) var events: [Event] = []

    func settingsThemeChanged(theme: SettingsTheme) {
        events.append(.themeChanged(theme: theme))
    }

    func settingsLanguageChanged(from: SettingsLanguage, toLanguage: SettingsLanguage) {
        events.append(.languageChanged(from: from, toLanguage: toLanguage))
    }
}
