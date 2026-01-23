import Foundation

enum RowType: Equatable, Sendable {
    case total
    case row(_ id: Int)
}
