import SwiftUI

struct KeyboardClearButton: View {
    // MARK: - Properties

    @EnvironmentObject private var viewModel: SurebetCalculatorViewModel

    // MARK: - Body

    var body: some View {
        Button {
            viewModel.send(.clearFocusableField)
        } label: {
            Text(SurebetCalculatorLocalizationKey.clear.localized)
                .foregroundColor(.red)
        }
        .accessibilityIdentifier(AccessibilityIdentifiers.Keyboard.clearButton)
    }
}

#Preview {
    KeyboardClearButton()
        .environmentObject(SurebetCalculatorViewModel())
}
