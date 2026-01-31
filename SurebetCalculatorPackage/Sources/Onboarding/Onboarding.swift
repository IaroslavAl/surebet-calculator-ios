import SwiftUI

public enum Onboarding {
    // MARK: - Public Methods

    @MainActor
    public static func view(
        onboardingIsShown: Binding<Bool>,
        analytics: OnboardingAnalytics = NoopOnboardingAnalytics()
    ) -> some View {
        OnboardingView(
            onboardingIsShown: onboardingIsShown,
            viewModel: OnboardingViewModel(analytics: analytics)
        )
    }
}
