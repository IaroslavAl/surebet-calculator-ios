import Foundation

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

extension SurebetCalculatorViewModel {
    struct Snapshot {
        let total: TotalRow
        let rowsById: [RowID: Row]
        let orderedRowIds: [RowID]
        let selectedNumberOfRows: NumberOfRows
        let selection: Selection
        let activeRowIds: [RowID]
    }

    var maxRowCount: Int {
        min(orderedRowIds.count, CalculatorConstants.maxRowCount)
    }

    static func resolveInitialRows(
        rowsById: [RowID: Row]?,
        orderedRowIds: [RowID]?
    ) -> (rowsById: [RowID: Row], orderedRowIds: [RowID]) {
        guard let rowsById, let orderedRowIds else {
            return Row.createRows(CalculatorConstants.maxRowCount)
        }
        return normalizedRows(rowsById: rowsById, orderedRowIds: orderedRowIds)
    }

    static func clampedSelectedNumber(requested: NumberOfRows, maxRows: Int) -> NumberOfRows {
        let clampedSelected = min(requested.rawValue, maxRows)
        return NumberOfRows(rawValue: clampedSelected) ?? .two
    }

    static func makeInitialRowViewModels(orderedRowIds: [RowID]) -> [RowItemViewModel] {
        orderedRowIds.map { id in
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
    }

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
        let displayIndex = activeRowIds.firstIndex(of: id) ?? orderedRowIds.firstIndex(of: id) ?? 0

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

    func moveRowIds(in rowIDs: inout [RowID], fromOffsets: IndexSet, toOffset: Int) {
        let moving = fromOffsets.map { rowIDs[$0] }
        for index in fromOffsets.sorted(by: >) {
            rowIDs.remove(at: index)
        }
        let adjustedOffset = toOffset - fromOffsets.filter { $0 < toOffset }.count
        rowIDs.insert(contentsOf: moving, at: adjustedOffset)
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
}
