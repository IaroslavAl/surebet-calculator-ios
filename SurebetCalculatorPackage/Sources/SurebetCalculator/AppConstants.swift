import Foundation
import SwiftUI

/// Константы приложения, сгруппированные по категориям
public enum AppConstants {
    // MARK: - Layout

    /// Константы для отступов (padding)
    public enum Padding {
        /// Маленький отступ (8pt)
        public static let small: CGFloat = 8

        /// Средний отступ (12pt)
        public static let medium: CGFloat = 12

        /// Большой отступ (16pt)
        public static let large: CGFloat = 16

        /// Очень большой отступ (24pt)
        public static let extraLarge: CGFloat = 24

        /// Очень-очень большой отступ (36pt)
        public static let extraExtraLarge: CGFloat = 36
    }

    /// Константы для высот элементов
    public enum Heights {
        /// Компактная высота (40pt)
        public static let compact: CGFloat = 40

        /// Обычная высота (60pt)
        public static let regular: CGFloat = 60

        /// Высота тулбара над клавиатурой (44pt)
        public static let keyboardAccessoryToolbar: CGFloat = 44
    }

    /// Константы для радиусов скругления углов
    public enum CornerRadius {
        /// Маленький радиус (10pt)
        public static let small: CGFloat = 10

        /// Средний радиус (12pt)
        public static let medium: CGFloat = 12

        /// Большой радиус (15pt)
        public static let large: CGFloat = 15

        /// Очень большой радиус (18pt)
        public static let extraLarge: CGFloat = 18

        /// Очень-очень большой радиус (24pt)
        public static let extraExtraLarge: CGFloat = 24
    }

    // MARK: - Delays

    /// Константы для задержек выполнения
    public enum Delays {
        /// Задержка перед запросом отзыва (1 секунда)
        public static let reviewRequest: UInt64 = NSEC_PER_SEC * 1

        /// Задержка для debounce аналитики расчёта (1 секунда)
        public static let calculationAnalytics: UInt64 = NSEC_PER_SEC * 1
    }

    // MARK: - Typography

    /// Система типографики приложения
    public enum Typography {
        /// Основной шрифт для контента (body для iPhone, title для iPad)
        @MainActor
        public static var body: Font {
            Device.isIPad ? .title : .body
        }

        /// Шрифт для числовых значений (моноширинные цифры)
        @MainActor
        public static var numeric: Font {
            body.monospacedDigit()
        }

        /// Шрифт для заголовков страниц (title для iPhone, largeTitle для iPad)
        @MainActor
        public static var title: Font {
            Device.isIPad ? .largeTitle : .title
        }

        /// Шрифт для кнопок и иконок (title для iPhone, largeTitle для iPad)
        @MainActor
        public static var button: Font {
            Device.isIPad ? .largeTitle : .title
        }

        /// Шрифт для описаний и подписей (body для iPhone, title2 для iPad)
        @MainActor
        public static var description: Font {
            Device.isIPad ? .title2 : .body
        }

        /// Шрифт для меток (caption для iPhone, body для iPad)
        @MainActor
        public static var label: Font {
            Device.isIPad ? .body : .caption
        }
    }

    // MARK: - Other

    /// Прочие константы
    public enum Other {
        /// Минимальный scale factor для текста
        public static let minimumTextScaleFactor: CGFloat = 0.5

        /// Индекс первой страницы
        public static let firstPageIndex = 0
    }

    // MARK: - Calculator

    /// Константы для калькулятора
    public enum Calculator {
        /// Минимальное количество исходов
        public static let minRowCount = 2

        /// Максимальное количество исходов
        public static let maxRowCount = 20
    }
}
