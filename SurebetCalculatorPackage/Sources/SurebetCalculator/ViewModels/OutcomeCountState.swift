import Foundation

struct OutcomeCountState: Equatable, Sendable {
    let selectedNumberOfRows: NumberOfRows
    let minRowCount: Int
    let maxRowCount: Int
}
