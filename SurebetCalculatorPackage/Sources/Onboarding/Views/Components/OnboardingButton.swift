import SwiftUI
import DesignSystem

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
        isIPad ? DesignSystem.Radius.extraLarge : DesignSystem.Radius.medium
    }

    func action() {
        viewModel.send(.setCurrentPage(viewModel.currentPage + 1))
    }

    var label: some View {
        Text(text)
            .font(DesignSystem.Typography.button)
            .foregroundColor(DesignSystem.Color.onboardingButtonText)
            .bold()
            .frame(maxWidth: .infinity)
            .padding(padding)
            .background(DesignSystem.Color.onboardingButtonBackground)
            .cornerRadius(cornerRadius)
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(DesignSystem.Color.onboardingButtonBorder, lineWidth: 1)
            }
            .animation(DesignSystem.Animation.quickInteraction, value: viewModel.currentPage)
    }

    var padding: CGFloat {
        isIPad ? DesignSystem.Spacing.extraLarge : DesignSystem.Spacing.large
    }
}

#Preview {
    OnboardingButton()
        .environmentObject(OnboardingViewModel())
}
