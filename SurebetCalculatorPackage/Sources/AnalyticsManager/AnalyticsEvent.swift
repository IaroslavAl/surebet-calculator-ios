import Foundation

// MARK: - Analytics Event

/// Типобезопасный каталог событий аналитики.
/// Все события приложения определены как case этого enum с соответствующими параметрами.
public enum AnalyticsEvent: Sendable, Equatable {
    // MARK: - Onboarding

    /// Пользователь начал онбординг
    case onboardingStarted

    /// Пользователь просмотрел страницу онбординга
    /// - Parameters:
    ///   - pageIndex: Индекс страницы (0-based)
    ///   - pageTitle: Название страницы
    case onboardingPageViewed(pageIndex: Int, pageTitle: String)

    /// Пользователь завершил онбординг
    /// - Parameter pagesViewed: Количество просмотренных страниц
    case onboardingCompleted(pagesViewed: Int)

    /// Пользователь пропустил онбординг
    /// - Parameter lastPageIndex: Индекс последней просмотренной страницы
    case onboardingSkipped(lastPageIndex: Int)

    // MARK: - Calculator

    /// Добавлена строка калькулятора
    /// - Parameter rowCount: Текущее количество строк
    case calculatorRowAdded(rowCount: Int)

    /// Удалена строка калькулятора
    /// - Parameter rowCount: Текущее количество строк
    case calculatorRowRemoved(rowCount: Int)

    /// Калькулятор очищен
    case calculatorCleared

    /// Выполнен расчёт
    /// - Parameters:
    ///   - rowCount: Количество строк
    ///   - profitPercentage: Процент прибыли
    case calculationPerformed(rowCount: Int, profitPercentage: Double)

    // MARK: - Review

    /// Показан запрос на оценку приложения
    case reviewPromptShown

    /// Ответ пользователя на запрос оценки
    /// - Parameter enjoyingApp: Нравится ли пользователю приложение
    case reviewResponse(enjoyingApp: Bool)

    // MARK: - App

    /// Приложение открыто
    /// - Parameter sessionNumber: Номер сессии
    case appOpened(sessionNumber: Int)
}

// MARK: - Event Properties

extension AnalyticsEvent {
    /// Название события в snake_case для AppMetrica
    public var name: String {
        switch self {
        case .onboardingStarted:
            return "onboarding_started"
        case .onboardingPageViewed:
            return "onboarding_page_viewed"
        case .onboardingCompleted:
            return "onboarding_completed"
        case .onboardingSkipped:
            return "onboarding_skipped"
        case .calculatorRowAdded:
            return "calculator_row_added"
        case .calculatorRowRemoved:
            return "calculator_row_removed"
        case .calculatorCleared:
            return "calculator_cleared"
        case .calculationPerformed:
            return "calculation_performed"
        case .reviewPromptShown:
            return "review_prompt_shown"
        case .reviewResponse:
            return "review_response"
        case .appOpened:
            return "app_opened"
        }
    }

    /// Параметры события для AppMetrica
    public var parameters: [String: AnalyticsParameterValue]? {
        switch self {
        case .onboardingStarted,
             .calculatorCleared,
             .reviewPromptShown:
            return nil

        case .onboardingPageViewed(let pageIndex, let pageTitle):
            return [
                "page_index": .int(pageIndex),
                "page_title": .string(pageTitle)
            ]

        case .onboardingCompleted(let pagesViewed):
            return ["pages_viewed": .int(pagesViewed)]

        case .onboardingSkipped(let lastPageIndex):
            return ["last_page_index": .int(lastPageIndex)]

        case .calculatorRowAdded(let rowCount),
             .calculatorRowRemoved(let rowCount):
            return ["row_count": .int(rowCount)]

        case .calculationPerformed(let rowCount, let profitPercentage):
            return [
                "row_count": .int(rowCount),
                "profit_percentage": .double(profitPercentage)
            ]

        case .reviewResponse(let enjoyingApp):
            return ["enjoying_app": .bool(enjoyingApp)]

        case .appOpened(let sessionNumber):
            return ["session_number": .int(sessionNumber)]
        }
    }
}
