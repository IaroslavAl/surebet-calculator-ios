import Foundation
import Survey

/// Константы, специфичные для Root-модуля.
enum RootConstants {
    /// Задержка перед показом запроса отзыва (1 секунда).
    static let reviewRequestDelay: UInt64 = NSEC_PER_SEC * 1
    /// Небольшая задержка перед показом опроса после перехода в раздел.
    /// Нужна, чтобы не пересекаться с push-навигацией на iOS 16.
    static let surveyPresentationDelay: UInt64 = 300_000_000

    /// Ключ для хранения уже обработанных (dismiss/submit) опросов.
    static let handledSurveyIDsKey = "handled_survey_ids"

    /// Источник данных для опросов (mock/remote).
    static let surveyDataSource: SurveyDataSource = .remote

    /// Базовый URL API для remote-опросов.
    static let surveyAPIBaseURL = "http://api.surebet-calculator.ru"

    /// Сценарий mock-опроса для локального тестирования.
    static let surveyMockScenario: SurveyMockScenario = .rotation
}

enum SurveyDataSource {
    case mock
    case remote
}
