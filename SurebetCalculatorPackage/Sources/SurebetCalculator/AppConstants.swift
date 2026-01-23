import Foundation

/// Константы приложения, сгруппированные по категориям
enum AppConstants {
    // MARK: - Layout

    /// Константы для макета и отображения
    enum Layout {
        /// Константы для отступов (padding)
        enum Padding {
            /// Маленький отступ (8pt)
            static let small: CGFloat = 8

            /// Средний отступ (12pt)
            static let medium: CGFloat = 12

            /// Большой отступ (16pt)
            static let large: CGFloat = 16

            /// Очень большой отступ (24pt)
            static let extraLarge: CGFloat = 24

            /// Очень-очень большой отступ (36pt)
            static let extraExtraLarge: CGFloat = 36
        }

        /// Константы для высот элементов
        enum Heights {
            /// Компактная высота (40pt)
            static let compact: CGFloat = 40

            /// Обычная высота (60pt)
            static let regular: CGFloat = 60
        }

        /// Константы для радиусов скругления углов
        enum CornerRadius {
            /// Маленький радиус (10pt)
            static let small: CGFloat = 10

            /// Средний радиус (12pt)
            static let medium: CGFloat = 12

            /// Большой радиус (15pt)
            static let large: CGFloat = 15

            /// Очень большой радиус (18pt)
            static let extraLarge: CGFloat = 18

            /// Очень-очень большой радиус (24pt)
            static let extraExtraLarge: CGFloat = 24
        }
    }

    // MARK: - Delays

    /// Константы для задержек выполнения
    enum Delays {
        /// Задержка перед запросом отзыва (1 секунда)
        static let reviewRequest: UInt64 = NSEC_PER_SEC * 1
    }

    // MARK: - Other

    /// Прочие константы
    enum Other {
        /// Минимальный scale factor для текста
        static let minimumTextScaleFactor: CGFloat = 0.5

        /// Индекс первой страницы
        static let firstPageIndex = 0
    }
}
