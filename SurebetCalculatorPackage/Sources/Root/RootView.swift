import Banner
import Onboarding
import SurebetCalculator
import SwiftUI

@MainActor
struct RootView: View {
    // MARK: - Properties

    @StateObject private var viewModel = RootViewModel()

    // MARK: - Body

    var body: some View {
        mainContent
            .modifier(LifecycleModifier(viewModel: viewModel))
            .modifier(ReviewAlertModifier(viewModel: viewModel))
            .modifier(FullscreenBannerOverlayModifier(viewModel: viewModel))
            .modifier(AnimationModifier(viewModel: viewModel))
    }
}

// MARK: - Private Computed Properties

private extension RootView {
    var mainContent: some View {
        Group {
            if viewModel.isOnboardingShown {
                calculatorView
            } else {
                onboardingView
            }
        }
    }

    var calculatorView: some View {
        NavigationView {
            SurebetCalculator.view()
        }
        .navigationViewStyle(.stack)
    }

    @ViewBuilder
    var onboardingView: some View {
        if viewModel.shouldShowOnboardingWithAnimation {
            Onboarding.view(onboardingIsShown: onboardingBinding)
                .transition(AppConstants.Animations.moveFromBottom)
        }
    }

    var onboardingBinding: Binding<Bool> {
        Binding(
            get: { viewModel.isOnboardingShown },
            set: { viewModel.send(.updateOnboardingShown($0)) }
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
                withAnimation(AppConstants.Animations.smoothTransition) {
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
    private var alertIsPresentedBinding: Binding<Bool> {
        Binding(
            get: { viewModel.alertIsPresented },
            set: { viewModel.send(.setAlertPresented($0)) }
        )
    }

    func body(content: Content) -> some View {
        content
            .alert(viewModel.requestReviewTitle, isPresented: alertIsPresentedBinding) {
                Button(RootLocalizationKey.reviewButtonNo.localized) {
                    viewModel.send(.handleReviewNo)
                }
                Button(RootLocalizationKey.reviewButtonYes.localized) {
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
                        .transition(AppConstants.Animations.moveFromBottom)
                }
            }
    }
}

private struct AnimationModifier: ViewModifier {
    @ObservedObject var viewModel: RootViewModel

    func body(content: Content) -> some View {
        content
            .animation(AppConstants.Animations.smoothTransition, value: viewModel.isOnboardingShown)
            .animation(AppConstants.Animations.smoothTransition, value: viewModel.fullscreenBannerIsPresented)
    }
}

// MARK: - Preview

#Preview {
    RootView()
}
