import Foundation

@MainActor
final class SurebetCalculatorViewModel: ObservableObject {
    // MARK: - Properties

    @Published private(set) var total: TotalRow
    @Published private(set) var rows: [Row]
    @Published private(set) var selectedNumberOfRows: NumberOfRows
    @Published private(set) var selectedRow: RowType?
    @Published private(set) var focus: FocusableField?

    private let calculationService: CalculationService

    // MARK: - Initialization

    init(
        total: TotalRow = TotalRow(),
        rows: [Row] = Row.createRows(),
        selectedNumberOfRows: NumberOfRows = .two,
        selectedRow: RowType? = .total,
        focus: FocusableField? = nil,
        calculationService: CalculationService = DefaultCalculationService()
    ) {
        self.total = total
        self.rows = rows
        self.selectedNumberOfRows = selectedNumberOfRows
        self.selectedRow = selectedRow
        self.focus = focus
        self.calculationService = calculationService
    }

    // MARK: - Public Methods

    enum ViewAction {
        case selectRow(RowType)
        case addRow
        case removeRow
        case setTextFieldText(FocusableField, String)
        case setFocus(FocusableField?)
        case clearFocusableField
        case clearAll
        case hideKeyboard
    }

    func send(_ action: ViewAction) {
        switch action {
        case let .selectRow(row):
            select(row)
        case .addRow:
            addRow()
        case .removeRow:
            removeRow()
        case let .setTextFieldText(field, text):
            set(field, text: text)
        case let .setFocus(focus):
            set(focus)
        case .clearFocusableField:
            clearFocusableField()
        case .clearAll:
            clearAll()
        case .hideKeyboard:
            hideKeyboard()
        }
    }
}

// MARK: - Public Extensions

extension SurebetCalculatorViewModel {
    var displayedRowIndexes: Range<Int> {
        0..<selectedNumberOfRows.rawValue
    }

    /// Проверяет, должно ли поле быть заблокировано
    func isFieldDisabled(_ field: FocusableField) -> Bool {
        switch (selectedRow, field) {
        case (_, .rowCoefficient):
            return false
        case (.none, .rowBetSize):
            return false
        case (.total, .totalBetSize):
            return false
        case let (.row(selectedId), .rowBetSize(currentId)):
            if selectedId == currentId {
                return false
            }
            return true
        default:
            return true
        }
    }
}

// MARK: - Private Methods

private extension SurebetCalculatorViewModel {
    func select(_ row: RowType) {
        if selectedRow == row {
            deselectCurrentRow()
            selectedRow = nil
        } else {
            deselectCurrentRow()
            switch row {
            case .total:
                total.isON = true
            case let .row(id):
                rows[id].isON = true
            }
            selectedRow = row
        }
        calculate()
    }

    func addRow() {
        if selectedNumberOfRows != .ten {
            selectedNumberOfRows = .init(rawValue: selectedNumberOfRows.rawValue + 1) ?? .two
        }
    }

    func removeRow() {
        if selectedNumberOfRows != .two {
            selectedNumberOfRows = .init(rawValue: selectedNumberOfRows.rawValue - 1) ?? .two
            let indexesOfUndisplayedRows = selectedNumberOfRows.rawValue..<rows.count
            if rows[indexesOfUndisplayedRows].contains(where: \.isON) {
                deselectCurrentRow()
            }
            clear(indexesOfUndisplayedRows)
            calculate()
        }
    }

    func set(_ textField: FocusableField, text: String) {
        switch textField {
        case .totalBetSize:
            setTotalBetSize(text: text)
        case let .rowBetSize(id):
            setRowBetSize(id: id, text: text)
        case let .rowCoefficient(id):
            setRowCoefficient(id: id, text: text)
        }
        calculate()
    }

    func set(_ focus: FocusableField?) {
        self.focus = focus
    }

    func clearFocusableField() {
        switch focus {
        case .totalBetSize:
            total.betSize.removeAll()
            set(.totalBetSize, text: "")
        case let .rowBetSize(id):
            rows[id].betSize.removeAll()
            set(.rowBetSize(id), text: "")
        case let .rowCoefficient(id):
            rows[id].coefficient.removeAll()
        case .none:
            break
        }
    }

    func clearAll() {
        clearTotal()
        clear(rows.indices)
    }

    func hideKeyboard() {
        focus = .none
    }
}

private extension SurebetCalculatorViewModel {
    func setTotalBetSize(text: String) {
        if total.betSize != text, selectedRow != .total {
            select(.total)
        }
        total.betSize = text
        if text.isEmpty {
            displayedRowIndexes.forEach {
                rows[$0].betSize.removeAll()
            }
        }
    }

    func setRowBetSize(id: Int, text: String) {
        rows[id].betSize = text
        if text.isEmpty, selectedRow != .none {
            rows.map(\.id).forEach {
                rows[$0].betSize.removeAll()
            }
            total.betSize.removeAll()
        } else if selectedRow == .none {
            setTotalFromBetSizes()
        }
    }

    func setTotalFromBetSizes() {
        let sumOfBetSizes = rows[displayedRowIndexes]
            .compactMap { $0.betSize.formatToDouble() }
            .reduce(0) { $0 + $1 }
        total.betSize = sumOfBetSizes == 0 ? "" : sumOfBetSizes.formatToString()
    }

    func setRowCoefficient(id: Int, text: String) {
        rows[id].coefficient = text
    }

    func deselectCurrentRow() {
        switch selectedRow {
        case .total:
            total.isON = false
        case let .row(number):
            rows[number].isON = false
        case .none:
            break
        }
    }

    func clearTotal() {
        total.betSize.removeAll()
        total.profitPercentage = "0%"
    }

    func clear(_ rowsRange: Range<Int>) {
        rowsRange.forEach {
            rows[$0].betSize.removeAll()
            rows[$0].coefficient.removeAll()
            rows[$0].income = "0"
        }
    }

    func calculate() {
        let (updatedTotal, updatedRows) = calculationService.calculate(
            total: total,
            rows: rows,
            selectedRow: selectedRow,
            displayedRowIndexes: displayedRowIndexes
        )
        total = updatedTotal ?? total
        rows = updatedRows ?? rows
    }
}
