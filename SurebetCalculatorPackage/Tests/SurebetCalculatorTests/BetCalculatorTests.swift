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
    @Test
    func totalCalculation() {
        // Given
        let calculator = Calculator(
            total: TotalRow(betSize: "1000", profitPercentage: ""),
            rows: [
                Row(id: 0, betSize: "", coefficient: "2", income: ""),
                Row(id: 1, betSize: "", coefficient: "3", income: "")
            ],
            selectedRow: .total,
            displayedRowIndexes: 0..<2
        )

        // When
        let result = calculator.calculate()

        // Then
        #expect(result.total?.betSize == "1000")
        #expect(result.total?.profitPercentage == "20%")
        #expect(result.rows?[0].income == "200")
        #expect(result.rows?[0].betSize == "600")
        #expect(result.rows?[1].income == "200")
        #expect(result.rows?[1].betSize == "400")
    }

    @Test
    func rowCalculation() {
        // Given
        let calculator = Calculator(
            total: TotalRow(betSize: "", profitPercentage: ""),
            rows: [
                Row(id: 0, betSize: "500", coefficient: "2", income: ""),
                Row(id: 1, betSize: "", coefficient: "3", income: "")
            ],
            selectedRow: .row(0),
            displayedRowIndexes: 0..<2
        )

        // When
        let result = calculator.calculate()

        // Then
        #expect(result.total?.betSize == formatNumber(833.33))
        #expect(result.total?.profitPercentage == "20%")
        #expect(result.rows?[0].income == formatNumber(166.67))
        #expect(result.rows?[1].income == formatNumber(166.67))
        #expect(result.rows?[1].betSize == formatNumber(333.33))
    }

    @Test
    func noneCalculation() {
        // Given
        let calculator = Calculator(
            total: TotalRow(betSize: "", profitPercentage: ""),
            rows: [
                Row(id: 0, betSize: "", coefficient: "2", income: ""),
                Row(id: 1, betSize: "", coefficient: "3", income: "")
            ],
            selectedRow: .none,
            displayedRowIndexes: 0..<2
        )

        // When
        let result = calculator.calculate()

        // Then
        #expect(result.total?.betSize == "")
        #expect(result.total?.profitPercentage == "0%")
        #expect(result.rows?[0].betSize == "")
        #expect(result.rows?[0].coefficient == "2")
        #expect(result.rows?[0].income == "0")
        #expect(result.rows?[1].betSize == "")
        #expect(result.rows?[1].coefficient == "3")
        #expect(result.rows?[1].income == "0")
    }

    @Test
    func rowCalculationWhenBetSizeIsEmpty() {
        // Given
        let calculator = Calculator(
            total: TotalRow(betSize: "1000", profitPercentage: "77%"),
            rows: [
                Row(id: 0, betSize: "", coefficient: "2", income: "123"),
                Row(id: 1, betSize: "200", coefficient: "3", income: "456")
            ],
            selectedRow: .row(0),
            displayedRowIndexes: 0..<2
        )

        // When
        let result = calculator.calculate()

        // Then
        #expect(result.total?.betSize == "")
        #expect(result.total?.profitPercentage == "0%")
        #expect(result.rows?[0].betSize == "")
        #expect(result.rows?[0].coefficient == "2")
        #expect(result.rows?[0].income == "0")
        #expect(result.rows?[1].betSize == "")
        #expect(result.rows?[1].coefficient == "3")
        #expect(result.rows?[1].income == "0")
    }

    @Test
    func rowsCalculationWhenAnyBetSizeIsInvalid() {
        // Given
        let calculator = Calculator(
            total: TotalRow(betSize: "900", profitPercentage: "12%"),
            rows: [
                Row(id: 0, betSize: "100", coefficient: "2", income: "10"),
                Row(id: 1, betSize: "xxx", coefficient: "3", income: "20")
            ],
            selectedRow: .none,
            displayedRowIndexes: 0..<2
        )

        // When
        let result = calculator.calculate()

        // Then
        #expect(result.total?.betSize == "")
        #expect(result.total?.profitPercentage == "0%")
        #expect(result.rows?[0].betSize == "100")
        #expect(result.rows?[0].coefficient == "2")
        #expect(result.rows?[0].income == "0")
        #expect(result.rows?[1].betSize == "xxx")
        #expect(result.rows?[1].coefficient == "3")
        #expect(result.rows?[1].income == "0")
    }

    @Test
    func invalidCoefficient() {
        // Given
        let calculator = Calculator(
            total: TotalRow(betSize: "", profitPercentage: ""),
            rows: [
                Row(id: 0, betSize: "100", coefficient: "", income: ""),
                Row(id: 1, betSize: "200", coefficient: "3", income: "")
            ],
            selectedRow: .none,
            displayedRowIndexes: 0..<2
        )

        // When
        let result = calculator.calculate()

        // Then
        #expect(result.total?.betSize == "")
        #expect(result.total?.profitPercentage == "0%")
        #expect(result.rows?[0].betSize == "100")
        #expect(result.rows?[0].coefficient == "")
        #expect(result.rows?[0].income == "0")
        #expect(result.rows?[1].betSize == "200")
        #expect(result.rows?[1].coefficient == "3")
        #expect(result.rows?[1].income == "0")
    }

    @Test
    func profitPercentageCalculationWithMultipleRows() {
        // Given
        let calculator = Calculator(
            total: TotalRow(betSize: "1000", profitPercentage: ""),
            rows: [
                Row(id: 0, betSize: "300", coefficient: "2", income: ""),
                Row(id: 1, betSize: "700", coefficient: "4", income: "")
            ],
            selectedRow: .none,
            displayedRowIndexes: 0..<2
        )

        // When
        let result = calculator.calculate()

        // Then
        #expect(result.total?.profitPercentage == formatNumber(33.33, isPercent: true))
        #expect(result.rows?[0].income == "-400")
        #expect(result.rows?[1].income == "1800")
    }

    @Test
    func totalCalculationWithThreeRows() {
        // Given
        let calculator = Calculator(
            total: TotalRow(betSize: "1000", profitPercentage: ""),
            rows: [
                Row(id: 0, betSize: "", coefficient: "2", income: ""),
                Row(id: 1, betSize: "", coefficient: "3", income: ""),
                Row(id: 2, betSize: "", coefficient: "4", income: "")
            ],
            selectedRow: .total,
            displayedRowIndexes: 0..<3
        )

        // When
        let result = calculator.calculate()

        // Then
        #expect(result.total?.betSize == "1000")
        #expect(result.total?.profitPercentage == formatNumber(-7.69, isPercent: true))
        #expect(result.rows?[0].income == formatNumber(-76.92))
        #expect(result.rows?[0].betSize == formatNumber(461.54))
        #expect(result.rows?[1].income == formatNumber(-76.92))
        #expect(result.rows?[1].betSize == formatNumber(307.69))
        #expect(result.rows?[2].income == formatNumber(-76.92))
        #expect(result.rows?[2].betSize == formatNumber(230.77))
    }

    @Test
    func totalCalculationWithFourRows() {
        // Given
        let calculator = Calculator(
            total: TotalRow(betSize: "1000", profitPercentage: ""),
            rows: [
                Row(id: 0, betSize: "", coefficient: "2", income: ""),
                Row(id: 1, betSize: "", coefficient: "3", income: ""),
                Row(id: 2, betSize: "", coefficient: "4", income: ""),
                Row(id: 3, betSize: "", coefficient: "5", income: "")
            ],
            selectedRow: .total,
            displayedRowIndexes: 0..<4
        )

        // When
        let result = calculator.calculate()

        // Then
        #expect(result.total?.betSize == "1000")
        #expect(result.total?.profitPercentage == formatNumber(-22.08, isPercent: true))
        #expect(result.rows?[0].income == formatNumber(-220.78))
        #expect(result.rows?[0].betSize == formatNumber(389.61))
        #expect(result.rows?[1].income == formatNumber(-220.78))
        #expect(result.rows?[1].betSize == formatNumber(259.74))
        #expect(result.rows?[2].income == formatNumber(-220.78))
        #expect(result.rows?[2].betSize == formatNumber(194.81))
        #expect(result.rows?[3].income == formatNumber(-220.78))
        #expect(result.rows?[3].betSize == formatNumber(155.84))
    }

    // MARK: - Edge Cases

    @Test
    func calculateWhenZeroCoefficient() {
        // Given
        let calculator = Calculator(
            total: TotalRow(betSize: "1000", profitPercentage: ""),
            rows: [
                Row(id: 0, betSize: "", coefficient: "0", income: ""),
                Row(id: 1, betSize: "", coefficient: "3", income: "")
            ],
            selectedRow: .total,
            displayedRowIndexes: 0..<2
        )

        // When
        let result = calculator.calculate()

        // Then
        // Нулевой коэффициент должен привести к .none методу
        #expect(result.total?.betSize == "1000")
        #expect(result.total?.profitPercentage == "0%")
        #expect(result.rows?[0].coefficient == "0")
        #expect(result.rows?[0].income == "0")
        #expect(result.rows?[1].coefficient == "3")
        #expect(result.rows?[1].income == "0")
    }

    @Test
    func calculateWhenNegativeCoefficient() {
        // Given
        let calculator = Calculator(
            total: TotalRow(betSize: "1000", profitPercentage: ""),
            rows: [
                Row(id: 0, betSize: "", coefficient: "-2", income: ""),
                Row(id: 1, betSize: "", coefficient: "3", income: "")
            ],
            selectedRow: .total,
            displayedRowIndexes: 0..<2
        )

        // When
        let result = calculator.calculate()

        // Then
        // Отрицательный коэффициент должен привести к .none методу
        #expect(result.total?.betSize == "1000")
        #expect(result.total?.profitPercentage == "0%")
        #expect(result.rows?[0].coefficient == "-2")
        #expect(result.rows?[0].income == "0")
        #expect(result.rows?[1].coefficient == "3")
        #expect(result.rows?[1].income == "0")
    }

    @Test
    func calculateWhenZeroBetSize() {
        // Given
        let calculator = Calculator(
            total: TotalRow(betSize: "0", profitPercentage: ""),
            rows: [
                Row(id: 0, betSize: "", coefficient: "2", income: ""),
                Row(id: 1, betSize: "", coefficient: "3", income: "")
            ],
            selectedRow: .total,
            displayedRowIndexes: 0..<2
        )

        // When
        let result = calculator.calculate()

        // Then
        // Нулевая ставка может быть валидной, но проверим поведение
        #expect(result.total != nil)
    }

    @Test
    func calculateWhenNegativeBetSize() {
        // Given
        let calculator = Calculator(
            total: TotalRow(betSize: "-1000", profitPercentage: ""),
            rows: [
                Row(id: 0, betSize: "", coefficient: "2", income: ""),
                Row(id: 1, betSize: "", coefficient: "3", income: "")
            ],
            selectedRow: .total,
            displayedRowIndexes: 0..<2
        )

        // When
        let result = calculator.calculate()

        // Then
        // Отрицательная ставка может быть валидной, но проверим поведение
        #expect(result.total != nil)
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
        let calculator = Calculator(
            total: TotalRow(betSize: "1000", profitPercentage: ""),
            rows: [
                Row(id: 0, betSize: "", coefficient: coefficient1, income: ""),
                Row(id: 1, betSize: "", coefficient: coefficient2, income: "")
            ],
            selectedRow: .total,
            displayedRowIndexes: 0..<2
        )

        // When
        let result = calculator.calculate()

        // Then
        // Очень маленькие коэффициенты должны обрабатываться корректно
        #expect(result.total != nil)
        #expect(result.rows != nil)
    }

    @Test
    func calculateWhenVeryLargeCoefficient() {
        // Given
        let calculator = Calculator(
            total: TotalRow(betSize: "1000", profitPercentage: ""),
            rows: [
                Row(id: 0, betSize: "", coefficient: "1000", income: ""),
                Row(id: 1, betSize: "", coefficient: "2000", income: "")
            ],
            selectedRow: .total,
            displayedRowIndexes: 0..<2
        )

        // When
        let result = calculator.calculate()

        // Then
        // Очень большие коэффициенты должны обрабатываться корректно
        #expect(result.total != nil)
        #expect(result.rows != nil)
    }

    @Test
    func calculateWhenVeryLargeBetSize() {
        // Given
        let calculator = Calculator(
            total: TotalRow(betSize: "999999999", profitPercentage: ""),
            rows: [
                Row(id: 0, betSize: "", coefficient: "2", income: ""),
                Row(id: 1, betSize: "", coefficient: "3", income: "")
            ],
            selectedRow: .total,
            displayedRowIndexes: 0..<2
        )

        // When
        let result = calculator.calculate()

        // Then
        // Очень большие ставки должны обрабатываться корректно
        #expect(result.total != nil)
        #expect(result.rows != nil)
    }

    @Test
    func calculateWhenVerySmallBetSize() {
        // Given
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        formatter.maximumFractionDigits = 2
        let betSize = formatter.string(from: 0.01 as NSNumber) ?? "0.01"
        let calculator = Calculator(
            total: TotalRow(betSize: betSize, profitPercentage: ""),
            rows: [
                Row(id: 0, betSize: "", coefficient: "2", income: ""),
                Row(id: 1, betSize: "", coefficient: "3", income: "")
            ],
            selectedRow: .total,
            displayedRowIndexes: 0..<2
        )

        // When
        let result = calculator.calculate()

        // Then
        // Очень маленькие ставки должны обрабатываться корректно
        #expect(result.total != nil)
        #expect(result.rows != nil)
    }

    @Test
    func calculateWhenFiveRows() {
        // Given
        let calculator = Calculator(
            total: TotalRow(betSize: "1000", profitPercentage: ""),
            rows: [
                Row(id: 0, betSize: "", coefficient: "2", income: ""),
                Row(id: 1, betSize: "", coefficient: "3", income: ""),
                Row(id: 2, betSize: "", coefficient: "4", income: ""),
                Row(id: 3, betSize: "", coefficient: "5", income: ""),
                Row(id: 4, betSize: "", coefficient: "6", income: "")
            ],
            selectedRow: .total,
            displayedRowIndexes: 0..<5
        )

        // When
        let result = calculator.calculate()

        // Then
        #expect(result.total != nil)
        #expect(result.rows != nil)
        #expect(result.rows?.count == 5)
    }

    @Test
    func calculateWhenTenRows() {
        // Given
        let calculator = Calculator(
            total: TotalRow(betSize: "1000", profitPercentage: ""),
            rows: [
                Row(id: 0, betSize: "", coefficient: "2", income: ""),
                Row(id: 1, betSize: "", coefficient: "3", income: ""),
                Row(id: 2, betSize: "", coefficient: "4", income: ""),
                Row(id: 3, betSize: "", coefficient: "5", income: ""),
                Row(id: 4, betSize: "", coefficient: "6", income: ""),
                Row(id: 5, betSize: "", coefficient: "7", income: ""),
                Row(id: 6, betSize: "", coefficient: "8", income: ""),
                Row(id: 7, betSize: "", coefficient: "9", income: ""),
                Row(id: 8, betSize: "", coefficient: "10", income: ""),
                Row(id: 9, betSize: "", coefficient: "11", income: "")
            ],
            selectedRow: .total,
            displayedRowIndexes: 0..<10
        )

        // When
        let result = calculator.calculate()

        // Then
        #expect(result.total != nil)
        #expect(result.rows != nil)
        #expect(result.rows?.count == 10)
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
        let calculator = Calculator(
            total: TotalRow(betSize: "1000", profitPercentage: ""),
            rows: [
                Row(id: 0, betSize: "", coefficient: coefficient, income: ""),
                Row(id: 1, betSize: "", coefficient: coefficient, income: "")
            ],
            selectedRow: .total,
            displayedRowIndexes: 0..<2
        )

        // When
        let result = calculator.calculate()

        // Then
        // Должно обработаться без краша
        #expect(result.total != nil)
        #expect(result.rows != nil)
    }

    @Test
    func calculateWhenAllCoefficientsAreZero() {
        // Given
        let calculator = Calculator(
            total: TotalRow(betSize: "1000", profitPercentage: ""),
            rows: [
                Row(id: 0, betSize: "", coefficient: "0", income: ""),
                Row(id: 1, betSize: "", coefficient: "0", income: "")
            ],
            selectedRow: .total,
            displayedRowIndexes: 0..<2
        )

        // When
        let result = calculator.calculate()

        // Then
        // Все нулевые коэффициенты должны привести к .none методу
        #expect(result.total?.betSize == "1000")
        #expect(result.total?.profitPercentage == "0%")
        #expect(result.rows?[0].coefficient == "0")
        #expect(result.rows?[0].income == "0")
        #expect(result.rows?[1].coefficient == "0")
        #expect(result.rows?[1].income == "0")
    }

    @Test
    func calculateWhenAllCoefficientsAreNegative() {
        // Given
        let calculator = Calculator(
            total: TotalRow(betSize: "1000", profitPercentage: ""),
            rows: [
                Row(id: 0, betSize: "", coefficient: "-2", income: ""),
                Row(id: 1, betSize: "", coefficient: "-3", income: "")
            ],
            selectedRow: .total,
            displayedRowIndexes: 0..<2
        )

        // When
        let result = calculator.calculate()

        // Then
        // Все отрицательные коэффициенты должны привести к .none методу
        #expect(result.total?.betSize == "1000")
        #expect(result.total?.profitPercentage == "0%")
        #expect(result.rows?[0].coefficient == "-2")
        #expect(result.rows?[0].income == "0")
        #expect(result.rows?[1].coefficient == "-3")
        #expect(result.rows?[1].income == "0")
    }
}
