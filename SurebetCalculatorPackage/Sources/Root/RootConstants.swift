import Foundation

/// Константы, специфичные для Root-модуля.
enum RootConstants {
    /// Задержка перед показом запроса отзыва (1 секунда).
    static let reviewRequestDelay: UInt64 = NSEC_PER_SEC * 1

    /// Флаг для отключения баннеров через launch arguments.
    /// Использование: -disableBannerFetch
    static var isBannerFetchEnabled: Bool {
        if ProcessInfo.processInfo.arguments.contains("-disableBannerFetch") {
            return false
        }
        if isRunningTests {
            return true
        }
        return true
    }

    private static var isRunningTests: Bool {
        let environment = ProcessInfo.processInfo.environment
        if environment["XCTestConfigurationFilePath"] != nil {
            return true
        }
        if environment["XCTestBundlePath"] != nil {
            return true
        }
        if environment["XCTestSessionIdentifier"] != nil {
            return true
        }
        if environment["SWIFT_TESTING"] != nil {
            return true
        }
        return NSClassFromString("XCTestCase") != nil
    }
}
