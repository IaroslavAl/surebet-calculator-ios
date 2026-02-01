import Foundation

struct RowID: Hashable, Sendable {
    let rawValue: UInt64
}

struct RowIDGenerator: Sendable {
    private var nextValue: UInt64 = 0

    mutating func make() -> RowID {
        defer { nextValue += 1 }
        return RowID(rawValue: nextValue)
    }
}
