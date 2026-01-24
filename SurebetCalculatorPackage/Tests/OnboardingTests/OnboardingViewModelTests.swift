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

    // MARK: - Edge Cases

    /// Тест установки отрицательной страницы
    @Test
    func setCurrentPageWhenNegative() {
        // Given
        let viewModel = OnboardingViewModel()

        // When
        viewModel.send(.setCurrentPage(-1))

        // Then
        // Должно вызвать dismiss, так как индекс не входит в диапазон
        #expect(viewModel.onboardingIsShown == true)
    }

    /// Тест установки страницы равной максимальной
    @Test
    func setCurrentPageWhenEqualToMax() {
        // Given
        let viewModel = OnboardingViewModel()
        let maxPage = viewModel.pages.count - 1

        // When
        viewModel.send(.setCurrentPage(maxPage))

        // Then
        #expect(viewModel.currentPage == maxPage)
        #expect(viewModel.onboardingIsShown == false)
    }

    /// Тест установки страницы больше максимальной
    @Test
    func setCurrentPageWhenGreaterThanMax() {
        // Given
        let viewModel = OnboardingViewModel()
        let maxPage = viewModel.pages.count

        // When
        viewModel.send(.setCurrentPage(maxPage))

        // Then
        // Должно вызвать dismiss
        #expect(viewModel.onboardingIsShown == true)
    }

    /// Тест установки страницы на граничное значение (0)
    @Test
    func setCurrentPageWhenZero() {
        // Given
        let viewModel = OnboardingViewModel()
        viewModel.send(.setCurrentPage(1))

        // When
        viewModel.send(.setCurrentPage(0))

        // Then
        #expect(viewModel.currentPage == 0)
        #expect(viewModel.onboardingIsShown == false)
    }

    /// Тест проверки состояния после dismiss
    @Test
    func dismissSetsOnboardingIsShown() {
        // Given
        let viewModel = OnboardingViewModel()
        viewModel.send(.setCurrentPage(1))

        // When
        viewModel.send(.dismiss)

        // Then
        #expect(viewModel.onboardingIsShown == true)
        // currentPage должен остаться прежним
        #expect(viewModel.currentPage == 1)
    }
}
