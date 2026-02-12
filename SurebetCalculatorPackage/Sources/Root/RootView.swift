import AnalyticsManager
import Banner
import DesignSystem
import FeatureToggles
import Foundation
import MainMenu
import Onboarding
import ReviewHandler
import Settings
import SurebetCalculator
import Survey
import SwiftUI

@MainActor
struct RootView: View {
    // MARK: - Properties

    @ObservedObject private var viewModel: RootViewModel
    private let onboardingAnalytics: OnboardingAnalytics
    private let calculatorDependencies: SurebetCalculator.Dependencies
    private let settingsDependencies: Settings.Dependencies
    private let bannerDependencies: Banner.Dependencies
    @AppStorage private var themeRawValue: String

    // MARK: - Initialization

    init(
        viewModel: RootViewModel,
        onboardingAnalytics: OnboardingAnalytics,
        calculatorDependencies: SurebetCalculator.Dependencies,
        settingsDependencies: Settings.Dependencies,
        bannerDependencies: Banner.Dependencies,
        themeUserDefaults: UserDefaults = .standard
    ) {
        self.viewModel = viewModel
        self.onboardingAnalytics = onboardingAnalytics
        self.calculatorDependencies = calculatorDependencies
        self.settingsDependencies = settingsDependencies
        self.bannerDependencies = bannerDependencies
        _themeRawValue = AppStorage(
            wrappedValue: SettingsTheme.system.rawValue,
            SettingsStorage.themeKey,
            store: themeUserDefaults
        )
    }

    // MARK: - Body

    var body: some View {
        mainContent
            .preferredColorScheme(selectedTheme.preferredColorScheme)
            .modifier(LifecycleModifier(viewModel: viewModel))
            .modifier(ReviewAlertModifier(viewModel: viewModel))
            .modifier(
                FullscreenBannerOverlayModifier(
                    viewModel: viewModel,
                    bannerDependencies: bannerDependencies
                )
            )
            .modifier(SurveySheetModifier(viewModel: viewModel))
            .modifier(AnimationModifier(viewModel: viewModel))
    }
}

// MARK: - Private Computed Properties

private extension RootView {
    var selectedTheme: SettingsTheme {
        SettingsTheme(rawValue: themeRawValue) ?? .system
    }

    var mainContent: some View {
        ZStack {
            menuView
            onboardingView
        }
    }

    var menuView: some View {
        NavigationStack(path: navigationPathBinding) {
            MainMenu.view(
                onRouteRequested: { route in
                    viewModel.send(.mainMenuRouteRequested(route))
                }
            )
            .navigationDestination(for: AppRoute.self) { route in
                destination(for: route)
            }
        }
        .allowsHitTesting(!viewModel.shouldShowOnboardingWithAnimation)
        .accessibilityHidden(viewModel.shouldShowOnboardingWithAnimation)
    }

    var onboardingView: some View {
        Group {
            if viewModel.shouldShowOnboardingWithAnimation {
                Onboarding.view(
                    onboardingIsShown: onboardingBinding,
                    analytics: onboardingAnalytics
                )
                .transition(DesignSystem.Animation.moveFromBottom)
            }
        }
        .zIndex(1)
        .animation(DesignSystem.Animation.smoothTransition, value: viewModel.shouldShowOnboardingWithAnimation)
    }

    var onboardingBinding: Binding<Bool> {
        Binding(
            get: { viewModel.isOnboardingShown },
            set: { value in
                withAnimation(DesignSystem.Animation.smoothTransition) {
                    viewModel.send(.updateOnboardingShown(value))
                }
            }
        )
    }

    var navigationPathBinding: Binding<[AppRoute]> {
        Binding(
            get: { viewModel.navigationPath },
            set: { viewModel.send(.setNavigationPath($0)) }
        )
    }

    @ViewBuilder
    func destination(for route: AppRoute) -> some View {
        switch route {
        case let .mainMenu(mainMenuRoute):
            mainMenuDestination(for: mainMenuRoute)
        }
    }

