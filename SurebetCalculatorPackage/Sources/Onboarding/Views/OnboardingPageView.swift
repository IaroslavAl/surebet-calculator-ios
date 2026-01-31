import SwiftUI

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
                .font(OnboardingConstants.Typography.title)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .minimumScaleFactor(OnboardingConstants.minimumTextScaleFactor)
            Spacer()
        }
        .padding(.horizontal, contentPadding)
    }

    var contentPadding: CGFloat {
        isIPad ? OnboardingConstants.paddingExtraLarge : OnboardingConstants.paddingSmall
    }

    var imagePadding: CGFloat {
        isIPad ? OnboardingConstants.paddingExtraExtraLarge : .zero
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
