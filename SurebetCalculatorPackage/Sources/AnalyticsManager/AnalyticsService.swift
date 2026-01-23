import Foundation

/// Протокол для сервиса аналитики.
/// Обеспечивает инверсию зависимостей и позволяет легко тестировать компоненты.
public protocol AnalyticsService: Sendable {
    /// Логирует событие с типобезопасными параметрами.
    /// - Parameters:
    ///   - name: Название события
    ///   - parameters: Словарь параметров с типобезопасными значениями
    func log(name: String, parameters: [String: AnalyticsParameterValue]?)
}