    @ViewBuilder
    func mainMenuDestination(for route: MainMenuRoute) -> some View {
        switch route {
        case let .section(section):
            switch section {
            case .calculator:
                SurebetCalculator.view(dependencies: calculatorDependencies)
            case .settings:
                Settings.view(dependencies: settingsDependencies)
            case .instructions:
                MainMenu.instructionsView()
            }
        case .disableAds:
            MainMenu.disableAdsPlaceholderView()
        }
    }
}

// MARK: - View Modifiers

private struct LifecycleModifier: ViewModifier {
    let viewModel: RootViewModel

    func body(content: Content) -> some View {
        content
            .onAppear {
                viewModel.send(.rootLifecycleStarted)
            }
    }
}

private struct ReviewAlertModifier: ViewModifier {
    @ObservedObject var viewModel: RootViewModel
    @Environment(\.locale) private var locale
    private var alertIsPresentedBinding: Binding<Bool> {
        Binding(
            get: { viewModel.alertIsPresented },
            set: { viewModel.send(.setAlertPresented($0)) }
        )
    }

    func body(content: Content) -> some View {
        content
            .alert(viewModel.requestReviewTitle(locale: locale), isPresented: alertIsPresentedBinding) {
                Button(RootLocalizationKey.reviewButtonNo.localized(locale)) {
                    viewModel.send(.handleReviewNo)
                }
                Button(RootLocalizationKey.reviewButtonYes.localized(locale)) {
                    viewModel.send(.handleReviewYes)
                }
            }
    }
}

private struct FullscreenBannerOverlayModifier: ViewModifier {
    @ObservedObject var viewModel: RootViewModel
    let bannerDependencies: Banner.Dependencies
    private var fullscreenBannerBinding: Binding<Bool> {
        Binding(
            get: { viewModel.fullscreenBannerIsPresented },
            set: { viewModel.send(.setFullscreenBannerPresented($0)) }
        )
    }

    func body(content: Content) -> some View {
        content
            .overlay {
                if viewModel.fullscreenBannerIsPresented {
                    Banner.fullscreenBannerView(
                        isPresented: fullscreenBannerBinding,
                        dependencies: bannerDependencies
                    )
                        .transition(DesignSystem.Animation.moveFromBottom)
                }
            }
    }
}

private struct AnimationModifier: ViewModifier {
    @ObservedObject var viewModel: RootViewModel

    func body(content: Content) -> some View {
        content
            .animation(DesignSystem.Animation.smoothTransition, value: viewModel.fullscreenBannerIsPresented)
    }
}

private struct SurveySheetModifier: ViewModifier {
    @ObservedObject var viewModel: RootViewModel

    private var surveyIsPresentedBinding: Binding<Bool> {
        Binding(
            get: { viewModel.surveyIsPresented },
            set: { viewModel.send(.setSurveyPresented($0)) }
        )
    }

    func body(content: Content) -> some View {
        content
            .sheet(
                isPresented: surveyIsPresentedBinding,
                onDismiss: {
                    viewModel.send(.surveySheetDismissed)
                }
            ) {
                if let survey = viewModel.activeSurvey {
                    Survey.sheet(
                        survey: survey,
                        onSubmit: { submission in
                            viewModel.send(.surveySubmitted(submission))
                        },
                        onClose: {
                            viewModel.send(.surveyCloseTapped)
                        }
                    )
                }
            }
    }
}

// MARK: - Preview

#Preview {
    RootView(
        viewModel: RootViewModel(
            analyticsService: AnalyticsManager(),
            reviewService: ReviewHandler(),
            delay: SystemDelay(),
            featureFlags: .releaseDefaults,
            bannerFetcher: { },
            bannerCacheChecker: { false },
            surveyService: MockSurveyService(scenario: .none),
            surveyLocaleProvider: { Locale.autoupdatingCurrent.identifier },
            rootStateStore: UserDefaultsRootStateStore()
        ),
        onboardingAnalytics: NoopOnboardingAnalytics(),
        calculatorDependencies: SurebetCalculator.Dependencies(analytics: NoopCalculatorAnalytics()),
        settingsDependencies: Settings.Dependencies(themeStore: UserDefaultsThemeStore()),
        bannerDependencies: Banner.Dependencies(
            service: Service(),
            analyticsService: AnalyticsManager(),
            urlOpener: DefaultURLOpener()
        )
    )
}
