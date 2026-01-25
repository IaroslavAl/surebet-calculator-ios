import SwiftUI

struct ToggleButton: View {
    // MARK: - Properties

    @EnvironmentObject private var viewModel: SurebetCalculatorViewModel

    let row: RowType

    // MARK: - Body

    var body: some View {
        Button(action: actionWithImpactFeedback, label: label)
            .buttonStyle(ScaleButtonStyle())
            .animation(AppConstants.Animations.quickInteraction, value: isON)
            .accessibilityIdentifier(accessibilityIdentifier)
    }
}

// MARK: - Private Methods

private extension ToggleButton {
    var isON: Bool {
        switch row {
        case .total:
            return viewModel.total.isON
        case let .row(id):
            if let row = viewModel.rows.first(where: { $0.id == id }) {
                return row.isON
            }
            return false
        }
    }
    var height: CGFloat {
        isIPad ? AppConstants.Heights.regular : AppConstants.Heights.compact
    }
    var horizontalPadding: CGFloat {
        isIPad ? AppConstants.Padding.medium : AppConstants.Padding.small
    }
    var transition: AnyTransition { AppConstants.Animations.scaleWithOpacity }

    func label() -> some View {
        if isON {
            Image(systemName: "soccerball")
                .frame(minWidth: 0, minHeight: height, maxHeight: height)
                .foregroundColor(AppColors.primaryGreen)
                .padding(.horizontal, horizontalPadding)
                .transition(transition)
        } else {
            Image(systemName: "circle")
                .frame(minWidth: 0, minHeight: height, maxHeight: height)
                .foregroundColor(AppColors.primaryRed)
                .padding(.horizontal, horizontalPadding)
                .transition(transition)
        }
    }

    func actionWithImpactFeedback() {
        withAnimation(AppConstants.Animations.quickInteraction) {
            viewModel.send(.selectRow(row))
        }
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }

    var accessibilityIdentifier: String {
        switch row {
        case .total:
            return AccessibilityIdentifiers.TotalRow.toggleButton
        case let .row(id):
            return AccessibilityIdentifiers.Row.toggleButton(id)
        }
    }
}

#Preview {
    ToggleButton(row: .total)
        .environmentObject(SurebetCalculatorViewModel())
}
