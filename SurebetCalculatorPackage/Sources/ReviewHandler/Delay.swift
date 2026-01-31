import Foundation

public protocol Delay: Sendable {
    func sleep(nanoseconds: UInt64) async
}

public struct SystemDelay: Delay {
    public init() {}

    public func sleep(nanoseconds: UInt64) async {
        try? await Task.sleep(nanoseconds: nanoseconds)
    }
}
