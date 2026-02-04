import SwiftUI

struct OnboardingCloseButton: View {
    // MARK: - Properties

    @EnvironmentObject private var viewModel: OnboardingViewModel

    // MARK: - Body

    var body: some View {
        Button(action: action) {
            label
        }
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
            .font(OnboardingConstants.Typography.icon)
            .foregroundColor(OnboardingColors.closeButton)
            .padding(padding)
            .background(OnboardingColors.surface)
            .clipShape(Circle())
            .overlay {
                Circle()
                    .stroke(OnboardingColors.border, lineWidth: 1)
            }
    }

    var padding: CGFloat {
        isIPad ? OnboardingConstants.paddingSmall : 6
    }
}

#Preview {
    OnboardingCloseButton()
        .environmentObject(OnboardingViewModel())
}
