@testable import SurebetCalculator

/// Мок для CalculatorAnalytics для использования в тестах
/// Хранит историю вызовов для проверки в тестах
final class MockCalculatorAnalytics: CalculatorAnalytics, @unchecked Sendable {
    enum Event: Equatable {
        case calculatorRowsCountChanged(
            rowCount: Int,
            changeDirection: CalculatorRowsCountChangeDirection
        )
        case calculatorModeSelected(mode: CalculatorMode)
        case calculatorCleared
        case calculatorCalculationPerformed(
            rowCount: Int,
            mode: CalculatorMode,
            profitPercentage: Double,
            isProfitable: Bool
        )
    }

    private(set) var events: [Event] = []

    var eventCallCount: Int {
        events.count
    }

    func calculatorRowsCountChanged(
        rowCount: Int,
        changeDirection: CalculatorRowsCountChangeDirection
    ) {
        events.append(
            .calculatorRowsCountChanged(
                rowCount: rowCount,
                changeDirection: changeDirection
            )
        )
    }

    func calculatorModeSelected(mode: CalculatorMode) {
        events.append(.calculatorModeSelected(mode: mode))
    }

    func calculatorCleared() {
        events.append(.calculatorCleared)
    }

    func calculatorCalculationPerformed(
        rowCount: Int,
        mode: CalculatorMode,
        profitPercentage: Double,
        isProfitable: Bool
    ) {
        events.append(
            .calculatorCalculationPerformed(
                rowCount: rowCount,
                mode: mode,
                profitPercentage: profitPercentage,
                isProfitable: isProfitable
            )
        )
    }
}
