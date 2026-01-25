import SwiftUI

/// Система адаптивных цветов для онбординга
enum OnboardingColors {
    // MARK: - Button Colors

    /// Цвет фона для кнопок онбординга
    static var buttonBackground: Color {
        .green
    }

    /// Цвет текста на кнопках онбординга
    static var buttonText: Color {
        .white
    }

    // MARK: - Indicator Colors

    /// Цвет для индикатора активной страницы
    static var activeIndicator: Color {
        Color(uiColor: .darkGray)
    }

    /// Цвет для индикатора неактивной страницы
    static var inactiveIndicator: Color {
        Color(uiColor: .lightGray)
    }

    // MARK: - Close Button Color

    /// Цвет для кнопки закрытия онбординга
    static var closeButton: Color {
        Color(uiColor: .darkGray)
    }
}
