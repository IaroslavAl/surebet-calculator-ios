import SwiftUI

/// Доступные варианты темы оформления.
public enum SettingsTheme: String, CaseIterable, Sendable {
    case system
    case light
    case dark

    /// Выбранная цветовая схема для темы.
    public var preferredColorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}

extension SettingsTheme {
    var titleKey: SettingsLocalizationKey {
        switch self {
        case .system:
            return .themeSystemTitle
        case .light:
            return .themeLightTitle
        case .dark:
            return .themeDarkTitle
        }
    }

    var subtitleKey: SettingsLocalizationKey {
        switch self {
        case .system:
            return .themeSystemSubtitle
        case .light:
            return .themeLightSubtitle
        case .dark:
            return .themeDarkSubtitle
        }
    }

    var systemImageName: String {
        switch self {
        case .system:
            return "gearshape"
        case .light:
            return "sun.max"
        case .dark:
            return "moon.stars"
        }
    }

    func title(locale: Locale) -> String {
        titleKey.localized(locale)
    }

    func subtitle(locale: Locale) -> String {
        subtitleKey.localized(locale)
    }
}
