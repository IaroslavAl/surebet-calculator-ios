import Foundation
import Testing
@testable import Root

@MainActor
struct AppContainerTests {
    @Test
    func liveContainerBuildsRootGraph() {
        let suiteName = "app-container-tests-\(UUID().uuidString)"
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            Issue.record("Failed to create isolated UserDefaults suite")
            return
        }
        defer {
            defaults.removePersistentDomain(forName: suiteName)
        }

        let container = AppContainer.live(userDefaults: defaults)
        let viewModel = container.makeRootViewModel()

        viewModel.send(.onAppear)

        #expect(viewModel.navigationPath.isEmpty)
        #expect(viewModel.alertIsPresented == false)
    }
}
