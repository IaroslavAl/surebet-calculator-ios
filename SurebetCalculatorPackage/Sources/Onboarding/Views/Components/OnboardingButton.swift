import SwiftUI
import DesignSystem

struct OnboardingButton: View {
    // MARK: - Properties

    @EnvironmentObject private var viewModel: OnboardingViewModel
    @Environment(\.locale) private var locale

    // MARK: - Body

    var body: some View {
        PrimaryActionButton(
            text,
            variant: .onboarding,
            size: .large,
            accessibilityIdentifier: OnboardingAccessibilityIdentifiers.nextButton,
            action: action
        )
        .animation(DesignSystem.Animation.quickInteraction, value: viewModel.currentPage)
        .accessibilityLabel(text)
    }
}

// MARK: - Private Methods

private extension OnboardingButton {
    var text: String {
        let firstPage = OnboardingConstants.firstPageIndex
        let lastPage = viewModel.pages.index(before: viewModel.pages.endIndex)
        if viewModel.currentPage == firstPage {
            return OnboardingLocalizationKey.moreDetails.localized(locale)
        }
        if viewModel.currentPage == lastPage {
            return OnboardingLocalizationKey.close.localized(locale)
        }
        return OnboardingLocalizationKey.next.localized(locale)
    }
    func action() {
        viewModel.send(.setCurrentPage(viewModel.currentPage + 1))
    }
}

#Preview {
    OnboardingButton()
        .environmentObject(OnboardingViewModel())
}
