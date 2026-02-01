@testable import SurebetCalculator
import Foundation
import Testing

/// Тесты для DefaultCalculationService
struct DefaultCalculationServiceTests {
    private func makeRows(_ rows: [Row]) -> (rowsById: [RowID: Row], orderedRowIds: [RowID]) {
        let orderedRowIds = rows.map(\.id)
        let rowsById = Dictionary(uniqueKeysWithValues: rows.map { ($0.id, $0) })
        return (rowsById: rowsById, orderedRowIds: orderedRowIds)
    }

    @Test
    func calculateWhenValidParameters() {
        // Given
        let service = DefaultCalculationService()
        let total = TotalRow(betSize: "1000", profitPercentage: "")
        let rows = [
            Row(id: RowID(rawValue: 0), betSize: "", coefficient: "2", income: ""),
            Row(id: RowID(rawValue: 1), betSize: "", coefficient: "3", income: "")
        ]
        let data = makeRows(rows)

        // When
        let result = service.calculate(
            input: CalculationInput(
                total: total,
                rowsById: data.rowsById,
                orderedRowIds: data.orderedRowIds,
                activeRowIds: data.orderedRowIds,
                selection: .total
            )
        )

        // Then
        // Проверяем, что результат не nil и содержит корректные данные
        switch result {
        case let .updated(output):
            #expect(output.total.betSize == "1000")
            #expect(output.total.profitPercentage == "20%")
            #expect(output.rowsById.count == 2)
        default:
            #expect(Bool(false))
        }
    }

    @Test
    func calculateWhenInvalidCoefficients() {
        // Given
        let service = DefaultCalculationService()
        let total = TotalRow(betSize: "1000", profitPercentage: "")
        let rows = [
            Row(id: RowID(rawValue: 0), betSize: "", coefficient: "", income: ""),
            Row(id: RowID(rawValue: 1), betSize: "", coefficient: "3", income: "")
        ]
        let data = makeRows(rows)

        // When
        let result = service.calculate(
            input: CalculationInput(
                total: total,
                rowsById: data.rowsById,
                orderedRowIds: data.orderedRowIds,
                activeRowIds: data.orderedRowIds,
                selection: .total
            )
        )

        // Then
        // При невалидных коэффициентах Calculator сбрасывает только вычисляемые значения
        switch result {
        case let .resetDerived(output):
            #expect(output.total.betSize == "1000")
            #expect(output.total.profitPercentage == "0%")
            #expect(output.rowsById[RowID(rawValue: 0)]?.betSize == "")
            #expect(output.rowsById[RowID(rawValue: 0)]?.coefficient == "")
            #expect(output.rowsById[RowID(rawValue: 0)]?.income == "0")
            #expect(output.rowsById[RowID(rawValue: 1)]?.betSize == "")
            #expect(output.rowsById[RowID(rawValue: 1)]?.coefficient == "3")
            #expect(output.rowsById[RowID(rawValue: 1)]?.income == "0")
        default:
            #expect(Bool(false))
        }
    }

    @Test
    func calculateWhenSelectedRowIsNone() {
        // Given
        let service = DefaultCalculationService()
        let total = TotalRow(betSize: "", profitPercentage: "")
        let rows = [
            Row(id: RowID(rawValue: 0), betSize: "", coefficient: "2", income: ""),
            Row(id: RowID(rawValue: 1), betSize: "", coefficient: "3", income: "")
        ]
        let data = makeRows(rows)

        // When
        let result = service.calculate(
            input: CalculationInput(
                total: total,
                rowsById: data.rowsById,
                orderedRowIds: data.orderedRowIds,
                activeRowIds: data.orderedRowIds,
                selection: .none
            )
        )

        // Then
        // Когда selection = .none и нет валидных betSize, сбрасываются только вычисляемые значения
        switch result {
        case let .resetDerived(output):
            #expect(output.total.betSize == "")
            #expect(output.total.profitPercentage == "0%")
            #expect(output.rowsById[RowID(rawValue: 0)]?.betSize == "")
            #expect(output.rowsById[RowID(rawValue: 0)]?.coefficient == "2")
            #expect(output.rowsById[RowID(rawValue: 0)]?.income == "0")
            #expect(output.rowsById[RowID(rawValue: 1)]?.betSize == "")
            #expect(output.rowsById[RowID(rawValue: 1)]?.coefficient == "3")
            #expect(output.rowsById[RowID(rawValue: 1)]?.income == "0")
        default:
            #expect(Bool(false))
        }
    }

