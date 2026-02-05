import SwiftUI
import UIKit

struct NavigationClearButton: View {
    // MARK: - Properties

    @EnvironmentObject private var viewModel: SurebetCalculatorViewModel

    // MARK: - Body

    var body: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            viewModel.send(.clearAll)
        } label: {
            Image(systemName: "trash")
                .font(font)
                .foregroundColor(AppColors.textSecondary)
                .accessibilityLabel(SurebetCalculatorLocalizationKey.clearAll.localized)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(AccessibilityIdentifiers.Calculator.clearButton)
    }

    var font: Font {
        isIPad ? .body : .callout
    }

}

#Preview {
    NavigationClearButton()
        .environmentObject(SurebetCalculatorViewModel())
}
