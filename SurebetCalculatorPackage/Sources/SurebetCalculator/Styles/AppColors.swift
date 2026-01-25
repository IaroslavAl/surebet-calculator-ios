import SwiftUI

/// Система адаптивных цветов для светлой и темной темы
enum AppColors {
    // MARK: - Primary Colors

    /// Основной зеленый цвет (для валидных значений, активных состояний)
    static var primaryGreen: Color {
        .green
    }

    /// Основной красный цвет (для ошибок, невалидных значений)
    static var primaryRed: Color {
        .red
    }

    // MARK: - Background Colors

    /// Фон для текстовых полей и элементов ввода
    static var textFieldBackground: Color {
        Color(uiColor: .secondarySystemFill)
    }

    /// Фон для ошибок (полупрозрачный красный)
    static var errorBackground: Color {
        .red.opacity(0.3)
    }

    // MARK: - Text Colors

    /// Цвет текста для валидных значений
    static var validText: Color {
        .green
    }

    /// Цвет текста для невалидных значений
    static var invalidText: Color {
        .red
    }

    // MARK: - Button Colors

    /// Цвет для активных кнопок
    static var activeButton: Color {
        .green
    }

    /// Цвет для неактивных кнопок
    static var inactiveButton: Color {
        .gray
    }

    /// Цвет текста на кнопках
    static var buttonText: Color {
        .white
    }

    // MARK: - Onboarding Colors

    /// Цвет для индикатора активной страницы онбординга
    static var onboardingActiveIndicator: Color {
        Color(uiColor: .darkGray)
    }

    /// Цвет для индикатора неактивной страницы онбординга
    static var onboardingInactiveIndicator: Color {
        Color(uiColor: .lightGray)
    }

    /// Цвет для кнопки закрытия онбординга
    static var onboardingCloseButton: Color {
        Color(uiColor: .darkGray)
    }

    // MARK: - Banner Colors

    /// Цвет для кнопки закрытия баннера (inline)
    static var bannerCloseButtonInline: Color {
        .black.opacity(0.25)
    }

    /// Цвет для кнопки закрытия баннера (fullscreen)
    static var bannerCloseButtonFullscreen: Color {
        .white.opacity(0.5)
    }

    /// Цвет фона для fullscreen баннера
    static var bannerFullscreenBackground: Color {
        .black.opacity(0.75)
    }
}