    @Test
    func calculateWhenSelectedRowIsRow() {
        // Given
        let service = DefaultCalculationService()
        let total = TotalRow(betSize: "", profitPercentage: "")
        let rows = [
            Row(id: RowID(rawValue: 0), betSize: "500", coefficient: "2", income: ""),
            Row(id: RowID(rawValue: 1), betSize: "", coefficient: "3", income: "")
        ]
        let data = makeRows(rows)

        // When
        let result = service.calculate(
            input: CalculationInput(
                total: total,
                rowsById: data.rowsById,
                orderedRowIds: data.orderedRowIds,
                activeRowIds: data.orderedRowIds,
                selection: .row(RowID(rawValue: 0))
            )
        )

        // Then
        // Проверяем, что результат не nil и содержит корректные данные
        switch result {
        case let .updated(output):
            let formatter = NumberFormatter()
            formatter.numberStyle = .none
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = 2
            formatter.locale = Locale.current
            let expectedBetSize = formatter.string(from: 833.33 as NSNumber) ?? ""
            #expect(output.total.betSize == expectedBetSize)
            #expect(output.total.profitPercentage == "20%")
            #expect(output.rowsById.count == 2)
        default:
            #expect(Bool(false))
        }
    }

    @Test
    func calculateWhenMultipleRows() {
        // Given
        let service = DefaultCalculationService()
        let total = TotalRow(betSize: "1000", profitPercentage: "")
        let rows = [
            Row(id: RowID(rawValue: 0), betSize: "", coefficient: "2", income: ""),
            Row(id: RowID(rawValue: 1), betSize: "", coefficient: "3", income: ""),
            Row(id: RowID(rawValue: 2), betSize: "", coefficient: "4", income: "")
        ]
        let data = makeRows(rows)

        // When
        let result = service.calculate(
            input: CalculationInput(
                total: total,
                rowsById: data.rowsById,
                orderedRowIds: data.orderedRowIds,
                activeRowIds: data.orderedRowIds,
                selection: .total
            )
        )

        // Then
        // Проверяем, что результат не nil и содержит корректные данные для 3 строк
        switch result {
        case let .updated(output):
            #expect(output.total.betSize == "1000")
            #expect(output.rowsById.count == 3)
        default:
            #expect(Bool(false))
        }
    }

    @Test
    func calculateWhenResultIsResetDerived() {
        // Given
        let service = DefaultCalculationService()
        let total = TotalRow(betSize: "", profitPercentage: "")
        let rows = [
            Row(id: RowID(rawValue: 0), betSize: "", coefficient: "0", income: ""),
            Row(id: RowID(rawValue: 1), betSize: "", coefficient: "3", income: "")
        ]
        let data = makeRows(rows)

        // When
        let result = service.calculate(
            input: CalculationInput(
                total: total,
                rowsById: data.rowsById,
                orderedRowIds: data.orderedRowIds,
                activeRowIds: data.orderedRowIds,
                selection: .total
            )
        )

        // Then
        // Нулевой коэффициент должен привести к сбросу вычисляемых значений
        switch result {
        case let .resetDerived(output):
            #expect(output.total.betSize == "")
            #expect(output.total.profitPercentage == "0%")
            #expect(output.rowsById[RowID(rawValue: 0)]?.betSize == "")
            #expect(output.rowsById[RowID(rawValue: 0)]?.coefficient == "0")
            #expect(output.rowsById[RowID(rawValue: 0)]?.income == "0")
            #expect(output.rowsById[RowID(rawValue: 1)]?.betSize == "")
            #expect(output.rowsById[RowID(rawValue: 1)]?.coefficient == "3")
            #expect(output.rowsById[RowID(rawValue: 1)]?.income == "0")
        default:
            #expect(Bool(false))
        }
    }
}
