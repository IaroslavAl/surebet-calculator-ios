import SwiftUI

struct RowView: View {
    // MARK: - Properties

    @EnvironmentObject private var viewModel: SurebetCalculatorViewModel

    let rowId: RowID
    let displayIndex: Int

    // MARK: - Body

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            ToggleButton(row: .row(rowId))
            HStack(spacing: spacing) {
                betSize
                coefficient
                income
            }
        }
    }
}

// MARK: - Private Computed Properties

private extension RowView {
    var coefficientText: String { SurebetCalculatorLocalizationKey.coefficient.localized }
    var betSizeText: String { SurebetCalculatorLocalizationKey.betSize.localized }
    var incomeText: String { SurebetCalculatorLocalizationKey.income.localized }
    var spacing: CGFloat { isIPad ? AppConstants.Padding.medium : AppConstants.Padding.small }

    var betSize: some View {
        VStack(spacing: spacing) {
            if displayIndex == 0 {
                Text(betSizeText)
                    .font(AppConstants.Typography.label)
            }
            TextFieldView(
                placeholder: betSizeText,
                focusableField: .rowBetSize(rowId)
            )
        }
    }

    var coefficient: some View {
        VStack(spacing: spacing) {
            if displayIndex == 0 {
                Text(coefficientText)
                    .font(AppConstants.Typography.label)
            }
            TextFieldView(
                placeholder: coefficientText,
                focusableField: .rowCoefficient(rowId)
            )
        }
    }

    var income: some View {
        VStack(spacing: spacing) {
            if displayIndex == 0 {
                Text(incomeText)
                    .font(AppConstants.Typography.label)
            }
            TextView(
                text: viewModel.row(for: rowId)?.income ?? "0",
                isPercent: false,
                accessibilityId: AccessibilityIdentifiers.Row.incomeText(displayIndex)
            )
        }
    }
}

#Preview {
    RowView(rowId: RowID(rawValue: 0), displayIndex: 0)
        .padding(.trailing)
        .environmentObject(SurebetCalculatorViewModel())
}
