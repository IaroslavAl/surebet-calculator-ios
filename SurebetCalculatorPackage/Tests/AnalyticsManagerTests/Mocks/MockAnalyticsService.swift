import Foundation
@testable import AnalyticsManager

/// Мок для AnalyticsService для использования в тестах
/// Хранит историю вызовов для проверки в тестах
final class MockAnalyticsService: AnalyticsService, @unchecked Sendable {
    // MARK: - Properties

    /// Количество вызовов метода log
    var logCallCount = 0

    /// Последнее переданное имя события
    var lastEventName: String?

    /// Последние переданные параметры
    var lastParameters: [String: AnalyticsParameterValue]?

    /// Все вызовы метода log (для проверки истории)
    var logCalls: [(name: String, parameters: [String: AnalyticsParameterValue]?)] = []

    // MARK: - AnalyticsService

    func log(name: String, parameters: [String: AnalyticsParameterValue]?) {
        logCallCount += 1
        lastEventName = name
        lastParameters = parameters
        logCalls.append((name: name, parameters: parameters))
    }
}
