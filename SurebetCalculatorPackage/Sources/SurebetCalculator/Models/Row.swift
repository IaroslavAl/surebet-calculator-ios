import Foundation

struct Row: Equatable, Sendable {
    let id: Int
    var isON = false
    var betSize = ""
    var coefficient = ""
    var income = "0"

    static func createRows(_ number: Int = 10) -> [Row] {
        (0..<number).map { Row(id: $0) }
    }
}
