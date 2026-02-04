import SwiftUI

struct KeyboardAccessoryToolbar: View {
    // MARK: - Properties

    let onClear: () -> Void
    let onDone: () -> Void

    // MARK: - Body

    var body: some View {
        KeyboardAccessoryToolbarRepresentable(
            onClear: onClear,
            onDone: onDone
        )
        .frame(maxWidth: .infinity)
    }
}

private struct KeyboardAccessoryToolbarRepresentable: UIViewRepresentable {
    let onClear: () -> Void
    let onDone: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onClear: onClear, onDone: onDone)
    }

    func makeUIView(context: Context) -> KeyboardAccessoryToolbarView {
        let view = KeyboardAccessoryToolbarView()
        view.configure(
            onClear: { context.coordinator.onClear() },
            onDone: { context.coordinator.onDone() }
        )
        return view
    }

    func updateUIView(_ uiView: KeyboardAccessoryToolbarView, context: Context) {
        context.coordinator.onClear = onClear
        context.coordinator.onDone = onDone
        uiView.updateActions(
            onClear: { context.coordinator.onClear() },
            onDone: { context.coordinator.onDone() }
        )
    }

    final class Coordinator {
        var onClear: () -> Void
        var onDone: () -> Void

        init(onClear: @escaping () -> Void, onDone: @escaping () -> Void) {
            self.onClear = onClear
            self.onDone = onDone
        }
    }
}

#Preview {
    KeyboardAccessoryToolbar(onClear: {}, onDone: {})
}
