import SwiftUI
import DesignSystem

@MainActor
struct OnboardingView: View {
    // MARK: - Properties

    @StateObject private var viewModel: OnboardingViewModel
    @Binding var onboardingIsShown: Bool
    @Environment(\.locale) private var locale

    // MARK: - Initialization

    init(onboardingIsShown: Binding<Bool>, viewModel: OnboardingViewModel) {
        self._onboardingIsShown = onboardingIsShown
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: .zero) {
            topBar
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
        .background {
            DesignSystem.Color.onboardingBackground.ignoresSafeArea()
        }
        .onAppear {
            viewModel.send(.updateLocale(locale))
        }
        .onChange(of: locale) {
            viewModel.send(.updateLocale($0))
        }
        .onChange(of: viewModel.onboardingIsShown) {
            onboardingIsShown = $0
        }
        .environmentObject(viewModel)
    }
}

// MARK: - Private Computed Properties

private extension OnboardingView {
    var padding: CGFloat {
        isIPad ? DesignSystem.Spacing.extraLarge : DesignSystem.Spacing.large
    }

    var topBar: some View {
        HStack {
            Spacer()
            OnboardingCloseButton()
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.horizontal, padding)
        .padding(.top, padding)
    }
}

#Preview {
    OnboardingView(
        onboardingIsShown: .constant(false),
        viewModel: OnboardingViewModel()
    )
}
