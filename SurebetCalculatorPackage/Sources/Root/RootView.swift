import AnalyticsManager
import Banner
import DesignSystem
import FeatureToggles
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
    private let mainMenuDependencies: MainMenu.Dependencies
    private let bannerDependencies: Banner.Dependencies
    @AppStorage(SettingsStorage.themeKey) private var themeRawValue = SettingsTheme.system.rawValue

    // MARK: - Initialization

    init(
        viewModel: RootViewModel,
        onboardingAnalytics: OnboardingAnalytics,
        mainMenuDependencies: MainMenu.Dependencies,
        bannerDependencies: Banner.Dependencies
    ) {
        self.viewModel = viewModel
        self.onboardingAnalytics = onboardingAnalytics
        self.mainMenuDependencies = mainMenuDependencies
        self.bannerDependencies = bannerDependencies
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
        NavigationStack {
            MainMenu.view(
                dependencies: mainMenuDependencies,
                onSectionOpened: { section in
                    viewModel.send(.sectionOpened(section))
                }
            )
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
}

// MARK: - View Modifiers

private struct LifecycleModifier: ViewModifier {
    let viewModel: RootViewModel

    func body(content: Content) -> some View {
        content
            .onAppear {
                viewModel.send(.onAppear)
            }
            .onAppear {
                withAnimation(DesignSystem.Animation.smoothTransition) {
                    viewModel.send(.showOnboardingView)
                }
            }
            .onAppear {
                viewModel.send(.showRequestReview)
            }
            .onAppear {
                viewModel.send(.showFullscreenBanner)
            }
            .onAppear {
                viewModel.send(.fetchBanner)
            }
            .onAppear {
                viewModel.send(.fetchSurvey)
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
        mainMenuDependencies: MainMenu.Dependencies(
            calculator: SurebetCalculator.Dependencies(analytics: NoopCalculatorAnalytics()),
            settings: Settings.Dependencies(themeStore: UserDefaultsThemeStore())
        ),
        bannerDependencies: Banner.Dependencies(
            service: Service(),
            analyticsService: AnalyticsManager(),
            urlOpener: DefaultURLOpener()
        )
    )
}
