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
                .accessibilityLabel(String(localized: "Image"))
            Spacer()
            Text(page.description)
                .font(.title)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .minimumScaleFactor(OnboardingConstants.minimumTextScaleFactor)
            Spacer()
        }
    }
}

#Preview {
    OnboardingPageView(
        page: .init(
            image: "onboarding1",
            description: "description"
        )
    )
}
