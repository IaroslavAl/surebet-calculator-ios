import Foundation
import Testing
@testable import Survey

@MainActor
struct SurveySheetViewModelTests {
    @Test
    func submitWhenRequiredFieldMissing() {
        // Given
        let survey = SurveyModel(
            id: "survey_required",
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
        var submitted: SurveySubmission?
        let viewModel = SurveySheetViewModel(
            survey: survey,
            onSubmit: { submitted = $0 },
            onClose: { }
        )

        // When
        viewModel.send(.submitTapped)

        // Then
        #expect(submitted == nil)
        #expect(viewModel.validationError(for: "rating") == .required)
    }

    @Test
    func submitWhenRequiredFieldFilled() {
        // Given
        let survey = SurveyModel(
            id: "survey_rating",
            version: 2,
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
        var submitted: SurveySubmission?
        let viewModel = SurveySheetViewModel(
            survey: survey,
            onSubmit: { submitted = $0 },
            onClose: { }
        )

        // When
        viewModel.send(.setRating(fieldID: "rating", value: 8))
        viewModel.send(.submitTapped)

        // Then
        #expect(submitted?.surveyID == "survey_rating")
        #expect(submitted?.surveyVersion == 2)
        #expect(submitted?.answers.count == 1)
        #expect(submitted?.answers.first?.fieldID == "rating")
        #expect(submitted?.answers.first?.value == .rating(8))
    }

    @Test
    func submitWhenOptionalTextEmpty() {
        // Given
        let survey = SurveyModel(
            id: "survey_optional_text",
            title: "Title",
            body: "Body",
            submitButtonTitle: "Submit",
            fields: [
                SurveyField(
                    id: "comment",
                    title: "Comment",
                    isRequired: false,
                    type: .textInput(
                        config: SurveyTextInputConfig(
                            placeholder: "Type",
                            isMultiline: true,
                            minLength: nil,
                            maxLength: 200
                        )
                    )
                )
            ]
        )

        var submitted: SurveySubmission?
        let viewModel = SurveySheetViewModel(
            survey: survey,
            onSubmit: { submitted = $0 },
            onClose: { }
        )

        // When
        viewModel.send(.submitTapped)

        // Then
        #expect(submitted != nil)
        #expect(submitted?.answers.isEmpty == true)
    }

    @Test
    func submitWhenLowRatingAndNoCommentForRatingWithComment() {
        // Given
        let survey = SurveyModel(
            id: "survey_rating_comment",
            title: "Title",
            body: "Body",
            submitButtonTitle: "Submit",
            fields: [
                SurveyField(
                    id: "feedback",
                    title: "Feedback",
                    isRequired: true,
                    type: .ratingWithComment(
                        config: SurveyRatingWithCommentConfig(
                            minValue: 1,
                            maxValue: 10,
                            step: 1,
                            commentPlaceholder: "Comment",
                            commentRequiredAtOrBelow: 6,
                            commentMaxLength: 300
                        )
                    )
                )
            ]
        )

        var submitted: SurveySubmission?
        let viewModel = SurveySheetViewModel(
            survey: survey,
            onSubmit: { submitted = $0 },
            onClose: { }
        )

        // When
        viewModel.send(.setRatingWithCommentRating(fieldID: "feedback", value: 5))
        viewModel.send(.submitTapped)

        // Then
        #expect(submitted == nil)
        #expect(viewModel.validationError(for: "feedback") == .commentRequired)
    }

    @Test
    func closeWhenCloseTapped() {
        // Given
        let survey = SurveyModel(
            id: "survey_close",
            title: "Title",
            body: "Body",
            submitButtonTitle: "Submit",
            fields: []
        )

        var closeCallCount = 0
        let viewModel = SurveySheetViewModel(
            survey: survey,
            onSubmit: { _ in },
            onClose: { closeCallCount += 1 }
        )

        // When
        viewModel.send(.closeTapped)

        // Then
        #expect(closeCallCount == 1)
    }
}
