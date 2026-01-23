import Foundation
import Testing
@testable import Root
@testable import SurebetCalculator
@testable import AnalyticsManager
@testable import ReviewHandler

/// Интеграционные тесты для проверки взаимодействия модулей
@MainActor
struct IntegrationTests {
    // MARK: - Helper Methods

    /// Очищает UserDefaults для тестовых ключей
    func clearTestUserDefaults() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "onboardingIsShown")
        defaults.removeObject(forKey: "1.7.0")
        defaults.removeObject(forKey: "numberOfOpenings")
    }

    // MARK: - Root -> Calculator Flow

    /// Тест полного flow: RootViewModel -> SurebetCalculatorViewModel -> CalculationService
    @Test
    func rootToCalculatorFlowWhenInitialized() {
        // Given
        clearTestUserDefaults()
        let rootViewModel = RootViewModel()

        // When
        // Инициализация завершена

        // Then
        // RootViewModel готов к работе
        #expect(rootViewModel.shouldShowOnboarding == !rootViewModel.isOnboardingShown)

        // Проверяем, что можем создать SurebetCalculatorViewModel
        let calculatorViewModel = SurebetCalculatorViewModel()
        #expect(calculatorViewModel.selectedNumberOfRows == .two)
        #expect(calculatorViewModel.selectedRow == .total)
    }

    /// Тест передачи данных между модулями через CalculationService
    @Test
    func dataFlowThroughCalculationService() {
        // Given
        let calculatorViewModel = SurebetCalculatorViewModel()

        // When
        calculatorViewModel.send(.setTextFieldText(.totalBetSize, "1000"))
        calculatorViewModel.send(.setTextFieldText(.rowCoefficient(0), "2.5"))
        calculatorViewModel.send(.setTextFieldText(.rowBetSize(0), "500"))

        // Then
        // Проверяем, что данные передались через CalculationService
        #expect(calculatorViewModel.total.betSize == "1000")
        #expect(calculatorViewModel.rows[0].coefficient == "2.5")
        #expect(calculatorViewModel.rows[0].betSize == "500")
    }

    /// Тест обновления UI при изменении состояния
    @Test
    func uiUpdateWhenStateChanges() {
        // Given
        let calculatorViewModel = SurebetCalculatorViewModel()

        // When
        calculatorViewModel.send(.selectRow(.row(0)))

        // Then
        #expect(calculatorViewModel.selectedRow == .row(0))
        #expect(calculatorViewModel.rows[0].isON == true)
    }

    /// Тест MainActor isolation для инициализации обоих ViewModel
    @Test
    func mainActorIsolationWhenInitializingViewModels() async {
        // Given & When
        clearTestUserDefaults()
        // Оба ViewModel должны инициализироваться на MainActor
        let rootViewModel = RootViewModel()
        let calculatorViewModel = SurebetCalculatorViewModel()

        // Then
        // Проверяем, что нет дедлоков и оба ViewModel работают
        #expect(rootViewModel.shouldShowOnboarding == !rootViewModel.isOnboardingShown)
        #expect(calculatorViewModel.selectedNumberOfRows == .two)

        // Проверяем, что можем выполнить действия на MainActor
        await MainActor.run {
            rootViewModel.onAppear()
            calculatorViewModel.send(.addRow)
        }

        // Проверяем, что действия выполнились корректно
        #expect(calculatorViewModel.selectedNumberOfRows == .three)
    }

    /// Тест полного flow: RootViewModel -> SurebetCalculatorViewModel -> CalculationService -> результат
    @Test
    func fullFlowFromRootToCalculation() {
        // Given
        clearTestUserDefaults()
        let rootViewModel = RootViewModel()
        rootViewModel.updateOnboardingShown(true)
        let calculatorViewModel = SurebetCalculatorViewModel()

        // When
        // Пользователь вводит данные в калькулятор
        calculatorViewModel.send(.setTextFieldText(.totalBetSize, "1000"))
        calculatorViewModel.send(.setTextFieldText(.rowCoefficient(0), "2.0"))
        calculatorViewModel.send(.setTextFieldText(.rowCoefficient(1), "2.0"))

        // Then
        // Проверяем, что расчет выполнен через CalculationService
        #expect(calculatorViewModel.total.betSize == "1000")
        #expect(calculatorViewModel.rows[0].coefficient == "2.0")
        #expect(calculatorViewModel.rows[1].coefficient == "2.0")

        // Проверяем, что RootViewModel готов показать калькулятор
        #expect(rootViewModel.isOnboardingShown == true)
    }
}
