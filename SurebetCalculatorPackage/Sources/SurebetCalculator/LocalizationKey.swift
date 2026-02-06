import DesignSystem
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
    case outcomesCount = "calculator_outcomes_count"

    /// Локализованная строка для ключа.
    func localized(_ locale: Locale) -> String {
        let bundle = LocalizationBundleResolver.localizedBundle(for: locale, in: .module)
        return bundle.localizedString(forKey: rawValue, value: nil, table: "Localizable")
    }
}
