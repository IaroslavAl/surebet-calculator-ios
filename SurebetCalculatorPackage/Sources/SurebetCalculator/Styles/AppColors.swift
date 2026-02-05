import SwiftUI
import UIKit

/// Система адаптивных цветов для светлой и темной темы
public enum AppColors {
    // MARK: - Base

    /// Базовый фон приложения
    public static var background: Color {
        dynamicColor(
            light: UIColor(red: 237 / 255, green: 241 / 255, blue: 237 / 255, alpha: 1),
            dark: UIColor(red: 14 / 255, green: 18 / 255, blue: 16 / 255, alpha: 1)
        )
    }

    /// Основная поверхность (карточки, контейнеры)
    public static var surface: Color {
        dynamicColor(
            light: UIColor(red: 252 / 255, green: 253 / 255, blue: 252 / 255, alpha: 1),
            dark: UIColor(red: 23 / 255, green: 27 / 255, blue: 24 / 255, alpha: 1)
        )
    }

    /// Поверхность с легким выделением (summary, активные блоки)
    public static var surfaceElevated: Color {
        dynamicColor(
            light: UIColor(red: 248 / 255, green: 250 / 255, blue: 248 / 255, alpha: 1),
            dark: UIColor(red: 30 / 255, green: 35 / 255, blue: 32 / 255, alpha: 1)
        )
    }

    /// Поверхность для ввода
    public static var surfaceInput: Color {
        dynamicColor(
            light: UIColor(red: 238 / 255, green: 243 / 255, blue: 238 / 255, alpha: 1),
            dark: UIColor(red: 35 / 255, green: 42 / 255, blue: 38 / 255, alpha: 1)
        )
    }

    /// Поверхность для результата
    public static var surfaceResult: Color {
        dynamicColor(
            light: UIColor(red: 245 / 255, green: 248 / 255, blue: 245 / 255, alpha: 1),
            dark: UIColor(red: 30 / 255, green: 36 / 255, blue: 33 / 255, alpha: 1)
        )
    }

    // MARK: - Borders

    /// Базовый бордер
    public static var border: Color {
        dynamicColor(
            light: UIColor(red: 190 / 255, green: 205 / 255, blue: 194 / 255, alpha: 1),
            dark: UIColor(red: 46 / 255, green: 54 / 255, blue: 50 / 255, alpha: 1)
        )
    }

    /// Более мягкий бордер
    public static var borderMuted: Color {
        dynamicColor(
            light: UIColor(red: 210 / 255, green: 221 / 255, blue: 212 / 255, alpha: 1),
            dark: UIColor(red: 36 / 255, green: 43 / 255, blue: 39 / 255, alpha: 1)
        )
    }

    // MARK: - Accent & Status

    /// Акцентный цвет (тёплый, нейтральный)
    public static var accent: Color {
        dynamicColor(
            light: UIColor(red: 29 / 255, green: 174 / 255, blue: 94 / 255, alpha: 1),
            dark: UIColor(red: 52 / 255, green: 201 / 255, blue: 123 / 255, alpha: 1)
        )
    }

    /// Мягкий акцент для выделения
    public static var accentSoft: Color {
        dynamicColor(
            light: UIColor(red: 223 / 255, green: 245 / 255, blue: 232 / 255, alpha: 1),
            dark: UIColor(red: 31 / 255, green: 58 / 255, blue: 44 / 255, alpha: 1)
        )
    }

    /// Цвет для позитивных значений
    public static var success: Color {
        dynamicColor(
            light: UIColor(red: 27 / 255, green: 148 / 255, blue: 86 / 255, alpha: 1),
            dark: UIColor(red: 74 / 255, green: 214 / 255, blue: 136 / 255, alpha: 1)
        )
    }

    /// Цвет для ошибок и негативных значений
    public static var error: Color {
        dynamicColor(
            light: UIColor(red: 186 / 255, green: 86 / 255, blue: 78 / 255, alpha: 1),
            dark: UIColor(red: 222 / 255, green: 126 / 255, blue: 118 / 255, alpha: 1)
        )
    }

    /// Фон ошибки (мягкий)
    public static var errorBackground: Color {
        error.opacity(0.12)
    }

    // MARK: - Text

    /// Основной цвет текста
    public static var textPrimary: Color {
        dynamicColor(
            light: UIColor(red: 21 / 255, green: 28 / 255, blue: 23 / 255, alpha: 1),
            dark: UIColor(red: 233 / 255, green: 241 / 255, blue: 234 / 255, alpha: 1)
        )
    }

    /// Вторичный цвет текста
    public static var textSecondary: Color {
        dynamicColor(
            light: UIColor(red: 74 / 255, green: 88 / 255, blue: 79 / 255, alpha: 1),
            dark: UIColor(red: 181 / 255, green: 195 / 255, blue: 187 / 255, alpha: 1)
        )
    }

    /// Приглушенный текст
    public static var textMuted: Color {
        dynamicColor(
            light: UIColor(red: 103 / 255, green: 118 / 255, blue: 108 / 255, alpha: 1),
            dark: UIColor(red: 140 / 255, green: 154 / 255, blue: 146 / 255, alpha: 1)
        )
    }

    // MARK: - Legacy Aliases

    /// Основной зеленый цвет (для валидных значений, активных состояний)
    public static var primaryGreen: Color { success }

    /// Основной красный цвет (для ошибок, невалидных значений)
    public static var primaryRed: Color { error }

    /// Фон для текстовых полей и элементов ввода
    public static var textFieldBackground: Color { surfaceInput }

    /// Цвет текста для валидных значений
    public static var validText: Color { success }

    /// Цвет текста для невалидных значений
    public static var invalidText: Color { error }

    /// Цвет для активных кнопок
    public static var activeButton: Color { accent }

    /// Цвет для неактивных кнопок
    public static var inactiveButton: Color { borderMuted }

    /// Цвет текста на кнопках
    public static var buttonText: Color { textPrimary }

    /// Цвет для индикатора активной страницы онбординга
    public static var onboardingActiveIndicator: Color { textSecondary }

    /// Цвет для индикатора неактивной страницы онбординга
    public static var onboardingInactiveIndicator: Color { textMuted }

    /// Цвет для кнопки закрытия онбординга
    public static var onboardingCloseButton: Color { textSecondary }

    /// Цвет для кнопки закрытия баннера (inline)
    public static var bannerCloseButtonInline: Color { .black.opacity(0.25) }

    /// Цвет для кнопки закрытия баннера (fullscreen)
    public static var bannerCloseButtonFullscreen: Color { .white.opacity(0.5) }

    /// Цвет фона для fullscreen баннера
    public static var bannerFullscreenBackground: Color { .black.opacity(0.75) }
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
