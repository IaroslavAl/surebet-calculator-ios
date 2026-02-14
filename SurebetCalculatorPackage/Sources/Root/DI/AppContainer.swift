import AnalyticsManager
import FeatureToggles
import Foundation
import Onboarding
import ReviewHandler
import Settings
import SurebetCalculator

protocol LaunchArgumentsProvider: Sendable {
    var arguments: [String] { get }
}

struct ProcessInfoLaunchArgumentsProvider: LaunchArgumentsProvider {
    var arguments: [String] {
        ProcessInfo.processInfo.arguments
    }
}

@MainActor
public final class AppContainer {
    let calculatorDependencies: SurebetCalculator.Dependencies
    let settingsDependencies: Settings.Dependencies
    let onboardingAnalytics: OnboardingAnalytics
    let userDefaults: UserDefaults

    private let makeRootViewModelClosure: @MainActor () -> RootViewModel

    init(
        calculatorDependencies: SurebetCalculator.Dependencies,
        settingsDependencies: Settings.Dependencies,
        onboardingAnalytics: OnboardingAnalytics,
        userDefaults: UserDefaults,
        makeRootViewModel: @escaping @MainActor () -> RootViewModel
    ) {
        self.calculatorDependencies = calculatorDependencies
        self.settingsDependencies = settingsDependencies
        self.onboardingAnalytics = onboardingAnalytics
        self.userDefaults = userDefaults
        makeRootViewModelClosure = makeRootViewModel
    }

    func makeRootViewModel() -> RootViewModel {
        makeRootViewModelClosure()
    }

    public static func live(userDefaults: UserDefaults = .standard) -> AppContainer {
        live(
            launchArgumentsProvider: ProcessInfoLaunchArgumentsProvider(),
            userDefaults: userDefaults
        )
    }

    static func live(
        launchArgumentsProvider: LaunchArgumentsProvider = ProcessInfoLaunchArgumentsProvider(),
        userDefaults: UserDefaults
    ) -> AppContainer {
        let analyticsService = AnalyticsManager()
        let reviewService = ReviewHandler()
        let delay = SystemDelay()
        let featureFlagsProvider = DefaultFeatureFlagsProvider(
            launchArguments: launchArgumentsProvider.arguments,
            userDefaults: userDefaults
        )
        let featureFlags = featureFlagsProvider.snapshot()
        let rootStateStore = UserDefaultsRootStateStore(userDefaults: userDefaults)

        let onboardingAnalytics = OnboardingAnalyticsAdapter(
            analyticsService: analyticsService
        )
        let calculatorAnalytics = CalculatorAnalyticsAdapter(
            analyticsService: analyticsService
        )
        let calculatorDependencies = SurebetCalculator.Dependencies(
            analytics: calculatorAnalytics
        )
        let settingsDependencies = Settings.Dependencies(
            themeStore: UserDefaultsThemeStore(userDefaults: userDefaults)
        )

        return AppContainer(
            calculatorDependencies: calculatorDependencies,
            settingsDependencies: settingsDependencies,
            onboardingAnalytics: onboardingAnalytics,
            userDefaults: userDefaults,
            makeRootViewModel: {
                RootViewModel(
                    analyticsService: analyticsService,
                    reviewService: reviewService,
                    delay: delay,
                    featureFlags: featureFlags,
                    rootStateStore: rootStateStore
                )
            }
        )
    }
}
