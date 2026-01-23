// swiftlint:disable file_length
// swiftlint:disable type_body_length

@testable import SurebetCalculator
import Testing

@MainActor
struct SurebetCalculatorViewModelTests {
    @Test
    func selectRow() {
        // Given
        let viewModel = SurebetCalculatorViewModel()
        let id = 0
        let row: RowType = .row(id)

        // When
        viewModel.send(.selectRow(row))

        // Then
        #expect(!viewModel.total.isON)
        #expect(viewModel.rows[id].isON)
        #expect(viewModel.selectedRow == row)
    }

    @Test
    func selectTotal() {
        // Given
        let viewModel = SurebetCalculatorViewModel(selectedRow: .none)
        let row: RowType = .total

        // When
        viewModel.send(.selectRow(row))

        // Then
        #expect(viewModel.total.isON)
        #expect(viewModel.selectedRow == row)
    }

    @Test
    func selectNone() {
        // Given
        let id = 0
        let viewModel = SurebetCalculatorViewModel(selectedRow: .row(id))
        let row: RowType = .row(id)

        // When
        viewModel.send(.selectRow(row))

        // Then
        #expect(!viewModel.rows[id].isON)
        #expect(viewModel.selectedRow == .none)
    }

    @Test
    func selectNumberOfRowsWhenToDeselectAndClear() {
        // Given
        let initialNumberOfRows: NumberOfRows = .three
        let newNumberOfRows: NumberOfRows = .two
        let id = 2
        let viewModel = SurebetCalculatorViewModel(
            rows: [
                .init(id: 0),
                .init(id: 1),
                .init(id: 2, isON: true, betSize: "777"),
                .init(id: 3)
            ],
            selectedNumberOfRows: initialNumberOfRows,
            selectedRow: .row(id)
        )

        // When
        viewModel.send(.removeRow)

        // Then
        #expect(!viewModel.rows[id].isON)
        #expect(viewModel.rows[id].betSize == "")
        #expect(viewModel.selectedNumberOfRows == newNumberOfRows)
    }

    @Test
    func setTotalBetSizeTextField() {
        // Given
        let viewModel = SurebetCalculatorViewModel(
            total: .init(betSize: "777"),
            rows: [
                .init(id: 0, betSize: "555"),
                .init(id: 1),
                .init(id: 2),
                .init(id: 3)
            ],
            selectedRow: .row(0)
        )
        let textField: FocusableField = .totalBetSize
        let text = ""

        // When
        viewModel.send(.setTextFieldText(textField, text))

        // Then
        #expect(viewModel.selectedRow == .total)
        #expect(viewModel.total.betSize == text)
        #expect(viewModel.rows[0].betSize == "")
    }

    @Test
    func setRowBetSize() {
        // Given
        let viewModel = SurebetCalculatorViewModel(
            total: .init(isON: true, betSize: "777"),
            rows: [
                .init(id: 0),
                .init(id: 1, betSize: "777"),
                .init(id: 2),
                .init(id: 3)
            ]
        )
        let textField: FocusableField = .rowBetSize(0)
        let text = ""

        // When
        viewModel.send(.setTextFieldText(textField, text))

        // Then
        #expect(viewModel.rows[0].betSize == text)
        #expect(viewModel.rows[1].betSize == "")
        #expect(viewModel.total.betSize == "")
    }

    @Test
    func setRowBetSizeWhenSelectedRowIsNone() {
        // Given
        let viewModel = SurebetCalculatorViewModel(selectedRow: .none)
        let textField: FocusableField = .rowBetSize(0)
        let text = "777"

        // When
        viewModel.send(.setTextFieldText(textField, text))

        // Then
        #expect(viewModel.rows[0].betSize == text)
        #expect(viewModel.total.betSize == "777")
    }

    @Test
    func setRowBetSizeWhenSelectedRowIsNoneAndSumOfBetSizesEqualZero() {
        // Given
        let viewModel = SurebetCalculatorViewModel(selectedRow: .none)
        let textField: FocusableField = .rowBetSize(0)
        let text = ""

        // When
        viewModel.send(.setTextFieldText(textField, text))

        // Then
        #expect(viewModel.rows[0].betSize == text)
        #expect(viewModel.total.betSize == "")
    }

