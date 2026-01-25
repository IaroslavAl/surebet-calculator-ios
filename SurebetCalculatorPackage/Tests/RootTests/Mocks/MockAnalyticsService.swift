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

    /// Количество вызовов метода log(event:)
    var logEventCallCount = 0

    /// Последнее переданное событие
    var lastEvent: AnalyticsEvent?

    /// Все вызовы метода log(event:) (для проверки истории)
    var logEventCalls: [AnalyticsEvent] = []

    // MARK: - AnalyticsService

    func log(event: AnalyticsEvent) {
        logEventCallCount += 1
        lastEvent = event
        logEventCalls.append(event)
        // Также вызываем старый метод для обратной совместимости
        log(name: event.name, parameters: event.parameters)
    }

    func log(name: String, parameters: [String: AnalyticsParameterValue]?) {
        logCallCount += 1
        lastEventName = name
        lastParameters = parameters
        logCalls.append((name: name, parameters: parameters))
    }
}
