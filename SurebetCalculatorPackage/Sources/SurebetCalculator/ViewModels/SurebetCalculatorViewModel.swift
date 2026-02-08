import Foundation

@MainActor
final class SurebetCalculatorViewModel: ObservableObject {
    // MARK: - Properties

    private(set) var total: TotalRow
    private(set) var rowsById: [RowID: Row]
    private(set) var orderedRowIds: [RowID]
    private(set) var selectedNumberOfRows: NumberOfRows
    private(set) var selection: Selection
    @Published private(set) var focus: FocusableField?

    @Published private(set) var activeRowViewModels: [RowItemViewModel]
    let totalRowViewModel: TotalRowItemViewModel
    let outcomeCountViewModel: OutcomeCountViewModel

    private var rowViewModelsById: [RowID: RowItemViewModel]

    private let calculationService: CalculationService
    private let analytics: CalculatorAnalytics
    private let delay: CalculationAnalyticsDelay

    /// Задача для debounce аналитики расчета
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
            resolvedRows = Self.normalizedRows(
                rowsById: rowsById,
                orderedRowIds: orderedRowIds
            )
        } else {
            resolvedRows = Row.createRows(CalculatorConstants.maxRowCount)
        }

        let maxRows = min(resolvedRows.orderedRowIds.count, CalculatorConstants.maxRowCount)
        let clampedSelected = min(selectedNumberOfRows.rawValue, maxRows)
        let normalizedSelectedNumber = NumberOfRows(rawValue: clampedSelected) ?? .two

        self.total = total
        self.rowsById = resolvedRows.rowsById
        self.orderedRowIds = resolvedRows.orderedRowIds
        self.selectedNumberOfRows = normalizedSelectedNumber
        self.selection = selection
        self.focus = focus
        self.calculationService = calculationService
        self.analytics = analytics
        self.delay = delay

        let initialRowViewModels = resolvedRows.orderedRowIds.map { id in
            RowItemViewModel(
                id: id,
                state: RowItemState(
                    id: id,
                    displayIndex: 0,
                    isSelected: false,
                    isOn: false,
                    coefficient: "",
                    betSize: "",
                    income: "0",
                    isBetSizeDisabled: true
                )
            )
        }
        self.rowViewModelsById = Dictionary(
            initialRowViewModels.map { ($0.id, $0) },
            uniquingKeysWith: { existing, _ in existing }
        )
        self.activeRowViewModels = Array(initialRowViewModels.prefix(normalizedSelectedNumber.rawValue))

        self.totalRowViewModel = TotalRowItemViewModel(
            state: TotalRowItemState(
                isSelected: false,
                isOn: total.isON,
                betSize: total.betSize,
                profitPercentage: total.profitPercentage,
                isBetSizeDisabled: true
            )
        )
        self.outcomeCountViewModel = OutcomeCountViewModel(
            state: OutcomeCountState(
                selectedNumberOfRows: normalizedSelectedNumber,
                minRowCount: CalculatorConstants.minRowCount,
                maxRowCount: maxRows
            )
        )

        synchronizePresentation(from: nil)
    }

    // MARK: - Public Methods

    enum ViewAction {
        case selectRow(Selection)
        case addRow
        case removeRow
        case setNumberOfRows(NumberOfRows)
        case reorderRows(fromOffsets: IndexSet, toOffset: Int)
        case setTextFieldText(FocusableField, String)
        case setFocus(FocusableField?)
        case clearFocusableField
        case clearAll
        case hideKeyboard
    }

    func send(_ action: ViewAction) {
        let previousSnapshot = makeSnapshot()

        switch action {
        case let .selectRow(row):
            select(row)
        case .addRow:
            addRow()
        case .removeRow:
            removeRow()
        case let .setNumberOfRows(numberOfRows):
            setNumberOfRows(numberOfRows)
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

        synchronizePresentation(from: previousSnapshot)
    }
}

// MARK: - Initialization Helpers

