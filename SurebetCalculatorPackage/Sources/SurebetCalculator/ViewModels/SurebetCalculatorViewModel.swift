import Foundation

@MainActor
final class SurebetCalculatorViewModel: ObservableObject {
    // MARK: - Properties

    @Published private(set) var total: TotalRow
    @Published private(set) var rowsById: [RowID: Row]
    @Published private(set) var orderedRowIds: [RowID]
    @Published private(set) var selectedNumberOfRows: NumberOfRows
    @Published private(set) var selection: Selection
    @Published private(set) var focus: FocusableField?

    private let calculationService: CalculationService
    private let analytics: CalculatorAnalytics
    private let delay: CalculationAnalyticsDelay

    /// Задача для debounce аналитики расчёта
    private var calculationAnalyticsTask: Task<Void, Never>?

    // MARK: - Initialization

    init(
        total: TotalRow = TotalRow(),
        rowsById: [RowID: Row]? = nil,
        orderedRowIds: [RowID]? = nil,
        selectedNumberOfRows: NumberOfRows = .two,
        selection: Selection = .total,
        focus: FocusableField? = nil,
        calculationService: CalculationService = DefaultCalculationService(),
        analytics: CalculatorAnalytics = NoopCalculatorAnalytics(),
        delay: CalculationAnalyticsDelay = SystemCalculationAnalyticsDelay()
    ) {
        let resolvedRows: (rowsById: [RowID: Row], orderedRowIds: [RowID])
        if let rowsById, let orderedRowIds {
            resolvedRows = (rowsById: rowsById, orderedRowIds: orderedRowIds)
        } else {
            resolvedRows = Row.createRows(AppConstants.Calculator.maxRowCount)
        }
        let maxRows = min(resolvedRows.orderedRowIds.count, AppConstants.Calculator.maxRowCount)
        let clampedSelected = min(selectedNumberOfRows.rawValue, maxRows)

        self.total = total
        self.rowsById = resolvedRows.rowsById
        self.orderedRowIds = resolvedRows.orderedRowIds
        self.selectedNumberOfRows = NumberOfRows(rawValue: clampedSelected) ?? .two
        self.selection = selection
        self.focus = focus
        self.calculationService = calculationService
        self.analytics = analytics
        self.delay = delay
    }

    // MARK: - Public Methods

    enum ViewAction {
        case selectRow(Selection)
        case addRow
        case removeRow
        case reorderRows(fromOffsets: IndexSet, toOffset: Int)
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
        case let .reorderRows(fromOffsets, toOffset):
            reorderRows(fromOffsets: fromOffsets, toOffset: toOffset)
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
    var activeRowIds: [RowID] {
        Array(orderedRowIds.prefix(selectedNumberOfRows.rawValue))
    }

    /// Проверяет, должно ли поле быть заблокировано
    func isFieldDisabled(_ field: FocusableField) -> Bool {
        switch (selection, field) {
        case (_, .rowCoefficient):
            return false
        case (.none, .rowBetSize):
            return false
        case (.total, .totalBetSize):
            return false
        case let (.row(selectedId), .rowBetSize(currentId)):
            return selectedId != currentId
        default:
            return true
        }
    }

    func displayIndex(for id: RowID) -> Int? {
        activeRowIds.firstIndex(of: id)
    }

    func row(for id: RowID) -> Row? {
        rowsById[id]
    }
}

// MARK: - Private Methods

private extension SurebetCalculatorViewModel {
    var maxRowCount: Int {
        min(orderedRowIds.count, AppConstants.Calculator.maxRowCount)
    }

    func select(_ row: Selection) {
        if selection == row {
            deselectCurrentRow()
            selection = .none
        } else {
            deselectCurrentRow()
            switch row {
            case .total:
                total.isON = true
            case let .row(id):
                if var existingRow = rowsById[id] {
                    existingRow.isON = true
                    rowsById[id] = existingRow
                }
            case .none:
                break
            }
            selection = row
        }
        calculate()
    }

    func addRow() {
        if selectedNumberOfRows.rawValue < maxRowCount {
            selectedNumberOfRows = .init(rawValue: selectedNumberOfRows.rawValue + 1) ?? selectedNumberOfRows
            calculate()
            analytics.calculatorRowAdded(rowCount: selectedNumberOfRows.rawValue)
        }
    }

