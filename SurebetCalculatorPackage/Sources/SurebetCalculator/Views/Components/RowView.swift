import SwiftUI
import DesignSystem
import UIKit

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
    var coefficientText: String { SurebetCalculatorLocalizationKey.coefficient.localized }
    var betSizeText: String { SurebetCalculatorLocalizationKey.betSize.localized }
    var columnSpacing: CGFloat { isIPad ? DesignSystem.Spacing.large : DesignSystem.Spacing.small }
    var rowPadding: CGFloat { isIPad ? DesignSystem.Spacing.large : DesignSystem.Spacing.small }
    var rowCornerRadius: CGFloat { isIPad ? DesignSystem.Radius.large : DesignSystem.Radius.medium }
    var selectionIndicatorSize: CGFloat { isIPad ? 48 : 44 }
    var isSelected: Bool { viewModel.selection == .row(rowId) }

    var betSize: some View {
        TextFieldView(
            placeholder: "",
            label: betSizeText,
            focusableField: .rowBetSize(rowId)
        )
    }

    var coefficient: some View {
        TextFieldView(
            placeholder: "",
            label: coefficientText,
            focusableField: .rowCoefficient(rowId)
        )
    }

    var income: some View {
        TextView(
            text: viewModel.row(for: rowId)?.income ?? "0",
            isPercent: false,
            isEmphasized: isSelected,
            accessibilityId: AccessibilityIdentifiers.Row.incomeText(displayIndex)
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
        .contentShape(.rect)
        .onTapGesture(perform: actionWithImpactFeedback)
    }

    func actionWithImpactFeedback() {
        guard viewModel.selection != .row(rowId) else { return }
        withAnimation(DesignSystem.Animation.quickInteraction) {
            viewModel.send(.selectRow(.row(rowId)))
        }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}

#Preview {
    RowView(rowId: RowID(rawValue: 0), displayIndex: 0)
        .padding(.trailing)
        .environmentObject(SurebetCalculatorViewModel())
}