private extension SurebetCalculatorViewModel {
    static func normalizedRows(
        rowsById: [RowID: Row],
        orderedRowIds: [RowID]
    ) -> (rowsById: [RowID: Row], orderedRowIds: [RowID]) {
        var seenRowIDs = Set<RowID>()
        var normalizedOrderedRowIDs: [RowID] = []
        normalizedOrderedRowIDs.reserveCapacity(rowsById.count)

        for id in orderedRowIds where rowsById[id] != nil {
            guard seenRowIDs.insert(id).inserted else { continue }
            normalizedOrderedRowIDs.append(id)
        }

        let missingRowIDs = rowsById.keys
            .sorted(by: { $0.rawValue < $1.rawValue })
            .filter { seenRowIDs.insert($0).inserted }
        normalizedOrderedRowIDs.append(contentsOf: missingRowIDs)

        return (rowsById: rowsById, orderedRowIds: normalizedOrderedRowIDs)
    }
}

// MARK: - Public Extensions

extension SurebetCalculatorViewModel {
    var activeRowIds: [RowID] {
        Array(orderedRowIds.prefix(selectedNumberOfRows.rawValue))
    }

    var availableRowCounts: [NumberOfRows] {
        let maxCount = min(orderedRowIds.count, CalculatorConstants.maxRowCount)
        return NumberOfRows.allCases.filter { count in
            count.rawValue >= CalculatorConstants.minRowCount && count.rawValue <= maxCount
        }
    }

    var activeRowViewModelIDs: [RowID] {
        activeRowViewModels.map(\.id)
    }

    /// Проверяет, должно ли поле быть заблокировано.
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

// MARK: - Snapshot

private extension SurebetCalculatorViewModel {
    struct Snapshot {
        let total: TotalRow
        let rowsById: [RowID: Row]
        let orderedRowIds: [RowID]
        let selectedNumberOfRows: NumberOfRows
        let selection: Selection
        let activeRowIds: [RowID]
    }

    func makeSnapshot() -> Snapshot {
        Snapshot(
            total: total,
            rowsById: rowsById,
            orderedRowIds: orderedRowIds,
            selectedNumberOfRows: selectedNumberOfRows,
            selection: selection,
            activeRowIds: activeRowIds
        )
    }
}

// MARK: - Presentation Sync

private extension SurebetCalculatorViewModel {
    func synchronizePresentation(from previousSnapshot: Snapshot?) {
        synchronizeActiveRowViewModels()
        outcomeCountViewModel.apply(makeOutcomeCountState())
        totalRowViewModel.apply(makeTotalRowItemState())

        let rowIDsToRefresh = changedRowIDs(previousSnapshot: previousSnapshot)
        for id in rowIDsToRefresh {
            guard let rowViewModel = rowViewModelsById[id] else { continue }
            rowViewModel.apply(makeRowItemState(for: id))
        }
    }

    func synchronizeActiveRowViewModels() {
        let desired = activeRowIds.compactMap { rowViewModelsById[$0] }
        guard desired.map(\.id) != activeRowViewModels.map(\.id) else { return }
        activeRowViewModels = desired
    }

    func changedRowIDs(previousSnapshot: Snapshot?) -> Set<RowID> {
        guard let previousSnapshot else {
            return Set(orderedRowIds)
        }

        var ids = Set<RowID>()

        if previousSnapshot.selection != selection {
            ids.formUnion(previousSnapshot.activeRowIds)
            ids.formUnion(activeRowIds)

            if case let .row(id) = previousSnapshot.selection {
                ids.insert(id)
            }
            if case let .row(id) = selection {
                ids.insert(id)
            }
        }

        if previousSnapshot.selectedNumberOfRows != selectedNumberOfRows ||
            previousSnapshot.orderedRowIds != orderedRowIds {
            ids.formUnion(previousSnapshot.activeRowIds)
            ids.formUnion(activeRowIds)
        }

        let allKnownIDs = Set(previousSnapshot.rowsById.keys).union(rowsById.keys)
        for id in allKnownIDs where previousSnapshot.rowsById[id] != rowsById[id] {
            ids.insert(id)
        }

        return ids
    }

