import AppMetricaCore
import Banner
import Onboarding
import Settings
import SurebetCalculator
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
    private let calculatorDependencies: SurebetCalculator.Dependencies
    private let settingsDependencies: Settings.Dependencies
    private let bannerDependencies: Banner.Dependencies
    private let userDefaults: UserDefaults

    init(container: AppContainer) {
        _viewModel = StateObject(wrappedValue: container.makeRootViewModel())
        onboardingAnalytics = container.onboardingAnalytics
        calculatorDependencies = container.calculatorDependencies
        settingsDependencies = container.settingsDependencies
        bannerDependencies = container.bannerDependencies
        userDefaults = container.userDefaults
    }

    var body: some View {
        RootView(
            viewModel: viewModel,
            onboardingAnalytics: onboardingAnalytics,
            calculatorDependencies: calculatorDependencies,
            settingsDependencies: settingsDependencies,
            bannerDependencies: bannerDependencies,
            themeUserDefaults: userDefaults
        )
    }
}

// MARK: - AppMetrica
public typealias AppMetrica = AppMetricaCore.AppMetrica
public typealias AppMetricaConfiguration = AppMetricaCore.AppMetricaConfiguration
