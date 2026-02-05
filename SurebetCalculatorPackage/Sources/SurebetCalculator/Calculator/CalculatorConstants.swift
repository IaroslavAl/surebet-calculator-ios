import Foundation

/// Константы, специфичные для логики калькулятора.
enum CalculatorConstants {
    /// Минимальное количество исходов.
    static let minRowCount = 2

    /// Максимальное количество исходов.
    static let maxRowCount = 20

    /// Задержка для debounce аналитики расчёта (1 секунда).
    static let calculationAnalyticsDelay: UInt64 = NSEC_PER_SEC * 1
}
