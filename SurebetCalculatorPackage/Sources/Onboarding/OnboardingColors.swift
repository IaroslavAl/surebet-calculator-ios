import SwiftUI
import UIKit

/// Система адаптивных цветов для онбординга
enum OnboardingColors {
    // MARK: - Background

    /// Фон экрана онбординга
    static var background: Color {
        dynamicColor(
            light: UIColor(red: 244 / 255, green: 247 / 255, blue: 244 / 255, alpha: 1),
            dark: UIColor(red: 14 / 255, green: 18 / 255, blue: 16 / 255, alpha: 1)
        )
    }

    /// Поверхность карточек
    static var surface: Color {
        dynamicColor(
            light: UIColor(red: 1, green: 1, blue: 1, alpha: 1),
            dark: UIColor(red: 23 / 255, green: 27 / 255, blue: 24 / 255, alpha: 1)
        )
    }

    /// Цвет бордера
    static var border: Color {
        dynamicColor(
            light: UIColor(red: 214 / 255, green: 227 / 255, blue: 216 / 255, alpha: 1),
            dark: UIColor(red: 46 / 255, green: 54 / 255, blue: 50 / 255, alpha: 1)
        )
    }

    // MARK: - Button Colors

    /// Цвет фона для кнопок онбординга
    static var buttonBackground: Color {
        dynamicColor(
            light: UIColor(red: 29 / 255, green: 174 / 255, blue: 94 / 255, alpha: 1),
            dark: UIColor(red: 52 / 255, green: 201 / 255, blue: 123 / 255, alpha: 1)
        )
    }

    /// Цвет текста на кнопках онбординга
    static var buttonText: Color {
        .white
    }

    /// Цвет бордера у кнопок
    static var buttonBorder: Color {
        dynamicColor(
            light: UIColor(red: 29 / 255, green: 174 / 255, blue: 94 / 255, alpha: 1),
            dark: UIColor(red: 52 / 255, green: 201 / 255, blue: 123 / 255, alpha: 1)
        )
    }

    // MARK: - Text

    /// Основной цвет текста
    static var textPrimary: Color {
        dynamicColor(
            light: UIColor(red: 29 / 255, green: 36 / 255, blue: 31 / 255, alpha: 1),
            dark: UIColor(red: 233 / 255, green: 241 / 255, blue: 234 / 255, alpha: 1)
        )
    }

    /// Вторичный цвет текста
    static var textSecondary: Color {
        dynamicColor(
            light: UIColor(red: 84 / 255, green: 100 / 255, blue: 90 / 255, alpha: 1),
            dark: UIColor(red: 181 / 255, green: 195 / 255, blue: 187 / 255, alpha: 1)
        )
    }

    // MARK: - Indicator Colors

    /// Цвет для индикатора активной страницы
    static var activeIndicator: Color {
        dynamicColor(
            light: UIColor(red: 29 / 255, green: 174 / 255, blue: 94 / 255, alpha: 1),
            dark: UIColor(red: 52 / 255, green: 201 / 255, blue: 123 / 255, alpha: 1)
        )
    }

    /// Цвет для индикатора неактивной страницы
    static var inactiveIndicator: Color {
        dynamicColor(
            light: UIColor(red: 229 / 255, green: 237 / 255, blue: 230 / 255, alpha: 1),
            dark: UIColor(red: 36 / 255, green: 43 / 255, blue: 39 / 255, alpha: 1)
        )
    }

    // MARK: - Close Button Color

    /// Цвет для кнопки закрытия онбординга
    static var closeButton: Color {
        dynamicColor(
            light: UIColor(red: 84 / 255, green: 100 / 255, blue: 90 / 255, alpha: 1),
            dark: UIColor(red: 181 / 255, green: 195 / 255, blue: 187 / 255, alpha: 1)
        )
    }
}

private extension OnboardingColors {
    static func dynamicColor(light: UIColor, dark: UIColor) -> Color {
        Color(
            uiColor: UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark ? dark : light
            }
        )
    }
}
