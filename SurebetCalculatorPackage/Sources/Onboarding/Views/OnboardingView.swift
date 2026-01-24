import SwiftUI

@MainActor
struct OnboardingView: View {
    // MARK: - Properties

    @StateObject private var viewModel = OnboardingViewModel()
    @Binding var onboardingIsShown: Bool

    // MARK: - Body

    var body: some View {
        VStack(spacing: .zero) {
            OnboardingCloseButton()
            OnboardingTabView()
            OnboardingIndex()
            OnboardingButton()
        }
        .padding()
        .onChange(of: viewModel.onboardingIsShown) {
            onboardingIsShown = $0
        }
        .environmentObject(viewModel)
        .accessibilityIdentifier(OnboardingAccessibilityIdentifiers.view)
    }
}

#Preview {
    OnboardingView(onboardingIsShown: .constant(false))
}
