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
                .foregroundColor(AppColors.textSecondary)
                .padding(padding)
                .background(AppColors.surface)
                .clipShape(Circle())
                .overlay {
                    Circle()
                        .stroke(AppColors.border, lineWidth: 1)
                }
                .accessibilityLabel(SurebetCalculatorLocalizationKey.clearAll.localized)
        }
        .accessibilityIdentifier(AccessibilityIdentifiers.Calculator.clearButton)
    }

    var font: Font {
        isIPad ? .body : .callout
    }

    var padding: CGFloat {
        isIPad ? AppConstants.Padding.small : 6
    }
}

#Preview {
    NavigationClearButton()
        .environmentObject(SurebetCalculatorViewModel())
}
