@testable import SurebetCalculator
import Testing

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
}
