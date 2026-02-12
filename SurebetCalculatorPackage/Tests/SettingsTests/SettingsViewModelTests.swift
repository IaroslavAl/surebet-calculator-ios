import Testing
@testable import Settings

@MainActor
struct SettingsViewModelTests {
    @Test
    func initLoadsThemeFromStore() {
        let store = MockThemeStore(initialTheme: .dark)

        let viewModel = SettingsViewModel(themeStore: store)

        #expect(viewModel.selectedTheme == .dark)
        #expect(store.loadCallCount == 1)
    }

    @Test
    func selectThemePersistsToStore() {
        let store = MockThemeStore(initialTheme: .system)
        let viewModel = SettingsViewModel(themeStore: store)

        viewModel.send(.selectTheme(.light))

        #expect(viewModel.selectedTheme == .light)
        #expect(store.savedThemes == [.light])
    }

    @Test
    func selectSameThemeDoesNotPersistAgain() {
        let store = MockThemeStore(initialTheme: .system)
        let viewModel = SettingsViewModel(themeStore: store)

        viewModel.send(.selectTheme(.system))

        #expect(store.savedThemes.isEmpty)
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
