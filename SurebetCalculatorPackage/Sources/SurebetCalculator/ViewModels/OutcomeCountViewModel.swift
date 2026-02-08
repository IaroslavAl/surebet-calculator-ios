import Foundation

@MainActor
final class OutcomeCountViewModel: ObservableObject {
    @Published private(set) var state: OutcomeCountState

    init(state: OutcomeCountState) {
        self.state = state
    }

    func apply(_ newState: OutcomeCountState) {
        guard state != newState else { return }
        state = newState
    }
}