    func makeRowItemState(for id: RowID) -> RowItemState {
        let row = rowsById[id] ?? Row(id: id)

        let displayIndex = activeRowIds.firstIndex(of: id)
            ?? orderedRowIds.firstIndex(of: id)
            ?? 0

        let isSelected: Bool
        switch selection {
        case let .row(selectedID):
            isSelected = selectedID == id
        default:
            isSelected = false
        }

        return RowItemState(
            id: id,
            displayIndex: displayIndex,
            isSelected: isSelected,
            isOn: row.isON,
            coefficient: row.coefficient,
            betSize: row.betSize,
            income: row.income,
            isBetSizeDisabled: isFieldDisabled(.rowBetSize(id))
        )
    }

    func makeTotalRowItemState() -> TotalRowItemState {
        TotalRowItemState(
            isSelected: selection == .total,
            isOn: total.isON,
            betSize: total.betSize,
            profitPercentage: total.profitPercentage,
            isBetSizeDisabled: isFieldDisabled(.totalBetSize)
        )
    }

    func makeOutcomeCountState() -> OutcomeCountState {
        OutcomeCountState(
            selectedNumberOfRows: selectedNumberOfRows,
            minRowCount: CalculatorConstants.minRowCount,
            maxRowCount: maxRowCount
        )
    }
}

// MARK: - Private Methods

private extension SurebetCalculatorViewModel {
    var maxRowCount: Int {
        min(orderedRowIds.count, CalculatorConstants.maxRowCount)
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
        normalizeFocusForCurrentStateIfNeeded()
        calculate()
    }

    func addRow() {
        guard selectedNumberOfRows.rawValue < maxRowCount else { return }
        let updated = NumberOfRows(rawValue: selectedNumberOfRows.rawValue + 1) ?? selectedNumberOfRows
        setNumberOfRows(updated)
    }

    func removeRow() {
        guard selectedNumberOfRows.rawValue > CalculatorConstants.minRowCount else { return }
        let updated = NumberOfRows(rawValue: selectedNumberOfRows.rawValue - 1) ?? selectedNumberOfRows
        setNumberOfRows(updated)
    }

    func setNumberOfRows(_ numberOfRows: NumberOfRows) {
        let clampedRaw = min(numberOfRows.rawValue, maxRowCount)
        let clamped = NumberOfRows(
            rawValue: max(clampedRaw, CalculatorConstants.minRowCount)
        ) ?? selectedNumberOfRows
        guard clamped != selectedNumberOfRows else { return }

        let previous = selectedNumberOfRows
        selectedNumberOfRows = clamped

        if clamped.rawValue < previous.rawValue {
            let inactiveRowIDs = orderedRowIds.dropFirst(clamped.rawValue)
            if case let .row(id) = selection, inactiveRowIDs.contains(id) {
                deselectCurrentRow()
                total.isON = true
                selection = .total
            }
            clear(Array(inactiveRowIDs))
        }

        normalizeFocusForCurrentStateIfNeeded()
        calculate()

        if clamped.rawValue > previous.rawValue {
            analytics.calculatorRowAdded(rowCount: clamped.rawValue)
        } else {
            analytics.calculatorRowRemoved(rowCount: clamped.rawValue)
        }
    }

    func reorderRows(fromOffsets: IndexSet, toOffset: Int) {
        var updated = orderedRowIds
        moveRowIds(in: &updated, fromOffsets: fromOffsets, toOffset: toOffset)
        orderedRowIds = updated
        calculate()
    }

    func set(_ textField: FocusableField, text: String) {
        let didMutate: Bool
        switch textField {
        case .totalBetSize:
            didMutate = setTotalBetSize(text: text)
        case let .rowBetSize(id):
            didMutate = setRowBetSize(id: id, text: text)
        case let .rowCoefficient(id):
            didMutate = setRowCoefficient(id: id, text: text)
        }
        guard didMutate else { return }
        calculate()
    }

    func set(_ focus: FocusableField?) {
        guard self.focus != focus else { return }
        self.focus = focus
    }

