@testable import SurebetCalculator
import Foundation
import Testing

@MainActor
final class TestDelay: CalculationAnalyticsDelay, @unchecked Sendable {
    // MARK: - Properties

    private var continuations: [CheckedContinuation<Void, Never>] = []
    private var waiters: [CheckedContinuation<Void, Never>] = []
    var sleepCallCount = 0
    var lastNanoseconds: UInt64?

    // MARK: - Delay

    func sleep(nanoseconds: UInt64) async {
        sleepCallCount += 1
        lastNanoseconds = nanoseconds
        if !waiters.isEmpty {
            waiters.forEach { $0.resume() }
            waiters.removeAll()
        }
        await withCheckedContinuation { continuation in
            continuations.append(continuation)
        }
    }

    func advance() async {
        continuations.forEach { $0.resume() }
        continuations.removeAll()
        await Task.yield()
    }

    func waitForSleepCall() async {
        if !continuations.isEmpty {
            return
        }
        await withCheckedContinuation { continuation in
            waiters.append(continuation)
        }
    }
}

private func rowId(_ value: Int) -> RowID {
    RowID(rawValue: UInt64(value))
}

private func makeRows(_ rows: [Row]) -> (rowsById: [RowID: Row], orderedRowIds: [RowID]) {
    let orderedRowIds = rows.map(\.id)
    let rowsById = Dictionary(uniqueKeysWithValues: rows.map { ($0.id, $0) })
    return (rowsById: rowsById, orderedRowIds: orderedRowIds)
}

@MainActor
private func makeViewModel(
    total: TotalRow = TotalRow(),
    rows: [Row]? = nil,
    selectedNumberOfRows: NumberOfRows = .two,
    selection: Selection = .total,
    focus: FocusableField? = nil,
    calculationService: CalculationService = DefaultCalculationService(),
    analytics: CalculatorAnalytics = NoopCalculatorAnalytics(),
    delay: CalculationAnalyticsDelay = SystemCalculationAnalyticsDelay()
) -> SurebetCalculatorViewModel {
    if let rows {
        let data = makeRows(rows)
        return SurebetCalculatorViewModel(
            total: total,
            rowsById: data.rowsById,
            orderedRowIds: data.orderedRowIds,
            selectedNumberOfRows: selectedNumberOfRows,
            selection: selection,
            focus: focus,
            calculationService: calculationService,
            analytics: analytics,
            delay: delay
        )
    }
    return SurebetCalculatorViewModel(
        total: total,
        selectedNumberOfRows: selectedNumberOfRows,
        selection: selection,
        focus: focus,
        calculationService: calculationService,
        analytics: analytics,
        delay: delay
    )
}

@MainActor
private func row(_ viewModel: SurebetCalculatorViewModel, _ id: Int) -> Row {
    viewModel.rowsById[rowId(id)] ?? Row(id: rowId(id))
}

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

/// Форматирует коэффициент для ввода в тестах.
private func formatCoefficient(_ value: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.locale = Locale.current
    formatter.maximumFractionDigits = 2
    return formatter.string(from: value as NSNumber) ?? ""
}

@MainActor
struct SurebetCalculatorViewModelTests {
    // MARK: - Tests

    @Test
    func selectRow() {
        // Given
        let viewModel = makeViewModel()
        let id = 0
        let selection: Selection = .row(rowId(id))

        // When
        viewModel.send(.selectRow(selection))

        // Then
        #expect(!viewModel.total.isON)
        #expect(row(viewModel, id).isON)
        #expect(viewModel.selection == selection)
    }

    @Test
    func selectTotal() {
        // Given
        let viewModel = makeViewModel(selection: .none)
        let selection: Selection = .total

        // When
        viewModel.send(.selectRow(selection))

        // Then
        #expect(viewModel.total.isON)
        #expect(viewModel.selection == selection)
    }

    @Test
    func selectNone() {
        // Given
        let id = 0
        let viewModel = makeViewModel(selection: .row(rowId(id)))
        let selection: Selection = .row(rowId(id))

        // When
        viewModel.send(.selectRow(selection))

        // Then
        #expect(!row(viewModel, id).isON)
        #expect(viewModel.selection == .none)
    }

    @Test
    func initNormalizesDuplicateAndMissingOrderedRowIDs() {
        // Given
        let row0 = rowId(0)
        let row1 = rowId(1)
        let row2 = rowId(2)
        let unknown = rowId(99)
        let rowsById: [RowID: Row] = [
            row0: Row(id: row0),
            row1: Row(id: row1),
            row2: Row(id: row2)
        ]

        // When
        let viewModel = SurebetCalculatorViewModel(
            rowsById: rowsById,
            orderedRowIds: [row1, row1, unknown],
            selectedNumberOfRows: .three,
            selection: .none,
            calculationService: DefaultCalculationService(),
            analytics: NoopCalculatorAnalytics(),
            delay: SystemCalculationAnalyticsDelay()
        )

        // Then
        #expect(viewModel.orderedRowIds == [row1, row0, row2])
        #expect(viewModel.activeRowViewModelIDs == [row1, row0, row2])
    }

    @Test
    func selectRowMovesFocusFromTotalBetSizeToSelectedRowBetSize() {
        // Given
        let selectedRowID = rowId(1)
        let viewModel = makeViewModel(
            selection: .total,
            focus: .totalBetSize
        )

        // When
        viewModel.send(.selectRow(.row(selectedRowID)))

        // Then
        #expect(viewModel.focus == .rowBetSize(selectedRowID))
    }

    @Test
    func selectTotalMovesFocusFromRowBetSizeToTotalBetSize() {
        // Given
        let viewModel = makeViewModel(
            selection: .none,
            focus: .rowBetSize(rowId(0))
        )

        // When
        viewModel.send(.selectRow(.total))

        // Then
        #expect(viewModel.focus == .totalBetSize)
    }

