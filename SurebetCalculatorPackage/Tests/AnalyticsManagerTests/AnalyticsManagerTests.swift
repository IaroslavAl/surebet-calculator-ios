import Foundation
import Testing
@testable import AnalyticsManager

/// Тесты для AnalyticsManager и AnalyticsService
struct AnalyticsManagerTests {
    // MARK: - log(name:parameters:) Tests

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
        if case .string(let value1) = mockService.lastParameters?["key1"] {
            #expect(value1 == "value1")
        } else {
            Issue.record("key1 should be string with value 'value1'")
        }
        if case .int(let value2) = mockService.lastParameters?["key2"] {
            #expect(value2 == 42)
        } else {
            Issue.record("key2 should be int with value 42")
        }
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

    // MARK: - AnalyticsParameterValue.anyValue Tests

    @Test
    func anyValueWhenParameterIsString() {
        let parameter: AnalyticsParameterValue = .string("test")

        let anyValue = parameter.anyValue

        #expect(anyValue is String)
        if let stringValue = anyValue as? String {
            #expect(stringValue == "test")
        } else {
            Issue.record("anyValue should be String")
        }
    }

    @Test
    func anyValueWhenParameterIsInt() {
        let parameter: AnalyticsParameterValue = .int(42)

        let anyValue = parameter.anyValue

        #expect(anyValue is Int)
        if let intValue = anyValue as? Int {
            #expect(intValue == 42)
        } else {
            Issue.record("anyValue should be Int")
        }
    }

    @Test
    func anyValueWhenParameterIsDouble() {
        let parameter: AnalyticsParameterValue = .double(3.14)

        let anyValue = parameter.anyValue

        #expect(anyValue is Double)
        if let doubleValue = anyValue as? Double {
            #expect(doubleValue == 3.14)
        } else {
            Issue.record("anyValue should be Double")
        }
    }

    @Test
    func anyValueWhenParameterIsBool() {
        let parameter: AnalyticsParameterValue = .bool(true)

        let anyValue = parameter.anyValue

        #expect(anyValue is Bool)
        if let boolValue = anyValue as? Bool {
            #expect(boolValue == true)
        } else {
            Issue.record("anyValue should be Bool")
        }
    }

    // MARK: - AnalyticsEvent Tests

    @Test
    func analyticsEventNameWhenOnboardingStarted() {
        let event = AnalyticsEvent.onboardingStarted

        #expect(event.name == "onboarding_started")
        #expect(event.parameters == nil)
    }

    @Test
    func analyticsEventNameWhenOnboardingPageViewed() {
        let event = AnalyticsEvent.onboardingPageViewed(pageIndex: 2, pageTitle: "Test Page")

        #expect(event.name == "onboarding_page_viewed")
        #expect(event.parameters?["page_index"] == .int(2))
        #expect(event.parameters?["page_title"] == .string("Test Page"))
    }

    @Test
    func analyticsEventNameWhenOnboardingCompleted() {
        let event = AnalyticsEvent.onboardingCompleted(pagesViewed: 5)

        #expect(event.name == "onboarding_completed")
        #expect(event.parameters?["pages_viewed"] == .int(5))
    }

    @Test
    func analyticsEventNameWhenOnboardingSkipped() {
        let event = AnalyticsEvent.onboardingSkipped(lastPageIndex: 1)

        #expect(event.name == "onboarding_skipped")
        #expect(event.parameters?["last_page_index"] == .int(1))
    }

    @Test
    func analyticsEventNameWhenCalculatorRowAdded() {
        let event = AnalyticsEvent.calculatorRowAdded(rowCount: 3)

        #expect(event.name == "calculator_row_added")
        #expect(event.parameters?["row_count"] == .int(3))
    }

    @Test
    func analyticsEventNameWhenCalculatorRowRemoved() {
        let event = AnalyticsEvent.calculatorRowRemoved(rowCount: 2)

        #expect(event.name == "calculator_row_removed")
        #expect(event.parameters?["row_count"] == .int(2))
    }

    @Test
    func analyticsEventNameWhenCalculatorCleared() {
        let event = AnalyticsEvent.calculatorCleared

        #expect(event.name == "calculator_cleared")
        #expect(event.parameters == nil)
    }

    @Test
    func analyticsEventNameWhenCalculationPerformed() {
        let event = AnalyticsEvent.calculationPerformed(rowCount: 4, profitPercentage: 5.5)

        #expect(event.name == "calculation_performed")
        #expect(event.parameters?["row_count"] == .int(4))
        #expect(event.parameters?["profit_percentage"] == .double(5.5))
    }

    @Test
    func analyticsEventNameWhenReviewPromptShown() {
        let event = AnalyticsEvent.reviewPromptShown

        #expect(event.name == "review_prompt_shown")
        #expect(event.parameters == nil)
    }

    @Test
    func analyticsEventNameWhenReviewResponse() {
        let event = AnalyticsEvent.reviewResponse(enjoyingApp: true)

        #expect(event.name == "review_response")
        #expect(event.parameters?["enjoying_app"] == .bool(true))
    }

    @Test
    func analyticsEventNameWhenAppOpened() {
        let event = AnalyticsEvent.appOpened(sessionNumber: 10)

        #expect(event.name == "app_opened")
        #expect(event.parameters?["session_number"] == .int(10))
    }

    // MARK: - log(event:) Tests

    @Test
    func logEventWhenEventWithoutParameters() {
        let mockService = MockAnalyticsService()
        let event = AnalyticsEvent.onboardingStarted

        mockService.log(event: event)

        #expect(mockService.logEventCallCount == 1)
        #expect(mockService.lastEvent == event)
        #expect(mockService.logEventCalls.count == 1)
        #expect(mockService.logEventCalls[0] == event)
        #expect(mockService.logCallCount == 1)
        #expect(mockService.lastEventName == "onboarding_started")
        #expect(mockService.lastParameters == nil)
    }

    @Test
    func logEventWhenEventWithParameters() {
        let mockService = MockAnalyticsService()
        let event = AnalyticsEvent.onboardingPageViewed(pageIndex: 2, pageTitle: "Test Page")

        mockService.log(event: event)

        #expect(mockService.logEventCallCount == 1)
        #expect(mockService.lastEvent == event)
        #expect(mockService.logEventCalls.count == 1)
        #expect(mockService.logEventCalls[0] == event)
        #expect(mockService.logCallCount == 1)
        #expect(mockService.lastEventName == "onboarding_page_viewed")
        #expect(mockService.lastParameters?["page_index"] == .int(2))
        #expect(mockService.lastParameters?["page_title"] == .string("Test Page"))
    }
}
