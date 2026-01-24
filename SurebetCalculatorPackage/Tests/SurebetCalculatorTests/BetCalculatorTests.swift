@testable import SurebetCalculator
import Testing

// swiftlint:disable file_length
struct CalculatorTests {
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
        #expect(result.total?.betSize == "833,33")
        #expect(result.total?.profitPercentage == "20%")
        #expect(result.rows?[0].income == "166,67")
        #expect(result.rows?[1].income == "166,67")
        #expect(result.rows?[1].betSize == "333,33")
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
        #expect(result.total == nil)
        #expect(result.rows == nil)
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
        #expect(result.total == nil)
        #expect(result.rows == nil)
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
        #expect(result.total?.profitPercentage == "33,33%")
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
        #expect(result.total?.profitPercentage == "-7,69%")
        #expect(result.rows?[0].income == "-76,92")
        #expect(result.rows?[0].betSize == "461,54")
        #expect(result.rows?[1].income == "-76,92")
        #expect(result.rows?[1].betSize == "307,69")
        #expect(result.rows?[2].income == "-76,92")
        #expect(result.rows?[2].betSize == "230,77")
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
        #expect(result.total?.profitPercentage == "-22,08%")
        #expect(result.rows?[0].income == "-220,78")
        #expect(result.rows?[0].betSize == "389,61")
        #expect(result.rows?[1].income == "-220,78")
        #expect(result.rows?[1].betSize == "259,74")
        #expect(result.rows?[2].income == "-220,78")
        #expect(result.rows?[2].betSize == "194,81")
        #expect(result.rows?[3].income == "-220,78")
        #expect(result.rows?[3].betSize == "155,84")
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
        #expect(result.total == nil)
        #expect(result.rows == nil)
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
        #expect(result.total == nil)
        #expect(result.rows == nil)
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
        let calculator = Calculator(
            total: TotalRow(betSize: "1000", profitPercentage: ""),
            rows: [
                Row(id: 0, betSize: "", coefficient: "0,01", income: ""),
                Row(id: 1, betSize: "", coefficient: "0,02", income: "")
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
        let calculator = Calculator(
            total: TotalRow(betSize: "0,01", profitPercentage: ""),
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
        let calculator = Calculator(
            total: TotalRow(betSize: "1000", profitPercentage: ""),
            rows: [
                Row(id: 0, betSize: "", coefficient: "1,0001", income: ""),
                Row(id: 1, betSize: "", coefficient: "1,0001", income: "")
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
        #expect(result.total == nil)
        #expect(result.rows == nil)
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
        #expect(result.total == nil)
        #expect(result.rows == nil)
    }
}
