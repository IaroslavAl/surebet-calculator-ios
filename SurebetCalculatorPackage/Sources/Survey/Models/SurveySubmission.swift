import Foundation

public struct SurveySubmission: Sendable, Equatable {
    public let surveyID: String
    public let surveyVersion: Int?
    public let answers: [SurveyAnswer]

    public init(surveyID: String, surveyVersion: Int?, answers: [SurveyAnswer]) {
        self.surveyID = surveyID
        self.surveyVersion = surveyVersion
        self.answers = answers
    }
}

public struct SurveyAnswer: Sendable, Equatable {
    public let fieldID: String
    public let value: SurveyAnswerValue

    public init(fieldID: String, value: SurveyAnswerValue) {
        self.fieldID = fieldID
        self.value = value
    }
}

public enum SurveyAnswerValue: Sendable, Equatable {
    case rating(Int)
    case text(String)
    case singleChoice(optionID: String)
    case multiChoice(optionIDs: [String])
    case ratingWithComment(rating: Int?, comment: String?)
}
