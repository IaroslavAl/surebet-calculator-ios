import SwiftUI
import DesignSystem

struct RowView: View {
    // MARK: - Properties

    @ObservedObject var viewModel: RowItemViewModel
    @Environment(\.locale) private var locale

    let focusedField: FocusState<FocusableField?>.Binding
    let onSelect: () -> Void
    let onCoefficientChange: (String) -> Void
    let onBetSizeChange: (String) -> Void

    // MARK: - Body

    var body: some View {
        HStack(spacing: columnSpacing) {
            ToggleButton(
                isOn: state.isOn,
                accessibilityIdentifier: AccessibilityIdentifiers.Row.toggleButton(state.displayIndex),
                action: onSelect
            )
                .frame(width: selectionIndicatorSize)
            coefficient
                .frame(maxWidth: .infinity)
            betSize
                .frame(maxWidth: .infinity)
            income
                .frame(maxWidth: .infinity)
        }
        .padding(rowPadding)
        .background(background)
        .cornerRadius(rowCornerRadius)
        .overlay {
            RoundedRectangle(cornerRadius: rowCornerRadius)
                .stroke(isSelected ? DesignSystem.Color.accent : DesignSystem.Color.borderMuted, lineWidth: 1)
        }
    }
}

// MARK: - Private Computed Properties

private extension RowView {
    var state: RowItemState { viewModel.state }
    var coefficientText: String { SurebetCalculatorLocalizationKey.coefficient.localized(locale) }
    var betSizeText: String { SurebetCalculatorLocalizationKey.betSize.localized(locale) }
    var columnSpacing: CGFloat { isIPad ? DesignSystem.Spacing.large : DesignSystem.Spacing.small }
    var rowPadding: CGFloat { isIPad ? DesignSystem.Spacing.large : DesignSystem.Spacing.small }
    var rowCornerRadius: CGFloat { isIPad ? DesignSystem.Radius.large : DesignSystem.Radius.medium }
    var selectionIndicatorSize: CGFloat { isIPad ? 48 : 44 }
    var isSelected: Bool { state.isSelected }

    var betSize: some View {
        TextFieldView(
            placeholder: "",
            label: betSizeText,
            focusableField: .rowBetSize(state.id),
            displayIndex: state.displayIndex,
            focusedField: focusedField,
            text: state.betSize,
            isDisabled: state.isBetSizeDisabled,
            onTextChange: onBetSizeChange
        )
    }

    var coefficient: some View {
        TextFieldView(
            placeholder: "",
            label: coefficientText,
            focusableField: .rowCoefficient(state.id),
            displayIndex: state.displayIndex,
            focusedField: focusedField,
            text: state.coefficient,
            isDisabled: false,
            onTextChange: onCoefficientChange
        )
    }

    var income: some View {
        TextView(
            text: state.income,
            isPercent: false,
            isEmphasized: isSelected,
            accessibilityId: AccessibilityIdentifiers.Row.incomeText(state.displayIndex)
        )
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

private struct RowViewPreview: View {
    @FocusState private var focusedField: FocusableField?

    private let rowViewModel = RowItemViewModel(
        id: RowID(rawValue: 0),
        state: RowItemState(
            id: RowID(rawValue: 0),
            displayIndex: 0,
            isSelected: false,
            isOn: false,
            coefficient: "2",
            betSize: "100",
            income: "10",
            isBetSizeDisabled: true
        )
    )

    var body: some View {
        RowView(
            viewModel: rowViewModel,
            focusedField: $focusedField,
            onSelect: {},
            onCoefficientChange: { _ in },
            onBetSizeChange: { _ in }
        )
        .padding(.trailing)
    }
}

#Preview {
    RowViewPreview()
}
