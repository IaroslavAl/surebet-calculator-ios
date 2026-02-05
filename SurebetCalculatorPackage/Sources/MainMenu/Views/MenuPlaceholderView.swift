import SurebetCalculator
import SwiftUI

struct MenuPlaceholderView: View {
    // MARK: - Properties

    let title: String
    let message: String
    let systemImage: String

    // MARK: - Body

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
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
    var sectionSpacing: CGFloat { isIPad ? AppConstants.Padding.extraLarge : AppConstants.Padding.large }
    var horizontalPadding: CGFloat { AppConstants.Padding.large }
    var verticalPadding: CGFloat { isIPad ? AppConstants.Padding.extraLarge : AppConstants.Padding.large }
    var cardCornerRadius: CGFloat { isIPad ? AppConstants.CornerRadius.extraLarge : AppConstants.CornerRadius.large }

    var header: some View {
        VStack(spacing: AppConstants.Padding.medium) {
            icon
            Text(title)
                .font(AppConstants.Typography.title)
                .foregroundColor(AppColors.textPrimary)
        }
        .frame(maxWidth: .infinity)
    }

    var icon: some View {
        Image(systemName: systemImage)
            .font(.system(size: iconSize, weight: .semibold))
            .foregroundColor(AppColors.accent)
            .frame(width: iconContainerSize, height: iconContainerSize)
            .background(AppColors.accentSoft)
            .clipShape(Circle())
    }

    var messageCard: some View {
        Text(message)
            .font(AppConstants.Typography.description)
            .foregroundColor(AppColors.textSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(cardPadding)
            .background(AppColors.surface)
            .cornerRadius(cardCornerRadius)
            .overlay {
                RoundedRectangle(cornerRadius: cardCornerRadius)
                    .stroke(AppColors.borderMuted, lineWidth: 1)
            }
    }

    var iconContainerSize: CGFloat { isIPad ? 88 : 64 }
    var iconSize: CGFloat { isIPad ? 38 : 28 }
    var cardPadding: CGFloat { isIPad ? AppConstants.Padding.extraLarge : AppConstants.Padding.large }
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
