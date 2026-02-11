import Foundation
import Survey

/// Константы, специфичные для Root-модуля.
enum RootConstants {
    /// Задержка перед показом запроса отзыва (1 секунда).
    static let reviewRequestDelay: UInt64 = NSEC_PER_SEC * 1
    /// Небольшая задержка перед показом опроса после перехода в раздел.
    /// Нужна, чтобы не пересекаться с push-навигацией на iOS 16.
    static let surveyPresentationDelay: UInt64 = 300_000_000

    /// Флаг для управления показом onboarding.
    /// По умолчанию выключен для релиза без onboarding.
    /// Использование:
    /// - `-enableOnboarding` для принудительного включения
    /// - `-disableOnboarding` для принудительного выключения
    static var isOnboardingEnabled: Bool {
        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains("-enableOnboarding") {
            return true
        }
        if arguments.contains("-disableOnboarding") {
            return false
        }
        return false
    }

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

    /// Флаг включения in-app опросов.
    /// Изменяется вручную в коде под релиз.
    static let isSurveyEnabled = true

    /// Ключ для хранения уже обработанных (dismiss/submit) опросов.
    static let handledSurveyIDsKey = "handled_survey_ids"

    /// Источник данных для опросов (mock/remote).
    static let surveyDataSource: SurveyDataSource = .remote

    /// Базовый URL API для remote-опросов.
    static let surveyAPIBaseURL = "http://api.surebet-calculator.ru"

    /// Сценарий mock-опроса для локального тестирования.
    static let surveyMockScenario: SurveyMockScenario = .rotation

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

enum SurveyDataSource {
    case mock
    case remote
}
