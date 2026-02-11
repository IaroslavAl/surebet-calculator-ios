import AnalyticsManager
import AppMetricaCore
import FeatureToggles
import Onboarding
import ReviewHandler
import Settings
import SwiftUI
import SurebetCalculator
import Survey

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
        let surveyService = Self.makeSurveyService()
        let featureFlagsProvider = DefaultFeatureFlagsProvider()
        viewModel = RootViewModel(
            analyticsService: analyticsService,
            reviewService: reviewService,
            featureFlags: featureFlagsProvider.snapshot(),
            surveyService: surveyService,
            surveyLocaleProvider: Self.selectedSurveyLocaleIdentifier
        )
        onboardingAnalytics = OnboardingAnalyticsAdapter(
            analyticsService: analyticsService
        )
        calculatorAnalytics = CalculatorAnalyticsAdapter(
            analyticsService: analyticsService
        )
    }

    private static func makeSurveyService() -> SurveyService {
        switch RootConstants.surveyDataSource {
        case .mock:
            return MockSurveyService(scenario: RootConstants.surveyMockScenario)
        case .remote:
            guard let baseURL = URL(string: RootConstants.surveyAPIBaseURL) else {
                return MockSurveyService(scenario: RootConstants.surveyMockScenario)
            }
            return RemoteSurveyService(baseURL: baseURL)
        }
    }

    nonisolated private static func selectedSurveyLocaleIdentifier() -> String {
        let rawValue = UserDefaults.standard.string(forKey: SettingsStorage.languageKey)
            ?? SettingsLanguage.system.rawValue
        let selectedLanguage = SettingsLanguage(rawValue: rawValue) ?? .system

        switch selectedLanguage {
        case .system:
            return Locale.autoupdatingCurrent.identifier
        default:
            return selectedLanguage.rawValue
        }
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
