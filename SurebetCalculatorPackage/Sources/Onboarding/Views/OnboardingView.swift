import SwiftUI

@MainActor
struct OnboardingView: View {
    // MARK: - Properties

    @StateObject private var viewModel: OnboardingViewModel
    @Binding var onboardingIsShown: Bool

    // MARK: - Initialization

    init(onboardingIsShown: Binding<Bool>, viewModel: OnboardingViewModel) {
        self._onboardingIsShown = onboardingIsShown
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: .zero) {
            OnboardingCloseButton()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, padding)
                .padding(.top, padding)
            OnboardingTabView()
            VStack(spacing: .zero) {
                OnboardingIndex()
                    .padding(.horizontal, padding)
                OnboardingButton()
                    .padding(.horizontal, padding)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.bottom, padding)
        .onChange(of: viewModel.onboardingIsShown) {
            onboardingIsShown = $0
        }
        .environmentObject(viewModel)
        .accessibilityIdentifier(OnboardingAccessibilityIdentifiers.view)
    }
}

// MARK: - Private Computed Properties

private extension OnboardingView {
    var padding: CGFloat {
        isIPad ? OnboardingConstants.paddingExtraLarge : OnboardingConstants.paddingSmall
    }
}

#Preview {
    OnboardingView(
        onboardingIsShown: .constant(false),
        viewModel: OnboardingViewModel()
    )
}
