import Foundation
@testable import SurebetCalculator

/// Мок для CalculationService для использования в тестах
final class MockCalculationService: CalculationService, @unchecked Sendable {
    // MARK: - Properties

    var calculateCallCount = 0
    var calculateResult: CalculationResult = .noOp
    var calculateInputs: [CalculationInput] = []

    // MARK: - Public Methods

    func calculate(input: CalculationInput) -> CalculationResult {
        calculateCallCount += 1
        calculateInputs.append(input)
        return calculateResult
    }
}
