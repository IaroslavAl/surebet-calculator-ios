@testable import SurebetCalculator
import Foundation
import Testing

// swiftlint:disable file_length
struct CalculatorTests {
    // MARK: - Helpers

    /// Форматирует число в строку с учётом текущей локали (для тестов).
    private func formatNumber(_ value: Double, isPercent: Bool = false) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.locale = Locale.current
        let formatted = formatter.string(from: value as NSNumber) ?? ""
        return isPercent ? formatted + "%" : formatted
    }

    private func makeRows(_ rows: [Row]) -> (rowsById: [RowID: Row], orderedRowIds: [RowID]) {
        let orderedRowIds = rows.map(\.id)
        let rowsById = Dictionary(uniqueKeysWithValues: rows.map { ($0.id, $0) })
        return (rowsById: rowsById, orderedRowIds: orderedRowIds)
    }

    private func makeCalculator(
        total: TotalRow,
        rows: [Row],
        activeCount: Int,
        selection: Selection
    ) -> Calculator {
        let data = makeRows(rows)
        let activeRowIds = Array(data.orderedRowIds.prefix(activeCount))
        return Calculator(
            total: total,
            rowsById: data.rowsById,
            orderedRowIds: data.orderedRowIds,
            activeRowIds: activeRowIds,
            selection: selection
        )
    }

    private func expectUpdated(_ result: CalculationResult) -> CalculationOutput {
        switch result {
        case let .updated(output):
            return output
        default:
            #expect(Bool(false))
            return CalculationOutput(total: TotalRow(), rowsById: [:])
        }
    }

    private func expectResetDerived(_ result: CalculationResult) -> CalculationOutput {
        switch result {
        case let .resetDerived(output):
            return output
        default:
            #expect(Bool(false))
            return CalculationOutput(total: TotalRow(), rowsById: [:])
        }
    }

    private func expectNotNoOp(_ result: CalculationResult) {
        if case .noOp = result {
            #expect(Bool(false))
        }
    }

    @Test
    func resetDerivedWhenActiveRowIdsLessThanTwo() {
        // Given
        let calculator = makeCalculator(
            total: TotalRow(betSize: "1000", profitPercentage: "10%"),
            rows: [
                Row(id: RowID(rawValue: 0), betSize: "1000", coefficient: "2", income: "999")
            ],
            activeCount: 1,
            selection: .total
        )

        // When
        let result = calculator.calculate()

        // Then
        let output = expectResetDerived(result)
        #expect(output.total.betSize == "1000")
        #expect(output.total.profitPercentage == "0%")
        #expect(output.rowsById[RowID(rawValue: 0)]?.betSize == "")
        #expect(output.rowsById[RowID(rawValue: 0)]?.income == "0")
    }

    @Test
    func totalCalculation() {
        // Given
        let calculator = makeCalculator(
            total: TotalRow(betSize: "1000", profitPercentage: ""),
            rows: [
                Row(id: RowID(rawValue: 0), betSize: "", coefficient: "2", income: ""),
                Row(id: RowID(rawValue: 1), betSize: "", coefficient: "3", income: "")
            ],
            activeCount: 2,
            selection: .total
        )

        // When
        let result = calculator.calculate()

        // Then
        let output = expectUpdated(result)
        #expect(output.total.betSize == "1000")
        #expect(output.total.profitPercentage == "20%")
        #expect(output.rowsById[RowID(rawValue: 0)]?.income == "200")
        #expect(output.rowsById[RowID(rawValue: 0)]?.betSize == "600")
        #expect(output.rowsById[RowID(rawValue: 1)]?.income == "200")
        #expect(output.rowsById[RowID(rawValue: 1)]?.betSize == "400")
    }

    @Test
    func rowCalculation() {
        // Given
        let calculator = makeCalculator(
            total: TotalRow(betSize: "", profitPercentage: ""),
            rows: [
                Row(id: RowID(rawValue: 0), betSize: "500", coefficient: "2", income: ""),
                Row(id: RowID(rawValue: 1), betSize: "", coefficient: "3", income: "")
            ],
            activeCount: 2,
            selection: .row(RowID(rawValue: 0))
        )

        // When
        let result = calculator.calculate()

        // Then
        let output = expectUpdated(result)
        #expect(output.total.betSize == formatNumber(833.33))
        #expect(output.total.profitPercentage == "20%")
        #expect(output.rowsById[RowID(rawValue: 0)]?.income == formatNumber(166.67))
        #expect(output.rowsById[RowID(rawValue: 1)]?.income == formatNumber(166.67))
        #expect(output.rowsById[RowID(rawValue: 1)]?.betSize == formatNumber(333.33))
    }

    @Test
    func noneCalculation() {
        // Given
        let calculator = makeCalculator(
            total: TotalRow(betSize: "", profitPercentage: ""),
            rows: [
                Row(id: RowID(rawValue: 0), betSize: "", coefficient: "2", income: ""),
                Row(id: RowID(rawValue: 1), betSize: "", coefficient: "3", income: "")
            ],
            activeCount: 2,
            selection: .none
        )

        // When
        let result = calculator.calculate()

        // Then
        let output = expectResetDerived(result)
        #expect(output.total.betSize == "")
        #expect(output.total.profitPercentage == "0%")
        #expect(output.rowsById[RowID(rawValue: 0)]?.betSize == "")
        #expect(output.rowsById[RowID(rawValue: 0)]?.coefficient == "2")
        #expect(output.rowsById[RowID(rawValue: 0)]?.income == "0")
        #expect(output.rowsById[RowID(rawValue: 1)]?.betSize == "")
        #expect(output.rowsById[RowID(rawValue: 1)]?.coefficient == "3")
        #expect(output.rowsById[RowID(rawValue: 1)]?.income == "0")
    }

    @Test
    func rowCalculationWhenBetSizeIsEmpty() {
        // Given
        let calculator = makeCalculator(
            total: TotalRow(betSize: "1000", profitPercentage: "77%"),
            rows: [
                Row(id: RowID(rawValue: 0), betSize: "", coefficient: "2", income: "123"),
                Row(id: RowID(rawValue: 1), betSize: "200", coefficient: "3", income: "456")
            ],
            activeCount: 2,
            selection: .row(RowID(rawValue: 0))
        )

        // When
        let result = calculator.calculate()

        // Then
        let output = expectResetDerived(result)
        #expect(output.total.betSize == "")
        #expect(output.total.profitPercentage == "0%")
        #expect(output.rowsById[RowID(rawValue: 0)]?.betSize == "")
        #expect(output.rowsById[RowID(rawValue: 0)]?.coefficient == "2")
        #expect(output.rowsById[RowID(rawValue: 0)]?.income == "0")
        #expect(output.rowsById[RowID(rawValue: 1)]?.betSize == "")
        #expect(output.rowsById[RowID(rawValue: 1)]?.coefficient == "3")
        #expect(output.rowsById[RowID(rawValue: 1)]?.income == "0")
    }

    @Test
    func rowsCalculationWhenAnyBetSizeIsInvalid() {
        // Given
        let calculator = makeCalculator(
            total: TotalRow(betSize: "900", profitPercentage: "12%"),
            rows: [
                Row(id: RowID(rawValue: 0), betSize: "100", coefficient: "2", income: "10"),
                Row(id: RowID(rawValue: 1), betSize: "xxx", coefficient: "3", income: "20")
            ],
            activeCount: 2,
            selection: .none
        )

        // When
        let result = calculator.calculate()

        // Then
        let output = expectResetDerived(result)
        #expect(output.total.betSize == "")
        #expect(output.total.profitPercentage == "0%")
        #expect(output.rowsById[RowID(rawValue: 0)]?.betSize == "100")
        #expect(output.rowsById[RowID(rawValue: 0)]?.coefficient == "2")
        #expect(output.rowsById[RowID(rawValue: 0)]?.income == "0")
        #expect(output.rowsById[RowID(rawValue: 1)]?.betSize == "xxx")
        #expect(output.rowsById[RowID(rawValue: 1)]?.coefficient == "3")
        #expect(output.rowsById[RowID(rawValue: 1)]?.income == "0")
    }

    @Test
    func invalidCoefficient() {
        // Given
        let calculator = makeCalculator(
            total: TotalRow(betSize: "", profitPercentage: ""),
            rows: [
                Row(id: RowID(rawValue: 0), betSize: "100", coefficient: "", income: ""),
                Row(id: RowID(rawValue: 1), betSize: "200", coefficient: "3", income: "")
            ],
            activeCount: 2,
            selection: .none
        )

        // When
        let result = calculator.calculate()

        // Then
        let output = expectResetDerived(result)
        #expect(output.total.betSize == "")
        #expect(output.total.profitPercentage == "0%")
        #expect(output.rowsById[RowID(rawValue: 0)]?.betSize == "100")
        #expect(output.rowsById[RowID(rawValue: 0)]?.coefficient == "")
        #expect(output.rowsById[RowID(rawValue: 0)]?.income == "0")
        #expect(output.rowsById[RowID(rawValue: 1)]?.betSize == "200")
        #expect(output.rowsById[RowID(rawValue: 1)]?.coefficient == "3")
        #expect(output.rowsById[RowID(rawValue: 1)]?.income == "0")
    }

    @Test
    func profitPercentageCalculationWithMultipleRows() {
        // Given
        let calculator = makeCalculator(
            total: TotalRow(betSize: "1000", profitPercentage: ""),
            rows: [
                Row(id: RowID(rawValue: 0), betSize: "300", coefficient: "2", income: ""),
                Row(id: RowID(rawValue: 1), betSize: "700", coefficient: "4", income: "")
            ],
            activeCount: 2,
            selection: .none
        )

        // When
        let result = calculator.calculate()

        // Then
        let output = expectUpdated(result)
        #expect(output.total.profitPercentage == formatNumber(33.33, isPercent: true))
        #expect(output.rowsById[RowID(rawValue: 0)]?.income == "-400")
        #expect(output.rowsById[RowID(rawValue: 1)]?.income == "1800")
    }

    @Test
    func totalCalculationWithThreeRows() {
        // Given
        let calculator = makeCalculator(
            total: TotalRow(betSize: "1000", profitPercentage: ""),
            rows: [
                Row(id: RowID(rawValue: 0), betSize: "", coefficient: "2", income: ""),
                Row(id: RowID(rawValue: 1), betSize: "", coefficient: "3", income: ""),
                Row(id: RowID(rawValue: 2), betSize: "", coefficient: "4", income: "")
            ],
            activeCount: 3,
            selection: .total
        )

        // When
        let result = calculator.calculate()

        // Then
        let output = expectUpdated(result)
        #expect(output.total.betSize == "1000")
        #expect(output.total.profitPercentage == formatNumber(-7.69, isPercent: true))
        #expect(output.rowsById[RowID(rawValue: 0)]?.income == formatNumber(-76.92))
        #expect(output.rowsById[RowID(rawValue: 0)]?.betSize == formatNumber(461.54))
        #expect(output.rowsById[RowID(rawValue: 1)]?.income == formatNumber(-76.92))
        #expect(output.rowsById[RowID(rawValue: 1)]?.betSize == formatNumber(307.69))
        #expect(output.rowsById[RowID(rawValue: 2)]?.income == formatNumber(-76.92))
        #expect(output.rowsById[RowID(rawValue: 2)]?.betSize == formatNumber(230.77))
    }

    @Test
    func totalCalculationWithFourRows() {
        // Given
        let calculator = makeCalculator(
            total: TotalRow(betSize: "1000", profitPercentage: ""),
            rows: [
                Row(id: RowID(rawValue: 0), betSize: "", coefficient: "2", income: ""),
                Row(id: RowID(rawValue: 1), betSize: "", coefficient: "3", income: ""),
                Row(id: RowID(rawValue: 2), betSize: "", coefficient: "4", income: ""),
                Row(id: RowID(rawValue: 3), betSize: "", coefficient: "5", income: "")
            ],
            activeCount: 4,
            selection: .total
        )

        // When
        let result = calculator.calculate()

        // Then
        let output = expectUpdated(result)
        #expect(output.total.betSize == "1000")
        #expect(output.total.profitPercentage == formatNumber(-22.08, isPercent: true))
        #expect(output.rowsById[RowID(rawValue: 0)]?.income == formatNumber(-220.78))
        #expect(output.rowsById[RowID(rawValue: 0)]?.betSize == formatNumber(389.61))
        #expect(output.rowsById[RowID(rawValue: 1)]?.income == formatNumber(-220.78))
        #expect(output.rowsById[RowID(rawValue: 1)]?.betSize == formatNumber(259.74))
        #expect(output.rowsById[RowID(rawValue: 2)]?.income == formatNumber(-220.78))
        #expect(output.rowsById[RowID(rawValue: 2)]?.betSize == formatNumber(194.81))
        #expect(output.rowsById[RowID(rawValue: 3)]?.income == formatNumber(-220.78))
        #expect(output.rowsById[RowID(rawValue: 3)]?.betSize == formatNumber(155.84))
    }

    // MARK: - Edge Cases

    @Test
    func calculateWhenZeroCoefficient() {
        // Given
        let calculator = makeCalculator(
            total: TotalRow(betSize: "1000", profitPercentage: ""),
            rows: [
                Row(id: RowID(rawValue: 0), betSize: "", coefficient: "0", income: ""),
                Row(id: RowID(rawValue: 1), betSize: "", coefficient: "3", income: "")
            ],
            activeCount: 2,
            selection: .total
        )

        // When
        let result = calculator.calculate()

        // Then
        // Нулевой коэффициент должен привести к .none методу
        let output = expectResetDerived(result)
        #expect(output.total.betSize == "1000")
        #expect(output.total.profitPercentage == "0%")
        #expect(output.rowsById[RowID(rawValue: 0)]?.coefficient == "0")
        #expect(output.rowsById[RowID(rawValue: 0)]?.income == "0")
        #expect(output.rowsById[RowID(rawValue: 1)]?.coefficient == "3")
        #expect(output.rowsById[RowID(rawValue: 1)]?.income == "0")
    }

    @Test
    func calculateWhenNegativeCoefficient() {
        // Given
        let calculator = makeCalculator(
            total: TotalRow(betSize: "1000", profitPercentage: ""),
            rows: [
                Row(id: RowID(rawValue: 0), betSize: "", coefficient: "-2", income: ""),
                Row(id: RowID(rawValue: 1), betSize: "", coefficient: "3", income: "")
            ],
            activeCount: 2,
            selection: .total
        )

        // When
        let result = calculator.calculate()

        // Then
        // Отрицательный коэффициент должен привести к .none методу
        let output = expectResetDerived(result)
        #expect(output.total.betSize == "1000")
        #expect(output.total.profitPercentage == "0%")
        #expect(output.rowsById[RowID(rawValue: 0)]?.coefficient == "-2")
        #expect(output.rowsById[RowID(rawValue: 0)]?.income == "0")
        #expect(output.rowsById[RowID(rawValue: 1)]?.coefficient == "3")
        #expect(output.rowsById[RowID(rawValue: 1)]?.income == "0")
    }

    @Test
    func calculateWhenZeroBetSize() {
        // Given
        let calculator = makeCalculator(
            total: TotalRow(betSize: "0", profitPercentage: ""),
            rows: [
                Row(id: RowID(rawValue: 0), betSize: "", coefficient: "2", income: ""),
                Row(id: RowID(rawValue: 1), betSize: "", coefficient: "3", income: "")
            ],
            activeCount: 2,
            selection: .total
        )

        // When
        let result = calculator.calculate()

        // Then
        // Нулевая ставка может быть валидной, но проверим поведение
        expectNotNoOp(result)
    }

    @Test
    func calculateWhenNegativeBetSize() {
        // Given
        let calculator = makeCalculator(
            total: TotalRow(betSize: "-1000", profitPercentage: ""),
            rows: [
                Row(id: RowID(rawValue: 0), betSize: "", coefficient: "2", income: ""),
                Row(id: RowID(rawValue: 1), betSize: "", coefficient: "3", income: "")
            ],
            activeCount: 2,
            selection: .total
        )

        // When
        let result = calculator.calculate()

        // Then
        // Отрицательная ставка может быть валидной, но проверим поведение
        expectNotNoOp(result)
    }

    @Test
    func calculateWhenVerySmallCoefficient() {
        // Given
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        formatter.maximumFractionDigits = 2
        let coefficient1 = formatter.string(from: 0.01 as NSNumber) ?? "0.01"
        let coefficient2 = formatter.string(from: 0.02 as NSNumber) ?? "0.02"
        let calculator = makeCalculator(
            total: TotalRow(betSize: "1000", profitPercentage: ""),
            rows: [
                Row(id: RowID(rawValue: 0), betSize: "", coefficient: coefficient1, income: ""),
                Row(id: RowID(rawValue: 1), betSize: "", coefficient: coefficient2, income: "")
            ],
            activeCount: 2,
            selection: .total
        )

        // When
        let result = calculator.calculate()

        // Then
        // Очень маленькие коэффициенты должны обрабатываться корректно
        expectNotNoOp(result)
    }

    @Test
    func calculateWhenVeryLargeCoefficient() {
        // Given
        let calculator = makeCalculator(
            total: TotalRow(betSize: "1000", profitPercentage: ""),
            rows: [
                Row(id: RowID(rawValue: 0), betSize: "", coefficient: "1000", income: ""),
                Row(id: RowID(rawValue: 1), betSize: "", coefficient: "2000", income: "")
            ],
            activeCount: 2,
            selection: .total
        )

        // When
        let result = calculator.calculate()

        // Then
        // Очень большие коэффициенты должны обрабатываться корректно
        expectNotNoOp(result)
    }

    @Test
    func calculateWhenVeryLargeBetSize() {
        // Given
        let calculator = makeCalculator(
            total: TotalRow(betSize: "999999999", profitPercentage: ""),
            rows: [
                Row(id: RowID(rawValue: 0), betSize: "", coefficient: "2", income: ""),
                Row(id: RowID(rawValue: 1), betSize: "", coefficient: "3", income: "")
            ],
            activeCount: 2,
            selection: .total
        )

        // When
        let result = calculator.calculate()

        // Then
        // Очень большие ставки должны обрабатываться корректно
        expectNotNoOp(result)
    }

    @Test
    func calculateWhenVerySmallBetSize() {
        // Given
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        formatter.maximumFractionDigits = 2
        let betSize = formatter.string(from: 0.01 as NSNumber) ?? "0.01"
        let calculator = makeCalculator(
            total: TotalRow(betSize: betSize, profitPercentage: ""),
            rows: [
                Row(id: RowID(rawValue: 0), betSize: "", coefficient: "2", income: ""),
                Row(id: RowID(rawValue: 1), betSize: "", coefficient: "3", income: "")
            ],
            activeCount: 2,
            selection: .total
        )

        // When
        let result = calculator.calculate()

        // Then
        // Очень маленькие ставки должны обрабатываться корректно
        expectNotNoOp(result)
    }

    @Test
    func calculateWhenFiveRows() {
        // Given
        let calculator = makeCalculator(
            total: TotalRow(betSize: "1000", profitPercentage: ""),
            rows: [
                Row(id: RowID(rawValue: 0), betSize: "", coefficient: "2", income: ""),
                Row(id: RowID(rawValue: 1), betSize: "", coefficient: "3", income: ""),
                Row(id: RowID(rawValue: 2), betSize: "", coefficient: "4", income: ""),
                Row(id: RowID(rawValue: 3), betSize: "", coefficient: "5", income: ""),
                Row(id: RowID(rawValue: 4), betSize: "", coefficient: "6", income: "")
            ],
            activeCount: 5,
            selection: .total
        )

        // When
        let result = calculator.calculate()

        // Then
        expectNotNoOp(result)
    }

    @Test
    func calculateWhenTenRows() {
        // Given
        let calculator = makeCalculator(
            total: TotalRow(betSize: "1000", profitPercentage: ""),
            rows: [
                Row(id: RowID(rawValue: 0), betSize: "", coefficient: "2", income: ""),
                Row(id: RowID(rawValue: 1), betSize: "", coefficient: "3", income: ""),
                Row(id: RowID(rawValue: 2), betSize: "", coefficient: "4", income: ""),
                Row(id: RowID(rawValue: 3), betSize: "", coefficient: "5", income: ""),
                Row(id: RowID(rawValue: 4), betSize: "", coefficient: "6", income: ""),
                Row(id: RowID(rawValue: 5), betSize: "", coefficient: "7", income: ""),
                Row(id: RowID(rawValue: 6), betSize: "", coefficient: "8", income: ""),
                Row(id: RowID(rawValue: 7), betSize: "", coefficient: "9", income: ""),
                Row(id: RowID(rawValue: 8), betSize: "", coefficient: "10", income: ""),
                Row(id: RowID(rawValue: 9), betSize: "", coefficient: "11", income: "")
            ],
            activeCount: 10,
            selection: .total
        )

        // When
        let result = calculator.calculate()

        // Then
        expectNotNoOp(result)
    }

    @Test
    func calculateWhenDivisionByZeroPrevention() {
        // Given
        // Создаем ситуацию, где surebetValue может быть очень маленьким
        // но не нулевым, чтобы проверить защиту от деления на ноль
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        formatter.maximumFractionDigits = 4
        let coefficient = formatter.string(from: 1.0001 as NSNumber) ?? "1.0001"
        let calculator = makeCalculator(
            total: TotalRow(betSize: "1000", profitPercentage: ""),
            rows: [
                Row(id: RowID(rawValue: 0), betSize: "", coefficient: coefficient, income: ""),
                Row(id: RowID(rawValue: 1), betSize: "", coefficient: coefficient, income: "")
            ],
            activeCount: 2,
            selection: .total
        )

        // When
        let result = calculator.calculate()

        // Then
        // Должно обработаться без краша
        expectNotNoOp(result)
    }

    @Test
    func calculateWhenAllCoefficientsAreZero() {
        // Given
        let calculator = makeCalculator(
            total: TotalRow(betSize: "1000", profitPercentage: ""),
            rows: [
                Row(id: RowID(rawValue: 0), betSize: "", coefficient: "0", income: ""),
                Row(id: RowID(rawValue: 1), betSize: "", coefficient: "0", income: "")
            ],
            activeCount: 2,
            selection: .total
        )

        // When
        let result = calculator.calculate()

        // Then
        // Все нулевые коэффициенты должны привести к .none методу
        let output = expectResetDerived(result)
        #expect(output.total.betSize == "1000")
        #expect(output.total.profitPercentage == "0%")
        #expect(output.rowsById[RowID(rawValue: 0)]?.coefficient == "0")
        #expect(output.rowsById[RowID(rawValue: 0)]?.income == "0")
        #expect(output.rowsById[RowID(rawValue: 1)]?.coefficient == "0")
        #expect(output.rowsById[RowID(rawValue: 1)]?.income == "0")
    }

    @Test
    func calculateWhenAllCoefficientsAreNegative() {
        // Given
        let calculator = makeCalculator(
            total: TotalRow(betSize: "1000", profitPercentage: ""),
            rows: [
                Row(id: RowID(rawValue: 0), betSize: "", coefficient: "-2", income: ""),
                Row(id: RowID(rawValue: 1), betSize: "", coefficient: "-3", income: "")
            ],
            activeCount: 2,
            selection: .total
        )

        // When
        let result = calculator.calculate()

        // Then
        // Все отрицательные коэффициенты должны привести к .none методу
        let output = expectResetDerived(result)
        #expect(output.total.betSize == "1000")
        #expect(output.total.profitPercentage == "0%")
        #expect(output.rowsById[RowID(rawValue: 0)]?.coefficient == "-2")
        #expect(output.rowsById[RowID(rawValue: 0)]?.income == "0")
        #expect(output.rowsById[RowID(rawValue: 1)]?.coefficient == "-3")
        #expect(output.rowsById[RowID(rawValue: 1)]?.income == "0")
    }
}
