import Foundation

/// Ключи локализации для модуля Root
enum RootLocalizationKey: String {
    case reviewRequestTitle = "review_request_title"
    case reviewButtonNo = "review_button_no"
    case reviewButtonYes = "review_button_yes"

    /// Локализованная строка для ключа
    var localized: String {
        String(localized: String.LocalizationValue(stringLiteral: rawValue), bundle: .module)
    }
}
