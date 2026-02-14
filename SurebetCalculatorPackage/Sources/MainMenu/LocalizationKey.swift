import DesignSystem
import Foundation

/// Ключи локализации для модуля MainMenu
enum MainMenuLocalizationKey: String {
    case menuNavigationTitle = "menu_navigation_title"
    case menuTitle = "menu_title"
    case menuSubtitle = "menu_subtitle"
    case menuCalculatorTitle = "menu_calculator_title"
    case menuCalculatorSubtitle = "menu_calculator_subtitle"
    case menuSettingsTitle = "menu_settings_title"
    case menuSettingsSubtitle = "menu_settings_subtitle"
    case menuSettingsDescription = "menu_settings_description"
    case menuInstructionsTitle = "menu_instructions_title"
    case menuInstructionsSubtitle = "menu_instructions_subtitle"
    case menuFeedbackTitle = "menu_feedback_title"
    case menuFeedbackSubtitle = "menu_feedback_subtitle"
    case menuFeedbackDescription = "menu_feedback_description"
    case instructionsSubtitle = "instructions_subtitle"
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
        let bundle = LocalizationBundleResolver.localizedBundle(for: locale, in: .module)
        return bundle.localizedString(forKey: rawValue, value: nil, table: "Localizable")
    }
}
