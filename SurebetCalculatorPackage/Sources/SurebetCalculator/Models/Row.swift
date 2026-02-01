import Foundation

struct Row: Equatable, Sendable {
    let id: RowID
    var isON = false
    var betSize = ""
    var coefficient = ""
    var income = "0"

    static func createRows(_ number: Int) -> (rowsById: [RowID: Row], orderedRowIds: [RowID]) {
        var generator = RowIDGenerator()
        var rowsById: [RowID: Row] = [:]
        var orderedRowIds: [RowID] = []

        for _ in 0..<number {
            let id = generator.make()
            let row = Row(id: id)
            rowsById[id] = row
            orderedRowIds.append(id)
        }

        return (rowsById: rowsById, orderedRowIds: orderedRowIds)
    }
}
