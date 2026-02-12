import AnalyticsManager
import Banner
import FeatureToggles
import Foundation
import MainMenu
import Onboarding
import ReviewHandler
import Settings
import SurebetCalculator
import Survey

protocol LaunchArgumentsProvider: Sendable {
    var arguments: [String] { get }
}

struct ProcessInfoLaunchArgumentsProvider: LaunchArgumentsProvider {
    var arguments: [String] {
        ProcessInfo.processInfo.arguments
    }
}

protocol LocaleProvider: Sendable {
    func currentLocaleIdentifier() -> String
}

struct SystemLocaleProvider: LocaleProvider {
    func currentLocaleIdentifier() -> String {
        Locale.autoupdatingCurrent.identifier
    }
}

@MainActor
public final class AppContainer {
    let mainMenuDependencies: MainMenu.Dependencies
    let bannerDependencies: Banner.Dependencies
    let onboardingAnalytics: OnboardingAnalytics

    private let makeRootViewModelClosure: @MainActor () -> RootViewModel

    init(
        mainMenuDependencies: MainMenu.Dependencies,
        bannerDependencies: Banner.Dependencies,
        onboardingAnalytics: OnboardingAnalytics,
        makeRootViewModel: @escaping @MainActor () -> RootViewModel
    ) {
        self.mainMenuDependencies = mainMenuDependencies
        self.bannerDependencies = bannerDependencies
        self.onboardingAnalytics = onboardingAnalytics
        makeRootViewModelClosure = makeRootViewModel
    }

    func makeRootViewModel() -> RootViewModel {
        makeRootViewModelClosure()
    }

    public static func live(userDefaults: UserDefaults = .standard) -> AppContainer {
        live(
            launchArgumentsProvider: ProcessInfoLaunchArgumentsProvider(),
            localeProvider: SystemLocaleProvider(),
            userDefaults: userDefaults
        )
    }

    static func live(
        launchArgumentsProvider: LaunchArgumentsProvider = ProcessInfoLaunchArgumentsProvider(),
        localeProvider: LocaleProvider = SystemLocaleProvider(),
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
        let bannerService = Service(defaults: userDefaults)
        let surveyService = makeSurveyService()

        let onboardingAnalytics = OnboardingAnalyticsAdapter(
            analyticsService: analyticsService
        )
        let calculatorAnalytics = CalculatorAnalyticsAdapter(
            analyticsService: analyticsService
        )
        let mainMenuDependencies = MainMenu.Dependencies(
            calculator: SurebetCalculator.Dependencies(
                analytics: calculatorAnalytics
            ),
            settings: Settings.Dependencies(
                themeStore: UserDefaultsThemeStore(userDefaults: userDefaults)
            )
        )
        let bannerDependencies = Banner.Dependencies(
            service: bannerService,
            analyticsService: analyticsService,
            urlOpener: DefaultURLOpener()
        )

        return AppContainer(
            mainMenuDependencies: mainMenuDependencies,
            bannerDependencies: bannerDependencies,
            onboardingAnalytics: onboardingAnalytics,
            makeRootViewModel: {
                RootViewModel(
                    analyticsService: analyticsService,
                    reviewService: reviewService,
                    delay: delay,
                    featureFlags: featureFlags,
                    bannerFetcher: {
                        try? await bannerService.fetchBannerAndImage()
                    },
                    bannerCacheChecker: {
                        bannerService.isBannerFullyCached()
                    },
                    surveyService: surveyService,
                    surveyLocaleProvider: makeSurveyLocaleProvider(
                        localeProvider: localeProvider,
                        userDefaults: userDefaults
                    ),
                    rootStateStore: rootStateStore
                )
            }
        )
    }
}

private extension AppContainer {
    static func makeSurveyService() -> SurveyService {
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

    static func makeSurveyLocaleProvider(
        localeProvider: LocaleProvider,
        userDefaults: UserDefaults
    ) -> () -> String {
        {
            let rawValue = userDefaults.string(forKey: SettingsStorage.languageKey)
                ?? SettingsLanguage.system.rawValue
            let selectedLanguage = SettingsLanguage(rawValue: rawValue) ?? .system

            switch selectedLanguage {
            case .system:
                return localeProvider.currentLocaleIdentifier()
            default:
                return selectedLanguage.rawValue
            }
        }
    }
}
