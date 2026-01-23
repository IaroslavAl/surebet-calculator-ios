@testable import Onboarding
import Testing

@MainActor
struct OnboardingViewModelTests {
    @Test
    func setCurrentPage() {
        // Given
        let viewModel = OnboardingViewModel()

        // When
        viewModel.send(.setCurrentPage(1))

        // Then
        #expect(viewModel.currentPage == 1)
    }

    @Test
    func setCurrentPageWhenCurrentPageIsOutOfRange() {
        // Given
        let viewModel = OnboardingViewModel()

        // When
        viewModel.send(.setCurrentPage(100))

        // Then
        #expect(viewModel.currentPage == 0)
        #expect(viewModel.onboardingIsShown)
    }

    @Test
    func dismiss() {
        // Given
        let viewModel = OnboardingViewModel()

        // When
        viewModel.send(.dismiss)

        // Then
        #expect(viewModel.onboardingIsShown)
    }
}