    func clearFocusableField() {
        switch focus {
        case .totalBetSize:
            set(.totalBetSize, text: "")
        case let .rowBetSize(id):
            set(.rowBetSize(id), text: "")
        case let .rowCoefficient(id):
            set(.rowCoefficient(id), text: "")
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
    @discardableResult
    func setTotalBetSize(text: String) -> Bool {
        var didMutate = false

        if total.betSize != text, selection != .total {
            deselectCurrentRow()
            total.isON = true
            selection = .total
            didMutate = true
        }

        if total.betSize != text {
            total.betSize = text
            didMutate = true
        }

        guard text.isEmpty else { return didMutate }
        for id in activeRowIds {
            guard var row = rowsById[id], !row.betSize.isEmpty else { continue }
            row.betSize.removeAll()
            rowsById[id] = row
            didMutate = true
        }

        return didMutate
    }

    @discardableResult
    func setRowBetSize(id: RowID, text: String) -> Bool {
        var didMutate = false

        if var row = rowsById[id], row.betSize != text {
            row.betSize = text
            rowsById[id] = row
            didMutate = true
        }

        if text.isEmpty, selection != .none {
            let rowIDs = Array(rowsById.keys)
            for rowID in rowIDs {
                guard var row = rowsById[rowID], !row.betSize.isEmpty else { continue }
                row.betSize.removeAll()
                rowsById[rowID] = row
                didMutate = true
            }
            if !total.betSize.isEmpty {
                total.betSize.removeAll()
                didMutate = true
            }
        } else if selection == .none {
            didMutate = setTotalFromBetSizes() || didMutate
        }

        return didMutate
    }

    @discardableResult
    func setTotalFromBetSizes() -> Bool {
        let sumOfBetSizes = activeRowIds
            .compactMap { rowsById[$0]?.betSize.formatToDouble() }
            .reduce(0) { $0 + $1 }
        let updatedValue = sumOfBetSizes == 0 ? "" : sumOfBetSizes.formatToString()
        guard total.betSize != updatedValue else { return false }
        total.betSize = updatedValue
        return true
    }

    @discardableResult
    func setRowCoefficient(id: RowID, text: String) -> Bool {
        guard var row = rowsById[id], row.coefficient != text else { return false }
        row.coefficient = text
        rowsById[id] = row
        return true
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

    func clear(_ rowIDs: [RowID]) {
        for id in rowIDs {
            if var row = rowsById[id] {
                row.betSize.removeAll()
                row.coefficient.removeAll()
                row.income = "0"
                rowsById[id] = row
            }
        }
    }

    func moveRowIds(in rowIDs: inout [RowID], fromOffsets: IndexSet, toOffset: Int) {
        let moving = fromOffsets.map { rowIDs[$0] }
        for index in fromOffsets.sorted(by: >) {
            rowIDs.remove(at: index)
        }
        let adjustedOffset = toOffset - fromOffsets.filter { $0 < toOffset }.count
        rowIDs.insert(contentsOf: moving, at: adjustedOffset)
    }

    func normalizeFocusForCurrentStateIfNeeded() {
        guard let currentFocus = focus else { return }
        guard isFocusableFieldAvailable(currentFocus), !isFieldDisabled(currentFocus) else {
            focus = preferredFocusForCurrentState(previousFocus: currentFocus)
            return
        }
    }

    func isFocusableFieldAvailable(_ field: FocusableField) -> Bool {
        switch field {
        case .totalBetSize:
            return true
        case let .rowBetSize(id), let .rowCoefficient(id):
            return activeRowIds.contains(id)
        }
    }

    func preferredFocusForCurrentState(previousFocus: FocusableField) -> FocusableField? {
        switch selection {
        case .total:
            return .totalBetSize
        case let .row(id):
            return .rowBetSize(id)
        case .none:
            if case let .rowBetSize(id) = previousFocus, activeRowIds.contains(id) {
                return .rowBetSize(id)
            }
            guard let firstActiveRowID = activeRowIds.first else { return .none }
            return .rowBetSize(firstActiveRowID)
        }
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

    /// Логирует событие расчета с debounce, чтобы не спамить при каждом нажатии клавиши.
    func logCalculationPerformedDebounced() {
        calculationAnalyticsTask?.cancel()
        calculationAnalyticsTask = Task {
            await delay.sleep(nanoseconds: CalculatorConstants.calculationAnalyticsDelay)
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
