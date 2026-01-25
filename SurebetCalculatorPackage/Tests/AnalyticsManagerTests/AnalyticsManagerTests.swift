import Foundation
import Testing
@testable import AnalyticsManager

// swiftlint:disable file_length
/// Тесты для AnalyticsManager и AnalyticsService
struct AnalyticsManagerTests {
    // MARK: - log(name:parameters:) Tests

    /// Тест логирования события с параметрами
    @Test
    func logWhenEventNameAndParametersProvided() {
        // Given
        let mockService = MockAnalyticsService()
        let eventName = "test_event"
        let parameters: [String: AnalyticsParameterValue] = [
            "key1": .string("value1"),
            "key2": .int(42)
        ]

        // When
        mockService.log(name: eventName, parameters: parameters)

        // Then
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

    /// Тест логирования события без параметров
    @Test
    func logWhenEventNameWithoutParameters() {
        // Given
        let mockService = MockAnalyticsService()
        let eventName = "test_event"

        // When
        mockService.log(name: eventName, parameters: nil)

        // Then
        #expect(mockService.logCallCount == 1)
        #expect(mockService.lastEventName == eventName)
        #expect(mockService.lastParameters == nil)
    }

    /// Тест логирования события с пустыми параметрами
    @Test
    func logWhenEventNameWithEmptyParameters() {
        // Given
        let mockService = MockAnalyticsService()
        let eventName = "test_event"
        let parameters: [String: AnalyticsParameterValue] = [:]

        // When
        mockService.log(name: eventName, parameters: parameters)

        // Then
        #expect(mockService.logCallCount == 1)
        #expect(mockService.lastEventName == eventName)
        #expect(mockService.lastParameters?.isEmpty == true)
    }

    // MARK: - Parameter Types Tests

    /// Тест логирования с параметром типа String
    @Test
    func logWhenParameterTypeIsString() {
        // Given
        let mockService = MockAnalyticsService()
        let parameters: [String: AnalyticsParameterValue] = [
            "string_param": .string("test_string")
        ]

        // When
        mockService.log(name: "test", parameters: parameters)

        // Then
        if case .string(let value) = mockService.lastParameters?["string_param"] {
            #expect(value == "test_string")
        } else {
            Issue.record("Parameter should be of type string")
        }
    }

    /// Тест логирования с параметром типа Int
    @Test
    func logWhenParameterTypeIsInt() {
        // Given
        let mockService = MockAnalyticsService()
        let parameters: [String: AnalyticsParameterValue] = [
            "int_param": .int(123)
        ]

        // When
        mockService.log(name: "test", parameters: parameters)

        // Then
        if case .int(let value) = mockService.lastParameters?["int_param"] {
            #expect(value == 123)
        } else {
            Issue.record("Parameter should be of type int")
        }
    }

    /// Тест логирования с параметром типа Double
    @Test
    func logWhenParameterTypeIsDouble() {
        // Given
        let mockService = MockAnalyticsService()
        let parameters: [String: AnalyticsParameterValue] = [
            "double_param": .double(3.14)
        ]

        // When
        mockService.log(name: "test", parameters: parameters)

        // Then
        if case .double(let value) = mockService.lastParameters?["double_param"] {
            #expect(value == 3.14)
        } else {
            Issue.record("Parameter should be of type double")
        }
    }

    /// Тест логирования с параметром типа Bool
    @Test
    func logWhenParameterTypeIsBool() {
        // Given
        let mockService = MockAnalyticsService()
        let parameters: [String: AnalyticsParameterValue] = [
            "bool_param": .bool(true)
        ]

        // When
        mockService.log(name: "test", parameters: parameters)

        // Then
        if case .bool(let value) = mockService.lastParameters?["bool_param"] {
            #expect(value == true)
        } else {
            Issue.record("Parameter should be of type bool")
        }
    }

    /// Тест логирования с несколькими параметрами разных типов
    @Test
    func logWhenMultipleParameterTypes() {
        // Given
        let mockService = MockAnalyticsService()
        let parameters: [String: AnalyticsParameterValue] = [
            "string": .string("test"),
            "int": .int(42),
            "double": .double(3.14),
            "bool": .bool(false)
        ]

        // When
        mockService.log(name: "test", parameters: parameters)

        // Then
        #expect(mockService.lastParameters?.count == 4)
        if case .string(let stringValue) = mockService.lastParameters?["string"] {
            #expect(stringValue == "test")
        } else {
            Issue.record("string parameter should be 'test'")
        }
        if case .int(let intValue) = mockService.lastParameters?["int"] {
            #expect(intValue == 42)
        } else {
            Issue.record("int parameter should be 42")
        }
        if case .double(let doubleValue) = mockService.lastParameters?["double"] {
            #expect(doubleValue == 3.14)
        } else {
            Issue.record("double parameter should be 3.14")
        }
        if case .bool(let boolValue) = mockService.lastParameters?["bool"] {
            #expect(boolValue == false)
        } else {
            Issue.record("bool parameter should be false")
        }
    }

    // MARK: - AnalyticsParameterValue.anyValue Tests

    /// Тест конвертации AnalyticsParameterValue в Any для String
    @Test
    func anyValueWhenParameterIsString() {
        // Given
        let parameter: AnalyticsParameterValue = .string("test")

        // When
        let anyValue = parameter.anyValue

        // Then
        #expect(anyValue is String)
        if let stringValue = anyValue as? String {
            #expect(stringValue == "test")
        } else {
            Issue.record("anyValue should be String")
        }
    }

    /// Тест конвертации AnalyticsParameterValue в Any для Int
    @Test
    func anyValueWhenParameterIsInt() {
        // Given
        let parameter: AnalyticsParameterValue = .int(42)

        // When
        let anyValue = parameter.anyValue

        // Then
        #expect(anyValue is Int)
        if let intValue = anyValue as? Int {
            #expect(intValue == 42)
        } else {
            Issue.record("anyValue should be Int")
        }
    }

    /// Тест конвертации AnalyticsParameterValue в Any для Double
    @Test
    func anyValueWhenParameterIsDouble() {
        // Given
        let parameter: AnalyticsParameterValue = .double(3.14)

        // When
        let anyValue = parameter.anyValue

        // Then
        #expect(anyValue is Double)
        if let doubleValue = anyValue as? Double {
            #expect(doubleValue == 3.14)
        } else {
            Issue.record("anyValue should be Double")
        }
    }

    /// Тест конвертации AnalyticsParameterValue в Any для Bool
    @Test
    func anyValueWhenParameterIsBool() {
        // Given
        let parameter: AnalyticsParameterValue = .bool(true)

        // When
        let anyValue = parameter.anyValue

        // Then
        #expect(anyValue is Bool)
        if let boolValue = anyValue as? Bool {
            #expect(boolValue == true)
        } else {
            Issue.record("anyValue should be Bool")
        }
    }

    // MARK: - AnalyticsManager Static Method Tests

    /// Тест статического метода AnalyticsManager.log()
    @Test
    func staticLogWhenCalled() {
        // Given
        let eventName = "static_test_event"
        let parameters: [String: AnalyticsParameterValue] = [
            "test_key": .string("test_value")
        ]

        // When
        AnalyticsManager.log(name: eventName, parameters: parameters)

        // Then
        // В DEBUG режиме метод не должен вызывать AppMetrica
        // Проверяем, что метод выполняется без ошибок
        // Реальная проверка вызова AppMetrica невозможна в DEBUG режиме
        // из-за #if !DEBUG в реализации
    }

    // MARK: - Multiple Calls Tests

    /// Тест множественных вызовов log
    @Test
    func logWhenMultipleCalls() {
        // Given
        let mockService = MockAnalyticsService()

        // When
        mockService.log(name: "event1", parameters: ["key1": .string("value1")])
        mockService.log(name: "event2", parameters: ["key2": .int(2)])
        mockService.log(name: "event3", parameters: nil)

        // Then
        #expect(mockService.logCallCount == 3)
        #expect(mockService.logCalls.count == 3)
        #expect(mockService.logCalls[0].name == "event1")
        #expect(mockService.logCalls[1].name == "event2")
        #expect(mockService.logCalls[2].name == "event3")
        #expect(mockService.lastEventName == "event3")
    }

    // MARK: - AnalyticsEvent Tests

    /// Тест названия события onboarding_started
    @Test
    func analyticsEventNameWhenOnboardingStarted() {
        // Given
        let event = AnalyticsEvent.onboardingStarted

        // Then
        #expect(event.name == "onboarding_started")
        #expect(event.parameters == nil)
    }

    /// Тест названия и параметров события onboarding_page_viewed
    @Test
    func analyticsEventNameWhenOnboardingPageViewed() {
        // Given
        let event = AnalyticsEvent.onboardingPageViewed(pageIndex: 2, pageTitle: "Test Page")

        // Then
        #expect(event.name == "onboarding_page_viewed")
        #expect(event.parameters?["page_index"] == .int(2))
        #expect(event.parameters?["page_title"] == .string("Test Page"))
    }

    /// Тест названия и параметров события onboarding_completed
    @Test
    func analyticsEventNameWhenOnboardingCompleted() {
        // Given
        let event = AnalyticsEvent.onboardingCompleted(pagesViewed: 5)

        // Then
        #expect(event.name == "onboarding_completed")
        #expect(event.parameters?["pages_viewed"] == .int(5))
    }

    /// Тест названия и параметров события onboarding_skipped
    @Test
    func analyticsEventNameWhenOnboardingSkipped() {
        // Given
        let event = AnalyticsEvent.onboardingSkipped(lastPageIndex: 1)

        // Then
        #expect(event.name == "onboarding_skipped")
        #expect(event.parameters?["last_page_index"] == .int(1))
    }

    /// Тест названия и параметров события calculator_row_added
    @Test
    func analyticsEventNameWhenCalculatorRowAdded() {
        // Given
        let event = AnalyticsEvent.calculatorRowAdded(rowCount: 3)

        // Then
        #expect(event.name == "calculator_row_added")
        #expect(event.parameters?["row_count"] == .int(3))
    }

    /// Тест названия и параметров события calculator_row_removed
    @Test
    func analyticsEventNameWhenCalculatorRowRemoved() {
        // Given
        let event = AnalyticsEvent.calculatorRowRemoved(rowCount: 2)

        // Then
        #expect(event.name == "calculator_row_removed")
        #expect(event.parameters?["row_count"] == .int(2))
    }

    /// Тест названия события calculator_cleared
    @Test
    func analyticsEventNameWhenCalculatorCleared() {
        // Given
        let event = AnalyticsEvent.calculatorCleared

        // Then
        #expect(event.name == "calculator_cleared")
        #expect(event.parameters == nil)
    }

    /// Тест названия и параметров события calculation_performed
    @Test
    func analyticsEventNameWhenCalculationPerformed() {
        // Given
        let event = AnalyticsEvent.calculationPerformed(rowCount: 4, profitPercentage: 5.5)

        // Then
        #expect(event.name == "calculation_performed")
        #expect(event.parameters?["row_count"] == .int(4))
        #expect(event.parameters?["profit_percentage"] == .double(5.5))
    }

    /// Тест названия и параметров события banner_viewed
    @Test
    func analyticsEventNameWhenBannerViewed() {
        // Given
        let event = AnalyticsEvent.bannerViewed(bannerId: "test_id", bannerType: .fullscreen)

        // Then
        #expect(event.name == "banner_viewed")
        #expect(event.parameters?["banner_id"] == .string("test_id"))
        #expect(event.parameters?["banner_type"] == .string("fullscreen"))
    }

    /// Тест названия и параметров события banner_clicked
    @Test
    func analyticsEventNameWhenBannerClicked() {
        // Given
        let event = AnalyticsEvent.bannerClicked(bannerId: "test_id", bannerType: .inline)

        // Then
        #expect(event.name == "banner_clicked")
        #expect(event.parameters?["banner_id"] == .string("test_id"))
        #expect(event.parameters?["banner_type"] == .string("inline"))
    }

    /// Тест названия и параметров события banner_closed
    @Test
    func analyticsEventNameWhenBannerClosed() {
        // Given
        let event = AnalyticsEvent.bannerClosed(bannerId: "test_id", bannerType: .fullscreen)

        // Then
        #expect(event.name == "banner_closed")
        #expect(event.parameters?["banner_id"] == .string("test_id"))
        #expect(event.parameters?["banner_type"] == .string("fullscreen"))
    }

    /// Тест названия события review_prompt_shown
    @Test
    func analyticsEventNameWhenReviewPromptShown() {
        // Given
        let event = AnalyticsEvent.reviewPromptShown

        // Then
        #expect(event.name == "review_prompt_shown")
        #expect(event.parameters == nil)
    }

    /// Тест названия и параметров события review_response
    @Test
    func analyticsEventNameWhenReviewResponse() {
        // Given
        let event = AnalyticsEvent.reviewResponse(enjoyingApp: true)

        // Then
        #expect(event.name == "review_response")
        #expect(event.parameters?["enjoying_app"] == .bool(true))
    }

    /// Тест названия и параметров события app_opened
    @Test
    func analyticsEventNameWhenAppOpened() {
        // Given
        let event = AnalyticsEvent.appOpened(sessionNumber: 10)

        // Then
        #expect(event.name == "app_opened")
        #expect(event.parameters?["session_number"] == .int(10))
    }

    // MARK: - log(event:) Tests

    /// Тест логирования типобезопасного события без параметров
    @Test
    func logEventWhenEventWithoutParameters() {
        // Given
        let mockService = MockAnalyticsService()
        let event = AnalyticsEvent.onboardingStarted

        // When
        mockService.log(event: event)

        // Then
        #expect(mockService.logEventCallCount == 1)
        #expect(mockService.lastEvent == event)
        #expect(mockService.logEventCalls.count == 1)
        #expect(mockService.logEventCalls[0] == event)
        // Проверяем, что также вызван старый метод
        #expect(mockService.logCallCount == 1)
        #expect(mockService.lastEventName == "onboarding_started")
        #expect(mockService.lastParameters == nil)
    }

    /// Тест логирования типобезопасного события с параметрами
    @Test
    func logEventWhenEventWithParameters() {
        // Given
        let mockService = MockAnalyticsService()
        let event = AnalyticsEvent.onboardingPageViewed(pageIndex: 2, pageTitle: "Test Page")

        // When
        mockService.log(event: event)

        // Then
        #expect(mockService.logEventCallCount == 1)
        #expect(mockService.lastEvent == event)
        #expect(mockService.logEventCalls.count == 1)
        #expect(mockService.logEventCalls[0] == event)
        // Проверяем, что также вызван старый метод
        #expect(mockService.logCallCount == 1)
        #expect(mockService.lastEventName == "onboarding_page_viewed")
        #expect(mockService.lastParameters?["page_index"] == .int(2))
        #expect(mockService.lastParameters?["page_title"] == .string("Test Page"))
    }

    /// Тест множественных вызовов log(event:)
    @Test
    func logEventWhenMultipleCalls() {
        // Given
        let mockService = MockAnalyticsService()
        let event1 = AnalyticsEvent.onboardingStarted
        let event2 = AnalyticsEvent.calculatorRowAdded(rowCount: 3)
        let event3 = AnalyticsEvent.appOpened(sessionNumber: 5)

        // When
        mockService.log(event: event1)
        mockService.log(event: event2)
        mockService.log(event: event3)

        // Then
        #expect(mockService.logEventCallCount == 3)
        #expect(mockService.logEventCalls.count == 3)
        #expect(mockService.logEventCalls[0] == event1)
        #expect(mockService.logEventCalls[1] == event2)
        #expect(mockService.logEventCalls[2] == event3)
        #expect(mockService.lastEvent == event3)
        // Проверяем, что также вызван старый метод для каждого события
        #expect(mockService.logCallCount == 3)
        #expect(mockService.logCalls[0].name == "onboarding_started")
        #expect(mockService.logCalls[1].name == "calculator_row_added")
        #expect(mockService.logCalls[2].name == "app_opened")
    }
}
