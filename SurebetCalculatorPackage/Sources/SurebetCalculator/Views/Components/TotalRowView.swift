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
    var betSizeLabel: String { String(localized: "Total bet size") }
    var profitPercentageLabel: String { String(localized: "Profit percentage") }
    var placeholder: String { String(localized: "Total bet size") }
    var spacing: CGFloat { isIPad ? AppConstants.Padding.medium : AppConstants.Padding.small }

    var totalBetSizeColumn: some View {
        VStack(spacing: spacing) {
            Text(betSizeLabel)
            TextFieldView(
                placeholder: placeholder,
                focusableField: .totalBetSize
            )
        }
    }

    var profitPercentageColumn: some View {
        VStack(spacing: spacing) {
            Text(profitPercentageLabel)
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
