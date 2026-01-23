import Foundation

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published private(set) var currentPage: Int
    @Published private(set) var onboardingIsShown: Bool
    let pages: [OnboardingPage]

    init() {
        self.currentPage = 0
        self.onboardingIsShown = false
        self.pages = OnboardingPage.createPages()
    }

    enum ViewAction {
        case setCurrentPage(Int)
        case dismiss
    }

    func send(_ action: ViewAction) {
        switch action {
        case let .setCurrentPage(index):
            setCurrentPage(index)
        case .dismiss:
            dismiss()
        }
    }
}

private extension OnboardingViewModel {
    func setCurrentPage(_ index: Int) {
        if pages.indices.contains(index) {
            currentPage = index
        } else {
            dismiss()
        }
    }

    func dismiss() {
        onboardingIsShown = true
    }
}