    @Test
    func deselectTotalMovesFocusToFirstActiveRowBetSize() {
        // Given
        let firstActiveRowID = rowId(0)
        let viewModel = makeViewModel(
            selection: .total,
            focus: .totalBetSize
        )

        // When
        viewModel.send(.selectRow(.total))

        // Then
        #expect(viewModel.selection == .none)
        #expect(viewModel.focus == .rowBetSize(firstActiveRowID))
    }

    @Test
    func selectNumberOfRowsWhenToDeselectAndClear() {
        // Given
        let initialNumberOfRows: NumberOfRows = .three
        let newNumberOfRows: NumberOfRows = .two
        let id = 2
        let viewModel = makeViewModel(
            rows: [
                .init(id: RowID(rawValue: 0)),
                .init(id: RowID(rawValue: 1)),
                .init(id: RowID(rawValue: 2), isON: true, betSize: "777"),
                .init(id: RowID(rawValue: 3))
            ],
            selectedNumberOfRows: initialNumberOfRows,
            selection: .row(rowId(id))
        )

        // When
        viewModel.send(.removeRow)

        // Then
        #expect(!row(viewModel, id).isON)
        #expect(row(viewModel, id).betSize == "")
        #expect(viewModel.selectedNumberOfRows == newNumberOfRows)
    }

    @Test
    func removeRowMovesFocusFromInactiveRowToFirstActiveRowBetSize() {
        // Given
        let viewModel = makeViewModel(
            rows: [
                .init(id: rowId(0)),
                .init(id: rowId(1)),
                .init(id: rowId(2)),
                .init(id: rowId(3))
            ],
            selectedNumberOfRows: .three,
            selection: .none,
            focus: .rowBetSize(rowId(2))
        )

        // When
        viewModel.send(.removeRow)

        // Then
        #expect(viewModel.selectedNumberOfRows == .two)
        #expect(viewModel.focus == .rowBetSize(rowId(0)))
    }

    @Test
    func setTotalBetSizeTextField() {
        // Given
        let viewModel = makeViewModel(
            total: .init(betSize: "777"),
            rows: [
                .init(id: RowID(rawValue: 0), betSize: "555"),
                .init(id: RowID(rawValue: 1)),
                .init(id: RowID(rawValue: 2)),
                .init(id: RowID(rawValue: 3))
            ],
            selection: .row(rowId(0))
        )
        let textField: FocusableField = .totalBetSize
        let text = ""

        // When
        viewModel.send(.setTextFieldText(textField, text))

        // Then
        #expect(viewModel.selection == .total)
        #expect(viewModel.total.betSize == text)
        #expect(row(viewModel, 0).betSize == "")
    }

    @Test
    func setRowBetSize() {
        // Given
        let viewModel = makeViewModel(
            total: .init(isON: true, betSize: "777"),
            rows: [
                .init(id: RowID(rawValue: 0)),
                .init(id: RowID(rawValue: 1), betSize: "777"),
                .init(id: RowID(rawValue: 2)),
                .init(id: RowID(rawValue: 3))
            ]
        )
        let textField: FocusableField = .rowBetSize(rowId(0))
        let text = ""

        // When
        viewModel.send(.setTextFieldText(textField, text))

        // Then
        #expect(row(viewModel, 0).betSize == text)
        #expect(row(viewModel, 1).betSize == "")
        #expect(viewModel.total.betSize == "")
    }

    @Test
    func setRowBetSizeWhenSelectedRowIsNone() {
        // Given
        let viewModel = makeViewModel(selection: .none)
        let textField: FocusableField = .rowBetSize(rowId(0))
        let text = "777"

        // When
        viewModel.send(.setTextFieldText(textField, text))

        // Then
        #expect(row(viewModel, 0).betSize == text)
        #expect(viewModel.total.betSize == "")
    }

    @Test
    func setRowBetSizeWhenSelectedRowIsNoneAndSumOfBetSizesEqualZero() {
        // Given
        let viewModel = makeViewModel(selection: .none)
        let textField: FocusableField = .rowBetSize(rowId(0))
        let text = ""

        // When
        viewModel.send(.setTextFieldText(textField, text))

        // Then
        #expect(row(viewModel, 0).betSize == text)
        #expect(viewModel.total.betSize == "")
    }

    @Test
    func setRowCoefficient() {
        // Given
        let viewModel = makeViewModel()
        let textField: FocusableField = .rowCoefficient(rowId(0))
        let text = ""

        // When
        viewModel.send(.setTextFieldText(textField, text))

        // Then
        #expect(row(viewModel, 0).coefficient == text)
    }

    @Test
    func setFocus() {
        // Given
        let viewModel = makeViewModel()
        let field: FocusableField = .totalBetSize

        // When
        viewModel.send(.setFocus(field))

        // Then
        #expect(viewModel.focus == field)
    }

    @Test
    func clearTotalBetSizeField() {
        // Given
        let viewModel = makeViewModel(
            total: .init(betSize: "777"),
            focus: .totalBetSize
        )

        // When
        viewModel.send(.clearFocusableField)

        // Then
        #expect(viewModel.total.betSize == "")
    }

    @Test
    func clearRowBetSizeField() {
        // Given
        let viewModel = makeViewModel(
            rows: [
                .init(id: RowID(rawValue: 0), betSize: "777"),
                .init(id: RowID(rawValue: 1)),
                .init(id: RowID(rawValue: 2)),
                .init(id: RowID(rawValue: 3))
            ],
            focus: .rowBetSize(rowId(0))
        )

        // When
        viewModel.send(.clearFocusableField)

        // Then
        #expect(row(viewModel, 0).betSize == "")
    }

