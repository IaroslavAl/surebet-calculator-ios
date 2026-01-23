import Foundation

/// Реализация CalculationService, использующая Calculator для выполнения вычислений.
struct DefaultCalculationService: CalculationService, Sendable {
    // MARK: - Public Methods

    /// Выполняет вычисления через Calculator.
    func calculate(
        total: TotalRow,
        rows: [Row],
        selectedRow: RowType?,
        displayedRowIndexes: Range<Int>
    ) -> (total: TotalRow?, rows: [Row]?) {
        let calculator = Calculator(
            total: total,
            rows: rows,
            selectedRow: selectedRow,
            displayedRowIndexes: displayedRowIndexes
        )
        return calculator.calculate()
    }
}