    @Test
    func setRowCoefficient() {
        // Given
        let viewModel = SurebetCalculatorViewModel()
        let textField: FocusableField = .rowCoefficient(0)
        let text = ""

        // When
        viewModel.send(.setTextFieldText(textField, text))

        // Then
        #expect(viewModel.rows[0].coefficient == text)
    }

    @Test
    func setFocus() {
        // Given
        let viewModel = SurebetCalculatorViewModel()
        let field: FocusableField = .totalBetSize

        // When
        viewModel.send(.setFocus(field))

        // Then
        #expect(viewModel.focus == field)
    }

    @Test
    func clearTotalBetSizeField() {
        // Given
        let viewModel = SurebetCalculatorViewModel(
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
        let viewModel = SurebetCalculatorViewModel(
            rows: [
                .init(id: 0, betSize: "777"),
                .init(id: 1),
                .init(id: 2),
                .init(id: 3)
            ],
            focus: .rowBetSize(0)
        )

        // When
        viewModel.send(.clearFocusableField)

        // Then
        #expect(viewModel.rows[0].betSize == "")
    }

    @Test
    func clearRowCoefficientField() {
        // Given
        let viewModel = SurebetCalculatorViewModel(
            rows: [
                .init(id: 0, coefficient: "777"),
                .init(id: 1),
                .init(id: 2),
                .init(id: 3)
            ],
            focus: .rowCoefficient(0)
        )

        // When
        viewModel.send(.clearFocusableField)

        // Then
        #expect(viewModel.rows[0].coefficient == "")
    }

    @Test
    func clearNoneField() {
        // Given
        let viewModel = SurebetCalculatorViewModel(focus: .none)

        // When
        viewModel.send(.clearFocusableField)

        // Then
    }

    @Test
    func clearAll() {
        // Given
        let viewModel = SurebetCalculatorViewModel(
            total: .init(betSize: "777", profitPercentage: "777%"),
            rows: [
                .init(id: 0, betSize: "777", coefficient: "777", income: "777"),
                .init(id: 1),
                .init(id: 2),
                .init(id: 3)
            ]
        )

        // When
        viewModel.send(.clearAll)

        // Then
        #expect(viewModel.total.betSize == "")
        #expect(viewModel.total.profitPercentage == "0%")
        #expect(viewModel.rows[0].betSize == "")
        #expect(viewModel.rows[0].coefficient == "")
        #expect(viewModel.rows[0].income == "0")
    }

    @Test
    func hideKeyboard() {
        // Given
        let viewModel = SurebetCalculatorViewModel(
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
        let viewModel = SurebetCalculatorViewModel(
            rows: [
                .init(id: 0, coefficient: "2,22"),
                .init(id: 1, coefficient: "3,33"),
                .init(id: 2),
                .init(id: 3)
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
                profitPercentage: "33,2%"
            )
        )
        #expect(
            viewModel.rows[0] == Row(
                id: 0,
                isON: false,
                betSize: "466,2",
                coefficient: "2,22",
                income: "257,96"
            )
        )
        #expect(
            viewModel.rows[1] == Row(
                id: 1,
                isON: false,
                betSize: "310,8",
                coefficient: "3,33",
                income: "257,96"
            )
        )
        #expect(viewModel.rows[2] == Row(id: 2))
        #expect(viewModel.rows[3] == Row(id: 3))
    }

