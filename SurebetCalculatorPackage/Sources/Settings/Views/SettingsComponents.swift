import SwiftUI
import DesignSystem

struct SettingsSectionCard<Content: View>: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let content: Content

    init(
        title: String,
        subtitle: String,
        systemImage: String,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
            header
            content
        }
        .padding(cardPadding)
        .background(DesignSystem.Color.surface)
        .cornerRadius(cardCornerRadius)
        .overlay {
            RoundedRectangle(cornerRadius: cardCornerRadius)
                .stroke(DesignSystem.Color.borderMuted, lineWidth: 1)
        }
    }
}

private extension SettingsSectionCard {
    var cardPadding: CGFloat {
        isIPad ? DesignSystem.Spacing.extraLarge : DesignSystem.Spacing.large
    }

    var cardCornerRadius: CGFloat {
        isIPad ? DesignSystem.Radius.extraLarge : DesignSystem.Radius.large
    }

    var header: some View {
        HStack(alignment: .center, spacing: DesignSystem.Spacing.medium) {
            icon
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.small / 2) {
                Text(title)
                    .font(DesignSystem.Typography.body.weight(.semibold))
                    .foregroundColor(DesignSystem.Color.textPrimary)
                Text(subtitle)
                    .font(DesignSystem.Typography.label)
                    .foregroundColor(DesignSystem.Color.textSecondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            Spacer(minLength: 0)
        }
    }

    var icon: some View {
        Image(systemName: systemImage)
            .font(.system(size: isIPad ? 22 : 18, weight: .semibold))
            .foregroundColor(DesignSystem.Color.accent)
            .frame(width: isIPad ? 48 : 40, height: isIPad ? 48 : 40)
            .background(DesignSystem.Color.accentSoft)
            .clipShape(Circle())
    }
}

struct SettingsOptionRow<Leading: View>: View {
    let title: String
    let subtitle: String?
    let badgeText: String?
    let isSelected: Bool
    let isEnabled: Bool
    let leading: Leading
    let action: () -> Void

    init(
        title: String,
        subtitle: String? = nil,
        badgeText: String? = nil,
        isSelected: Bool,
        isEnabled: Bool,
        @ViewBuilder leading: () -> Leading,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.badgeText = badgeText
        self.isSelected = isSelected
        self.isEnabled = isEnabled
        self.leading = leading()
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: DesignSystem.Spacing.small) {
                leading
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.extraSmall) {
                    Text(title)
                        .font(DesignSystem.Typography.body.weight(.semibold))
                        .foregroundColor(titleColor)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    if let subtitle {
                        Text(subtitle)
                            .font(DesignSystem.Typography.label)
                            .foregroundColor(subtitleColor)
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)
                    }
                }
                Spacer(minLength: 0)
                trailingContent
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(rowPadding)
            .background(backgroundColor)
            .cornerRadius(rowCornerRadius)
            .overlay {
                RoundedRectangle(cornerRadius: rowCornerRadius)
                    .stroke(borderColor, lineWidth: 1)
            }
        }
        .buttonStyle(.scale)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.6)
    }
}

private extension SettingsOptionRow {
    var rowPadding: CGFloat {
        isIPad ? DesignSystem.Spacing.medium : DesignSystem.Spacing.small
    }

    var rowCornerRadius: CGFloat {
        isIPad ? DesignSystem.Radius.large : DesignSystem.Radius.medium
    }

    var titleColor: Color {
        isEnabled ? DesignSystem.Color.textPrimary : DesignSystem.Color.textMuted
    }

    var subtitleColor: Color {
        isEnabled ? DesignSystem.Color.textSecondary : DesignSystem.Color.textMuted
    }

    var backgroundColor: Color {
        if isSelected {
            return DesignSystem.Color.accentSoft
        }
        return DesignSystem.Color.surfaceInput
    }

    var borderColor: Color {
        if isSelected {
            return DesignSystem.Color.accent
        }
        return DesignSystem.Color.borderMuted
    }

    var trailingContent: some View {
        HStack(spacing: DesignSystem.Spacing.small) {
            if let badgeText, !isEnabled {
                Text(badgeText)
                    .font(DesignSystem.Typography.label.weight(.semibold))
                    .foregroundColor(DesignSystem.Color.textSecondary)
                    .padding(.horizontal, DesignSystem.Spacing.small)
                    .padding(.vertical, DesignSystem.Spacing.extraSmall)
                    .background(DesignSystem.Color.surface)
                    .cornerRadius(DesignSystem.Radius.small)
            }
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(DesignSystem.Typography.icon)
                    .foregroundColor(DesignSystem.Color.accent)
            }
        }
    }
}
