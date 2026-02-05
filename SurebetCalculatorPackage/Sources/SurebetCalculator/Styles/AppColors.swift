import SwiftUI
import UIKit

/// Система адаптивных цветов для светлой и темной темы
enum AppColors {
    // MARK: - Base

    /// Базовый фон приложения
    static var background: Color {
        dynamicColor(
            light: UIColor(red: 237 / 255, green: 241 / 255, blue: 237 / 255, alpha: 1),
            dark: UIColor(red: 14 / 255, green: 18 / 255, blue: 16 / 255, alpha: 1)
        )
    }

    /// Основная поверхность (карточки, контейнеры)
    static var surface: Color {
        dynamicColor(
            light: UIColor(red: 252 / 255, green: 253 / 255, blue: 252 / 255, alpha: 1),
            dark: UIColor(red: 23 / 255, green: 27 / 255, blue: 24 / 255, alpha: 1)
        )
    }

    /// Поверхность с легким выделением (summary, активные блоки)
    static var surfaceElevated: Color {
        dynamicColor(
            light: UIColor(red: 248 / 255, green: 250 / 255, blue: 248 / 255, alpha: 1),
            dark: UIColor(red: 30 / 255, green: 35 / 255, blue: 32 / 255, alpha: 1)
        )
    }

    /// Поверхность для ввода
    static var surfaceInput: Color {
        dynamicColor(
            light: UIColor(red: 238 / 255, green: 243 / 255, blue: 238 / 255, alpha: 1),
            dark: UIColor(red: 35 / 255, green: 42 / 255, blue: 38 / 255, alpha: 1)
        )
    }

    /// Поверхность для результата
    static var surfaceResult: Color {
        dynamicColor(
            light: UIColor(red: 245 / 255, green: 248 / 255, blue: 245 / 255, alpha: 1),
            dark: UIColor(red: 30 / 255, green: 36 / 255, blue: 33 / 255, alpha: 1)
        )
    }

    // MARK: - Borders

    /// Базовый бордер
    static var border: Color {
        dynamicColor(
            light: UIColor(red: 190 / 255, green: 205 / 255, blue: 194 / 255, alpha: 1),
            dark: UIColor(red: 46 / 255, green: 54 / 255, blue: 50 / 255, alpha: 1)
        )
    }

    /// Более мягкий бордер
    static var borderMuted: Color {
        dynamicColor(
            light: UIColor(red: 210 / 255, green: 221 / 255, blue: 212 / 255, alpha: 1),
            dark: UIColor(red: 36 / 255, green: 43 / 255, blue: 39 / 255, alpha: 1)
        )
    }

    // MARK: - Accent & Status

    /// Акцентный цвет (тёплый, нейтральный)
    static var accent: Color {
        dynamicColor(
            light: UIColor(red: 29 / 255, green: 174 / 255, blue: 94 / 255, alpha: 1),
            dark: UIColor(red: 52 / 255, green: 201 / 255, blue: 123 / 255, alpha: 1)
        )
    }

    /// Мягкий акцент для выделения
    static var accentSoft: Color {
        dynamicColor(
            light: UIColor(red: 223 / 255, green: 245 / 255, blue: 232 / 255, alpha: 1),
            dark: UIColor(red: 31 / 255, green: 58 / 255, blue: 44 / 255, alpha: 1)
        )
    }

    /// Цвет для позитивных значений
    static var success: Color {
        dynamicColor(
            light: UIColor(red: 27 / 255, green: 148 / 255, blue: 86 / 255, alpha: 1),
            dark: UIColor(red: 74 / 255, green: 214 / 255, blue: 136 / 255, alpha: 1)
        )
    }

    /// Цвет для ошибок и негативных значений
    static var error: Color {
        dynamicColor(
            light: UIColor(red: 186 / 255, green: 86 / 255, blue: 78 / 255, alpha: 1),
            dark: UIColor(red: 222 / 255, green: 126 / 255, blue: 118 / 255, alpha: 1)
        )
    }

    /// Фон ошибки (мягкий)
    static var errorBackground: Color {
        error.opacity(0.12)
    }

    // MARK: - Text

    /// Основной цвет текста
    static var textPrimary: Color {
        dynamicColor(
            light: UIColor(red: 21 / 255, green: 28 / 255, blue: 23 / 255, alpha: 1),
            dark: UIColor(red: 233 / 255, green: 241 / 255, blue: 234 / 255, alpha: 1)
        )
    }

    /// Вторичный цвет текста
    static var textSecondary: Color {
        dynamicColor(
            light: UIColor(red: 74 / 255, green: 88 / 255, blue: 79 / 255, alpha: 1),
            dark: UIColor(red: 181 / 255, green: 195 / 255, blue: 187 / 255, alpha: 1)
        )
    }

    /// Приглушенный текст
    static var textMuted: Color {
        dynamicColor(
            light: UIColor(red: 103 / 255, green: 118 / 255, blue: 108 / 255, alpha: 1),
            dark: UIColor(red: 140 / 255, green: 154 / 255, blue: 146 / 255, alpha: 1)
        )
    }

    // MARK: - Legacy Aliases

    /// Основной зеленый цвет (для валидных значений, активных состояний)
    static var primaryGreen: Color { success }

    /// Основной красный цвет (для ошибок, невалидных значений)
    static var primaryRed: Color { error }

    /// Фон для текстовых полей и элементов ввода
    static var textFieldBackground: Color { surfaceInput }

    /// Цвет текста для валидных значений
    static var validText: Color { success }

    /// Цвет текста для невалидных значений
    static var invalidText: Color { error }

    /// Цвет для активных кнопок
    static var activeButton: Color { accent }

    /// Цвет для неактивных кнопок
    static var inactiveButton: Color { borderMuted }

    /// Цвет текста на кнопках
    static var buttonText: Color { textPrimary }

    /// Цвет для индикатора активной страницы онбординга
    static var onboardingActiveIndicator: Color { textSecondary }

    /// Цвет для индикатора неактивной страницы онбординга
    static var onboardingInactiveIndicator: Color { textMuted }

    /// Цвет для кнопки закрытия онбординга
    static var onboardingCloseButton: Color { textSecondary }

    /// Цвет для кнопки закрытия баннера (inline)
    static var bannerCloseButtonInline: Color { .black.opacity(0.25) }

    /// Цвет для кнопки закрытия баннера (fullscreen)
    static var bannerCloseButtonFullscreen: Color { .white.opacity(0.5) }

    /// Цвет фона для fullscreen баннера
    static var bannerFullscreenBackground: Color { .black.opacity(0.75) }
}

// MARK: - Private Helpers

private extension AppColors {
    static func dynamicColor(light: UIColor, dark: UIColor) -> Color {
        Color(
            uiColor: UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark ? dark : light
            }
        )
    }
}
