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
            .preferredColorScheme(.dark)
            .modifier(LifecycleModifier(viewModel: viewModel))
            .modifier(BannerTaskModifier())
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
                .transition(.move(edge: .bottom))
        }
    }

    var onboardingBinding: Binding<Bool> {
        Binding(
            get: { viewModel.isOnboardingShown },
            set: { viewModel.updateOnboardingShown($0) }
        )
    }
}

// MARK: - View Modifiers

private struct LifecycleModifier: ViewModifier {
    let viewModel: RootViewModel

    func body(content: Content) -> some View {
        content
            .onAppear {
                viewModel.onAppear()
            }
            .onAppear(perform: viewModel.showOnboardingView)
            .onAppear(perform: viewModel.showRequestReview)
            .onAppear(perform: viewModel.showFullscreenBanner)
    }
}

private struct BannerTaskModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .task {
                try? await Banner.fetchBanner()
            }
    }
}

private struct ReviewAlertModifier: ViewModifier {
    @ObservedObject var viewModel: RootViewModel

    func body(content: Content) -> some View {
        content
            .alert(viewModel.requestReviewTitle, isPresented: $viewModel.alertIsPresented) {
                Button(String(localized: "No")) {
                    viewModel.handleReviewNo()
                }
                Button(String(localized: "Yes")) {
                    Task {
                        await viewModel.handleReviewYes()
                    }
                }
            }
    }
}

private struct FullscreenBannerOverlayModifier: ViewModifier {
    @ObservedObject var viewModel: RootViewModel

    func body(content: Content) -> some View {
        content
            .overlay {
                if viewModel.fullscreenBannerIsPresented {
                    Banner.fullscreenBannerView(isPresented: $viewModel.fullscreenBannerIsPresented)
                        .transition(.move(edge: .bottom))
                }
            }
    }
}

private struct AnimationModifier: ViewModifier {
    @ObservedObject var viewModel: RootViewModel

    func body(content: Content) -> some View {
        content
            .animation(.default, value: viewModel.isOnboardingShown)
            .animation(.easeInOut, value: viewModel.fullscreenBannerIsPresented)
    }
}

// MARK: - Preview

#Preview {
    RootView()
}
