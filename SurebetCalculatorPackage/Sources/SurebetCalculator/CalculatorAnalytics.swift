import Foundation

public protocol CalculatorAnalytics: Sendable {
    func calculatorRowAdded(rowCount: Int)
    func calculatorRowRemoved(rowCount: Int)
    func calculatorCleared()
    func calculationPerformed(rowCount: Int, profitPercentage: Double)
}

public struct NoopCalculatorAnalytics: CalculatorAnalytics {
    public init() {}

    public func calculatorRowAdded(rowCount: Int) {}
    public func calculatorRowRemoved(rowCount: Int) {}
    public func calculatorCleared() {}
    public func calculationPerformed(rowCount: Int, profitPercentage: Double) {}
}
