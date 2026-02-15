import DesignSystem
import Foundation

/// Ключи локализации для модуля Root
enum RootLocalizationKey: String {
    case reviewRequestTitle = "review_request_title"
    case reviewButtonNo = "review_button_no"
    case reviewButtonYes = "review_button_yes"

    /// Локализованная строка для ключа.
    func localized(_ locale: Locale) -> String {
        let localizedBundle = LocalizationBundleResolver.localizedBundle(for: locale, in: .module)
        return String(
            localized: String.LocalizationValue(rawValue),
            table: "Localizable",
            bundle: localizedBundle
        )
    }
}
