public extension DesignSystem {
    /// Помощник для адаптивных значений.
    enum Adaptive {
        /// Возвращает значение, подходящее для текущего устройства.
        /// Почему: упрощает iPad/iPhone ветвления в UI.
        public static func value<T>(iPhone: T, iPad: T) -> T {
            Device.isIPadUnsafe ? iPad : iPhone
        }
    }
}
