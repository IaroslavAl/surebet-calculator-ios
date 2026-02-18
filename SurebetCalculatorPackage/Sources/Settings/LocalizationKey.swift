import DesignSystem
import Foundation

/// Ключи локализации для модуля Settings.
enum SettingsLocalizationKey: String {
    case navigationTitle = "settings_navigation_title"
    case themeTitle = "settings_theme_title"
    case themeSubtitle = "settings_theme_subtitle"
    case languageTitle = "settings_language_title"
    case languageSubtitle = "settings_language_subtitle"
    case languageFooter = "settings_language_footer"
    case optionUnavailable = "settings_option_unavailable"
    case themeSystemTitle = "settings_theme_system_title"
    case themeSystemSubtitle = "settings_theme_system_subtitle"
    case themeLightTitle = "settings_theme_light_title"
    case themeLightSubtitle = "settings_theme_light_subtitle"
    case themeDarkTitle = "settings_theme_dark_title"
    case themeDarkSubtitle = "settings_theme_dark_subtitle"
    case languageSystemTitle = "settings_language_system_title"
    case languageEnglishTitle = "settings_language_english_title"
    case languageRussianTitle = "settings_language_russian_title"
    case languageGermanTitle = "settings_language_german_title"
    case languageGreekTitle = "settings_language_greek_title"
    case languageSpanishTitle = "settings_language_spanish_title"
    case languageFrenchTitle = "settings_language_french_title"
    case languageItalianTitle = "settings_language_italian_title"
    case languagePortugueseTitle = "settings_language_portuguese_title"
    case languageCodeEnglish = "settings_language_code_english"
    case languageCodeRussian = "settings_language_code_russian"
    case languageCodeGerman = "settings_language_code_german"
    case languageCodeGreek = "settings_language_code_greek"
    case languageCodeSpanish = "settings_language_code_spanish"
    case languageCodeFrench = "settings_language_code_french"
    case languageCodeItalian = "settings_language_code_italian"
    case languageCodePortuguese = "settings_language_code_portuguese"

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
