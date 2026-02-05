import SwiftUI

public extension DesignSystem {
    /// Шкала отступов.
    enum Spacing {
        /// 6pt — сверхмалый шаг (точечные кейсы).
        public static let extraSmall: CGFloat = 6
        /// 8pt — базовый маленький шаг.
        public static let small: CGFloat = 8
        /// 12pt — средний шаг.
        public static let medium: CGFloat = 12
        /// 16pt — крупный шаг.
        public static let large: CGFloat = 16
        /// 24pt — очень крупный шаг.
        public static let extraLarge: CGFloat = 24
        /// 36pt — максимальный шаг.
        public static let extraExtraLarge: CGFloat = 36
    }
}
