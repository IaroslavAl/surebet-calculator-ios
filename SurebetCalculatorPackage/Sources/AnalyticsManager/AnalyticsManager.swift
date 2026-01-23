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
public struct AnalyticsManager: Sendable {
    /// Логирование события с типобезопасными параметрами
    /// - Parameters:
    ///   - name: Название события
    ///   - parameters: Словарь параметров с типобезопасными значениями
    public static func log(name: String, parameters: [String: AnalyticsParameterValue]? = nil) {
    #if !DEBUG
        let appMetricaParameters = parameters?.reduce(into: [AnyHashable: Any]()) { result, pair in
            result[pair.key] = pair.value.anyValue
        }
        AppMetrica.reportEvent(name: name, parameters: appMetricaParameters)
    #endif
    }
}
