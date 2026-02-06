import Foundation

/// Доступные варианты языка приложения.
public enum SettingsLanguage: String, CaseIterable, Sendable {
    case system = "system"
    case english = "en"
    case russian = "ru"
    case german = "de"
    case greek = "el"
    case spanish = "es"
    case french = "fr"
    case italian = "it"
    case portuguese = "pt"

    /// Локаль для выбранного языка.
    public var locale: Locale {
        switch self {
        case .system:
            return .autoupdatingCurrent
        case .english,
             .russian,
             .german,
             .greek,
             .spanish,
             .french,
             .italian,
             .portuguese:
            return Locale(identifier: rawValue)
        }
    }
}

extension SettingsLanguage {
    /// Языки, доступные для выбора прямо сейчас.
    static var selectableLanguages: [SettingsLanguage] {
        [
            .system,
            .english,
            .russian,
            .german,
            .greek,
            .spanish,
            .french,
            .italian,
            .portuguese
        ]
    }

    var isSelectable: Bool {
        Self.selectableLanguages.contains(self)
    }

    var titleKey: SettingsLocalizationKey {
        switch self {
        case .system:
            return .languageSystemTitle
        case .english:
            return .languageEnglishTitle
        case .russian:
            return .languageRussianTitle
        case .german:
            return .languageGermanTitle
        case .greek:
            return .languageGreekTitle
        case .spanish:
            return .languageSpanishTitle
        case .french:
            return .languageFrenchTitle
        case .italian:
            return .languageItalianTitle
        case .portuguese:
            return .languagePortugueseTitle
        }
    }

    var codeKey: SettingsLocalizationKey? {
        switch self {
        case .system:
            return nil
        case .english:
            return .languageCodeEnglish
        case .russian:
            return .languageCodeRussian
        case .german:
            return .languageCodeGerman
        case .greek:
            return .languageCodeGreek
        case .spanish:
            return .languageCodeSpanish
        case .french:
            return .languageCodeFrench
        case .italian:
            return .languageCodeItalian
        case .portuguese:
            return .languageCodePortuguese
        }
    }

    func title(locale: Locale) -> String {
        titleKey.localized(locale)
    }

    func code(locale: Locale) -> String? {
        codeKey?.localized(locale)
    }
}
