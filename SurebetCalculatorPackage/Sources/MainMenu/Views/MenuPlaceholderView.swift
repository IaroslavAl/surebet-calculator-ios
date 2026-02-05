import SurebetCalculator
import SwiftUI
import DesignSystem

struct MenuPlaceholderView: View {
    // MARK: - Properties

    let title: String
    let message: String
    let systemImage: String

    // MARK: - Body

    var body: some View {
        ZStack {
            DesignSystem.Color.background.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: sectionSpacing) {
                    header
                    messageCard
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.vertical, verticalPadding)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Private Computed Properties

private extension MenuPlaceholderView {
    var sectionSpacing: CGFloat { isIPad ? DesignSystem.Spacing.extraLarge : DesignSystem.Spacing.large }
    var horizontalPadding: CGFloat { DesignSystem.Spacing.large }
    var verticalPadding: CGFloat { isIPad ? DesignSystem.Spacing.extraLarge : DesignSystem.Spacing.large }
    var cardCornerRadius: CGFloat { isIPad ? DesignSystem.Radius.extraLarge : DesignSystem.Radius.large }

    var header: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            icon
            Text(title)
                .font(DesignSystem.Typography.title)
                .foregroundColor(DesignSystem.Color.textPrimary)
        }
        .frame(maxWidth: .infinity)
    }

    var icon: some View {
        Image(systemName: systemImage)
            .font(.system(size: iconSize, weight: .semibold))
            .foregroundColor(DesignSystem.Color.accent)
            .frame(width: iconContainerSize, height: iconContainerSize)
            .background(DesignSystem.Color.accentSoft)
            .clipShape(Circle())
    }

    var messageCard: some View {
        Text(message)
            .font(DesignSystem.Typography.description)
            .foregroundColor(DesignSystem.Color.textSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(cardPadding)
            .background(DesignSystem.Color.surface)
            .cornerRadius(cardCornerRadius)
            .overlay {
                RoundedRectangle(cornerRadius: cardCornerRadius)
                    .stroke(DesignSystem.Color.borderMuted, lineWidth: 1)
            }
    }

    var iconContainerSize: CGFloat { isIPad ? 88 : 64 }
    var iconSize: CGFloat { isIPad ? 38 : 28 }
    var cardPadding: CGFloat { isIPad ? DesignSystem.Spacing.extraLarge : DesignSystem.Spacing.large }
}

#Preview {
    NavigationStack {
        MenuPlaceholderView(
            title: "Settings",
            message: "Placeholder text",
            systemImage: "gearshape"
        )
    }
}
