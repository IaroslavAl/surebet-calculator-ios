import Foundation

/// Протокол для сервиса аналитики.
/// Обеспечивает инверсию зависимостей и позволяет легко тестировать компоненты.
public protocol AnalyticsService: Sendable {
    /// Логирует типобезопасное событие.
    /// - Parameter event: Событие для логирования
    func log(event: AnalyticsEvent)

    /// Логирует событие с типобезопасными параметрами.
    /// - Parameters:
    ///   - name: Название события
    ///   - parameters: Словарь параметров с типобезопасными значениями
    /// - Note: Deprecated. Используйте `log(event:)` для типобезопасного логирования.
    func log(name: String, parameters: [String: AnalyticsParameterValue]?)
}
