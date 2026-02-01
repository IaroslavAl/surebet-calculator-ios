@testable import SurebetCalculator
import Foundation
import Testing

/// Тесты для DefaultCalculationService
struct DefaultCalculationServiceTests {
    @Test
    func calculateWhenValidParameters() {
        // Given
        let service = DefaultCalculationService()
        let total = TotalRow(betSize: "1000", profitPercentage: "")
        let rows = [
            Row(id: 0, betSize: "", coefficient: "2", income: ""),
            Row(id: 1, betSize: "", coefficient: "3", income: "")
        ]
        let selectedRow: RowType = .total
        let displayedRowIndexes = 0..<2

        // When
        let result = service.calculate(
            total: total,
            rows: rows,
            selectedRow: selectedRow,
            displayedRowIndexes: displayedRowIndexes
        )

        // Then
        // Проверяем, что результат не nil и содержит корректные данные
        #expect(result.total != nil)
        #expect(result.rows != nil)
        #expect(result.total?.betSize == "1000")
        #expect(result.total?.profitPercentage == "20%")
        #expect(result.rows?.count == 2)
    }

    @Test
    func calculateWhenInvalidCoefficients() {
        // Given
        let service = DefaultCalculationService()
        let total = TotalRow(betSize: "1000", profitPercentage: "")
        let rows = [
            Row(id: 0, betSize: "", coefficient: "", income: ""),
            Row(id: 1, betSize: "", coefficient: "3", income: "")
        ]
        let selectedRow: RowType = .total
        let displayedRowIndexes = 0..<2

        // When
        let result = service.calculate(
            total: total,
            rows: rows,
            selectedRow: selectedRow,
            displayedRowIndexes: displayedRowIndexes
        )

        // Then
        // При невалидных коэффициентах Calculator сбрасывает только вычисляемые значения
        #expect(result.total?.betSize == "1000")
        #expect(result.total?.profitPercentage == "0%")
        #expect(result.rows?[0].betSize == "")
        #expect(result.rows?[0].coefficient == "")
        #expect(result.rows?[0].income == "0")
        #expect(result.rows?[1].betSize == "")
        #expect(result.rows?[1].coefficient == "3")
        #expect(result.rows?[1].income == "0")
    }

    @Test
    func calculateWhenSelectedRowIsNone() {
        // Given
        let service = DefaultCalculationService()
        let total = TotalRow(betSize: "", profitPercentage: "")
        let rows = [
            Row(id: 0, betSize: "", coefficient: "2", income: ""),
            Row(id: 1, betSize: "", coefficient: "3", income: "")
        ]
        let selectedRow: RowType? = .none
        let displayedRowIndexes = 0..<2

        // When
        let result = service.calculate(
            total: total,
            rows: rows,
            selectedRow: selectedRow,
            displayedRowIndexes: displayedRowIndexes
        )

        // Then
        // Когда selectedRow = .none и нет валидных betSize, сбрасываются только вычисляемые значения
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
    func calculateWhenSelectedRowIsRow() {
        // Given
        let service = DefaultCalculationService()
        let total = TotalRow(betSize: "", profitPercentage: "")
        let rows = [
            Row(id: 0, betSize: "500", coefficient: "2", income: ""),
            Row(id: 1, betSize: "", coefficient: "3", income: "")
        ]
        let selectedRow: RowType = .row(0)
        let displayedRowIndexes = 0..<2

        // When
        let result = service.calculate(
            total: total,
            rows: rows,
            selectedRow: selectedRow,
            displayedRowIndexes: displayedRowIndexes
        )

        // Then
        // Проверяем, что результат не nil и содержит корректные данные
        #expect(result.total != nil)
        #expect(result.rows != nil)
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.locale = Locale.current
        let expectedBetSize = formatter.string(from: 833.33 as NSNumber) ?? ""
        #expect(result.total?.betSize == expectedBetSize)
        #expect(result.total?.profitPercentage == "20%")
        #expect(result.rows?.count == 2)
    }

    @Test
    func calculateWhenMultipleRows() {
        // Given
        let service = DefaultCalculationService()
        let total = TotalRow(betSize: "1000", profitPercentage: "")
        let rows = [
            Row(id: 0, betSize: "", coefficient: "2", income: ""),
            Row(id: 1, betSize: "", coefficient: "3", income: ""),
            Row(id: 2, betSize: "", coefficient: "4", income: "")
        ]
        let selectedRow: RowType = .total
        let displayedRowIndexes = 0..<3

        // When
        let result = service.calculate(
            total: total,
            rows: rows,
            selectedRow: selectedRow,
            displayedRowIndexes: displayedRowIndexes
        )

        // Then
        // Проверяем, что результат не nil и содержит корректные данные для 3 строк
        #expect(result.total != nil)
        #expect(result.rows != nil)
        #expect(result.total?.betSize == "1000")
        #expect(result.rows?.count == 3)
    }

    @Test
    func calculateWhenResultIsNil() {
        // Given
        let service = DefaultCalculationService()
        let total = TotalRow(betSize: "", profitPercentage: "")
        let rows = [
            Row(id: 0, betSize: "", coefficient: "0", income: ""),
            Row(id: 1, betSize: "", coefficient: "3", income: "")
        ]
        let selectedRow: RowType = .total
        let displayedRowIndexes = 0..<2

        // When
        let result = service.calculate(
            total: total,
            rows: rows,
            selectedRow: selectedRow,
            displayedRowIndexes: displayedRowIndexes
        )

        // Then
        // Нулевой коэффициент должен привести к сбросу вычисляемых значений
        #expect(result.total?.betSize == "")
        #expect(result.total?.profitPercentage == "0%")
        #expect(result.rows?[0].betSize == "")
        #expect(result.rows?[0].coefficient == "0")
        #expect(result.rows?[0].income == "0")
        #expect(result.rows?[1].betSize == "")
        #expect(result.rows?[1].coefficient == "3")
        #expect(result.rows?[1].income == "0")
    }
}
