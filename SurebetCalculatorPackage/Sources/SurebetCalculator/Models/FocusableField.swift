import Foundation

enum FocusableField: Hashable, Sendable {
    case totalBetSize
    case rowBetSize(_ id: Int)
    case rowCoefficient(_ id: Int)
}
