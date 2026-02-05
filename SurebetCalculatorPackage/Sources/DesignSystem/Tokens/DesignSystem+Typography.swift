import SwiftUI

public extension DesignSystem {
    /// Система типографики приложения.
    enum Typography {
        /// Минимальный scale factor для текста.
        public static let minimumScaleFactor: CGFloat = 0.5

        /// Основной шрифт для контента (body для iPhone, title для iPad).
        @MainActor
        public static var body: Font {
            Device.isIPad ? .title : .body
        }

        /// Шрифт для числовых значений (моноширинные цифры).
        @MainActor
        public static var numeric: Font {
            body.monospacedDigit()
        }

        /// Шрифт для заголовков (title для iPhone, largeTitle для iPad).
        @MainActor
        public static var title: Font {
            Device.isIPad ? .largeTitle : .title
        }

        /// Шрифт для кнопок (title для iPhone, largeTitle для iPad).
        @MainActor
        public static var button: Font {
            Device.isIPad ? .largeTitle : .title
        }

        /// Шрифт для описаний и подписей (body для iPhone, title2 для iPad).
        @MainActor
        public static var description: Font {
            Device.isIPad ? .title2 : .body
        }

        /// Шрифт для меток (caption для iPhone, body для iPad).
        @MainActor
        public static var label: Font {
            Device.isIPad ? .body : .caption
        }

        /// Шрифт для иконок и компактных акцентов.
        @MainActor
        public static var icon: Font {
            .system(size: Device.isIPad ? 20 : 16, weight: .semibold)
        }
    }
}
