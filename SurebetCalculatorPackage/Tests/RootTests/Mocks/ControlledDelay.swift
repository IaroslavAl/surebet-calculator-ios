import ReviewHandler

final class ControlledDelay: Delay, @unchecked Sendable {
    private var continuations: [CheckedContinuation<Void, Never>] = []
    private var waiters: [CheckedContinuation<Void, Never>] = []

    func sleep(nanoseconds _: UInt64) async {
        if !waiters.isEmpty {
            waiters.forEach { $0.resume() }
            waiters.removeAll()
        }
        await withCheckedContinuation { continuation in
            continuations.append(continuation)
        }
    }

    func waitForSleepCall() async {
        if !continuations.isEmpty {
            return
        }
        await withCheckedContinuation { continuation in
            waiters.append(continuation)
        }
    }

    func advanceNext() async {
        guard !continuations.isEmpty else { return }
        let continuation = continuations.removeFirst()
        continuation.resume()
        await Task.yield()
    }
}
