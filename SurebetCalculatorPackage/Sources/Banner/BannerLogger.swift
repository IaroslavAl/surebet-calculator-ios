import Foundation
import OSLog

/// Логгер для модуля Banner
enum BannerLogger {
    /// Логгер для сервиса баннеров
    static let service = Logger(subsystem: "ru.surebet-calculator.banner", category: "Service")
}
