import SwiftUI
import DesignSystem

struct OnboardingPageView: View {
    // MARK: - Properties

    let page: OnboardingPage

    // MARK: - Body

    var body: some View {
        VStack(spacing: .zero) {
            Image(page.image, bundle: .module)
                .resizable()
                .scaledToFit()
                .padding(.vertical)
                .padding(.horizontal, imagePadding)
                .accessibilityLabel(OnboardingLocalizationKey.image.localized)
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

    var imagePadding: CGFloat {
        isIPad ? DesignSystem.Spacing.extraExtraLarge : .zero
    }
}

#Preview {
    OnboardingPageView(
        page: OnboardingPage.createPages().first ?? .init(
            image: "onboarding1",
            description: OnboardingLocalizationKey.page1Description.localized
        )
    )
}
