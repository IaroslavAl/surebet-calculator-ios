import SwiftUI
import UIKit

struct TotalRowView: View {
    // MARK: - Properties

    @EnvironmentObject private var viewModel: SurebetCalculatorViewModel

    // MARK: - Body

    var body: some View {
        HStack(alignment: .bottom, spacing: columnSpacing) {
            ToggleButton(row: .total)
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
                .stroke(isSelected ? AppColors.accent : AppColors.borderMuted, lineWidth: 1)
        }
    }
}

// MARK: - Private Computed Properties

private extension TotalRowView {
    var betSizeLabel: String { SurebetCalculatorLocalizationKey.totalBetSize.localized }
    var profitPercentageLabel: String { SurebetCalculatorLocalizationKey.profitPercentage.localized }
    var labelSpacing: CGFloat { AppConstants.Padding.small }
    var columnSpacing: CGFloat { isIPad ? AppConstants.Padding.large : AppConstants.Padding.small }
    var cardPadding: CGFloat { isIPad ? AppConstants.Padding.large : AppConstants.Padding.small }
    var cardCornerRadius: CGFloat { isIPad ? AppConstants.CornerRadius.large : AppConstants.CornerRadius.medium }
    var selectionIndicatorSize: CGFloat { isIPad ? 48 : 44 }
    var isSelected: Bool { viewModel.selection == .total }

    var totalBetSizeColumn: some View {
        VStack(spacing: labelSpacing) {
            Text(betSizeLabel)
                .font(AppConstants.Typography.label)
                .foregroundColor(AppColors.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            TextFieldView(
                placeholder: "",
                label: betSizeLabel,
                focusableField: .totalBetSize
            )
        }
    }

    var profitPercentageColumn: some View {
        VStack(spacing: labelSpacing) {
            Text(profitPercentageLabel)
                .font(AppConstants.Typography.label)
                .foregroundColor(AppColors.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            TextView(
                text: viewModel.total.profitPercentage,
                isPercent: true,
                isEmphasized: isSelected,
                accessibilityId: AccessibilityIdentifiers.TotalRow.profitPercentageText
            )
        }
    }

    var background: some View {
        Group {
            if isSelected {
                AppColors.surfaceElevated
            } else {
                AppColors.surface
            }
        }
        .contentShape(.rect)
        .onTapGesture(perform: actionWithImpactFeedback)
    }

    func actionWithImpactFeedback() {
        guard viewModel.selection != .total else { return }
        withAnimation(AppConstants.Animations.quickInteraction) {
            viewModel.send(.selectRow(.total))
        }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}

#Preview {
    TotalRowView()
        .padding(.trailing)
        .environmentObject(SurebetCalculatorViewModel())
}
