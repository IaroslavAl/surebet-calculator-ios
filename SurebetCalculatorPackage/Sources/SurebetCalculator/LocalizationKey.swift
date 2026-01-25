import Foundation

/// Ключи локализации для модуля SurebetCalculator
enum SurebetCalculatorLocalizationKey: String {
    case coefficient = "calculator_coefficient"
    case betSize = "calculator_bet_size"
    case income = "calculator_income"
    case clear = "calculator_clear"
    case clearAll = "calculator_clear_all"
    case done = "calculator_done"
    case totalBetSize = "calculator_total_bet_size"
    case profitPercentage = "calculator_profit_percentage"
    case navigationTitle = "calculator_navigation_title"

    /// Локализованная строка для ключа
    var localized: String {
        String(localized: String.LocalizationValue(stringLiteral: rawValue), bundle: .module)
    }
}
