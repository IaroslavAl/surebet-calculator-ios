import SwiftUI

struct OnboardingButton: View {
    // MARK: - Properties

    @EnvironmentObject private var viewModel: OnboardingViewModel

    // MARK: - Body

    var body: some View {
        Button(action: action) {
            label
        }
        .accessibilityLabel(text)
        .accessibilityIdentifier(OnboardingAccessibilityIdentifiers.nextButton)
    }
}

// MARK: - Private Methods

private extension OnboardingButton {
    var text: String {
        let firstPage = OnboardingConstants.firstPageIndex
        let lastPage = viewModel.pages.index(before: viewModel.pages.endIndex)
        if viewModel.currentPage == firstPage {
            return OnboardingLocalizationKey.moreDetails.localized
        }
        if viewModel.currentPage == lastPage {
            return OnboardingLocalizationKey.close.localized
        }
        return OnboardingLocalizationKey.next.localized
    }
    var cornerRadius: CGFloat {
        isIPad ? OnboardingConstants.cornerRadiusExtraLarge : OnboardingConstants.cornerRadiusMedium
    }

    func action() {
        viewModel.send(.setCurrentPage(viewModel.currentPage + 1))
    }

    var label: some View {
        Text(text)
            .foregroundColor(OnboardingColors.buttonText)
            .bold()
            .frame(maxWidth: .infinity)
            .padding(padding)
            .background(OnboardingColors.buttonBackground)
            .cornerRadius(cornerRadius)
            .animation(OnboardingConstants.Animations.quickInteraction, value: viewModel.currentPage)
    }

    var padding: CGFloat {
        isIPad ? OnboardingConstants.paddingExtraLarge : OnboardingConstants.paddingLarge
    }
}

#Preview {
    OnboardingButton()
        .environmentObject(OnboardingViewModel())
}
