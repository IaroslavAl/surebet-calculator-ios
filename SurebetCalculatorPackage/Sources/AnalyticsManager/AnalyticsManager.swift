import AppMetricaCore
import Foundation

// MARK: - Analytics Parameter Value

/// Типобезопасное значение параметра аналитики
public enum AnalyticsParameterValue: Sendable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)

    /// Конвертация в Any для AppMetrica
    var anyValue: Any {
        switch self {
        case .string(let value):
            return value
        case .int(let value):
            return value
        case .double(let value):
            return value
        case .bool(let value):
            return value
        }
    }
}

// MARK: - Analytics Manager

/// Менеджер аналитики с типобезопасными параметрами
public struct AnalyticsManager: AnalyticsService, Sendable {
    // MARK: - Initialization

    /// Публичный инициализатор
    public init() {}

    // MARK: - Public Methods

    /// Логирование типобезопасного события
    /// - Parameter event: Событие для логирования
    public func log(event: AnalyticsEvent) {
        log(name: event.name, parameters: event.parameters)
    }

    /// Логирование события с типобезопасными параметрами
    /// - Parameters:
    ///   - name: Название события
    ///   - parameters: Словарь параметров с типобезопасными значениями
    /// - Note: Deprecated. Используйте `log(event:)` для типобезопасного логирования.
    public func log(name: String, parameters: [String: AnalyticsParameterValue]?) {
        #if !DEBUG
        let appMetricaParameters = parameters?.reduce(into: [AnyHashable: Any]()) { result, pair in
            result[pair.key] = pair.value.anyValue
        }
        AppMetrica.reportEvent(name: name, parameters: appMetricaParameters)
        #endif
    }

    /// Статический метод для обратной совместимости
    /// - Parameters:
    ///   - name: Название события
    ///   - parameters: Словарь параметров с типобезопасными значениями
    /// - Note: Deprecated. Используйте экземпляр AnalyticsManager и метод `log(event:)`.
    public static func log(name: String, parameters: [String: AnalyticsParameterValue]? = nil) {
        let manager = AnalyticsManager()
        manager.log(name: name, parameters: parameters)
    }

    /// Статический метод для типобезопасного логирования
    /// - Parameter event: Событие для логирования
    /// - Note: Deprecated. Используйте экземпляр AnalyticsManager и метод `log(event:)`.
    public static func log(event: AnalyticsEvent) {
        let manager = AnalyticsManager()
        manager.log(event: event)
    }
}
