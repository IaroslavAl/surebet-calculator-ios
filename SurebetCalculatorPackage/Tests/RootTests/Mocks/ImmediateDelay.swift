@testable import ReviewHandler

struct ImmediateDelay: Delay, @unchecked Sendable {
    func sleep(nanoseconds: UInt64) async {
        await Task.yield()
    }
}
