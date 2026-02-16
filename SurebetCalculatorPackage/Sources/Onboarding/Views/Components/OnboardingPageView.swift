import SwiftUI
import DesignSystem

struct OnboardingPageView: View {
    // MARK: - Properties

    let page: OnboardingPage
    @Environment(\.locale) private var locale

    // MARK: - Body

    var body: some View {
        VStack(spacing: .zero) {
            illustrationView
            Spacer()
            Text(page.description)
                .font(DesignSystem.Typography.title)
                .foregroundColor(DesignSystem.Color.onboardingTextPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .minimumScaleFactor(DesignSystem.Typography.minimumScaleFactor)
            Spacer()
        }
        .padding(.horizontal, contentPadding)
    }

    var contentPadding: CGFloat {
        isIPad ? DesignSystem.Spacing.extraLarge : DesignSystem.Spacing.large
    }

    var illustrationPadding: CGFloat {
        isIPad ? DesignSystem.Spacing.extraExtraLarge : .zero
    }

    var illustrationSize: CGFloat {
        isIPad ? 132 : 96
    }

    var illustrationView: some View {
        RoundedRectangle(cornerRadius: DesignSystem.Radius.extraLarge)
            .fill(DesignSystem.Color.onboardingSurface)
            .overlay {
                RoundedRectangle(cornerRadius: DesignSystem.Radius.extraLarge)
                    .stroke(DesignSystem.Color.onboardingBorder, lineWidth: 1)
            }
            .overlay {
                Image(systemName: page.illustration.rawValue)
                    .font(.system(size: illustrationSize, weight: .semibold, design: .rounded))
                    .foregroundStyle(DesignSystem.Color.onboardingTextPrimary)
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(1.55, contentMode: .fit)
            .padding(.vertical)
            .padding(.horizontal, illustrationPadding)
            .accessibilityLabel(OnboardingLocalizationKey.image.localized(locale))
    }
}

#Preview {
    OnboardingPageView(
        page: OnboardingPage.createPages(locale: Locale.current).first ?? .init(
            id: 0,
            illustration: .stakeDistribution,
            pageID: "onboarding_page_1",
            description: OnboardingLocalizationKey.page1Description.localized(Locale.current)
        )
    )
}
