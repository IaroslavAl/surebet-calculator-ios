import SwiftUI

public enum Onboarding {
    // MARK: - Public Methods

    public static func view(onboardingIsShown: Binding<Bool>) -> some View {
        OnboardingView(onboardingIsShown: onboardingIsShown)
    }
}