    // swiftlint:disable:next function_body_length
    @Test
    func calculationMethodWhenSelectedRowIsRowAndSelectedNumberOfRowsIsThree() {
        // Given
        let viewModel = SurebetCalculatorViewModel(
            total: .init(isON: false),
            rows: [
                .init(id: 0, isON: true, coefficient: "2,22"),
                .init(id: 1, coefficient: "3,33"),
                .init(id: 2, coefficient: "4,44"),
                .init(id: 3)
            ],
            selectedNumberOfRows: .three,
            selectedRow: .row(0)
        )

        // When
        viewModel.send(.setTextFieldText(.rowBetSize(0), "777"))

        // Then
        #expect(
            viewModel.total == TotalRow(
                isON: false,
                betSize: "1683,5",
                profitPercentage: "2,46%"
            )
        )
        #expect(
            viewModel.rows[0] == Row(
                id: 0,
                isON: true,
                betSize: "777",
                coefficient: "2,22",
                income: "41,44"
            )
        )
        #expect(
            viewModel.rows[1] == Row(
                id: 1,
                isON: false,
                betSize: "518",
                coefficient: "3,33",
                income: "41,44"
            )
        )
        #expect(
            viewModel.rows[2] == Row(
                id: 2,
                isON: false,
                betSize: "388,5",
                coefficient: "4,44",
                income: "41,44"
            )
        )
        #expect(viewModel.rows[3] == Row(id: 3))
    }

    // swiftlint:disable:next function_body_length
    @Test
    func calculationMethodWhenSelectedRowIsNoneAndSelectedNumberOfRowsIsFour() {
        // Given
        let viewModel = SurebetCalculatorViewModel(
            total: .init(isON: false),
            rows: [
                .init(id: 0, betSize: "444", coefficient: "2,22"),
                .init(id: 1, betSize: "555", coefficient: "3,33"),
                .init(id: 2, betSize: "666", coefficient: "4,44"),
                .init(id: 3, coefficient: "5,55")
            ],
            selectedNumberOfRows: .four,
            selectedRow: .none
        )

        // When
        viewModel.send(.setTextFieldText(.rowBetSize(3), "777"))

        // Then
        #expect(
            viewModel.total == TotalRow(
                isON: false,
                betSize: "2442",
                profitPercentage: "-13,51%"
            )
        )
        #expect(
            viewModel.rows[0] == Row(
                id: 0,
                isON: false,
                betSize: "444",
                coefficient: "2,22",
                income: "-1456,32"
            )
        )
        #expect(
            viewModel.rows[1] == Row(
                id: 1,
                isON: false,
                betSize: "555",
                coefficient: "3,33",
                income: "-593,85"
            )
        )
        #expect(
            viewModel.rows[2] == Row(
                id: 2,
                isON: false,
                betSize: "666",
                coefficient: "4,44",
                income: "515,04"
            )
        )
        #expect(
            viewModel.rows[3] == Row(
                id: 3,
                isON: false,
                betSize: "777",
                coefficient: "5,55",
                income: "1870,35"
            )
        )
    }

    @Test
    func noneCalculationMethod() {
        // Given
        let viewModel = SurebetCalculatorViewModel(
            rows: [
                .init(id: 0, coefficient: "2,22"),
                .init(id: 1, coefficient: "3,33"),
                .init(id: 2),
                .init(id: 3)
            ]
        )

        // When
        viewModel.send(.setTextFieldText(.totalBetSize, "xxx"))

        // Then
    }

    @Test
    func profitPercentageDoesNotChangeForAllCoefficients() {
        // Given
        let viewModel = SurebetCalculatorViewModel(
            rows: [
                .init(id: 0, coefficient: "2,22"),
                .init(id: 1),
                .init(id: 2),
                .init(id: 3)
            ]
        )

        // When
        viewModel.send(.setTextFieldText(.rowCoefficient(1), "3,33"))

        // Then
        #expect(viewModel.total.profitPercentage == "0%")
    }

    // MARK: - Tests with Mocks

    @Test
    func calculationServiceIsCalledOnSelectRow() {
        // Given
        let mockService = MockCalculationService()
        let viewModel = SurebetCalculatorViewModel(
            calculationService: mockService
        )

        // When
        viewModel.send(.selectRow(.row(0)))

        // Then
        #expect(mockService.calculateCallCount == 1)
        #expect(mockService.calculateInputs.first != nil)
    }

    @Test
    func calculationServiceIsCalledOnSetTextFieldText() {
        // Given
        let mockService = MockCalculationService()
        let viewModel = SurebetCalculatorViewModel(
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
        let viewModel = SurebetCalculatorViewModel(
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
            Row(id: 0, betSize: "500", coefficient: "2", income: "100")
        ]
        mockService.calculateResult = (expectedTotal, expectedRows)
        let viewModel = SurebetCalculatorViewModel(
            calculationService: mockService
        )

        // When
        viewModel.send(.selectRow(.row(0)))

        // Then
        #expect(viewModel.total.betSize == expectedTotal.betSize)
        #expect(viewModel.total.profitPercentage == expectedTotal.profitPercentage)
        #expect(viewModel.rows[0].betSize == expectedRows[0].betSize)
    }
}
