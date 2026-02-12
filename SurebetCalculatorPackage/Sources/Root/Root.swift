import AppMetricaCore
import Banner
import MainMenu
import Onboarding
import SwiftUI

public enum Root {
    // MARK: - Public Methods

    @MainActor
    public static func view(container: AppContainer = .live()) -> some View {
        RootContainerView(container: container)
    }
}

@MainActor
private struct RootContainerView: View {
    @StateObject private var viewModel: RootViewModel
    private let onboardingAnalytics: OnboardingAnalytics
    private let mainMenuDependencies: MainMenu.Dependencies
    private let bannerDependencies: Banner.Dependencies

    init(container: AppContainer) {
        _viewModel = StateObject(wrappedValue: container.makeRootViewModel())
        onboardingAnalytics = container.onboardingAnalytics
        mainMenuDependencies = container.mainMenuDependencies
        bannerDependencies = container.bannerDependencies
    }

    var body: some View {
        RootView(
            viewModel: viewModel,
            onboardingAnalytics: onboardingAnalytics,
            mainMenuDependencies: mainMenuDependencies,
            bannerDependencies: bannerDependencies
        )
    }
}

// MARK: - AppMetrica
public typealias AppMetrica = AppMetricaCore.AppMetrica
public typealias AppMetricaConfiguration = AppMetricaCore.AppMetricaConfiguration
