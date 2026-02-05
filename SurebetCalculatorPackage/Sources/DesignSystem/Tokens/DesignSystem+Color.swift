import SwiftUI

public extension DesignSystem {
    /// Семантические цвета базовой темы приложения.
    enum Color {
        // MARK: - Backgrounds

        /// Базовый фон приложения.
        public static var background: SwiftUI.Color { token(.background) }

        /// Основная поверхность (карточки, контейнеры).
        public static var surface: SwiftUI.Color { token(.surface) }

        /// Поверхность с легким выделением.
        public static var surfaceElevated: SwiftUI.Color { token(.surfaceElevated) }

        /// Поверхность для ввода.
        public static var surfaceInput: SwiftUI.Color { token(.surfaceInput) }

        /// Поверхность для результата.
        public static var surfaceResult: SwiftUI.Color { token(.surfaceResult) }

        // MARK: - Borders

        /// Базовый бордер.
        public static var border: SwiftUI.Color { token(.border) }

        /// Более мягкий бордер.
        public static var borderMuted: SwiftUI.Color { token(.borderMuted) }

        // MARK: - Accent & Status

        /// Акцентный цвет.
        public static var accent: SwiftUI.Color { token(.accent) }

        /// Мягкий акцент для выделения.
        public static var accentSoft: SwiftUI.Color { token(.accentSoft) }

        /// Цвет для позитивных значений.
        public static var success: SwiftUI.Color { token(.success) }

        /// Цвет для ошибок и негативных значений.
        public static var error: SwiftUI.Color { token(.error) }

        /// Мягкий фон ошибки.
        public static var errorBackground: SwiftUI.Color {
            error.opacity(0.12)
        }

        // MARK: - Text

        /// Основной цвет текста.
        public static var textPrimary: SwiftUI.Color { token(.textPrimary) }

        /// Вторичный цвет текста.
        public static var textSecondary: SwiftUI.Color { token(.textSecondary) }

        /// Приглушенный текст.
        public static var textMuted: SwiftUI.Color { token(.textMuted) }

        // MARK: - Onboarding

        /// Фон онбординга.
        public static var onboardingBackground: SwiftUI.Color { token(.onboardingBackground) }

        /// Поверхность онбординга.
        public static var onboardingSurface: SwiftUI.Color { token(.onboardingSurface) }

        /// Бордер онбординга.
        public static var onboardingBorder: SwiftUI.Color { token(.onboardingBorder) }

        /// Фон кнопок онбординга.
        public static var onboardingButtonBackground: SwiftUI.Color { token(.onboardingButtonBackground) }

        /// Текст на кнопках онбординга.
        public static var onboardingButtonText: SwiftUI.Color { .white }

        /// Бордер кнопок онбординга.
        public static var onboardingButtonBorder: SwiftUI.Color { token(.onboardingButtonBorder) }

        /// Основной цвет текста онбординга.
        public static var onboardingTextPrimary: SwiftUI.Color { token(.onboardingTextPrimary) }

        /// Вторичный цвет текста онбординга.
        public static var onboardingTextSecondary: SwiftUI.Color { token(.onboardingTextSecondary) }

        /// Активный индикатор страницы онбординга.
        public static var onboardingIndicatorActive: SwiftUI.Color { token(.onboardingIndicatorActive) }

        /// Неактивный индикатор страницы онбординга.
        public static var onboardingIndicatorInactive: SwiftUI.Color { token(.onboardingIndicatorInactive) }

        /// Цвет кнопки закрытия онбординга.
        public static var onboardingCloseButton: SwiftUI.Color { token(.onboardingCloseButton) }

        // MARK: - Banner

        /// Цвет кнопки закрытия inline баннера.
        public static var bannerCloseButtonInline: SwiftUI.Color { token(.bannerCloseInline) }

        /// Цвет кнопки закрытия fullscreen баннера.
        public static var bannerCloseButtonFullscreen: SwiftUI.Color { token(.bannerCloseFullscreen) }

        /// Фон fullscreen баннера.
        public static var bannerFullscreenBackground: SwiftUI.Color { token(.bannerOverlay) }
    }
}

private extension DesignSystem.Color {
    enum Token: String {
        case background = "Background"
        case surface = "Surface"
        case surfaceElevated = "SurfaceElevated"
        case surfaceInput = "SurfaceInput"
        case surfaceResult = "SurfaceResult"
        case border = "Border"
        case borderMuted = "BorderMuted"
        case accent = "Accent"
        case accentSoft = "AccentSoft"
        case success = "Success"
        case error = "Error"
        case textPrimary = "TextPrimary"
        case textSecondary = "TextSecondary"
        case textMuted = "TextMuted"
        case onboardingBackground = "OnboardingBackground"
        case onboardingSurface = "OnboardingSurface"
        case onboardingBorder = "OnboardingBorder"
        case onboardingButtonBackground = "OnboardingButtonBackground"
        case onboardingButtonBorder = "OnboardingButtonBorder"
        case onboardingTextPrimary = "OnboardingTextPrimary"
        case onboardingTextSecondary = "OnboardingTextSecondary"
        case onboardingIndicatorActive = "OnboardingIndicatorActive"
        case onboardingIndicatorInactive = "OnboardingIndicatorInactive"
        case onboardingCloseButton = "OnboardingCloseButton"
        case bannerCloseInline = "BannerCloseInline"
        case bannerCloseFullscreen = "BannerCloseFullscreen"
        case bannerOverlay = "BannerOverlay"
    }

    static func token(_ token: Token) -> SwiftUI.Color {
        SwiftUI.Color(token.rawValue, bundle: .module)
    }
}
