import AnalyticsManager
import DesignSystem
import FeatureToggles
import Foundation
import MainMenu
import Onboarding
import ReviewHandler
import Settings
import SurebetCalculator
import SwiftUI

@MainActor
struct RootView: View {
    // MARK: - Properties

    @ObservedObject private var viewModel: RootViewModel
    private let onboardingAnalytics: OnboardingAnalytics
    private let calculatorDependencies: SurebetCalculator.Dependencies
    private let settingsDependencies: Settings.Dependencies
    @AppStorage private var themeRawValue: String

    // MARK: - Initialization

    init(
        viewModel: RootViewModel,
        onboardingAnalytics: OnboardingAnalytics,
        calculatorDependencies: SurebetCalculator.Dependencies,
        settingsDependencies: Settings.Dependencies,
        themeUserDefaults: UserDefaults = .standard
    ) {
        self.viewModel = viewModel
        self.onboardingAnalytics = onboardingAnalytics
        self.calculatorDependencies = calculatorDependencies
        self.settingsDependencies = settingsDependencies
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

// MARK: - Preview

#Preview {
    RootView(
        viewModel: RootViewModel(
            analyticsService: AnalyticsManager(),
            reviewService: ReviewHandler(),
            delay: SystemDelay(),
            featureFlags: .releaseDefaults,
            rootStateStore: UserDefaultsRootStateStore()
        ),
        onboardingAnalytics: NoopOnboardingAnalytics(),
        calculatorDependencies: SurebetCalculator.Dependencies(analytics: NoopCalculatorAnalytics()),
        settingsDependencies: Settings.Dependencies(themeStore: UserDefaultsThemeStore())
    )
}
