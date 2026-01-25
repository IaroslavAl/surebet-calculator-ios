import SwiftUI

/// Система адаптивных цветов для баннеров
enum BannerColors {
    // MARK: - Close Button Colors

    /// Цвет для кнопки закрытия inline баннера
    static var closeButtonInline: Color {
        .black.opacity(0.25)
    }

    /// Цвет для кнопки закрытия fullscreen баннера
    static var closeButtonFullscreen: Color {
        .white.opacity(0.5)
    }

    // MARK: - Background Colors

    /// Цвет фона для fullscreen баннера
    static var fullscreenBackground: Color {
        .black.opacity(0.75)
    }
}
