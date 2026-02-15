import DesignSystem
import Foundation

/// Ключи локализации для модуля Onboarding
enum OnboardingLocalizationKey: String {
    case page1Description = "onboarding_page_1_description"
    case page2Description = "onboarding_page_2_description"
    case page3Description = "onboarding_page_3_description"
    case image = "onboarding_image"
    case moreDetails = "onboarding_more_details"
    case close = "onboarding_close"
    case closeOnboarding = "onboarding_close_onboarding"
    case next = "onboarding_next"

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
