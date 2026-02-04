import SwiftUI

struct OutcomeCountControlView: View {
    // MARK: - Properties

    @EnvironmentObject private var viewModel: SurebetCalculatorViewModel

    // MARK: - Body

    var body: some View {
        HStack(spacing: spacing) {
            Text(label)
                .font(AppConstants.Typography.label)
                .foregroundColor(AppColors.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Spacer()
            HStack(spacing: spacing) {
                counterButton(
                    systemName: "minus",
                    isDisabled: isAtMin,
                    action: { viewModel.send(.removeRow) }
                )
                valuePill
                counterButton(
                    systemName: "plus",
                    isDisabled: isAtMax,
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
        .accessibilityIdentifier(AccessibilityIdentifiers.Calculator.rowCountPicker)
        .accessibilityElement(children: .combine)
        .accessibilityValue("\(viewModel.selectedNumberOfRows.rawValue)")
    }
}

// MARK: - Private Methods

private extension OutcomeCountControlView {
    var label: String { SurebetCalculatorLocalizationKey.outcomesCount.localized }
    var spacing: CGFloat { AppConstants.Padding.small }
    var horizontalPadding: CGFloat { isIPad ? AppConstants.Padding.large : AppConstants.Padding.medium }
    var verticalPadding: CGFloat { AppConstants.Padding.small }
    var cornerRadius: CGFloat { AppConstants.CornerRadius.medium }
    var controlHeight: CGFloat { isIPad ? 34 : 28 }
    var valueMinWidth: CGFloat { isIPad ? 40 : 32 }

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
    }

    func counterButton(
        systemName: String,
        isDisabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 12, weight: .semibold))
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
