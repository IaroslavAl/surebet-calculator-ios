import SwiftUI

struct TotalRowView: View {
    // MARK: - Properties

    @EnvironmentObject private var viewModel: SurebetCalculatorViewModel

    // MARK: - Body

    var body: some View {
        HStack(spacing: columnSpacing) {
            ToggleButton(row: .total)
                .frame(width: selectionIndicatorSize)
            HStack(spacing: columnSpacing) {
                totalBetSizeColumn
                    .frame(maxWidth: .infinity)
                profitPercentageColumn
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(cardPadding)
        .background(AppColors.surfaceElevated)
        .cornerRadius(cardCornerRadius)
        .overlay {
            RoundedRectangle(cornerRadius: cardCornerRadius)
                .stroke(isSelected ? AppColors.accent : AppColors.border, lineWidth: 1)
        }
    }
}

// MARK: - Private Computed Properties

private extension TotalRowView {
    var betSizeLabel: String { SurebetCalculatorLocalizationKey.totalBetSize.localized }
    var profitPercentageLabel: String { SurebetCalculatorLocalizationKey.profitPercentage.localized }
    var placeholder: String { SurebetCalculatorLocalizationKey.totalBetSize.localized }
    var labelSpacing: CGFloat { AppConstants.Padding.small }
    var columnSpacing: CGFloat { isIPad ? AppConstants.Padding.medium : AppConstants.Padding.small }
    var cardPadding: CGFloat { isIPad ? AppConstants.Padding.medium : AppConstants.Padding.small }
    var cardCornerRadius: CGFloat { isIPad ? AppConstants.CornerRadius.large : AppConstants.CornerRadius.medium }
    var selectionIndicatorSize: CGFloat { isIPad ? 36 : 32 }
    var isSelected: Bool { viewModel.selection == .total }

    var totalBetSizeColumn: some View {
        VStack(spacing: labelSpacing) {
            Text(betSizeLabel)
                .font(AppConstants.Typography.label)
                .foregroundColor(AppColors.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            TextFieldView(
                placeholder: placeholder,
                focusableField: .totalBetSize
            )
        }
    }

    var profitPercentageColumn: some View {
        VStack(spacing: labelSpacing) {
            Text(profitPercentageLabel)
                .font(AppConstants.Typography.label)
                .foregroundColor(AppColors.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
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
