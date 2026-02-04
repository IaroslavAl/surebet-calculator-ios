import SwiftUI
import UIKit

struct KeyboardClearButton: View {
    // MARK: - Properties

    @EnvironmentObject private var viewModel: SurebetCalculatorViewModel

    // MARK: - Body

    var body: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            viewModel.send(.clearFocusableField)
        } label: {
            Text(SurebetCalculatorLocalizationKey.clear.localized)
                .foregroundColor(AppColors.error)
        }
        .accessibilityIdentifier(AccessibilityIdentifiers.Keyboard.clearButton)
    }
}

#Preview {
    KeyboardClearButton()
        .environmentObject(SurebetCalculatorViewModel())
}
