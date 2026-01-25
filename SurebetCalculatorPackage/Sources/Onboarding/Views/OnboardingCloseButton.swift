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
        .accessibilityLabel(String(localized: "Close onboarding", bundle: .module))
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
            .foregroundColor(
                Color(uiColor: .darkGray)
            )
    }
}

#Preview {
    OnboardingCloseButton()
        .environmentObject(OnboardingViewModel())
}
