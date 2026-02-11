import SwiftUI

/// Reusable primary CTA button used across feature modules.
public struct PrimaryActionButton: View {
    public enum Variant: Sendable {
        case accent
        case onboarding
    }

    public enum Size: Sendable {
        case regular
        case large
    }

    private let title: String
    private let variant: Variant
    private let size: Size
    private let isEnabled: Bool
    private let action: () -> Void

    public init(
        _ title: String,
        variant: Variant = .accent,
        size: Size = .regular,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.variant = variant
        self.size = size
        self.isEnabled = isEnabled
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(font)
                .fontWeight(.bold)
                .foregroundColor(textColor)
                .frame(maxWidth: .infinity, minHeight: minHeight)
                .background(backgroundColor)
                .cornerRadius(cornerRadius)
                .overlay {
                    if let borderColor {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(borderColor, lineWidth: 1)
                    }
                }
                .opacity(isEnabled ? 1 : 0.5)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }
}

private extension PrimaryActionButton {
    var font: Font {
        switch variant {
        case .accent:
            return DesignSystem.Typography.body

        case .onboarding:
            return DesignSystem.Typography.button
        }
    }

    var textColor: Color {
        switch variant {
        case .accent:
            return .white

        case .onboarding:
            return DesignSystem.Color.onboardingButtonText
        }
    }

    var backgroundColor: Color {
        switch variant {
        case .accent:
            return DesignSystem.Color.accent

        case .onboarding:
            return DesignSystem.Color.onboardingButtonBackground
        }
    }

    var borderColor: Color? {
        switch variant {
        case .accent:
            return nil

        case .onboarding:
            return DesignSystem.Color.onboardingButtonBorder
        }
    }

    var cornerRadius: CGFloat {
        switch variant {
        case .accent:
            return DesignSystem.Radius.large

        case .onboarding:
            return isIPad ? DesignSystem.Radius.extraLarge : DesignSystem.Radius.medium
        }
    }

    var minHeight: CGFloat {
        switch size {
        case .regular:
            return 56

        case .large:
            return isIPad ? 68 : 56
        }
    }
}
