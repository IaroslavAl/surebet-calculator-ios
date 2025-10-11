import AnalyticsManager
import Banner
import Onboarding
import ReviewHandler
import SurebetCalculator
import SwiftUI

struct RootView: View {
    @AppStorage("onboardingIsShown") private var onboardingIsShown = false
    @AppStorage("1.4.0") private var requestReviewWasShown = false
    @AppStorage("numberOfOpenings") private var numberOfOpenings = 0

    @State private var isAnimation = false
    @State private var alertIsPresented = false
    @State private var fullscreenBannerIsPresented = false

    var body: some View {
        Group {
            if onboardingIsShown {
                NavigationView {
                    SurebetCalculator.view()
                }
                .navigationViewStyle(.stack)
            } else {
                if isAnimation {
                    Onboarding.view(onboardingIsShown: $onboardingIsShown)
                        .transition(.move(edge: .bottom))
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            numberOfOpenings += 1
        }
        .onAppear(perform: showOnboardingView)
        .onAppear(perform: showRequestReview)
        .onAppear(perform: showFullscreenBanner)
        .alert(requestReviewTitle, isPresented: $alertIsPresented) {
            Button("No") {
                alertIsPresented = false
                AnalyticsManager.log(name: "RequestReview", parameters: ["enjoying_calculator": false])
            }
            Button("Yes") {
                alertIsPresented = false
                ReviewHandler.requestReview()
                AnalyticsManager.log(name: "RequestReview", parameters: ["enjoying_calculator": true])
            }
        }
        .overlay {
            if fullscreenBannerIsPresented {
                Banner.fullscreenBannerView(isPresented: $fullscreenBannerIsPresented)
                    .transition(.move(edge: .bottom))
            }
        }
        .animation(.default, value: onboardingIsShown)
        .animation(.easeInOut, value: fullscreenBannerIsPresented)
    }
}

private extension RootView {
    var requestReviewTitle: String {
        "Do you like the app?"
    }

    func showOnboardingView() {
        withAnimation {
            isAnimation = true
        }
    }

    func showFullscreenBanner() {
        if fullscreenBannerIsAvailable {
            fullscreenBannerIsPresented = true
        }
    }

    var fullscreenBannerIsAvailable: Bool {
        onboardingIsShown && requestReviewWasShown && numberOfOpenings.isMultiple(of: 3)
    }

    func showRequestReview() {
#if !DEBUG
        Task {
            try await Task.sleep(nanoseconds: NSEC_PER_SEC * 1)
            if !requestReviewWasShown, numberOfOpenings >= 2, onboardingIsShown {
                alertIsPresented = true
                requestReviewWasShown = true
            }
        }
#endif
    }
}
