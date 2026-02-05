import SwiftUI
import DesignSystem
import UIKit

struct KeyboardClearButton: View {
    // MARK: - Properties

    @EnvironmentObject private var viewModel: SurebetCalculatorViewModel
    @Environment(\.locale) private var locale

    // MARK: - Body

    var body: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            viewModel.send(.clearFocusableField)
        } label: {
            Text(SurebetCalculatorLocalizationKey.clear.localized(locale))
                .foregroundColor(DesignSystem.Color.error)
        }
        .accessibilityIdentifier(AccessibilityIdentifiers.Keyboard.clearButton)
    }
}

#Preview {
    KeyboardClearButton()
        .environmentObject(SurebetCalculatorViewModel())
}
