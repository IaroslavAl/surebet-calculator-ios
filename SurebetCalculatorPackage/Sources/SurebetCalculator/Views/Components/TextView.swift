import SwiftUI
import DesignSystem

struct TextView: View {
    // MARK: - Properties

    let text: String
    let isPercent: Bool
    let isEmphasized: Bool
    var accessibilityId: String?

    // MARK: - Body

    var body: some View {
        Text(text)
            .font(DesignSystem.Typography.numeric)
            .padding(textPadding)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: frameHeight, maxHeight: frameHeight)
            .background(DesignSystem.Color.surfaceResult)
            .cornerRadius(cornerRadius)
            .foregroundColor(color)
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(isEmphasized ? DesignSystem.Color.border : DesignSystem.Color.borderMuted, lineWidth: 1)
            }
            .opacity(isEmphasized ? 1 : inactiveOpacity)
            .accessibilityIdentifier(accessibilityId ?? "")
    }
}

// MARK: - Private Computed Properties

private extension TextView {
    var textPadding: CGFloat {
        isIPad ? DesignSystem.Spacing.large : DesignSystem.Spacing.small
    }
    var frameHeight: CGFloat {
        isIPad ? DesignSystem.Size.controlRegularHeight : DesignSystem.Size.controlCompactHeight
    }
    var cornerRadius: CGFloat {
        isIPad ? DesignSystem.Radius.large : DesignSystem.Radius.small
    }
    var color: Color { text.isNumberNotNegative() ? DesignSystem.Color.success : DesignSystem.Color.error }
    var inactiveOpacity: CGFloat { 0.7 }
}

#Preview {
    TextView(
        text: 1.formatToString(isPercent: true),
        isPercent: true,
        isEmphasized: false
    )
        .padding()
}
