@testable import SurebetCalculator

/// Мок для CalculatorAnalytics для использования в тестах
/// Хранит историю вызовов для проверки в тестах
final class MockCalculatorAnalytics: CalculatorAnalytics, @unchecked Sendable {
    enum Event: Equatable {
        case calculatorRowAdded(rowCount: Int)
        case calculatorRowRemoved(rowCount: Int)
        case calculatorCleared
        case calculationPerformed(rowCount: Int, profitPercentage: Double)
    }

    private(set) var events: [Event] = []

    var eventCallCount: Int {
        events.count
    }

    func calculatorRowAdded(rowCount: Int) {
        events.append(.calculatorRowAdded(rowCount: rowCount))
    }

    func calculatorRowRemoved(rowCount: Int) {
        events.append(.calculatorRowRemoved(rowCount: rowCount))
    }

    func calculatorCleared() {
        events.append(.calculatorCleared)
    }

    func calculationPerformed(rowCount: Int, profitPercentage: Double) {
        events.append(
            .calculationPerformed(
                rowCount: rowCount,
                profitPercentage: profitPercentage
            )
        )
    }
}
