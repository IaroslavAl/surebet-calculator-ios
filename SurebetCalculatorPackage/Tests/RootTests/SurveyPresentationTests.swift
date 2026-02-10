import Foundation
import MainMenu
import Survey
import Testing
@testable import AnalyticsManager
@testable import Root
@testable import ReviewHandler

@MainActor
@Suite(.serialized)
struct SurveyPresentationTests {
    @Test
    func surveyShownOncePerSessionAndDismissedForeverByID() async {
        // Given
        let defaults = UserDefaults(suiteName: "survey-tests-\(UUID().uuidString)") ?? .standard
        defaults.removeObject(forKey: RootConstants.handledSurveyIDsKey)
        let analytics = MockAnalyticsService()
        let service = TestSurveyService(
            survey: SurveyModel(
                id: "survey_id_1",
                version: 1,
                title: "Title",
                body: "Body",
                submitButtonTitle: "Submit",
                fields: []
            )
        )
        let viewModel = RootViewModel(
            analyticsService: analytics,
            reviewService: MockReviewService(),
            delay: ImmediateDelay(),
            surveyService: service,
            surveyLocaleProvider: { "en" },
            surveyDefaults: defaults,
            isSurveyEnabled: true
        )

        // When
        viewModel.send(.fetchSurvey)
        viewModel.send(.sectionOpened(.calculator))
        await awaitCondition { viewModel.surveyIsPresented }

        // Then
        #expect(viewModel.surveyIsPresented == true)
        #expect(
            analytics.lastEvent == .surveyShown(
                surveyId: "survey_id_1",
                surveyVersion: 1,
                sourceScreen: "calculator"
            )
        )

        // When
        viewModel.send(.setSurveyPresented(false))
        viewModel.send(.surveySheetDismissed)
        viewModel.send(.sectionOpened(.settings))
        await awaitCondition {
            defaults.stringArray(forKey: RootConstants.handledSurveyIDsKey)?.contains("survey_id_1") == true
        }

        // Then
        #expect(viewModel.surveyIsPresented == false)
        #expect(defaults.stringArray(forKey: RootConstants.handledSurveyIDsKey)?.contains("survey_id_1") == true)
    }

    @Test
    func surveyNotShownAgainAfterSubmit() async {
        // Given
        let defaults = UserDefaults(suiteName: "survey-tests-submit-\(UUID().uuidString)") ?? .standard
        defaults.removeObject(forKey: RootConstants.handledSurveyIDsKey)
        let analytics = MockAnalyticsService()
        let service = TestSurveyService(
            survey: SurveyModel(
                id: "survey_id_2",
                version: 5,
                title: "Title",
                body: "Body",
                submitButtonTitle: "Submit",
                fields: [
                    SurveyField(
                        id: "rating",
                        title: "Rate",
                        isRequired: true,
                        type: .ratingScale(config: SurveyRatingScaleConfig(minValue: 1, maxValue: 10, step: 1))
                    )
                ]
            )
        )
        let viewModel = RootViewModel(
            analyticsService: analytics,
            reviewService: MockReviewService(),
            delay: ImmediateDelay(),
            surveyService: service,
            surveyLocaleProvider: { "en" },
            surveyDefaults: defaults,
            isSurveyEnabled: true
        )

        // When
        viewModel.send(.fetchSurvey)
        viewModel.send(.sectionOpened(.instructions))
        await awaitCondition { viewModel.surveyIsPresented }

        let submission = SurveySubmission(
            surveyID: "survey_id_2",
            surveyVersion: 5,
            answers: [
                SurveyAnswer(fieldID: "rating", value: .rating(9))
            ]
        )
        viewModel.send(.surveySubmitted(submission))
        viewModel.send(.surveySheetDismissed)
        await awaitCondition {
            defaults.stringArray(forKey: RootConstants.handledSurveyIDsKey)?.contains("survey_id_2") == true
        }

        // Then
        #expect(defaults.stringArray(forKey: RootConstants.handledSurveyIDsKey)?.contains("survey_id_2") == true)
        #expect(viewModel.surveyIsPresented == false)

        // When
        viewModel.send(.sectionOpened(.calculator))

        // Then
        #expect(viewModel.surveyIsPresented == false)
    }

    private func awaitCondition(
        _ condition: @escaping () -> Bool,
        maxIterations: Int = 50
    ) async {
        for _ in 0..<maxIterations {
            if condition() {
                return
            }
            await Task.yield()
        }
    }
}

private struct TestSurveyService: SurveyService {
    let survey: SurveyModel?

    func fetchActiveSurvey(localeIdentifier: String) async throws -> SurveyModel? {
        survey
    }
}
