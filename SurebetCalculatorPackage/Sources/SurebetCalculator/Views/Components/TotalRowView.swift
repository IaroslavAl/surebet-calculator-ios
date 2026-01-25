import SwiftUI

struct TotalRowView: View {
    // MARK: - Properties

    @EnvironmentObject private var viewModel: SurebetCalculatorViewModel

    // MARK: - Body

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            ToggleButton(row: .total)
            HStack(spacing: spacing) {
                totalBetSizeColumn
                profitPercentageColumn
            }
        }
    }
}

// MARK: - Private Computed Properties

private extension TotalRowView {
    var betSizeLabel: String { SurebetCalculatorLocalizationKey.totalBetSize.localized }
    var profitPercentageLabel: String { SurebetCalculatorLocalizationKey.profitPercentage.localized }
    var placeholder: String { SurebetCalculatorLocalizationKey.totalBetSize.localized }
    var spacing: CGFloat { isIPad ? AppConstants.Padding.medium : AppConstants.Padding.small }

    var totalBetSizeColumn: some View {
        VStack(spacing: spacing) {
            Text(betSizeLabel)
                .font(AppConstants.Typography.label)
            TextFieldView(
                placeholder: placeholder,
                focusableField: .totalBetSize
            )
        }
    }

    var profitPercentageColumn: some View {
        VStack(spacing: spacing) {
            Text(profitPercentageLabel)
                .font(AppConstants.Typography.label)
            TextView(
                text: viewModel.total.profitPercentage,
                isPercent: true,
                accessibilityId: AccessibilityIdentifiers.TotalRow.profitPercentageText
            )
        }
    }
}

#Preview {
    TotalRowView()
        .padding(.trailing)
        .environmentObject(SurebetCalculatorViewModel())
}
