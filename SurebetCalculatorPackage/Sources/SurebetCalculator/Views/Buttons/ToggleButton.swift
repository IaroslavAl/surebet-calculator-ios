import SwiftUI

struct ToggleButton: View {
    // MARK: - Properties

    @EnvironmentObject private var viewModel: SurebetCalculatorViewModel

    let row: RowType

    // MARK: - Body

    var body: some View {
        Button(action: actionWithImpactFeedback, label: label)
            .animation(.easeInOut(duration: animationDuration), value: isON)
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
    var height: CGFloat { isIPad ? 60 : 40 }
    var horizontalPadding: CGFloat { isIPad ? 12 : 8 }
    var transition: AnyTransition { .opacity.combined(with: .scale) }
    var animationDuration: Double { 0.25 }

    func label() -> some View {
        if isON {
            Image(systemName: "soccerball")
                .frame(minWidth: 0, minHeight: height, maxHeight: height)
                .foregroundColor(.green)
                .padding(.horizontal, horizontalPadding)
                .transition(transition)
        } else {
            Image(systemName: "circle")
                .frame(minWidth: 0, minHeight: height, maxHeight: height)
                .foregroundColor(.red)
                .padding(.horizontal, horizontalPadding)
                .transition(transition)
        }
    }

    func actionWithImpactFeedback() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        viewModel.send(.selectRow(row))
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
