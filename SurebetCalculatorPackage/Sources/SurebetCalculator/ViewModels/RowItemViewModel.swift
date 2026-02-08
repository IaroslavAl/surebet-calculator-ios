import Foundation

@MainActor
final class RowItemViewModel: ObservableObject, Identifiable {
    let id: RowID
    @Published private(set) var state: RowItemState

    init(id: RowID, state: RowItemState) {
        self.id = id
        self.state = state
    }

    func apply(_ newState: RowItemState) {
        guard state != newState else { return }
        state = newState
    }
}
