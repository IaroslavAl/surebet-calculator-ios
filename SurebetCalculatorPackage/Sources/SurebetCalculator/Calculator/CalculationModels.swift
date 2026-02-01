import Foundation

struct CalculationInput: Sendable {
    let total: TotalRow
    let rowsById: [RowID: Row]
    let orderedRowIds: [RowID]
    let activeRowIds: [RowID]
    let selection: Selection
}

struct CalculationOutput: Sendable {
    let total: TotalRow
    let rowsById: [RowID: Row]
}

enum CalculationInputError: Sendable, Equatable {
    case duplicateRowIds
    case missingRow(RowID)
    case selectionRowMissing(RowID)
}

enum CalculationResult: Sendable {
    case updated(CalculationOutput)
    case resetDerived(CalculationOutput)
    case noOp
    case invalidInput(CalculationInputError)
}
