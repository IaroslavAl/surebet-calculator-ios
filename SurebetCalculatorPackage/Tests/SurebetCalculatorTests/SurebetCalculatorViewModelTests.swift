@testable import AnalyticsManager
@testable import SurebetCalculator
import Testing

// swiftlint:disable file_length
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
        let expectedTotal = TotalRow(isON: false, betSize: "2442", profitPercentage: "-13,51%")
        #expect(viewModel.total == expectedTotal)

        let expectedRow0 = Row(id: 0, isON: false, betSize: "444", coefficient: "2,22", income: "-1456,32")
        #expect(viewModel.rows[0] == expectedRow0)

        let expectedRow1 = Row(id: 1, isON: false, betSize: "555", coefficient: "3,33", income: "-593,85")
        #expect(viewModel.rows[1] == expectedRow1)

        let expectedRow2 = Row(id: 2, isON: false, betSize: "666", coefficient: "4,44", income: "515,04")
        #expect(viewModel.rows[2] == expectedRow2)

        let expectedRow3 = Row(id: 3, isON: false, betSize: "777", coefficient: "5,55", income: "1870,35")
        #expect(viewModel.rows[3] == expectedRow3)
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

    // MARK: - addRow Tests

    @Test
    func addRowWhenNumberOfRowsIsLessThanTen() {
        // Given
        let viewModel = SurebetCalculatorViewModel(
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
        let viewModel = SurebetCalculatorViewModel(
            selectedNumberOfRows: .ten
        )

        // When
        viewModel.send(.addRow)

        // Then
        // Не должно добавляться, если уже 10 строк
        #expect(viewModel.selectedNumberOfRows == .ten)
    }

    @Test
    func addRowWhenNumberOfRowsIsNine() {
        // Given
        let viewModel = SurebetCalculatorViewModel(
            selectedNumberOfRows: .nine
        )

        // When
        viewModel.send(.addRow)

        // Then
        #expect(viewModel.selectedNumberOfRows == .ten)
    }

    @Test
    func addRowMultipleTimes() {
        // Given
        let viewModel = SurebetCalculatorViewModel(
            selectedNumberOfRows: .two
        )

        // When
        viewModel.send(.addRow)
        viewModel.send(.addRow)
        viewModel.send(.addRow)

        // Then
        #expect(viewModel.selectedNumberOfRows == .five)
    }

    // MARK: - removeRow Tests

    @Test
    func removeRowWhenNumberOfRowsIsGreaterThanTwo() {
        // Given
        let viewModel = SurebetCalculatorViewModel(
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
        let viewModel = SurebetCalculatorViewModel(
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
        let viewModel = SurebetCalculatorViewModel(
            rows: [
                .init(id: 0),
                .init(id: 1),
                .init(id: 2, isON: true, betSize: "777"),
                .init(id: 3)
            ],
            selectedNumberOfRows: .three,
            selectedRow: .row(id)
        )

        // When
        viewModel.send(.removeRow)

        // Then
        // Строка должна быть снята с выбора, так как она теперь вне отображаемого диапазона
        // Примечание: deselectCurrentRow() только снимает isON, но не меняет selectedRow
        #expect(!viewModel.rows[id].isON)
        #expect(viewModel.selectedNumberOfRows == .two)
    }

    @Test
    func removeRowWhenUndisplayedRowContainsData() {
        // Given
        let id = 2
        let viewModel = SurebetCalculatorViewModel(
            rows: [
                .init(id: 0),
                .init(id: 1),
                .init(id: 2, betSize: "777", coefficient: "2,22"),
                .init(id: 3)
            ],
            selectedNumberOfRows: .three
        )

        // When
        viewModel.send(.removeRow)

        // Then
        // Данные в неотображаемой строке должны быть очищены
        #expect(viewModel.rows[id].betSize == "")
        #expect(viewModel.rows[id].coefficient == "")
        #expect(viewModel.rows[id].income == "0")
        #expect(viewModel.selectedNumberOfRows == .two)
    }

    @Test
    func removeRowCallsCalculate() {
        // Given
        let mockService = MockCalculationService()
        let viewModel = SurebetCalculatorViewModel(
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
        let viewModel = SurebetCalculatorViewModel(
            rows: [
                .init(id: 0, isON: true),
                .init(id: 1),
                .init(id: 2),
                .init(id: 3)
            ],
            selectedNumberOfRows: .three,
            selectedRow: .row(0)
        )

        // When
        viewModel.send(.removeRow)

        // Then
        // Выбранная строка остается выбранной, так как она в отображаемом диапазоне
        #expect(viewModel.rows[0].isON)
        #expect(viewModel.selectedRow == .row(0))
        #expect(viewModel.selectedNumberOfRows == .two)
    }

    // MARK: - Concurrency Tests

    @Test
    func mainActorIsolation() async {
        // Given
        let viewModel = SurebetCalculatorViewModel()

        // When & Then
        // Проверяем, что методы ViewModel выполняются на MainActor
        await MainActor.run {
            viewModel.send(.selectRow(.row(0)))
            #expect(viewModel.selectedRow == .row(0))
        }

        // Проверяем доступ к @Published свойствам из MainActor контекста
        await MainActor.run {
            _ = viewModel.total
            _ = viewModel.rows
            _ = viewModel.selectedNumberOfRows
            _ = viewModel.selectedRow
            _ = viewModel.focus
        }
    }

    @Test
    func concurrentSendCalls() async {
        // Given
        let viewModel = SurebetCalculatorViewModel()
        let iterations = 100

        // When
        // Выполняем множество параллельных вызовов send()
        await withTaskGroup(of: Void.self) { group in
            for index in 0..<iterations {
                group.addTask {
                    await MainActor.run {
                        viewModel.send(.setTextFieldText(.rowCoefficient(index % 4), "\(index)"))
                    }
                }
            }
        }

        // Then
        // Проверяем, что состояние корректно (не должно быть крашей)
        // Все строки должны иметь валидные значения коэффициентов
        await MainActor.run {
            for index in 0..<4 {
                let coefficient = viewModel.rows[index].coefficient
                // Коэффициент должен быть либо пустым, либо валидным числом
                #expect(coefficient.isEmpty || Double(coefficient.replacingOccurrences(of: ",", with: ".")) != nil)
            }
        }
    }

    @Test
    func concurrentAddAndRemoveRow() async {
        // Given
        let viewModel = SurebetCalculatorViewModel(selectedNumberOfRows: .five)
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
            #expect(viewModel.selectedNumberOfRows.rawValue <= 10)
        }
    }

    @Test
    func concurrentSelectRow() async {
        // Given
        let viewModel = SurebetCalculatorViewModel()
        let rowTypes: [RowType] = [.total, .row(0), .row(1), .row(2), .row(3)]

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
        // Проверяем, что состояние корректно (selectedRow должен быть одним из валидных значений или nil)
        await MainActor.run {
            if let selected = viewModel.selectedRow {
                #expect(rowTypes.contains(selected))
            }
        }
    }

    @Test
    func publishedPropertiesUpdateOnMainActor() async {
        // Given
        let viewModel = SurebetCalculatorViewModel()

        // When
        await MainActor.run {
            viewModel.send(.setTextFieldText(.totalBetSize, "1000"))
            viewModel.send(.selectRow(.row(0)))
        }

        // Then
        // Проверяем, что @Published свойства обновились корректно
        await MainActor.run {
            #expect(viewModel.total.betSize == "1000")
            #expect(viewModel.selectedRow == .row(0))
            #expect(viewModel.rows[0].isON)
        }
    }

    @Test
    func rapidSequentialActions() async {
        // Given
        let viewModel = SurebetCalculatorViewModel()

        // When
        // Быстрые последовательные вызовы без задержек
        await MainActor.run {
            for index in 0..<10 {
                viewModel.send(.setTextFieldText(.rowCoefficient(index % 4), "\(index + 1)"))
                viewModel.send(.setTextFieldText(.rowBetSize(index % 4), "\(index * 100)"))
            }
            viewModel.send(.selectRow(.total))
            viewModel.send(.setTextFieldText(.totalBetSize, "5000"))
        }

        // Then
        // Проверяем, что финальное состояние корректно
        await MainActor.run {
            #expect(viewModel.total.betSize == "5000")
            #expect(viewModel.selectedRow == .total)
            #expect(viewModel.total.isON)
        }
    }

    // MARK: - Analytics Tests

    /// Тест события calculator_row_added при добавлении строки
    @Test
    func analyticsWhenCalculatorRowAdded() {
        // Given
        let mockAnalytics = MockAnalyticsService()
        let viewModel = SurebetCalculatorViewModel(
            selectedNumberOfRows: .two,
            analyticsService: mockAnalytics
        )

        // When
        viewModel.send(.addRow)

        // Then
        #expect(mockAnalytics.logEventCallCount >= 1)
        #expect(mockAnalytics.logEventCalls.contains { event in
            if case .calculatorRowAdded(let rowCount) = event {
                return rowCount == 3
            }
            return false
        })
    }

    /// Тест параметров события calculator_row_added
    @Test
    func analyticsWhenCalculatorRowAddedParameters() {
        // Given
        let mockAnalytics = MockAnalyticsService()
        let viewModel = SurebetCalculatorViewModel(
            selectedNumberOfRows: .two,
            analyticsService: mockAnalytics
        )

        // When
        viewModel.send(.addRow)

        // Then
        let addedEvents = mockAnalytics.logEventCalls.compactMap { event -> Int? in
            if case .calculatorRowAdded(let rowCount) = event {
                return rowCount
            }
            return nil
        }
        #expect(addedEvents.contains(3))
    }

    /// Тест события calculator_row_added не вызывается при максимальном количестве строк
    @Test
    func analyticsWhenCalculatorRowAddedNotCalledAtMax() {
        // Given
        let mockAnalytics = MockAnalyticsService()
        let viewModel = SurebetCalculatorViewModel(
            selectedNumberOfRows: .ten,
            analyticsService: mockAnalytics
        )
        let initialCallCount = mockAnalytics.logEventCallCount

        // When
        viewModel.send(.addRow)

        // Then
        // Не должно быть новых вызовов, так как уже максимальное количество строк
        #expect(mockAnalytics.logEventCallCount == initialCallCount)
    }

    /// Тест события calculator_row_removed при удалении строки
    @Test
    func analyticsWhenCalculatorRowRemoved() {
        // Given
        let mockAnalytics = MockAnalyticsService()
        let viewModel = SurebetCalculatorViewModel(
            selectedNumberOfRows: .three,
            analyticsService: mockAnalytics
        )

        // When
        viewModel.send(.removeRow)

        // Then
        #expect(mockAnalytics.logEventCallCount >= 1)
        #expect(mockAnalytics.logEventCalls.contains { event in
            if case .calculatorRowRemoved(let rowCount) = event {
                return rowCount == 2
            }
            return false
        })
    }

    /// Тест параметров события calculator_row_removed
    @Test
    func analyticsWhenCalculatorRowRemovedParameters() {
        // Given
        let mockAnalytics = MockAnalyticsService()
        let viewModel = SurebetCalculatorViewModel(
            selectedNumberOfRows: .three,
            analyticsService: mockAnalytics
        )

        // When
        viewModel.send(.removeRow)

        // Then
        let removedEvents = mockAnalytics.logEventCalls.compactMap { event -> Int? in
            if case .calculatorRowRemoved(let rowCount) = event {
                return rowCount
            }
            return nil
        }
        #expect(removedEvents.contains(2))
    }

    /// Тест события calculator_row_removed не вызывается при минимальном количестве строк
    @Test
    func analyticsWhenCalculatorRowRemovedNotCalledAtMin() {
        // Given
        let mockAnalytics = MockAnalyticsService()
        let viewModel = SurebetCalculatorViewModel(
            selectedNumberOfRows: .two,
            analyticsService: mockAnalytics
        )
        let initialCallCount = mockAnalytics.logEventCallCount

        // When
        viewModel.send(.removeRow)

        // Then
        // Не должно быть новых вызовов, так как уже минимальное количество строк
        #expect(mockAnalytics.logEventCallCount == initialCallCount)
    }

    /// Тест события calculator_cleared при очистке
    @Test
    func analyticsWhenCalculatorCleared() {
        // Given
        let mockAnalytics = MockAnalyticsService()
        let viewModel = SurebetCalculatorViewModel(
            total: .init(betSize: "777", profitPercentage: "10%"),
            rows: [
                .init(id: 0, betSize: "100", coefficient: "2.0"),
                .init(id: 1),
                .init(id: 2),
                .init(id: 3)
            ],
            analyticsService: mockAnalytics
        )
        let initialCallCount = mockAnalytics.logEventCallCount

        // When
        viewModel.send(.clearAll)

        // Then
        #expect(mockAnalytics.logEventCallCount > initialCallCount)
        #expect(mockAnalytics.logEventCalls.contains { event in
            if case .calculatorCleared = event {
                return true
            }
            return false
        })
    }

    /// Тест события calculation_performed с debounce
    @Test
    func analyticsWhenCalculationPerformed() async {
        // Given
        let mockAnalytics = MockAnalyticsService()
        let viewModel = SurebetCalculatorViewModel(
            rows: [
                .init(id: 0, coefficient: "2.0"),
                .init(id: 1, coefficient: "3.0"),
                .init(id: 2),
                .init(id: 3)
            ],
            analyticsService: mockAnalytics
        )

        // When
        viewModel.send(.setTextFieldText(.totalBetSize, "100"))
        // Ждём debounce время + небольшой запас (1 секунда + 0.5 секунды запас)
        try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 секунды

        // Then
        #expect(mockAnalytics.logEventCallCount >= 1)
        #expect(mockAnalytics.logEventCalls.contains { event in
            if case .calculationPerformed(let rowCount, _) = event {
                return rowCount == 2
            }
            return false
        })
    }

    /// Тест параметров события calculation_performed
    @Test
    func analyticsWhenCalculationPerformedParameters() async {
        // Given
        let mockAnalytics = MockAnalyticsService()
        let viewModel = SurebetCalculatorViewModel(
            rows: [
                .init(id: 0, coefficient: "2.0"),
                .init(id: 1, coefficient: "3.0"),
                .init(id: 2),
                .init(id: 3)
            ],
            analyticsService: mockAnalytics
        )

        // When
        viewModel.send(.setTextFieldText(.totalBetSize, "100"))
        // Ждём debounce время + небольшой запас (1 секунда + 0.5 секунды запас)
        try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 секунды

        // Then
        let calculationEvents = mockAnalytics.logEventCalls.compactMap { event -> (Int, Double)? in
            if case .calculationPerformed(let rowCount, let profitPercentage) = event {
                return (rowCount, profitPercentage)
            }
            return nil
        }
        #expect(!calculationEvents.isEmpty)
        if let event = calculationEvents.first {
            #expect(event.0 == 2) // rowCount
            #expect(event.1 >= 0) // profitPercentage должен быть неотрицательным для валидных коэффициентов
        }
    }

    /// Тест debounce для calculation_performed - должно быть только одно событие при быстрых изменениях
    @Test
    func analyticsWhenCalculationPerformedDebounce() async {
        // Given
        let mockAnalytics = MockAnalyticsService()
        let viewModel = SurebetCalculatorViewModel(
            rows: [
                .init(id: 0, coefficient: "2.0"),
                .init(id: 1, coefficient: "3.0"),
                .init(id: 2),
                .init(id: 3)
            ],
            analyticsService: mockAnalytics
        )

        // When
        // Быстро меняем значения несколько раз
        viewModel.send(.setTextFieldText(.totalBetSize, "100"))
        viewModel.send(.setTextFieldText(.totalBetSize, "200"))
        viewModel.send(.setTextFieldText(.totalBetSize, "300"))
        // Ждём debounce время + небольшой запас (1 секунда + 0.5 секунды запас)
        try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 секунды

        // Then
        // Должно быть только одно событие calculation_performed из-за debounce
        let calculationEvents = mockAnalytics.logEventCalls.filter { event in
            if case .calculationPerformed = event {
                return true
            }
            return false
        }
        #expect(calculationEvents.count == 1)
    }
}
