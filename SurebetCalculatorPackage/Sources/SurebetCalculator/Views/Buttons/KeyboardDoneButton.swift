import SwiftUI
import UIKit

struct KeyboardDoneButton: View {
    // MARK: - Properties

    @EnvironmentObject private var viewModel: SurebetCalculatorViewModel
    @Environment(\.locale) private var locale

    // MARK: - Body

    var body: some View {
        Button(text) {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            viewModel.send(.hideKeyboard)
        }
        .accessibilityIdentifier(AccessibilityIdentifiers.Keyboard.doneButton)
    }
}

// MARK: - Private Computed Properties

private extension KeyboardDoneButton {
    var text: String { SurebetCalculatorLocalizationKey.done.localized(locale) }
}

#Preview {
    KeyboardDoneButton()
        .environmentObject(SurebetCalculatorViewModel())
}
