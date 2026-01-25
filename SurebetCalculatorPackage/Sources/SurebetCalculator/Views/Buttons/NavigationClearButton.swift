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
                .font(font)
                .accessibilityLabel(SurebetCalculatorLocalizationKey.clearAll.localized)
        }
        .accessibilityIdentifier(AccessibilityIdentifiers.Calculator.clearButton)
    }

    var font: Font {
        isIPad ? .body : .title3
    }
}

#Preview {
    NavigationClearButton()
        .environmentObject(SurebetCalculatorViewModel())
}
