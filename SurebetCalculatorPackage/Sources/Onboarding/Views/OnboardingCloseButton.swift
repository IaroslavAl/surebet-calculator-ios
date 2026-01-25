import SwiftUI

struct OnboardingCloseButton: View {
    // MARK: - Properties

    @EnvironmentObject private var viewModel: OnboardingViewModel

    // MARK: - Body

    var body: some View {
        Button(action: action) {
            label
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityLabel(OnboardingLocalizationKey.closeOnboarding.localized)
        .accessibilityIdentifier(OnboardingAccessibilityIdentifiers.closeButton)
    }
}

// MARK: - Private Methods

private extension OnboardingCloseButton {
    var imageName: String { "xmark" }

    func action() {
        viewModel.send(.skip)
    }

    var label: some View {
        Image(systemName: imageName)
            .font(.title)
            .foregroundColor(OnboardingColors.closeButton)
    }
}

#Preview {
    OnboardingCloseButton()
        .environmentObject(OnboardingViewModel())
}
