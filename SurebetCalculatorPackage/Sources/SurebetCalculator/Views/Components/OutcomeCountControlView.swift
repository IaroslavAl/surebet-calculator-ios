import SwiftUI
import UIKit

struct OutcomeCountControlView: View {
    // MARK: - Properties

    @EnvironmentObject private var viewModel: SurebetCalculatorViewModel

    // MARK: - Body

    var body: some View {
        HStack(spacing: spacing) {
            Text(label)
                .font(AppConstants.Typography.label)
                .foregroundColor(AppColors.textSecondary)
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
        .background(AppColors.surface)
        .cornerRadius(cornerRadius)
        .overlay {
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(AppColors.border, lineWidth: 1)
        }
    }
}

// MARK: - Private Methods

private extension OutcomeCountControlView {
    var label: String { SurebetCalculatorLocalizationKey.outcomesCount.localized }
    var spacing: CGFloat { AppConstants.Padding.small }
    var horizontalPadding: CGFloat { isIPad ? AppConstants.Padding.large : AppConstants.Padding.medium }
    var verticalPadding: CGFloat { isIPad ? AppConstants.Padding.medium : AppConstants.Padding.small }
    var cornerRadius: CGFloat { AppConstants.CornerRadius.medium }
    var controlHeight: CGFloat { isIPad ? 44 : 28 }
    var valueMinWidth: CGFloat { isIPad ? 48 : 32 }

    var valuePill: some View {
        Text("\(viewModel.selectedNumberOfRows.rawValue)")
            .font(AppConstants.Typography.numeric)
            .foregroundColor(AppColors.textPrimary)
            .frame(minWidth: valueMinWidth, minHeight: controlHeight)
            .background(AppColors.surfaceInput)
            .cornerRadius(AppConstants.CornerRadius.small)
            .overlay {
                RoundedRectangle(cornerRadius: AppConstants.CornerRadius.small)
                    .stroke(AppColors.borderMuted, lineWidth: 1)
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
                .foregroundColor(isDisabled ? AppColors.textMuted : AppColors.textPrimary)
                .frame(width: controlHeight, height: controlHeight)
                .background(AppColors.surfaceInput)
                .clipShape(Circle())
                .overlay {
                    Circle()
                        .stroke(AppColors.borderMuted, lineWidth: 1)
                }
        }
        .disabled(isDisabled)
        .accessibilityIdentifier(accessibilityId)
    }

    var minRowCount: Int {
        viewModel.availableRowCounts.first?.rawValue ?? AppConstants.Calculator.minRowCount
    }

    var maxRowCount: Int {
        viewModel.availableRowCounts.last?.rawValue ?? AppConstants.Calculator.maxRowCount
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
