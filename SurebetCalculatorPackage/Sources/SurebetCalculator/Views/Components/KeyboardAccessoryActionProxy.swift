import Foundation

@MainActor
final class KeyboardAccessoryActionProxy: ObservableObject {
    private var onClear: () -> Void = {}
    private var onDone: () -> Void = {}

    func update(onClear: @escaping () -> Void, onDone: @escaping () -> Void) {
        self.onClear = onClear
        self.onDone = onDone
    }

    func performClear() {
        onClear()
    }

    func performDone() {
        onDone()
    }
}
