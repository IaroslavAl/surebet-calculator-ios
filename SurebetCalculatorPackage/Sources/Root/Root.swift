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
        let analyticsService = AnalyticsManager()
        let reviewService = ReviewHandler()
        let viewModel = RootViewModel(
            analyticsService: analyticsService,
            reviewService: reviewService
        )
        let onboardingAnalytics = OnboardingAnalyticsAdapter(
            analyticsService: analyticsService
        )
        let calculatorAnalytics = CalculatorAnalyticsAdapter(
            analyticsService: analyticsService
        )

        return RootView(
            viewModel: viewModel,
            onboardingAnalytics: onboardingAnalytics,
            calculatorAnalytics: calculatorAnalytics
        )
    }
}

// MARK: - AppMetrica
public typealias AppMetrica = AppMetricaCore.AppMetrica
public typealias AppMetricaConfiguration = AppMetricaCore.AppMetricaConfiguration
