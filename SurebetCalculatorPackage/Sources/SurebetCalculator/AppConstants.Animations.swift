import SwiftUI

/// Система анимаций приложения
public extension AppConstants {
    /// Константы для анимаций
    enum Animations {
        // MARK: - Durations

        /// Короткая длительность анимации (0.2 секунды)
        public static let shortDuration: Double = 0.2

        /// Средняя длительность анимации (0.3 секунды)
        public static let mediumDuration: Double = 0.3

        /// Длинная длительность анимации (0.5 секунд)
        public static let longDuration: Double = 0.5

        // MARK: - Animation Curves

        /// Плавная анимация для переходов между состояниями
        public static var smoothTransition: Animation {
            .easeInOut(duration: mediumDuration)
        }

        /// Быстрая анимация для интерактивных элементов
        public static var quickInteraction: Animation {
            .easeInOut(duration: shortDuration)
        }

        /// Медленная анимация для важных переходов
        public static var slowTransition: Animation {
            .easeInOut(duration: longDuration)
        }

        /// Spring анимация для естественных движений
        public static var spring: Animation {
            .spring(response: 0.4, dampingFraction: 0.8)
        }

        /// Spring анимация для bounce эффектов
        public static var springBounce: Animation {
            .spring(response: 0.5, dampingFraction: 0.6)
        }

        // MARK: - Transitions

        /// Плавный переход снизу
        public static var moveFromBottom: AnyTransition {
            .move(edge: .bottom).combined(with: .opacity)
        }

        /// Плавный переход справа
        public static var moveFromTrailing: AnyTransition {
            .move(edge: .trailing).combined(with: .opacity)
        }

        /// Плавный переход с масштабированием
        public static var scaleWithOpacity: AnyTransition {
            .scale.combined(with: .opacity)
        }

        /// Плавный переход с масштабированием и непрозрачностью
        public static var scaleAndOpacity: AnyTransition {
            .scale(scale: 0.95).combined(with: .opacity)
        }
    }
}
