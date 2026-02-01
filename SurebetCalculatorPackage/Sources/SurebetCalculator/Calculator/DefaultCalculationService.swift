import Foundation

/// Реализация CalculationService, использующая Calculator для выполнения вычислений.
struct DefaultCalculationService: CalculationService, Sendable {
    // MARK: - Public Methods

    /// Выполняет вычисления через Calculator.
    func calculate(input: CalculationInput) -> CalculationResult {
        let calculator = Calculator(
            total: input.total,
            rowsById: input.rowsById,
            orderedRowIds: input.orderedRowIds,
            activeRowIds: input.activeRowIds,
            selection: input.selection
        )
        return calculator.calculate()
    }
}
