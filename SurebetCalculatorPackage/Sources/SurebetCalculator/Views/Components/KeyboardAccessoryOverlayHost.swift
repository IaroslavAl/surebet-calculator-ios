import SwiftUI
import UIKit

struct KeyboardAccessoryOverlayHost: UIViewRepresentable {
    let actionProxy: KeyboardAccessoryActionProxy

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
        context.coordinator.update(actionProxy: actionProxy, in: uiView)
    }

    static func dismantleUIView(_ uiView: UIView, coordinator: Coordinator) {
        coordinator.teardown()
    }

    @MainActor
    final class Coordinator {
        private let manager = KeyboardAccessoryOverlayManager()

        func update(actionProxy: KeyboardAccessoryActionProxy, in view: UIView) {
            manager.update(actionProxy: actionProxy, in: view)
        }

        func teardown() {
            manager.teardown()
        }
    }
}

#Preview {
    KeyboardAccessoryOverlayHost(actionProxy: KeyboardAccessoryActionProxy())
}
