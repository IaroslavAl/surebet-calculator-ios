import SurebetCalculator
import SwiftUI

struct MenuCardLink<Destination: View>: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let style: MenuCardStyle
    let layout: MenuLayout
    let showsSubtitle: Bool
    let destination: () -> Destination

    var body: some View {
        NavigationLink {
            destination()
        } label: {
            MenuCard(
                title: title,
                subtitle: subtitle,
                systemImage: systemImage,
                style: style,
                layout: layout,
                showsSubtitle: showsSubtitle
            )
        }
        .buttonStyle(MenuCardButtonStyle())
    }
}

struct MenuCard: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let style: MenuCardStyle
    let layout: MenuLayout
    let showsSubtitle: Bool

    var body: some View {
        HStack(spacing: contentSpacing) {
            icon
            VStack(alignment: .leading, spacing: textSpacing) {
                Text(title)
                    .font(AppConstants.Typography.body.weight(.semibold))
                    .foregroundColor(style.titleColor)
                if showsSubtitle {
                    Text(subtitle)
                        .font(AppConstants.Typography.label)
                        .foregroundColor(style.subtitleColor)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .minimumScaleFactor(0.9)
                        .allowsTightening(true)
                }
            }
            Spacer(minLength: AppConstants.Padding.small)
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
            return isIPad ? AppConstants.Padding.extraLarge : AppConstants.Padding.large
        case .compact:
            return isIPad ? AppConstants.Padding.large : AppConstants.Padding.medium
        case .ultraCompact:
            return isIPad ? AppConstants.Padding.large : AppConstants.Padding.small
        }
    }

    private var cardCornerRadius: CGFloat {
        switch layout {
        case .regular:
            return isIPad ? AppConstants.CornerRadius.extraLarge : AppConstants.CornerRadius.large
        case .compact:
            return isIPad ? AppConstants.CornerRadius.large : AppConstants.CornerRadius.medium
        case .ultraCompact:
            return isIPad ? AppConstants.CornerRadius.large : AppConstants.CornerRadius.medium
        }
    }

    private var contentSpacing: CGFloat {
        switch layout {
        case .regular:
            return AppConstants.Padding.medium
        case .compact, .ultraCompact:
            return AppConstants.Padding.small
        }
    }

    private var textSpacing: CGFloat {
        switch layout {
        case .regular:
            return AppConstants.Padding.small
        case .compact, .ultraCompact:
            return AppConstants.Padding.small / 2
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
            .animation(AppConstants.Animations.quickInteraction, value: configuration.isPressed)
    }
}

enum MenuCardStyle {
    case primary
    case standard
    case highlight

    var background: Color {
        switch self {
        case .primary, .standard:
            AppColors.surface
        case .highlight:
            AppColors.accentSoft
        }
    }

    var border: Color {
        switch self {
        case .primary, .highlight:
            AppColors.accent
        case .standard:
            AppColors.borderMuted
        }
    }

    var iconBackground: Color {
        switch self {
        case .primary:
            AppColors.accentSoft
        case .highlight:
            AppColors.surface
        case .standard:
            AppColors.surfaceInput
        }
    }

    var iconColor: Color {
        switch self {
        case .primary, .highlight:
            AppColors.accent
        case .standard:
            AppColors.textSecondary
        }
    }

    var titleColor: Color { AppColors.textPrimary }

    var subtitleColor: Color {
        switch self {
        case .highlight:
            AppColors.textSecondary
        case .primary, .standard:
            AppColors.textMuted
        }
    }

    var chevronColor: Color {
        switch self {
        case .primary, .highlight:
            AppColors.accent
        case .standard:
            AppColors.textMuted
        }
    }
}
