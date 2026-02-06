import AnalyticsManager
import AppMetricaCore
import Onboarding
import ReviewHandler
import SwiftUI
import SurebetCalculator

public enum Root {
    // MARK: - Public Methods

    @MainActor
    public static func view() -> some View {
        RootContainerView()
    }
}

@MainActor
private final class RootDependencies: ObservableObject {
    let viewModel: RootViewModel
    let onboardingAnalytics: OnboardingAnalytics
    let calculatorAnalytics: CalculatorAnalytics

    init() {
        let analyticsService = AnalyticsManager()
        let reviewService = ReviewHandler()
        viewModel = RootViewModel(
            analyticsService: analyticsService,
            reviewService: reviewService
        )
        onboardingAnalytics = OnboardingAnalyticsAdapter(
            analyticsService: analyticsService
        )
        calculatorAnalytics = CalculatorAnalyticsAdapter(
            analyticsService: analyticsService
        )
    }
}

private struct RootContainerView: View {
    @StateObject private var dependencies = RootDependencies()

    var body: some View {
        RootView(
            viewModel: dependencies.viewModel,
            onboardingAnalytics: dependencies.onboardingAnalytics,
            calculatorAnalytics: dependencies.calculatorAnalytics
        )
    }
}

// MARK: - AppMetrica
public typealias AppMetrica = AppMetricaCore.AppMetrica
public typealias AppMetricaConfiguration = AppMetricaCore.AppMetricaConfiguration
