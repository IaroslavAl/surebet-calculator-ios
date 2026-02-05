import SwiftUI
import DesignSystem
import UIKit

struct OutcomeCountControlView: View {
    // MARK: - Properties

    @EnvironmentObject private var viewModel: SurebetCalculatorViewModel

    // MARK: - Body

    var body: some View {
        HStack(spacing: spacing) {
            Text(label)
                .font(DesignSystem.Typography.label)
                .foregroundColor(DesignSystem.Color.textSecondary)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .layoutPriority(1)
            Spacer()
            HStack(spacing: spacing) {
                counterButton(
                    systemName: "minus",
                    isDisabled: isAtMin,
                    accessibilityId: AccessibilityIdentifiers.Calculator.rowCountDecreaseButton,
                    action: { viewModel.send(.removeRow) }
                )
                valuePill
                counterButton(
                    systemName: "plus",
                    isDisabled: isAtMax,
                    accessibilityId: AccessibilityIdentifiers.Calculator.rowCountIncreaseButton,
                    action: { viewModel.send(.addRow) }
                )
            }
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, verticalPadding)
        .background(DesignSystem.Color.surface)
        .cornerRadius(cornerRadius)
        .overlay {
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(DesignSystem.Color.border, lineWidth: 1)
        }
    }
}

// MARK: - Private Methods

private extension OutcomeCountControlView {
    var label: String { SurebetCalculatorLocalizationKey.outcomesCount.localized }
    var spacing: CGFloat { DesignSystem.Spacing.small }
    var horizontalPadding: CGFloat { isIPad ? DesignSystem.Spacing.large : DesignSystem.Spacing.medium }
    var verticalPadding: CGFloat { isIPad ? DesignSystem.Spacing.medium : DesignSystem.Spacing.small }
    var cornerRadius: CGFloat { DesignSystem.Radius.medium }
    var controlHeight: CGFloat { isIPad ? 44 : 28 }
    var valueMinWidth: CGFloat { isIPad ? 48 : 32 }

    var valuePill: some View {
        Text("\(viewModel.selectedNumberOfRows.rawValue)")
            .font(DesignSystem.Typography.numeric)
            .foregroundColor(DesignSystem.Color.textPrimary)
            .frame(minWidth: valueMinWidth, minHeight: controlHeight)
            .background(DesignSystem.Color.surfaceInput)
            .cornerRadius(DesignSystem.Radius.small)
            .overlay {
                RoundedRectangle(cornerRadius: DesignSystem.Radius.small)
                    .stroke(DesignSystem.Color.borderMuted, lineWidth: 1)
            }
            .accessibilityIdentifier(AccessibilityIdentifiers.Calculator.rowCountValue)
    }

    func counterButton(
        systemName: String,
        isDisabled: Bool,
        accessibilityId: String,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            action()
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } label: {
            Image(systemName: systemName)
                .font(.system(size: isIPad ? 18 : 12, weight: .semibold))
                .foregroundColor(isDisabled ? DesignSystem.Color.textMuted : DesignSystem.Color.textPrimary)
                .frame(width: controlHeight, height: controlHeight)
                .background(DesignSystem.Color.surfaceInput)
                .clipShape(Circle())
                .overlay {
                    Circle()
                        .stroke(DesignSystem.Color.borderMuted, lineWidth: 1)
                }
        }
        .disabled(isDisabled)
        .accessibilityIdentifier(accessibilityId)
    }

    var minRowCount: Int {
        viewModel.availableRowCounts.first?.rawValue ?? CalculatorConstants.minRowCount
    }

    var maxRowCount: Int {
        viewModel.availableRowCounts.last?.rawValue ?? CalculatorConstants.maxRowCount
    }

    var isAtMin: Bool {
        viewModel.selectedNumberOfRows.rawValue <= minRowCount
    }

    var isAtMax: Bool {
        viewModel.selectedNumberOfRows.rawValue >= maxRowCount
    }
}

#Preview {
    OutcomeCountControlView()
        .environmentObject(SurebetCalculatorViewModel())
}
