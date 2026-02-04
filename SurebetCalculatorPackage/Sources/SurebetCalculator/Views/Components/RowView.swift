import SwiftUI

struct RowView: View {
    // MARK: - Properties

    @EnvironmentObject private var viewModel: SurebetCalculatorViewModel

    let rowId: RowID
    let displayIndex: Int

    // MARK: - Body

    var body: some View {
        HStack(spacing: columnSpacing) {
            ToggleButton(row: .row(rowId))
                .frame(width: selectionIndicatorSize)
            coefficient
                .frame(maxWidth: .infinity)
            betSize
                .frame(maxWidth: .infinity)
            income
                .frame(maxWidth: .infinity)
        }
        .padding(rowPadding)
        .background(isSelected ? AppColors.surfaceElevated : AppColors.surface)
        .cornerRadius(rowCornerRadius)
        .overlay {
            RoundedRectangle(cornerRadius: rowCornerRadius)
                .stroke(isSelected ? AppColors.accent : AppColors.borderMuted, lineWidth: 1)
        }
    }
}

// MARK: - Private Computed Properties

private extension RowView {
    var coefficientText: String { SurebetCalculatorLocalizationKey.coefficient.localized }
    var betSizeText: String { SurebetCalculatorLocalizationKey.betSize.localized }
    var columnSpacing: CGFloat { isIPad ? AppConstants.Padding.medium : AppConstants.Padding.small }
    var rowPadding: CGFloat { isIPad ? AppConstants.Padding.small : AppConstants.Padding.small }
    var rowCornerRadius: CGFloat { isIPad ? AppConstants.CornerRadius.large : AppConstants.CornerRadius.medium }
    var selectionIndicatorSize: CGFloat { isIPad ? 36 : 32 }
    var isSelected: Bool { viewModel.selection == .row(rowId) }

    var betSize: some View {
        TextFieldView(
            placeholder: betSizeText,
            focusableField: .rowBetSize(rowId)
        )
    }

    var coefficient: some View {
        TextFieldView(
            placeholder: coefficientText,
            focusableField: .rowCoefficient(rowId)
        )
    }

    var income: some View {
        TextView(
            text: viewModel.row(for: rowId)?.income ?? "0",
            isPercent: false,
            accessibilityId: AccessibilityIdentifiers.Row.incomeText(displayIndex)
        )
    }
}

#Preview {
    RowView(rowId: RowID(rawValue: 0), displayIndex: 0)
        .padding(.trailing)
        .environmentObject(SurebetCalculatorViewModel())
}
