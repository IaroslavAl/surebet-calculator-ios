import SwiftUI
import DesignSystem
import UIKit

struct ToggleButton: View {
    // MARK: - Properties

    let isOn: Bool
    let accessibilityIdentifier: String
    let action: () -> Void

    // MARK: - Body

    var body: some View {
        Button(action: actionWithImpactFeedback, label: label)
            .buttonStyle(.scale)
            .accessibilityIdentifier(accessibilityIdentifier)
    }
}

// MARK: - Private Methods

private extension ToggleButton {
    var transition: AnyTransition { DesignSystem.Animation.scaleWithOpacity }

    func label() -> some View {
        ZStack {
            Circle()
                .fill(isOn ? DesignSystem.Color.accentSoft : DesignSystem.Color.surface)
            Circle()
                .stroke(isOn ? DesignSystem.Color.accent : DesignSystem.Color.borderMuted, lineWidth: 1.2)
            if isOn {
                Image(systemName: "checkmark")
                    .font(.system(size: iconSize, weight: .semibold))
                    .foregroundColor(DesignSystem.Color.accent)
            }
        }
        .frame(width: size, height: size)
        .frame(width: tapAreaSize, height: tapAreaSize)
        .contentShape(.rect)
        .transition(transition)
    }

    func actionWithImpactFeedback() {
        withAnimation(DesignSystem.Animation.quickInteraction) {
            action()
        }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    var size: CGFloat {
        isIPad ? 32 : 24
    }

    var iconSize: CGFloat {
        isIPad ? 14 : 10
    }

    var tapAreaSize: CGFloat {
        isIPad ? DesignSystem.Size.controlRegularHeight : DesignSystem.Size.controlCompactHeight
    }
}

#Preview {
    ToggleButton(
        isOn: true,
        accessibilityIdentifier: AccessibilityIdentifiers.TotalRow.toggleButton,
        action: {}
    )
}
