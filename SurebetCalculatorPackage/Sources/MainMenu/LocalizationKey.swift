import DesignSystem
import Foundation

/// Ключи локализации для модуля MainMenu
enum MainMenuLocalizationKey: String {
    case menuNavigationTitle = "menu_navigation_title"
    case menuCalculatorTitle = "menu_calculator_title"
    case menuSettingsTitle = "menu_settings_title"
    case menuInstructionsTitle = "menu_instructions_title"
    case menuFeedbackTitle = "menu_feedback_title"
    case instructionsStepOneTitle = "instructions_step_one_title"
    case instructionsStepOneBody = "instructions_step_one_body"
    case instructionsStepTwoTitle = "instructions_step_two_title"
    case instructionsStepTwoBody = "instructions_step_two_body"
    case instructionsStepThreeTitle = "instructions_step_three_title"
    case instructionsStepThreeBody = "instructions_step_three_body"
    case instructionsStepFourTitle = "instructions_step_four_title"
    case instructionsStepFourBody = "instructions_step_four_body"

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
