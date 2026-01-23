import Foundation

enum CalculationMethod: Sendable {
    case total
    case rows
    case row(_ id: Int)
}
