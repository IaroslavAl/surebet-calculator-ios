import SwiftUI
import DesignSystem

struct TotalRowView: View {
    // MARK: - Properties

    @ObservedObject var viewModel: TotalRowItemViewModel
    @Environment(\.locale) private var locale
    let focusedField: FocusState<FocusableField?>.Binding
    let onSelect: () -> Void
    let onBetSizeChange: (String) -> Void

    // MARK: - Body

    var body: some View {
        HStack(alignment: .bottom, spacing: columnSpacing) {
            ToggleButton(
                isOn: state.isOn,
                accessibilityIdentifier: AccessibilityIdentifiers.TotalRow.toggleButton,
                action: onSelect
            )
                .frame(width: selectionIndicatorSize)
            totalBetSizeColumn
                .frame(maxWidth: .infinity)
            profitPercentageColumn
                .frame(maxWidth: .infinity)
        }
        .padding(cardPadding)
        .background(background)
        .cornerRadius(cardCornerRadius)
        .overlay {
            RoundedRectangle(cornerRadius: cardCornerRadius)
                .stroke(isSelected ? DesignSystem.Color.accent : DesignSystem.Color.borderMuted, lineWidth: 1)
        }
    }
}

// MARK: - Private Computed Properties

private extension TotalRowView {
    var state: TotalRowItemState { viewModel.state }
    var betSizeLabel: String { SurebetCalculatorLocalizationKey.totalBetSize.localized(locale) }
    var profitPercentageLabel: String { SurebetCalculatorLocalizationKey.profitPercentage.localized(locale) }
    var labelSpacing: CGFloat { DesignSystem.Spacing.small }
    var columnSpacing: CGFloat { isIPad ? DesignSystem.Spacing.large : DesignSystem.Spacing.small }
    var cardPadding: CGFloat { isIPad ? DesignSystem.Spacing.large : DesignSystem.Spacing.small }
    var cardCornerRadius: CGFloat { isIPad ? DesignSystem.Radius.large : DesignSystem.Radius.medium }
    var selectionIndicatorSize: CGFloat { isIPad ? 48 : 44 }
    var isSelected: Bool { state.isSelected }

    var totalBetSizeColumn: some View {
        VStack(spacing: labelSpacing) {
            Text(betSizeLabel)
                .font(DesignSystem.Typography.label)
                .foregroundColor(DesignSystem.Color.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            TextFieldView(
                placeholder: "",
                label: betSizeLabel,
                focusableField: .totalBetSize,
                focusedField: focusedField,
                text: state.betSize,
                isDisabled: state.isBetSizeDisabled,
                onTextChange: onBetSizeChange
            )
        }
    }

    var profitPercentageColumn: some View {
        VStack(spacing: labelSpacing) {
            Text(profitPercentageLabel)
                .font(DesignSystem.Typography.label)
                .foregroundColor(DesignSystem.Color.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            TextView(
                text: state.profitPercentage,
                isPercent: true,
                isEmphasized: isSelected,
                accessibilityId: AccessibilityIdentifiers.TotalRow.profitPercentageText
            )
        }
    }

    var background: some View {
        Group {
            if isSelected {
                DesignSystem.Color.surfaceElevated
            } else {
                DesignSystem.Color.surface
            }
        }
    }
}

private struct TotalRowViewPreview: View {
    @FocusState private var focusedField: FocusableField?

    private let viewModel = TotalRowItemViewModel(
        state: TotalRowItemState(
            isSelected: true,
            isOn: true,
            betSize: "1000",
            profitPercentage: "10%",
            isBetSizeDisabled: false
        )
    )

    var body: some View {
        TotalRowView(
            viewModel: viewModel,
            focusedField: $focusedField,
            onSelect: {},
            onBetSizeChange: { _ in }
        )
        .padding(.trailing)
    }
}

#Preview {
    TotalRowViewPreview()
}
