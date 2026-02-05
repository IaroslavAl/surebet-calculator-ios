import SwiftUI
import DesignSystem

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
            .font(DesignSystem.Typography.icon)
            .foregroundColor(DesignSystem.Color.onboardingCloseButton)
            .padding(padding)
            .background(DesignSystem.Color.onboardingSurface)
            .clipShape(Circle())
            .overlay {
                Circle()
                    .stroke(DesignSystem.Color.onboardingBorder, lineWidth: 1)
            }
    }

    var padding: CGFloat {
        isIPad ? DesignSystem.Spacing.small : DesignSystem.Spacing.extraSmall
    }
}

#Preview {
    OnboardingCloseButton()
        .environmentObject(OnboardingViewModel())
}
