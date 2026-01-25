import SwiftUI

struct RowView: View {
    // MARK: - Properties

    @EnvironmentObject private var viewModel: SurebetCalculatorViewModel

    let id: Int

    // MARK: - Body

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            ToggleButton(row: .row(id))
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
            if id == 0 {
                Text(betSizeText)
            }
            TextFieldView(
                placeholder: betSizeText,
                focusableField: .rowBetSize(id)
            )
        }
    }

    var coefficient: some View {
        VStack(spacing: spacing) {
            if id == 0 {
                Text(coefficientText)
            }
            TextFieldView(
                placeholder: coefficientText,
                focusableField: .rowCoefficient(id)
            )
        }
    }

    var income: some View {
        VStack(spacing: spacing) {
            if id == 0 {
                Text(incomeText)
            }
            TextView(
                text: viewModel.rows[id].income,
                isPercent: false,
                accessibilityId: AccessibilityIdentifiers.Row.incomeText(id)
            )
        }
    }
}

#Preview {
    RowView(id: 0)
        .padding(.trailing)
        .environmentObject(SurebetCalculatorViewModel())
}
