import Foundation

public enum CalculatorRowsCountChangeDirection: String, Sendable {
    case increased
    case decreased
}

public enum CalculatorMode: String, Sendable {
    case total
    case rows
    case row
}

public protocol CalculatorAnalytics: Sendable {
    func calculatorRowsCountChanged(
        rowCount: Int,
        changeDirection: CalculatorRowsCountChangeDirection
    )
    func calculatorModeSelected(mode: CalculatorMode)
    func calculatorCleared()
    func calculatorCalculationPerformed(
        rowCount: Int,
        mode: CalculatorMode,
        profitPercentage: Double,
        isProfitable: Bool
    )
}

public struct NoopCalculatorAnalytics: CalculatorAnalytics {
    public init() {}

    public func calculatorRowsCountChanged(
        rowCount _: Int,
        changeDirection _: CalculatorRowsCountChangeDirection
    ) {}
    public func calculatorModeSelected(mode _: CalculatorMode) {}
    public func calculatorCleared() {}
    public func calculatorCalculationPerformed(
        rowCount _: Int,
        mode _: CalculatorMode,
        profitPercentage _: Double,
        isProfitable _: Bool
    ) {}
}
