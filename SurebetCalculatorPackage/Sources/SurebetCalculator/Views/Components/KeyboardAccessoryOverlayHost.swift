import SwiftUI
import UIKit

struct KeyboardAccessoryOverlayHost: UIViewRepresentable {
    let onClear: () -> Void
    let onDone: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.update(onClear: onClear, onDone: onDone, in: uiView)
    }

    static func dismantleUIView(_ uiView: UIView, coordinator: Coordinator) {
        coordinator.teardown()
    }

    @MainActor
    final class Coordinator {
        private let manager = KeyboardAccessoryOverlayManager()

        func update(onClear: @escaping () -> Void, onDone: @escaping () -> Void, in view: UIView) {
            manager.updateActions(onClear: onClear, onDone: onDone)
            manager.attach(to: view)
        }

        func teardown() {
            manager.teardown()
        }
    }
}

#Preview {
    KeyboardAccessoryOverlayHost(onClear: {}, onDone: {})
}
