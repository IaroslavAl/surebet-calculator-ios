import Foundation
@testable import ReviewHandler

@MainActor
final class MockDelay: Delay, @unchecked Sendable {
    // MARK: - Properties

    var sleepCallCount = 0
    var lastNanoseconds: UInt64?

    // MARK: - Delay

    func sleep(nanoseconds: UInt64) async {
        sleepCallCount += 1
        lastNanoseconds = nanoseconds
    }
}
