import Foundation
import SwiftUI

/// Константы для модуля Onboarding
enum OnboardingConstants {
    /// Минимальный scale factor для текста
    static let minimumTextScaleFactor: CGFloat = 0.5

    /// Индекс первой страницы
    static let firstPageIndex = 0

    // MARK: - Layout

    /// Маленький отступ (8pt)
    static let paddingSmall: CGFloat = 8

    /// Средний отступ (12pt)
    static let paddingMedium: CGFloat = 12

    /// Очень большой отступ (24pt)
    static let paddingExtraLarge: CGFloat = 24

    /// Очень-очень большой отступ (36pt)
    static let paddingExtraExtraLarge: CGFloat = 36

    /// Средний радиус скругления (12pt)
    static let cornerRadiusMedium: CGFloat = 12

    /// Очень большой радиус скругления (18pt)
    static let cornerRadiusExtraLarge: CGFloat = 18

    // MARK: - Typography

    /// Система типографики для онбординга
    enum Typography {
        /// Шрифт для заголовков страниц (title для iPhone, largeTitle для iPad)
        @MainActor
        static var title: Font {
            Device.isIPad ? .largeTitle : .title
        }

        /// Шрифт для кнопок (title для iPhone, largeTitle для iPad)
        @MainActor
        static var button: Font {
            Device.isIPad ? .largeTitle : .title
        }

        /// Шрифт для иконок (title для iPhone, largeTitle для iPad)
        @MainActor
        static var icon: Font {
            Device.isIPad ? .largeTitle : .title
        }
    }

    // MARK: - Animations

    /// Система анимаций для онбординга
    enum Animations {
        /// Плавная анимация для переходов между страницами
        static var smoothTransition: Animation {
            .easeInOut(duration: 0.3)
        }

        /// Быстрая анимация для интерактивных элементов
        static var quickInteraction: Animation {
            .easeInOut(duration: 0.2)
        }

        /// Плавный переход справа
        static var moveFromTrailing: AnyTransition {
            .move(edge: .trailing).combined(with: .opacity)
        }
    }
}
