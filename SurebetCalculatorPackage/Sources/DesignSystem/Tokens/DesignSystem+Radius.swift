import SwiftUI

public extension DesignSystem {
    /// Шкала скруглений.
    enum Radius {
        /// 10pt — маленькое скругление.
        public static let small: CGFloat = 10
        /// 12pt — среднее скругление.
        public static let medium: CGFloat = 12
        /// 15pt — большое скругление.
        public static let large: CGFloat = 15
        /// 18pt — очень большое скругление.
        public static let extraLarge: CGFloat = 18
        /// 24pt — максимальное скругление.
        public static let extraExtraLarge: CGFloat = 24
    }
}