    func removeRow() {
        if selectedNumberOfRows.rawValue > AppConstants.Calculator.minRowCount {
            selectedNumberOfRows = .init(rawValue: selectedNumberOfRows.rawValue - 1) ?? selectedNumberOfRows
            let inactiveRowIds = orderedRowIds.dropFirst(selectedNumberOfRows.rawValue)
            if case let .row(id) = selection, inactiveRowIds.contains(id) {
                deselectCurrentRow()
                total.isON = true
                selection = .total
            }
            clear(Array(inactiveRowIds))
            calculate()
            analytics.calculatorRowRemoved(rowCount: selectedNumberOfRows.rawValue)
        }
    }

    func reorderRows(fromOffsets: IndexSet, toOffset: Int) {
        var updated = orderedRowIds
        moveRowIds(in: &updated, fromOffsets: fromOffsets, toOffset: toOffset)
        orderedRowIds = updated
        calculate()
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
            if var row = rowsById[id] {
                row.betSize.removeAll()
                rowsById[id] = row
            }
            set(.rowBetSize(id), text: "")
        case let .rowCoefficient(id):
            if var row = rowsById[id] {
                row.coefficient.removeAll()
                rowsById[id] = row
            }
        case .none:
            break
        }
    }

    func clearAll() {
        clearTotal()
        clear(orderedRowIds)
        analytics.calculatorCleared()
    }

    func hideKeyboard() {
        focus = .none
    }
}

private extension SurebetCalculatorViewModel {
    func setTotalBetSize(text: String) {
        if total.betSize != text, selection != .total {
            select(.total)
        }
        total.betSize = text
        if text.isEmpty {
            for id in activeRowIds {
                if var row = rowsById[id] {
                    row.betSize.removeAll()
                    rowsById[id] = row
                }
            }
        }
    }

    func setRowBetSize(id: RowID, text: String) {
        if var row = rowsById[id] {
            row.betSize = text
            rowsById[id] = row
        }
        if text.isEmpty, selection != .none {
            let rowIds = Array(rowsById.keys)
            for rowId in rowIds {
                if var row = rowsById[rowId] {
                    row.betSize.removeAll()
                    rowsById[rowId] = row
                }
            }
            total.betSize.removeAll()
        } else if selection == .none {
            setTotalFromBetSizes()
        }
    }

    func setTotalFromBetSizes() {
        let sumOfBetSizes = activeRowIds
            .compactMap { rowsById[$0]?.betSize.formatToDouble() }
            .reduce(0) { $0 + $1 }
        total.betSize = sumOfBetSizes == 0 ? "" : sumOfBetSizes.formatToString()
    }

    func setRowCoefficient(id: RowID, text: String) {
        if var row = rowsById[id] {
            row.coefficient = text
            rowsById[id] = row
        }
    }

    func deselectCurrentRow() {
        switch selection {
        case .total:
            total.isON = false
        case let .row(id):
            if var row = rowsById[id] {
                row.isON = false
                rowsById[id] = row
            }
        case .none:
            break
        }
    }

    func clearTotal() {
        total.betSize.removeAll()
        total.profitPercentage = "0%"
    }

    func clear(_ rowIds: [RowID]) {
        for id in rowIds {
            if var row = rowsById[id] {
                row.betSize.removeAll()
                row.coefficient.removeAll()
                row.income = "0"
                rowsById[id] = row
            }
        }
    }

    func moveRowIds(in rowIds: inout [RowID], fromOffsets: IndexSet, toOffset: Int) {
        let moving = fromOffsets.map { rowIds[$0] }
        for index in fromOffsets.sorted(by: >) {
            rowIds.remove(at: index)
        }
        let adjustedOffset = toOffset - fromOffsets.filter { $0 < toOffset }.count
        rowIds.insert(contentsOf: moving, at: adjustedOffset)
    }

    func calculate() {
        let result = calculationService.calculate(
            input: CalculationInput(
                total: total,
                rowsById: rowsById,
                orderedRowIds: orderedRowIds,
                activeRowIds: activeRowIds,
                selection: selection
            )
        )

        switch result {
        case let .updated(output), let .resetDerived(output):
            total = output.total
            rowsById = output.rowsById
        case .noOp, .invalidInput:
            break
        }

        logCalculationPerformedDebounced()
    }

    // MARK: - Analytics

    /// Логирует событие расчёта с debounce, чтобы не спамить при каждом нажатии клавиши
    func logCalculationPerformedDebounced() {
        calculationAnalyticsTask?.cancel()
        calculationAnalyticsTask = Task {
            await delay.sleep(nanoseconds: AppConstants.Delays.calculationAnalytics)
            guard !Task.isCancelled else { return }

            let profitPercentage = total.profitPercentage
                .replacingOccurrences(of: "%", with: "")
                .formatToDouble() ?? 0

            analytics.calculationPerformed(
                rowCount: selectedNumberOfRows.rawValue,
                profitPercentage: profitPercentage
            )
        }
    }
}
