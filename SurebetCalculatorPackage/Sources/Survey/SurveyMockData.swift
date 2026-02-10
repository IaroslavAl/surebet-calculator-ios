import Foundation

public enum SurveyMockScenario: String, Sendable {
    case none
    case ratingScale
    case textInput
    case singleChoice
    case multiChoice
    case ratingWithComment
    case rotation
}

enum SurveyMockData {
    private enum RotationKey {
        static let key = "survey_mock_rotation_index"
    }

    static var ratingScale: SurveyModel {
        SurveyModel(
            id: "mock_rating_scale",
            version: 1,
            title: "How do you rate Surebet Calculator?",
            body: "Rate the app from 1 to 10. This field is optional in real surveys, but mock keeps it required.",
            submitButtonTitle: "Submit answer",
            fields: [
                SurveyField(
                    id: "app_rating",
                    title: "Rate from 1 to 10",
                    subtitle: "1 = poor, 10 = excellent",
                    isRequired: true,
                    type: .ratingScale(config: SurveyRatingScaleConfig(minValue: 1, maxValue: 10, step: 1))
                )
            ]
        )
    }

    static var textInput: SurveyModel {
        SurveyModel(
            id: "mock_text_input",
            version: 1,
            title: "What should we improve first?",
            body: "Leave your feedback in free form text.",
            submitButtonTitle: "Submit answer",
            fields: [
                SurveyField(
                    id: "feedback_text",
                    title: "Your comment",
                    subtitle: "Please provide details",
                    isRequired: true,
                    type: .textInput(
                        config: SurveyTextInputConfig(
                            placeholder: "Type your answer",
                            isMultiline: true,
                            minLength: 5,
                            maxLength: 500
                        )
                    )
                )
            ]
        )
    }

    static var singleChoice: SurveyModel {
        SurveyModel(
            id: "mock_single_choice",
            version: 1,
            title: "What is your primary use case?",
            body: "Choose one option that describes your usage best.",
            submitButtonTitle: "Submit answer",
            fields: [
                SurveyField(
                    id: "primary_use_case",
                    title: "Main purpose",
                    subtitle: nil,
                    isRequired: true,
                    type: .singleChoice(
                        config: SurveyChoiceConfig(
                            options: [
                                SurveyChoiceOption(id: "arbitrage", title: "Arbitrage calculations"),
                                SurveyChoiceOption(id: "training", title: "Learning and training"),
                                SurveyChoiceOption(id: "quick_checks", title: "Quick checks before betting")
                            ],
                            minSelections: 1,
                            maxSelections: 1
                        )
                    )
                )
            ]
        )
    }

    static var multiChoice: SurveyModel {
        SurveyModel(
            id: "mock_multi_choice",
            version: 1,
            title: "Which sections do you use most?",
            body: "You can pick multiple options.",
            submitButtonTitle: "Submit answer",
            fields: [
                SurveyField(
                    id: "used_sections",
                    title: "Select sections",
                    subtitle: "Choose at least one",
                    isRequired: true,
                    type: .multiChoice(
                        config: SurveyChoiceConfig(
                            options: [
                                SurveyChoiceOption(id: "calculator", title: "Calculator"),
                                SurveyChoiceOption(id: "settings", title: "Settings"),
                                SurveyChoiceOption(id: "instructions", title: "Instructions")
                            ],
                            minSelections: 1,
                            maxSelections: 3
                        )
                    )
                )
            ]
        )
    }

    static var ratingWithComment: SurveyModel {
        SurveyModel(
            id: "mock_rating_with_comment",
            version: 1,
            title: "How likely are you to recommend us?",
            body: "Rate from 1 to 10 and optionally explain your score.",
            submitButtonTitle: "Submit answer",
            fields: [
                SurveyField(
                    id: "nps_like",
                    title: "Your rating",
                    subtitle: nil,
                    isRequired: true,
                    type: .ratingWithComment(
                        config: SurveyRatingWithCommentConfig(
                            minValue: 1,
                            maxValue: 10,
                            step: 1,
                            commentPlaceholder: "Tell us what we can improve",
                            commentRequiredAtOrBelow: 6,
                            commentMaxLength: 500
                        )
                    )
                )
            ]
        )
    }

    static func rotating(defaults: UserDefaults) -> SurveyModel {
        let surveys = [ratingScale, textInput, singleChoice, multiChoice, ratingWithComment]
        let currentIndex = defaults.integer(forKey: RotationKey.key)
        let boundedIndex = currentIndex % surveys.count
        let survey = surveys[boundedIndex]
        defaults.set((boundedIndex + 1) % surveys.count, forKey: RotationKey.key)
        return survey
    }
}
