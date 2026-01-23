import Foundation

/// Протокол для сервиса вычислений в калькуляторе сурбетов.
/// Обеспечивает инверсию зависимостей и позволяет легко тестировать ViewModel.
protocol CalculationService {
    /// Выполняет вычисления на основе текущего состояния калькулятора.
    /// - Parameters:
    ///   - total: Текущая строка с итоговыми данными.
    ///   - rows: Массив строк с данными о ставках.
    ///   - selectedRow: Выбранная строка для вычислений.
    ///   - displayedRowIndexes: Диапазон индексов отображаемых строк.
    /// - Returns: Кортеж с обновленными данными (total и rows), или nil если вычисления не требуются.
    func calculate(
        total: TotalRow,
        rows: [Row],
        selectedRow: RowType?,
        displayedRowIndexes: Range<Int>
    ) -> (total: TotalRow?, rows: [Row]?)
}
