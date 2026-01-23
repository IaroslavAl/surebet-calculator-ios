import Foundation

@MainActor
final class OnboardingViewModel: ObservableObject {
    // MARK: - Properties

    @Published private(set) var currentPage: Int
    @Published private(set) var onboardingIsShown: Bool
    let pages: [OnboardingPage]

    // MARK: - Initialization

    init() {
        self.currentPage = 0
        self.onboardingIsShown = false
        self.pages = OnboardingPage.createPages()
    }

    // MARK: - Public Methods

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

// MARK: - Private Methods

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
