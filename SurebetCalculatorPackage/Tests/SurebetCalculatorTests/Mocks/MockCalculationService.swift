import Foundation
@testable import SurebetCalculator

/// Структура для хранения входных данных вызова calculate
struct CalculateInput: @unchecked Sendable {
    let total: TotalRow
    let rows: [Row]
    let selectedRow: RowType?
    let displayedRowIndexes: Range<Int>
}

/// Мок для CalculationService для использования в тестах
final class MockCalculationService: CalculationService, @unchecked Sendable {
    // MARK: - Properties

    var calculateCallCount = 0
    var calculateResult: (total: TotalRow?, rows: [Row]?)?
    var calculateInputs: [CalculateInput] = []

    // MARK: - Public Methods

    func calculate(
        total: TotalRow,
        rows: [Row],
        selectedRow: RowType?,
        displayedRowIndexes: Range<Int>
    ) -> (total: TotalRow?, rows: [Row]?) {
        calculateCallCount += 1
        calculateInputs.append(CalculateInput(
            total: total,
            rows: rows,
            selectedRow: selectedRow,
            displayedRowIndexes: displayedRowIndexes
        ))
        return calculateResult ?? (nil, nil)
    }
}
