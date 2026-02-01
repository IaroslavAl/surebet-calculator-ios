import Foundation

enum Selection: Equatable, Sendable {
    case total
    case row(RowID)
    case none
}