    @Test
    func clearRowCoefficientField() {
        // Given
        let viewModel = makeViewModel(
            rows: [
                .init(id: RowID(rawValue: 0), coefficient: "777"),
                .init(id: RowID(rawValue: 1)),
                .init(id: RowID(rawValue: 2)),
                .init(id: RowID(rawValue: 3))
            ],
            focus: .rowCoefficient(rowId(0))
        )

        // When
        viewModel.send(.clearFocusableField)

        // Then
        #expect(row(viewModel, 0).coefficient == "")
    }

    @Test
    func clearNoneField() {
        // Given
        let viewModel = makeViewModel(focus: .none)

        // When
        viewModel.send(.clearFocusableField)

        // Then
    }

    @Test
    func clearAll() {
        // Given
        let viewModel = makeViewModel(
            total: .init(betSize: "777", profitPercentage: "777%"),
            rows: [
                .init(id: RowID(rawValue: 0), betSize: "777", coefficient: "777", income: "777"),
                .init(id: RowID(rawValue: 1)),
                .init(id: RowID(rawValue: 2)),
                .init(id: RowID(rawValue: 3))
            ]
        )

        // When
        viewModel.send(.clearAll)

        // Then
        #expect(viewModel.total.betSize == "")
        #expect(viewModel.total.profitPercentage == "0%")
        #expect(row(viewModel, 0).betSize == "")
        #expect(row(viewModel, 0).coefficient == "")
        #expect(row(viewModel, 0).income == "0")
    }

    @Test
    func hideKeyboard() {
        // Given
        let viewModel = makeViewModel(
            focus: .totalBetSize
        )

        // When
        viewModel.send(.hideKeyboard)

        // Then
        #expect(viewModel.focus == .none)
    }

