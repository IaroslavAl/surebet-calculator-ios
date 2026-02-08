import Foundation

struct RowItemState: Equatable, Sendable {
    let id: RowID
    let displayIndex: Int
    let isSelected: Bool
    let isOn: Bool
    let coefficient: String
    let betSize: String
    let income: String
    let isBetSizeDisabled: Bool
}
