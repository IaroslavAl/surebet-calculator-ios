import Banner
import DesignSystem
import MainMenu
import Onboarding
import Settings
import SurebetCalculator
import SwiftUI

@MainActor
struct RootView: View {
    // MARK: - Properties

    @StateObject private var viewModel: RootViewModel
    private let onboardingAnalytics: OnboardingAnalytics
    private let calculatorAnalytics: CalculatorAnalytics
    @AppStorage(SettingsStorage.themeKey) private var themeRawValue = SettingsTheme.system.rawValue

    // MARK: - Initialization

    init(
        viewModel: RootViewModel,
        onboardingAnalytics: OnboardingAnalytics,
        calculatorAnalytics: CalculatorAnalytics
    ) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.onboardingAnalytics = onboardingAnalytics
        self.calculatorAnalytics = calculatorAnalytics
    }

    // MARK: - Body

    var body: some View {
        mainContent
            .preferredColorScheme(selectedTheme.preferredColorScheme)
            .modifier(LifecycleModifier(viewModel: viewModel))
            .modifier(ReviewAlertModifier(viewModel: viewModel))
            .modifier(FullscreenBannerOverlayModifier(viewModel: viewModel))
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
            MainMenu.view(calculatorAnalytics: calculatorAnalytics)
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
                    Banner.fullscreenBannerView(isPresented: fullscreenBannerBinding)
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

// MARK: - Preview

#Preview {
    RootView(
        viewModel: RootViewModel(),
        onboardingAnalytics: NoopOnboardingAnalytics(),
        calculatorAnalytics: NoopCalculatorAnalytics()
    )
}
