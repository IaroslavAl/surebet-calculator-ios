import SwiftUI

struct ToggleButton: View {
    // MARK: - Properties

    @EnvironmentObject private var viewModel: SurebetCalculatorViewModel

    let row: Selection

    // MARK: - Body

    var body: some View {
        Button(action: actionWithImpactFeedback, label: label)
            .buttonStyle(.scale)
            .animation(AppConstants.Animations.quickInteraction, value: isON)
            .accessibilityIdentifier(accessibilityIdentifier)
    }
}

// MARK: - Private Methods

private extension ToggleButton {
    var isON: Bool {
        switch row {
        case .total:
            viewModel.total.isON
        case let .row(id):
            viewModel.row(for: id)?.isON ?? false
        case .none:
            false
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
        Group {
            if isON {
                Image(systemName: "soccerball")
                    .foregroundColor(AppColors.primaryGreen)
            } else {
                Image(systemName: "circle")
                    .foregroundColor(AppColors.primaryRed)
            }
        }
        .frame(minWidth: .zero, minHeight: height, maxHeight: height)
        .padding(.horizontal, horizontalPadding)
        .contentShape(.rect)
        .transition(transition)
    }

    func actionWithImpactFeedback() {
        withAnimation(AppConstants.Animations.quickInteraction) {
            viewModel.send(.selectRow(row))
        }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    var accessibilityIdentifier: String {
        switch row {
        case .total:
            return AccessibilityIdentifiers.TotalRow.toggleButton
        case let .row(id):
            let displayIndex = viewModel.displayIndex(for: id) ?? 0
            return AccessibilityIdentifiers.Row.toggleButton(displayIndex)
        case .none:
            return AccessibilityIdentifiers.TotalRow.toggleButton
        }
    }
}

#Preview {
    ToggleButton(row: .total)
        .environmentObject(SurebetCalculatorViewModel())
}
