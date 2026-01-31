import Foundation

protocol CalculationAnalyticsDelay: Sendable {
    func sleep(nanoseconds: UInt64) async
}

struct SystemCalculationAnalyticsDelay: CalculationAnalyticsDelay {
    func sleep(nanoseconds: UInt64) async {
        try? await Task.sleep(nanoseconds: nanoseconds)
    }
}
