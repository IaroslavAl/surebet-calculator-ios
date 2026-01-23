import Banner
import Onboarding
import SurebetCalculator
import SwiftUI

struct RootView: View {
    @StateObject private var viewModel = RootViewModel()

    var body: some View {
        Group {
            if viewModel.isOnboardingShown {
                NavigationView {
                    SurebetCalculator.view()
                }
                .navigationViewStyle(.stack)
            } else {
                if viewModel.shouldShowOnboardingWithAnimation {
                    Onboarding.view(onboardingIsShown: Binding(
                        get: { viewModel.isOnboardingShown },
                        set: { viewModel.updateOnboardingShown($0) }
                    ))
                    .transition(.move(edge: .bottom))
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            viewModel.onAppear()
        }
        .onAppear(perform: viewModel.showOnboardingView)
        .onAppear(perform: viewModel.showRequestReview)
        .onAppear(perform: viewModel.showFullscreenBanner)
        .task {
            try? await Banner.fetchBanner()
        }
        .alert(viewModel.requestReviewTitle, isPresented: $viewModel.alertIsPresented) {
            Button("No") {
                viewModel.handleReviewNo()
            }
            Button("Yes") {
                Task {
                    await viewModel.handleReviewYes()
                }
            }
        }
        .overlay {
            if viewModel.fullscreenBannerIsPresented {
                Banner.fullscreenBannerView(isPresented: $viewModel.fullscreenBannerIsPresented)
                    .transition(.move(edge: .bottom))
            }
        }
        .animation(.default, value: viewModel.isOnboardingShown)
        .animation(.easeInOut, value: viewModel.fullscreenBannerIsPresented)
    }
}
