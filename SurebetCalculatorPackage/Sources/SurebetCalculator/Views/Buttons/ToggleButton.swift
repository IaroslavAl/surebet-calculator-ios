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

    var transition: AnyTransition { AppConstants.Animations.scaleWithOpacity }

    func label() -> some View {
        ZStack {
            Circle()
                .fill(isON ? AppColors.accentSoft : AppColors.surface)
            Circle()
                .stroke(isON ? AppColors.accent : AppColors.borderMuted, lineWidth: 1.2)
            if isON {
                Image(systemName: "checkmark")
                    .font(.system(size: iconSize, weight: .semibold))
                    .foregroundColor(AppColors.accent)
            }
        }
        .frame(width: size, height: size)
        .frame(width: tapAreaSize, height: tapAreaSize)
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

    var size: CGFloat {
        isIPad ? 28 : 24
    }

    var iconSize: CGFloat {
        isIPad ? 12 : 10
    }

    var tapAreaSize: CGFloat {
        isIPad ? 36 : 32
    }
}

#Preview {
    ToggleButton(row: .total)
        .environmentObject(SurebetCalculatorViewModel())
}
