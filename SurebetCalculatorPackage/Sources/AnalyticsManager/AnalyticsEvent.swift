import Foundation

// MARK: - Analytics Event

/// Типобезопасный каталог событий аналитики.
/// Все события приложения определены как case этого enum с соответствующими параметрами.
public enum AnalyticsEvent: Sendable, Equatable {
    // MARK: - App Session

    /// Начало пользовательской сессии.
    /// - Parameters:
    ///   - startReason: Причина старта сессии.
    ///   - isFirstSession: Первая ли это сессия установки.
    ///   - featureOnboardingEnabled: Включен ли флаг onboarding.
    ///   - featureReviewPromptEnabled: Включен ли флаг review prompt.
    case appSessionStarted(
        startReason: String,
        isFirstSession: Bool,
        featureOnboardingEnabled: Bool,
        featureReviewPromptEnabled: Bool
    )

    /// Завершение пользовательской сессии.
    /// - Parameters:
    ///   - durationSeconds: Длительность сессии в секундах.
    ///   - endReason: Причина завершения сессии.
    case appSessionEnded(durationSeconds: Int, endReason: String)

    // MARK: - Onboarding

    /// Пользователь начал онбординг
    case onboardingStarted

    /// Пользователь просмотрел страницу онбординга
    /// - Parameters:
    ///   - pageIndex: Индекс страницы (0-based)
    ///   - pageID: Идентификатор страницы
    case onboardingPageViewed(pageIndex: Int, pageID: String)

    /// Пользователь завершил онбординг
    /// - Parameter pagesViewed: Количество просмотренных страниц
    case onboardingCompleted(pagesViewed: Int)

    /// Пользователь пропустил онбординг
    /// - Parameter lastPageIndex: Индекс последней просмотренной страницы
    case onboardingSkipped(lastPageIndex: Int)

    // MARK: - Navigation

    /// Открыт раздел приложения.
    /// - Parameter section: Идентификатор раздела.
    case navigationSectionOpened(section: String)

    /// Открыта форма обратной связи по email.
    /// - Parameter sourceScreen: Экран-источник действия.
    case feedbackEmailOpened(sourceScreen: String)

    // MARK: - Calculator

    /// Изменено количество исходов в калькуляторе.
    /// - Parameters:
    ///   - rowCount: Текущее количество исходов.
    ///   - changeDirection: Направление изменения (`increased`/`decreased`).
    case calculatorRowsCountChanged(rowCount: Int, changeDirection: String)

    /// Выбран режим расчета.
    /// - Parameter mode: Режим расчета (`total`/`rows`/`row`).
    case calculatorModeSelected(mode: String)

    /// Калькулятор очищен
    case calculatorCleared

    /// Выполнен расчёт
    /// - Parameters:
    ///   - rowCount: Количество строк
    ///   - mode: Режим расчета
    ///   - profitPercentage: Процент прибыли
    ///   - isProfitable: Признак положительной прибыли
    case calculatorCalculationPerformed(
        rowCount: Int,
        mode: String,
        profitPercentage: Double,
        isProfitable: Bool
    )

    // MARK: - Settings

    /// Пользователь изменил тему приложения.
    /// - Parameter theme: Значение темы.
    case settingsThemeChanged(theme: String)

    /// Пользователь изменил язык приложения.
    /// - Parameters:
    ///   - fromLanguage: Предыдущий язык.
    ///   - toLanguage: Новый язык.
    case settingsLanguageChanged(fromLanguage: String, toLanguage: String)

    // MARK: - Review

    /// Показан запрос на оценку приложения.
    case reviewPromptDisplayed

    /// Ответ пользователя на запрос оценки.
    /// - Parameter answer: Ответ пользователя (`yes`/`no`).
    case reviewPromptAnswered(answer: String)
}

// MARK: - Event Properties

extension AnalyticsEvent {
    /// Название события в snake_case для AppMetrica
    public var name: String {
        switch self {
        case .appSessionStarted:
            return "app_session_started"
        case .appSessionEnded:
            return "app_session_ended"
        case .onboardingStarted:
            return "onboarding_started"
        case .onboardingPageViewed:
            return "onboarding_page_viewed"
        case .onboardingCompleted:
            return "onboarding_completed"
        case .onboardingSkipped:
            return "onboarding_skipped"
        case .navigationSectionOpened:
            return "navigation_section_opened"
        case .feedbackEmailOpened:
            return "feedback_email_opened"
        case .calculatorRowsCountChanged:
            return "calculator_rows_count_changed"
        case .calculatorModeSelected:
            return "calculator_mode_selected"
        case .calculatorCleared:
            return "calculator_cleared"
        case .calculatorCalculationPerformed:
            return "calculator_calculation_performed"
        case .settingsThemeChanged:
            return "settings_theme_changed"
        case .settingsLanguageChanged:
            return "settings_language_changed"
        case .reviewPromptDisplayed:
            return "review_prompt_displayed"
        case .reviewPromptAnswered:
            return "review_prompt_answered"
        }
    }

    /// Параметры события для AppMetrica
    public var parameters: [String: AnalyticsParameterValue]? {
        switch self {
        case let .appSessionStarted(
            startReason,
            isFirstSession,
            featureOnboardingEnabled,
            featureReviewPromptEnabled
        ):
            return [
                "start_reason": .string(startReason),
                "is_first_session": .bool(isFirstSession),
                "feature_onboarding_enabled": .bool(featureOnboardingEnabled),
                "feature_review_prompt_enabled": .bool(featureReviewPromptEnabled)
            ]

        case let .appSessionEnded(durationSeconds, endReason):
            return [
                "duration_seconds": .int(durationSeconds),
                "end_reason": .string(endReason)
            ]

        case .onboardingStarted,
             .calculatorCleared,
             .reviewPromptDisplayed:
            return nil

        case let .onboardingPageViewed(pageIndex, pageID):
            return [
                "page_index": .int(pageIndex),
                "page_id": .string(pageID)
            ]

        case .onboardingCompleted(let pagesViewed):
            return ["pages_viewed": .int(pagesViewed)]

        case .onboardingSkipped(let lastPageIndex):
            return ["last_page_index": .int(lastPageIndex)]

        case let .navigationSectionOpened(section):
            return ["section": .string(section)]

        case let .feedbackEmailOpened(sourceScreen):
            return ["source_screen": .string(sourceScreen)]

        case let .calculatorRowsCountChanged(rowCount, changeDirection):
            return [
                "row_count": .int(rowCount),
                "change_direction": .string(changeDirection)
            ]

        case let .calculatorModeSelected(mode):
            return ["mode": .string(mode)]

        case let .calculatorCalculationPerformed(rowCount, mode, profitPercentage, isProfitable):
            return [
                "row_count": .int(rowCount),
                "mode": .string(mode),
                "profit_percentage": .double(profitPercentage),
                "is_profitable": .bool(isProfitable)
            ]

        case let .settingsThemeChanged(theme):
            return ["theme": .string(theme)]

        case let .settingsLanguageChanged(fromLanguage, toLanguage):
            return [
                "from_language": .string(fromLanguage),
                "to_language": .string(toLanguage)
            ]

        case let .reviewPromptAnswered(answer):
            return ["answer": .string(answer)]
        }
    }
}
