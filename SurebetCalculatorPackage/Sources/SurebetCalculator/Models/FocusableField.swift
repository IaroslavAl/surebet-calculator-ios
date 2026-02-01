import Foundation

enum FocusableField: Hashable, Sendable {
    case totalBetSize
    case rowBetSize(_ id: RowID)
    case rowCoefficient(_ id: RowID)
}
