import SwiftUI
import DesignSystem

struct MenuCardAction: View {
    let title: String
    let systemImage: String
    let style: MenuCardStyle
    let layout: MenuLayout
    let accessibilityIdentifier: String?
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            MenuCard(
                title: title,
                systemImage: systemImage,
                style: style,
                layout: layout
            )
        }
        .buttonStyle(MenuCardButtonStyle())
        .accessibilityIdentifier(accessibilityIdentifier ?? "")
    }
}

struct MenuCardButton: View {
    let title: String
    let systemImage: String
    let style: MenuCardStyle
    let layout: MenuLayout
    let accessibilityIdentifier: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            MenuCard(
                title: title,
                systemImage: systemImage,
                style: style,
                layout: layout
            )
        }
        .buttonStyle(MenuCardButtonStyle())
        .accessibilityIdentifier(accessibilityIdentifier ?? "")
    }
}

struct MenuCard: View {
    let title: String
    let systemImage: String
    let style: MenuCardStyle
    let layout: MenuLayout

    var body: some View {
        HStack(spacing: contentSpacing) {
            icon
            VStack(alignment: .leading, spacing: textSpacing) {
                Text(title)
                    .font(DesignSystem.Typography.body.weight(.semibold))
                    .foregroundColor(style.titleColor)
            }
            Spacer(minLength: DesignSystem.Spacing.small)
            Image(systemName: "chevron.right")
                .font(.system(size: chevronSize, weight: .semibold))
                .foregroundColor(style.chevronColor)
        }
        .padding(cardPadding)
        .background(style.background)
        .cornerRadius(cardCornerRadius)
        .overlay {
            RoundedRectangle(cornerRadius: cardCornerRadius)
                .stroke(style.border, lineWidth: 1)
        }
    }

    private var icon: some View {
        Image(systemName: systemImage)
            .font(.system(size: iconSymbolSize, weight: .semibold))
            .foregroundColor(style.iconColor)
            .frame(width: iconContainerSize, height: iconContainerSize)
            .background(style.iconBackground)
            .clipShape(Circle())
    }

    private var cardPadding: CGFloat {
        switch layout {
        case .regular:
            return isIPad ? DesignSystem.Spacing.extraLarge : DesignSystem.Spacing.large
        case .compact:
            return isIPad ? DesignSystem.Spacing.large : DesignSystem.Spacing.medium
        case .ultraCompact:
            return isIPad ? DesignSystem.Spacing.large : DesignSystem.Spacing.small
        }
    }

    private var cardCornerRadius: CGFloat {
        switch layout {
        case .regular:
            return isIPad ? DesignSystem.Radius.extraLarge : DesignSystem.Radius.large
        case .compact:
            return isIPad ? DesignSystem.Radius.large : DesignSystem.Radius.medium
        case .ultraCompact:
            return isIPad ? DesignSystem.Radius.large : DesignSystem.Radius.medium
        }
    }

    private var contentSpacing: CGFloat {
        switch layout {
        case .regular:
            return DesignSystem.Spacing.medium
        case .compact, .ultraCompact:
            return DesignSystem.Spacing.small
        }
    }

    private var textSpacing: CGFloat {
        switch layout {
        case .regular:
            return DesignSystem.Spacing.small
        case .compact, .ultraCompact:
            return DesignSystem.Spacing.small / 2
        }
    }

    private var iconContainerSize: CGFloat {
        switch layout {
        case .regular:
            return isIPad ? 56 : 44
        case .compact:
            return isIPad ? 52 : 40
        case .ultraCompact:
            return isIPad ? 48 : 36
        }
    }

    private var iconSymbolSize: CGFloat {
        switch layout {
        case .regular:
            return isIPad ? 24 : 18
        case .compact:
            return isIPad ? 22 : 16
        case .ultraCompact:
            return isIPad ? 20 : 14
        }
    }

    private var chevronSize: CGFloat {
        switch layout {
        case .regular:
            return isIPad ? 18 : 14
        case .compact:
            return isIPad ? 16 : 12
        case .ultraCompact:
            return isIPad ? 15 : 11
        }
    }
}

struct MenuCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(DesignSystem.Animation.quickInteraction, value: configuration.isPressed)
    }
}

enum MenuCardStyle {
    case primary
    case standard
    case highlight

    var background: Color {
        switch self {
        case .primary, .standard:
            DesignSystem.Color.surface
        case .highlight:
            DesignSystem.Color.accentSoft
        }
    }

    var border: Color {
        switch self {
        case .primary, .highlight:
            DesignSystem.Color.accent
        case .standard:
            DesignSystem.Color.borderMuted
        }
    }

    var iconBackground: Color {
        switch self {
        case .primary:
            DesignSystem.Color.accentSoft
        case .highlight:
            DesignSystem.Color.surface
        case .standard:
            DesignSystem.Color.surfaceInput
        }
    }

    var iconColor: Color {
        switch self {
        case .primary, .highlight:
            DesignSystem.Color.accent
        case .standard:
            DesignSystem.Color.textSecondary
        }
    }

    var titleColor: Color { DesignSystem.Color.textPrimary }

    var chevronColor: Color {
        switch self {
        case .primary, .highlight:
            DesignSystem.Color.accent
        case .standard:
            DesignSystem.Color.textMuted
        }
    }
}