    @Test
    func calculationMethodWhenSelectedRowIsTotalAndSelectedNumberOfRowsIsTwo() {
        // Given
        let viewModel = makeViewModel(
            rows: [
                .init(id: RowID(rawValue: 0), coefficient: formatCoefficient(2.22)),
                .init(id: RowID(rawValue: 1), coefficient: formatCoefficient(3.33)),
                .init(id: RowID(rawValue: 2)),
                .init(id: RowID(rawValue: 3))
            ],
            selectedNumberOfRows: .two
        )

        // When
        viewModel.send(.setTextFieldText(.totalBetSize, "777"))

        // Then
        #expect(
            viewModel.total == TotalRow(
                isON: true,
                betSize: "777",
                profitPercentage: formatNumber(33.2, isPercent: true)
            )
        )
        #expect(
            row(viewModel, 0) == Row(
                id: RowID(rawValue: 0),
                isON: false,
                betSize: formatNumber(466.2),
                coefficient: formatNumber(2.22),
                income: formatNumber(257.96)
            )
        )
        #expect(
            row(viewModel, 1) == Row(
                id: RowID(rawValue: 1),
                isON: false,
                betSize: formatNumber(310.8),
                coefficient: formatNumber(3.33),
                income: formatNumber(257.96)
            )
        )
        #expect(row(viewModel, 2) == Row(id: RowID(rawValue: 2)))
        #expect(row(viewModel, 3) == Row(id: RowID(rawValue: 3)))
    }

    @Test
    func calculationMethodWhenSelectedRowIsRowAndSelectedNumberOfRowsIsThree() {
        // Given
        let viewModel = makeViewModel(
            total: .init(isON: false),
            rows: [
                .init(id: RowID(rawValue: 0), isON: true, coefficient: formatCoefficient(2.22)),
                .init(id: RowID(rawValue: 1), coefficient: formatCoefficient(3.33)),
                .init(id: RowID(rawValue: 2), coefficient: formatCoefficient(4.44)),
                .init(id: RowID(rawValue: 3))
            ],
            selectedNumberOfRows: .three,
            selection: .row(rowId(0))
        )

        // When
        viewModel.send(.setTextFieldText(.rowBetSize(rowId(0)), "777"))

        // Then
        #expect(
            viewModel.total == TotalRow(
                isON: false,
                betSize: formatNumber(1683.5),
                profitPercentage: formatNumber(2.46, isPercent: true)
            )
        )
        #expect(
            row(viewModel, 0) == Row(
                id: RowID(rawValue: 0),
                isON: true,
                betSize: "777",
                coefficient: formatNumber(2.22),
                income: formatNumber(41.44)
            )
        )
        #expect(
            row(viewModel, 1) == Row(
                id: RowID(rawValue: 1),
                isON: false,
                betSize: "518",
                coefficient: formatNumber(3.33),
                income: formatNumber(41.44)
            )
        )
        #expect(
            row(viewModel, 2) == Row(
                id: RowID(rawValue: 2),
                isON: false,
                betSize: formatNumber(388.5),
                coefficient: formatNumber(4.44),
                income: formatNumber(41.44)
            )
        )
        #expect(row(viewModel, 3) == Row(id: RowID(rawValue: 3)))
    }

    @Test
    func calculationMethodWhenSelectedRowIsNoneAndSelectedNumberOfRowsIsFour() {
        // Given
        let viewModel = makeViewModel(
            total: .init(isON: false),
            rows: [
                .init(id: RowID(rawValue: 0), betSize: "444", coefficient: formatCoefficient(2.22)),
                .init(id: RowID(rawValue: 1), betSize: "555", coefficient: formatCoefficient(3.33)),
                .init(id: RowID(rawValue: 2), betSize: "666", coefficient: formatCoefficient(4.44)),
                .init(id: RowID(rawValue: 3), coefficient: formatCoefficient(5.55))
            ],
            selectedNumberOfRows: .four,
            selection: .none
        )

        // When
        viewModel.send(.setTextFieldText(.rowBetSize(rowId(3)), "777"))

        // Then
        let expectedTotal = TotalRow(
            isON: false,
            betSize: "2442",
            profitPercentage: formatNumber(-13.51, isPercent: true)
        )
        #expect(viewModel.total == expectedTotal)

        let expectedRow0 = Row(
            id: RowID(rawValue: 0),
            isON: false,
            betSize: "444",
            coefficient: formatNumber(2.22),
            income: formatNumber(-1456.32)
        )
        #expect(row(viewModel, 0) == expectedRow0)

        let expectedRow1 = Row(
            id: RowID(rawValue: 1),
            isON: false,
            betSize: "555",
            coefficient: formatNumber(3.33),
            income: formatNumber(-593.85)
        )
        #expect(row(viewModel, 1) == expectedRow1)

        let expectedRow2 = Row(
            id: RowID(rawValue: 2),
            isON: false,
            betSize: "666",
            coefficient: formatNumber(4.44),
            income: formatNumber(515.04)
        )
        #expect(row(viewModel, 2) == expectedRow2)

        let expectedRow3 = Row(
            id: RowID(rawValue: 3),
            isON: false,
            betSize: "777",
            coefficient: formatNumber(5.55),
            income: formatNumber(1870.35)
        )
        #expect(row(viewModel, 3) == expectedRow3)
    }

    @Test
    func reorderActiveRowsDoesNotBreakCalculation() {
        // Given
        let viewModel = makeViewModel(
            rows: [
                .init(id: RowID(rawValue: 0), coefficient: formatCoefficient(2.0)),
                .init(id: RowID(rawValue: 1), coefficient: formatCoefficient(3.0)),
                .init(id: RowID(rawValue: 2), coefficient: formatCoefficient(4.0))
            ],
            selectedNumberOfRows: .three,
            selection: .total
        )

        // When
        viewModel.send(.setTextFieldText(.totalBetSize, "1000"))
        let betSize0Before = row(viewModel, 0).betSize
        let betSize1Before = row(viewModel, 1).betSize
        let betSize2Before = row(viewModel, 2).betSize

        viewModel.send(.reorderRows(fromOffsets: IndexSet(integer: 0), toOffset: 3))

        // Then
        #expect(viewModel.activeRowIds == [rowId(1), rowId(2), rowId(0)])
        #expect(row(viewModel, 0).betSize == betSize0Before)
        #expect(row(viewModel, 1).betSize == betSize1Before)
        #expect(row(viewModel, 2).betSize == betSize2Before)
    }

    @Test
    func noneCalculationMethod() {
        // Given
        let viewModel = makeViewModel(
            rows: [
                .init(id: RowID(rawValue: 0), coefficient: formatCoefficient(2.22)),
                .init(id: RowID(rawValue: 1), coefficient: formatCoefficient(3.33)),
                .init(id: RowID(rawValue: 2)),
                .init(id: RowID(rawValue: 3))
            ]
        )

        // When
        viewModel.send(.setTextFieldText(.totalBetSize, "xxx"))

        // Then
    }

    @Test
    func profitPercentageDoesNotChangeForAllCoefficients() {
        // Given
        let viewModel = makeViewModel(
            rows: [
                .init(id: RowID(rawValue: 0), coefficient: formatCoefficient(2.22)),
                .init(id: RowID(rawValue: 1)),
                .init(id: RowID(rawValue: 2)),
                .init(id: RowID(rawValue: 3))
            ]
        )

        // When
        viewModel.send(.setTextFieldText(.rowCoefficient(rowId(1)), "3,33"))

        // Then
        #expect(viewModel.total.profitPercentage == "0%")
    }

    // MARK: - Tests with Mocks

    @Test
    func calculationServiceIsCalledOnSelectRow() {
        // Given
        let mockService = MockCalculationService()
        let viewModel = makeViewModel(
            calculationService: mockService
        )

        // When
        viewModel.send(.selectRow(.row(rowId(0))))

        // Then
        #expect(mockService.calculateCallCount == 1)
        #expect(mockService.calculateInputs.first != nil)
    }

    @Test
    func calculationServiceIsCalledOnSetTextFieldText() {
        // Given
        let mockService = MockCalculationService()
        let viewModel = makeViewModel(
            calculationService: mockService
        )

        // When
        viewModel.send(.setTextFieldText(.totalBetSize, "100"))

        // Then
        #expect(mockService.calculateCallCount == 1)
    }

    @Test
    func calculationServiceIsCalledOnRemoveRow() {
        // Given
        let mockService = MockCalculationService()
        let viewModel = makeViewModel(
            selectedNumberOfRows: .three,
            calculationService: mockService
        )

        // When
        viewModel.send(.removeRow)

        // Then
        #expect(mockService.calculateCallCount == 1)
    }

    @Test
    func calculationServiceResultIsApplied() {
        // Given
        let mockService = MockCalculationService()
        let expectedTotal = TotalRow(betSize: "999", profitPercentage: "99%")
        let expectedRows = [
            Row(id: RowID(rawValue: 0), betSize: "500", coefficient: "2", income: "100")
        ]
        let data = makeRows(expectedRows)
        mockService.calculateResult = .updated(
            CalculationOutput(total: expectedTotal, rowsById: data.rowsById)
        )
        let viewModel = makeViewModel(
            calculationService: mockService
        )

        // When
        viewModel.send(.selectRow(.row(rowId(0))))

        // Then
        #expect(viewModel.total.betSize == expectedTotal.betSize)
        #expect(viewModel.total.profitPercentage == expectedTotal.profitPercentage)
        #expect(row(viewModel, 0).betSize == expectedRows[0].betSize)
    }

    // MARK: - addRow Tests

    @Test
    func addRowWhenNumberOfRowsIsLessThanTen() {
        // Given
        let viewModel = makeViewModel(
            selectedNumberOfRows: .two
        )

        // When
        viewModel.send(.addRow)

        // Then
        #expect(viewModel.selectedNumberOfRows == .three)
    }

    @Test
    func addRowWhenNumberOfRowsIsTen() {
        // Given
        let viewModel = makeViewModel(
            selectedNumberOfRows: .twenty
        )

        // When
        viewModel.send(.addRow)

        // Then
        // Не должно добавляться, если уже 20 строк
        #expect(viewModel.selectedNumberOfRows == .twenty)
    }

    @Test
    func addRowWhenNumberOfRowsIsNine() {
        // Given
        let viewModel = makeViewModel(
            selectedNumberOfRows: .nineteen
        )

        // When
        viewModel.send(.addRow)

        // Then
        #expect(viewModel.selectedNumberOfRows == .twenty)
    }

    @Test
    func addRowMultipleTimes() {
        // Given
        let viewModel = makeViewModel(
            selectedNumberOfRows: .two
        )

        // When
        viewModel.send(.addRow)
        viewModel.send(.addRow)
        viewModel.send(.addRow)

        // Then
        #expect(viewModel.selectedNumberOfRows == .five)
    }

    @Test
    func addRowResetsDerivedValuesWhenSelectedRowIsNone() {
        // Given
        let viewModel = makeViewModel(selection: .none)

        // When
        viewModel.send(.setTextFieldText(.rowCoefficient(rowId(0)), "2"))
        viewModel.send(.setTextFieldText(.rowCoefficient(rowId(1)), "3"))
        viewModel.send(.setTextFieldText(.rowBetSize(rowId(0)), "100"))
        viewModel.send(.setTextFieldText(.rowBetSize(rowId(1)), "200"))
        viewModel.send(.addRow)

        // Then
        #expect(viewModel.total.betSize == "")
        #expect(viewModel.total.profitPercentage == "0%")
        #expect(row(viewModel, 0).betSize == "100")
        #expect(row(viewModel, 0).income == "0")
        #expect(row(viewModel, 1).betSize == "200")
        #expect(row(viewModel, 1).income == "0")
    }

    @Test
    func addRowResetsDerivedValuesWhenSelectedRowIsTotal() {
        // Given
        let viewModel = makeViewModel()

        // When
        viewModel.send(.setTextFieldText(.rowCoefficient(rowId(0)), "2"))
        viewModel.send(.setTextFieldText(.rowCoefficient(rowId(1)), "3"))
        viewModel.send(.setTextFieldText(.totalBetSize, "1000"))
        viewModel.send(.addRow)

        // Then
        #expect(viewModel.total.betSize == "1000")
        #expect(viewModel.total.profitPercentage == "0%")
        #expect(row(viewModel, 0).betSize == "")
        #expect(row(viewModel, 0).income == "0")
        #expect(row(viewModel, 1).betSize == "")
        #expect(row(viewModel, 1).income == "0")
    }

    @Test
    func addRowResetsDerivedValuesWhenSelectedRowIsSpecificRow() {
        // Given
        let viewModel = makeViewModel()

        // When
        viewModel.send(.selectRow(.row(rowId(0))))
        viewModel.send(.setTextFieldText(.rowCoefficient(rowId(0)), "2"))
        viewModel.send(.setTextFieldText(.rowCoefficient(rowId(1)), "3"))
        viewModel.send(.setTextFieldText(.rowBetSize(rowId(0)), "500"))
        viewModel.send(.addRow)

        // Then
        #expect(viewModel.total.betSize == "")
        #expect(viewModel.total.profitPercentage == "0%")
        #expect(row(viewModel, 0).betSize == "500")
        #expect(row(viewModel, 0).income == "0")
        #expect(row(viewModel, 1).betSize == "")
        #expect(row(viewModel, 1).income == "0")
    }

    // MARK: - removeRow Tests

    @Test
    func removeRowWhenNumberOfRowsIsGreaterThanTwo() {
        // Given
        let viewModel = makeViewModel(
            selectedNumberOfRows: .three
        )

        // When
        viewModel.send(.removeRow)

        // Then
        #expect(viewModel.selectedNumberOfRows == .two)
    }

    @Test
    func removeRowWhenNumberOfRowsIsTwo() {
        // Given
        let viewModel = makeViewModel(
            selectedNumberOfRows: .two
        )

        // When
        viewModel.send(.removeRow)

        // Then
        // Не должно удаляться, если уже 2 строки
        #expect(viewModel.selectedNumberOfRows == .two)
    }

    @Test
    func removeRowWhenSelectedRowIsInUndisplayedRange() {
        // Given
        let id = 2
        let viewModel = makeViewModel(
            rows: [
                .init(id: RowID(rawValue: 0)),
                .init(id: RowID(rawValue: 1)),
                .init(id: RowID(rawValue: 2), isON: true, betSize: "777"),
                .init(id: RowID(rawValue: 3))
            ],
            selectedNumberOfRows: .three,
            selection: .row(rowId(id))
        )

        // When
        viewModel.send(.removeRow)

        // Then
        // Строка должна быть снята с выбора, так как она теперь вне отображаемого диапазона
        // Выбор должен переключиться на total
        #expect(!row(viewModel, id).isON)
        #expect(viewModel.total.isON)
        #expect(viewModel.selection == .total)
        #expect(viewModel.selectedNumberOfRows == .two)
    }

    @Test
    func removeRowWhenUndisplayedRowContainsData() {
        // Given
        let id = 2
        let viewModel = makeViewModel(
            rows: [
                .init(id: RowID(rawValue: 0)),
                .init(id: RowID(rawValue: 1)),
                .init(id: RowID(rawValue: 2), betSize: "777", coefficient: formatCoefficient(2.22)),
                .init(id: RowID(rawValue: 3))
            ],
            selectedNumberOfRows: .three
        )

        // When
        viewModel.send(.removeRow)

        // Then
        // Данные в неотображаемой строке должны быть очищены
        #expect(row(viewModel, id).betSize == "")
        #expect(row(viewModel, id).coefficient == "")
        #expect(row(viewModel, id).income == "0")
        #expect(viewModel.selectedNumberOfRows == .two)
    }

    @Test
    func removeRowCallsCalculate() {
        // Given
        let mockService = MockCalculationService()
        let viewModel = makeViewModel(
            selectedNumberOfRows: .three,
            calculationService: mockService
        )

        // When
        viewModel.send(.removeRow)

        // Then
        // После удаления строки должен вызываться calculate
        #expect(mockService.calculateCallCount == 1)
    }

    @Test
    func removeRowWhenSelectedRowIsNotInUndisplayedRange() {
        // Given
        let viewModel = makeViewModel(
            rows: [
                .init(id: RowID(rawValue: 0), isON: true),
                .init(id: RowID(rawValue: 1)),
                .init(id: RowID(rawValue: 2)),
                .init(id: RowID(rawValue: 3))
            ],
            selectedNumberOfRows: .three,
            selection: .row(rowId(0))
        )

        // When
        viewModel.send(.removeRow)

        // Then
        // Выбранная строка остается выбранной, так как она в отображаемом диапазоне
        #expect(row(viewModel, 0).isON)
        #expect(viewModel.selection == .row(rowId(0)))
        #expect(viewModel.selectedNumberOfRows == .two)
    }

    @Test
    func rowItemStateUpdatesOnlyForChangedRow() {
        // Given
        let viewModel = makeViewModel()
        let initialStates = viewModel.activeRowViewModels.map(\.state)

        // When
        viewModel.send(.setTextFieldText(.rowCoefficient(rowId(0)), "2"))

        // Then
        let updatedStates = viewModel.activeRowViewModels.map(\.state)
        #expect(updatedStates[0].coefficient == "2")
        #expect(updatedStates[1] == initialStates[1])
    }

    @Test
    func rowItemViewModelsReflectReorderedActiveRows() {
        // Given
        let viewModel = makeViewModel(
            rows: [
                .init(id: RowID(rawValue: 0)),
                .init(id: RowID(rawValue: 1)),
                .init(id: RowID(rawValue: 2))
            ],
            selectedNumberOfRows: .three
        )

        // When
        viewModel.send(.reorderRows(fromOffsets: IndexSet(integer: 0), toOffset: 3))

        // Then
        #expect(viewModel.activeRowViewModels.map(\.id) == viewModel.activeRowIds)
        #expect(viewModel.activeRowViewModels.map(\.state.displayIndex) == [0, 1, 2])
    }

    @Test
    func totalRowItemStateUpdatesWhenSelectionChanges() {
        // Given
        let viewModel = makeViewModel()
        #expect(viewModel.totalRowViewModel.state.isSelected)

        // When
        viewModel.send(.selectRow(.row(rowId(0))))

        // Then
        #expect(!viewModel.totalRowViewModel.state.isSelected)
        #expect(viewModel.totalRowViewModel.state.isBetSizeDisabled)
    }

    @Test
    func outcomeCountStateUpdatesAfterAddRow() {
        // Given
        let viewModel = makeViewModel(selectedNumberOfRows: .two)
        #expect(viewModel.outcomeCountViewModel.state.selectedNumberOfRows == .two)

        // When
        viewModel.send(.addRow)

        // Then
        #expect(viewModel.outcomeCountViewModel.state.selectedNumberOfRows == .three)
        #expect(viewModel.outcomeCountViewModel.state.maxRowCount == CalculatorConstants.maxRowCount)
    }

    @Test
    func setFocusSameValueDoesNotChangeFocus() {
        // Given
        let viewModel = makeViewModel(focus: .totalBetSize)

        // When
        viewModel.send(.setFocus(.totalBetSize))

        // Then
        #expect(viewModel.focus == .totalBetSize)
    }

    // MARK: - Concurrency Tests

    @Test
    func mainActorIsolation() async {
        // Given
        let viewModel = makeViewModel()

        // When & Then
        // Проверяем, что методы ViewModel выполняются на MainActor
        await MainActor.run {
            viewModel.send(.selectRow(.row(rowId(0))))
            #expect(viewModel.selection == .row(rowId(0)))
        }

        // Проверяем доступ к @Published свойствам из MainActor контекста
        await MainActor.run {
            _ = viewModel.total
            _ = viewModel.rowsById
            _ = viewModel.selectedNumberOfRows
            _ = viewModel.selection
            _ = viewModel.focus
        }
    }

    @Test
    func concurrentSendCalls() async {
        // Given
        let viewModel = makeViewModel()
        let iterations = 100

        // When
        // Выполняем множество параллельных вызовов send()
        await withTaskGroup(of: Void.self) { group in
            for index in 0..<iterations {
                group.addTask {
                    await MainActor.run {
                        viewModel.send(.setTextFieldText(.rowCoefficient(rowId(index % 4)), "\(index)"))
                    }
                }
            }
        }

        // Then
        // Проверяем, что состояние корректно (не должно быть крашей)
        // Все строки должны иметь валидные значения коэффициентов
        await MainActor.run {
            for index in 0..<4 {
                let coefficient = row(viewModel, index).coefficient
                // Коэффициент должен быть либо пустым, либо валидным числом
                #expect(coefficient.isEmpty || Double(coefficient.replacingOccurrences(of: ",", with: ".")) != nil)
            }
        }
    }

    @Test
    func concurrentAddAndRemoveRow() async {
        // Given
        let viewModel = makeViewModel(selectedNumberOfRows: .five)
        let iterations = 50

        // When
        // Параллельно добавляем и удаляем строки
        await withTaskGroup(of: Void.self) { group in
            for index in 0..<iterations {
                if index % 2 == 0 {
                    group.addTask {
                        await MainActor.run {
                            viewModel.send(.addRow)
                        }
                    }
                } else {
                    group.addTask {
                        await MainActor.run {
                            viewModel.send(.removeRow)
                        }
                    }
                }
            }
        }

        // Then
        // Проверяем, что количество строк в допустимых пределах
        await MainActor.run {
            #expect(viewModel.selectedNumberOfRows.rawValue >= 2)
            #expect(viewModel.selectedNumberOfRows.rawValue <= 20)
        }
    }

    @Test
    func concurrentSelectRow() async {
        // Given
        let viewModel = makeViewModel()
        let rowTypes: [Selection] = [.total, .none, .row(rowId(0)), .row(rowId(1)), .row(rowId(2)), .row(rowId(3))]

        // When
        // Параллельно выбираем разные строки
        await withTaskGroup(of: Void.self) { group in
            for rowType in rowTypes {
                for _ in 0..<20 {
                    group.addTask {
                        await MainActor.run {
                            viewModel.send(.selectRow(rowType))
                        }
                    }
                }
            }
        }

        // Then
        // Проверяем, что состояние корректно (selection должен быть одним из валидных значений)
        await MainActor.run {
            let selected = viewModel.selection
            #expect(rowTypes.contains(selected))
        }
    }

    @Test
    func publishedPropertiesUpdateOnMainActor() async {
        // Given
        let viewModel = makeViewModel()

        // When
        await MainActor.run {
            viewModel.send(.setTextFieldText(.totalBetSize, "1000"))
            viewModel.send(.selectRow(.row(rowId(0))))
        }

        // Then
        // Проверяем, что @Published свойства обновились корректно
        await MainActor.run {
            #expect(viewModel.total.betSize == "")
            #expect(viewModel.selection == .row(rowId(0)))
            #expect(row(viewModel, 0).isON)
        }
    }

    @Test
    func rapidSequentialActions() async {
        // Given
        let viewModel = makeViewModel()

        // When
        // Быстрые последовательные вызовы без задержек
        await MainActor.run {
            for index in 0..<10 {
                viewModel.send(.setTextFieldText(.rowCoefficient(rowId(index % 4)), "\(index + 1)"))
                viewModel.send(.setTextFieldText(.rowBetSize(rowId(index % 4)), "\(index * 100)"))
            }
            viewModel.send(.selectRow(.total))
            viewModel.send(.setTextFieldText(.totalBetSize, "5000"))
        }

        // Then
        // Проверяем, что финальное состояние корректно
        await MainActor.run {
            #expect(viewModel.total.betSize == "5000")
            #expect(viewModel.selection == .total)
            #expect(viewModel.total.isON)
        }
    }

    // MARK: - Analytics Tests

    /// Тест события calculator_rows_count_changed при добавлении строки
    @Test
    func analyticsWhenCalculatorRowsCountChangedIncreased() {
        // Given
        let mockAnalytics = MockCalculatorAnalytics()
        let viewModel = makeViewModel(
            selectedNumberOfRows: .two,
            analytics: mockAnalytics
        )

        // When
        viewModel.send(.addRow)

        // Then
        #expect(mockAnalytics.eventCallCount >= 1)
        #expect(mockAnalytics.events.contains { event in
            if case let .calculatorRowsCountChanged(rowCount, direction) = event {
                return rowCount == 3 && direction == .increased
            }
            return false
        })
    }

    /// Тест параметров события calculator_rows_count_changed при увеличении
    @Test
    func analyticsWhenCalculatorRowsCountChangedIncreasedParameters() {
        // Given
        let mockAnalytics = MockCalculatorAnalytics()
        let viewModel = makeViewModel(
            selectedNumberOfRows: .two,
            analytics: mockAnalytics
        )

        // When
        viewModel.send(.addRow)

        // Then
        let addedEvents = mockAnalytics.events.compactMap { event -> (Int, CalculatorRowsCountChangeDirection)? in
            if case let .calculatorRowsCountChanged(rowCount, direction) = event {
                return (rowCount, direction)
            }
            return nil
        }
        #expect(addedEvents.contains { $0.0 == 3 && $0.1 == .increased })
    }

    /// Тест события calculator_rows_count_changed не вызывается при максимальном количестве строк
    @Test
    func analyticsWhenCalculatorRowsCountChangedNotCalledAtMax() {
        // Given
        let mockAnalytics = MockCalculatorAnalytics()
        let viewModel = makeViewModel(
            selectedNumberOfRows: .twenty,
            analytics: mockAnalytics
        )
        let initialCallCount = mockAnalytics.eventCallCount

        // When
        viewModel.send(.addRow)

        // Then
        // Не должно быть новых вызовов, так как уже максимальное количество строк
        #expect(mockAnalytics.eventCallCount == initialCallCount)
    }

    /// Тест события calculator_rows_count_changed при удалении строки
    @Test
    func analyticsWhenCalculatorRowsCountChangedDecreased() {
        // Given
        let mockAnalytics = MockCalculatorAnalytics()
        let viewModel = makeViewModel(
            selectedNumberOfRows: .three,
            analytics: mockAnalytics
        )

        // When
        viewModel.send(.removeRow)

        // Then
        #expect(mockAnalytics.eventCallCount >= 1)
        #expect(mockAnalytics.events.contains { event in
            if case let .calculatorRowsCountChanged(rowCount, direction) = event {
                return rowCount == 2 && direction == .decreased
            }
            return false
        })
    }

    /// Тест параметров события calculator_rows_count_changed при уменьшении
    @Test
    func analyticsWhenCalculatorRowsCountChangedDecreasedParameters() {
        // Given
        let mockAnalytics = MockCalculatorAnalytics()
        let viewModel = makeViewModel(
            selectedNumberOfRows: .three,
            analytics: mockAnalytics
        )

        // When
        viewModel.send(.removeRow)

        // Then
        let removedEvents = mockAnalytics.events.compactMap { event -> (Int, CalculatorRowsCountChangeDirection)? in
            if case let .calculatorRowsCountChanged(rowCount, direction) = event {
                return (rowCount, direction)
            }
            return nil
        }
        #expect(removedEvents.contains { $0.0 == 2 && $0.1 == .decreased })
    }

    /// Тест события calculator_rows_count_changed не вызывается при минимальном количестве строк
    @Test
    func analyticsWhenCalculatorRowsCountChangedNotCalledAtMin() {
        // Given
        let mockAnalytics = MockCalculatorAnalytics()
        let viewModel = makeViewModel(
            selectedNumberOfRows: .two,
            analytics: mockAnalytics
        )
        let initialCallCount = mockAnalytics.eventCallCount

        // When
        viewModel.send(.removeRow)

        // Then
        // Не должно быть новых вызовов, так как уже минимальное количество строк
        #expect(mockAnalytics.eventCallCount == initialCallCount)
    }

    @Test
    func analyticsWhenCalculatorModeSelected() {
        // Given
        let mockAnalytics = MockCalculatorAnalytics()
        let viewModel = makeViewModel(
            selection: .total,
            analytics: mockAnalytics
        )

        // When
        viewModel.send(.selectRow(.total))

        // Then
        #expect(
            mockAnalytics.events.contains {
                if case .calculatorModeSelected(mode: .rows) = $0 {
                    return true
                }
                return false
            }
        )
    }

    /// Тест события calculator_cleared при очистке
    @Test
    func analyticsWhenCalculatorCleared() {
        // Given
        let mockAnalytics = MockCalculatorAnalytics()
        let viewModel = makeViewModel(
            total: .init(betSize: "777", profitPercentage: "10%"),
            rows: [
                .init(id: RowID(rawValue: 0), betSize: "100", coefficient: "2.0"),
                .init(id: RowID(rawValue: 1)),
                .init(id: RowID(rawValue: 2)),
                .init(id: RowID(rawValue: 3))
            ],
            analytics: mockAnalytics
        )
        let initialCallCount = mockAnalytics.eventCallCount

        // When
        viewModel.send(.clearAll)

        // Then
        #expect(mockAnalytics.eventCallCount > initialCallCount)
        #expect(mockAnalytics.events.contains(.calculatorCleared))
    }

    /// Тест события calculator_calculation_performed с debounce
    @Test
    func analyticsWhenCalculationPerformed() async {
        // Given
        let mockAnalytics = MockCalculatorAnalytics()
        let delay = TestDelay()
        let viewModel = makeViewModel(
            rows: [
                .init(id: RowID(rawValue: 0), coefficient: "2.0"),
                .init(id: RowID(rawValue: 1), coefficient: "3.0"),
                .init(id: RowID(rawValue: 2)),
                .init(id: RowID(rawValue: 3))
            ],
            analytics: mockAnalytics,
            delay: delay
        )

        // When
        viewModel.send(.setTextFieldText(.totalBetSize, "100"))
        await delay.waitForSleepCall()
        await delay.advance()

        // Then
        #expect(mockAnalytics.eventCallCount >= 1)
        #expect(mockAnalytics.events.contains { event in
            if case .calculatorCalculationPerformed(let rowCount, _, _, _) = event {
                return rowCount == 2
            }
            return false
        })
    }

    /// Тест параметров события calculator_calculation_performed
    @Test
    func analyticsWhenCalculationPerformedParameters() async {
        // Given
        let mockAnalytics = MockCalculatorAnalytics()
        let delay = TestDelay()
        let viewModel = makeViewModel(
            rows: [
                .init(id: RowID(rawValue: 0), coefficient: "2.0"),
                .init(id: RowID(rawValue: 1), coefficient: "3.0"),
                .init(id: RowID(rawValue: 2)),
                .init(id: RowID(rawValue: 3))
            ],
            analytics: mockAnalytics,
            delay: delay
        )

        // When
        viewModel.send(.setTextFieldText(.totalBetSize, "100"))
        await delay.waitForSleepCall()
        await delay.advance()

        // Then
        let calculationEvent = mockAnalytics.events.first {
            if case .calculatorCalculationPerformed = $0 {
                return true
            }
            return false
        }

        guard case let .calculatorCalculationPerformed(
            rowCount,
            mode,
            profitPercentage,
            isProfitable
        )? = calculationEvent else {
            Issue.record("Ожидалось событие calculator_calculation_performed")
            return
        }

        #expect(rowCount == 2)
        #expect(mode == .total)
        #expect(profitPercentage >= 0)
        #expect(isProfitable == true)
    }

    /// Тест debounce для calculator_calculation_performed - одно событие при быстрых изменениях
    @Test
    func analyticsWhenCalculationPerformedDebounce() async {
        // Given
        let mockAnalytics = MockCalculatorAnalytics()
        let delay = TestDelay()
        let viewModel = makeViewModel(
            rows: [
                .init(id: RowID(rawValue: 0), coefficient: "2.0"),
                .init(id: RowID(rawValue: 1), coefficient: "3.0"),
                .init(id: RowID(rawValue: 2)),
                .init(id: RowID(rawValue: 3))
            ],
            analytics: mockAnalytics,
            delay: delay
        )

        // When
        // Быстро меняем значения несколько раз
        viewModel.send(.setTextFieldText(.totalBetSize, "100"))
        viewModel.send(.setTextFieldText(.totalBetSize, "200"))
        viewModel.send(.setTextFieldText(.totalBetSize, "300"))
        await delay.waitForSleepCall()
        await delay.advance()

        // Then
        // Должно быть только одно событие calculator_calculation_performed из-за debounce
        let calculationEvents = mockAnalytics.events.filter { event in
            if case .calculatorCalculationPerformed = event {
                return true
            }
            return false
        }
        #expect(calculationEvents.count == 1)
    }
}
