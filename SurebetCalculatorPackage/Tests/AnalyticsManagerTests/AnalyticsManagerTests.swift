import Foundation
import Testing
@testable import AnalyticsManager

struct AnalyticsManagerTests {
    @Test
    func logWhenEventNameAndParametersProvided() {
        let mockService = MockAnalyticsService()
        let eventName = "test_event"
        let parameters: [String: AnalyticsParameterValue] = [
            "key1": .string("value1"),
            "key2": .int(42)
        ]

        mockService.log(name: eventName, parameters: parameters)

        #expect(mockService.logCallCount == 1)
        #expect(mockService.lastEventName == eventName)
        #expect(mockService.lastParameters?.count == 2)
        #expect(mockService.lastParameters?["key1"] == .string("value1"))
        #expect(mockService.lastParameters?["key2"] == .int(42))
    }

    @Test
    func logWhenEventNameWithoutParameters() {
        let mockService = MockAnalyticsService()
        let eventName = "test_event"

        mockService.log(name: eventName, parameters: nil)

        #expect(mockService.logCallCount == 1)
        #expect(mockService.lastEventName == eventName)
        #expect(mockService.lastParameters == nil)
    }

    @Test
    func anyValueWhenParameterIsString() {
        let parameter: AnalyticsParameterValue = .string("test")
        let anyValue = parameter.anyValue

        #expect(anyValue as? String == "test")
    }

    @Test
    func anyValueWhenParameterIsInt() {
        let parameter: AnalyticsParameterValue = .int(42)
        let anyValue = parameter.anyValue

        #expect(anyValue as? Int == 42)
    }

    @Test
    func anyValueWhenParameterIsDouble() {
        let parameter: AnalyticsParameterValue = .double(3.14)
        let anyValue = parameter.anyValue

        #expect(anyValue as? Double == 3.14)
    }

    @Test
    func anyValueWhenParameterIsBool() {
        let parameter: AnalyticsParameterValue = .bool(true)
        let anyValue = parameter.anyValue

        #expect(anyValue as? Bool == true)
    }

    @Test
    func analyticsEventNameWhenAppSessionStarted() {
        let event = AnalyticsEvent.appSessionStarted(
            startReason: "initial_launch",
            isFirstSession: true,
            featureOnboardingEnabled: false,
            featureReviewPromptEnabled: true
        )

        #expect(event.name == "app_session_started")
        #expect(event.parameters?["start_reason"] == .string("initial_launch"))
        #expect(event.parameters?["is_first_session"] == .bool(true))
        #expect(event.parameters?["feature_onboarding_enabled"] == .bool(false))
        #expect(event.parameters?["feature_review_prompt_enabled"] == .bool(true))
    }

    @Test
    func analyticsEventNameWhenAppSessionEnded() {
        let event = AnalyticsEvent.appSessionEnded(
            durationSeconds: 42,
            endReason: "entered_background"
        )

        #expect(event.name == "app_session_ended")
        #expect(event.parameters?["duration_seconds"] == .int(42))
        #expect(event.parameters?["end_reason"] == .string("entered_background"))
    }

    @Test
    func analyticsEventNameWhenOnboardingPageViewed() {
        let event = AnalyticsEvent.onboardingPageViewed(pageIndex: 2, pageID: "onboarding_page_3")

        #expect(event.name == "onboarding_page_viewed")
        #expect(event.parameters?["page_index"] == .int(2))
        #expect(event.parameters?["page_id"] == .string("onboarding_page_3"))
    }

    @Test
    func analyticsEventNameWhenNavigationSectionOpened() {
        let event = AnalyticsEvent.navigationSectionOpened(section: "calculator")

        #expect(event.name == "navigation_section_opened")
        #expect(event.parameters?["section"] == .string("calculator"))
    }

    @Test
    func analyticsEventNameWhenFeedbackEmailOpened() {
        let event = AnalyticsEvent.feedbackEmailOpened(sourceScreen: "main_menu")

        #expect(event.name == "feedback_email_opened")
        #expect(event.parameters?["source_screen"] == .string("main_menu"))
    }

    @Test
    func analyticsEventNameWhenCalculatorRowsCountChanged() {
        let event = AnalyticsEvent.calculatorRowsCountChanged(
            rowCount: 4,
            changeDirection: "increased"
        )

        #expect(event.name == "calculator_rows_count_changed")
        #expect(event.parameters?["row_count"] == .int(4))
        #expect(event.parameters?["change_direction"] == .string("increased"))
    }

    @Test
    func analyticsEventNameWhenCalculatorModeSelected() {
        let event = AnalyticsEvent.calculatorModeSelected(mode: "row")

        #expect(event.name == "calculator_mode_selected")
        #expect(event.parameters?["mode"] == .string("row"))
    }

    @Test
    func analyticsEventNameWhenCalculatorCalculationPerformed() {
        let event = AnalyticsEvent.calculatorCalculationPerformed(
            rowCount: 4,
            mode: "rows",
            profitPercentage: 5.5,
            isProfitable: true
        )

        #expect(event.name == "calculator_calculation_performed")
        #expect(event.parameters?["row_count"] == .int(4))
        #expect(event.parameters?["mode"] == .string("rows"))
        #expect(event.parameters?["profit_percentage"] == .double(5.5))
        #expect(event.parameters?["is_profitable"] == .bool(true))
    }

    @Test
    func analyticsEventNameWhenSettingsThemeChanged() {
        let event = AnalyticsEvent.settingsThemeChanged(theme: "dark")

        #expect(event.name == "settings_theme_changed")
        #expect(event.parameters?["theme"] == .string("dark"))
    }

    @Test
    func analyticsEventNameWhenSettingsLanguageChanged() {
        let event = AnalyticsEvent.settingsLanguageChanged(
            fromLanguage: "en",
            toLanguage: "ru"
        )

        #expect(event.name == "settings_language_changed")
        #expect(event.parameters?["from_language"] == .string("en"))
        #expect(event.parameters?["to_language"] == .string("ru"))
    }

    @Test
    func analyticsEventNameWhenReviewPromptDisplayed() {
        let event = AnalyticsEvent.reviewPromptDisplayed

        #expect(event.name == "review_prompt_displayed")
        #expect(event.parameters == nil)
    }

    @Test
    func analyticsEventNameWhenReviewPromptAnswered() {
        let event = AnalyticsEvent.reviewPromptAnswered(answer: "yes")

        #expect(event.name == "review_prompt_answered")
        #expect(event.parameters?["answer"] == .string("yes"))
    }

    @Test
    func logEventWhenEventWithoutParameters() {
        let mockService = MockAnalyticsService()
        let event = AnalyticsEvent.onboardingStarted

        mockService.log(event: event)

        #expect(mockService.logEventCallCount == 1)
        #expect(mockService.lastEvent == event)
        #expect(mockService.lastEventName == "onboarding_started")
        #expect(mockService.lastParameters == nil)
    }

    @Test
    func logEventWhenEventWithParameters() {
        let mockService = MockAnalyticsService()
        let event = AnalyticsEvent.onboardingPageViewed(pageIndex: 2, pageID: "onboarding_page_3")

        mockService.log(event: event)

        #expect(mockService.logEventCallCount == 1)
        #expect(mockService.lastEvent == event)
        #expect(mockService.lastEventName == "onboarding_page_viewed")
        #expect(mockService.lastParameters?["page_index"] == .int(2))
        #expect(mockService.lastParameters?["page_id"] == .string("onboarding_page_3"))
    }
}
