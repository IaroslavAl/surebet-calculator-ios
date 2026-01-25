import SwiftUI

struct NavigationClearButton: View {
    // MARK: - Properties

    @EnvironmentObject private var viewModel: SurebetCalculatorViewModel

    // MARK: - Body

    var body: some View {
        Button {
            viewModel.send(.clearAll)
        } label: {
            Image(systemName: "trash")
                .accessibilityLabel(SurebetCalculatorLocalizationKey.clearAll.localized)
        }
        .accessibilityIdentifier(AccessibilityIdentifiers.Calculator.clearButton)
    }
}

#Preview {
    NavigationClearButton()
        .environmentObject(SurebetCalculatorViewModel())
}
