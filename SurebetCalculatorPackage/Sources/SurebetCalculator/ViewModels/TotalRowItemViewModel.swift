import Foundation

@MainActor
final class TotalRowItemViewModel: ObservableObject {
    @Published private(set) var state: TotalRowItemState

    init(state: TotalRowItemState) {
        self.state = state
    }

    func apply(_ newState: TotalRowItemState) {
        guard state != newState else { return }
        state = newState
    }
}
