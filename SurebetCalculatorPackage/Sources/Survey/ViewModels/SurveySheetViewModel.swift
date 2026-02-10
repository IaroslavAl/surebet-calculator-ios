import Foundation

@MainActor
final class SurveySheetViewModel: ObservableObject {
    struct State {
        let survey: SurveyModel
        var validationErrors: [String: SurveyValidationError] = [:]
        var answersVersion = 0
    }

    @Published private(set) var state: State

    private let onSubmit: (SurveySubmission) -> Void
    private let onClose: () -> Void

    private var draftAnswers: [String: SurveyDraftAnswer]

    init(
        survey: SurveyModel,
        onSubmit: @escaping (SurveySubmission) -> Void,
        onClose: @escaping () -> Void
    ) {
        self.state = State(survey: survey)
        self.onSubmit = onSubmit
        self.onClose = onClose
        self.draftAnswers = SurveyDraftAnswerFactory.makeInitialAnswers(for: survey)
    }

    enum Action {
        case setRating(fieldID: String, value: Int)
        case setText(fieldID: String, value: String)
        case selectSingleChoice(fieldID: String, optionID: String)
        case toggleMultiChoice(fieldID: String, optionID: String)
        case setRatingWithCommentRating(fieldID: String, value: Int)
        case setRatingWithCommentComment(fieldID: String, text: String)
        case submitTapped
        case closeTapped
    }

    func send(_ action: Action) {
        switch action {
        case let .setRating(fieldID, value):
            draftAnswers[fieldID] = .rating(value)
            markFieldEdited(fieldID)

        case let .setText(fieldID, value):
            draftAnswers[fieldID] = .text(value)
            markFieldEdited(fieldID)

        case let .selectSingleChoice(fieldID, optionID):
            draftAnswers[fieldID] = .singleChoice(optionID)
            markFieldEdited(fieldID)

        case let .toggleMultiChoice(fieldID, optionID):
            handleMultiChoiceToggle(fieldID: fieldID, optionID: optionID)
            markFieldEdited(fieldID)

        case let .setRatingWithCommentRating(fieldID, value):
            let currentComment = commentText(for: fieldID)
            draftAnswers[fieldID] = .ratingWithComment(rating: value, comment: currentComment)
            markFieldEdited(fieldID)

        case let .setRatingWithCommentComment(fieldID, text):
            let currentRating = ratingValue(for: fieldID)
            draftAnswers[fieldID] = .ratingWithComment(rating: currentRating, comment: text)
            markFieldEdited(fieldID)

        case .submitTapped:
            handleSubmitTapped()

        case .closeTapped:
            onClose()
        }
    }

    func ratingValue(for fieldID: String) -> Int? {
        guard let answer = draftAnswers[fieldID] else { return nil }

        switch answer {
        case let .rating(value):
            return value
        case let .ratingWithComment(rating, _):
            return rating
        default:
            return nil
        }
    }

    func textValue(for fieldID: String) -> String {
        guard let answer = draftAnswers[fieldID] else { return "" }

        switch answer {
        case let .text(value):
            return value
        case let .ratingWithComment(_, comment):
            return comment
        default:
            return ""
        }
    }

    func isOptionSelected(fieldID: String, optionID: String) -> Bool {
        guard let answer = draftAnswers[fieldID] else { return false }

        switch answer {
        case let .singleChoice(selected):
            return selected == optionID
        case let .multiChoice(selected):
            return selected.contains(optionID)
        default:
            return false
        }
    }

    func validationError(for fieldID: String) -> SurveyValidationError? {
        state.validationErrors[fieldID]
    }
}

private extension SurveySheetViewModel {
    func mutateState(_ mutation: (inout State) -> Void) {
        var nextState = state
        mutation(&nextState)
        state = nextState
    }

    func markFieldEdited(_ fieldID: String) {
        mutateState {
            $0.validationErrors[fieldID] = nil
            $0.answersVersion += 1
        }
    }

    func handleMultiChoiceToggle(fieldID: String, optionID: String) {
        var selected: Set<String>

        if case let .multiChoice(current)? = draftAnswers[fieldID] {
            selected = current
        } else {
            selected = []
        }

        if selected.contains(optionID) {
            selected.remove(optionID)
        } else {
            selected.insert(optionID)
        }

        draftAnswers[fieldID] = .multiChoice(selected)
    }

    func handleSubmitTapped() {
        let errors = validateFields()
        mutateState {
            $0.validationErrors = errors
        }

        guard errors.isEmpty else { return }

        let answers = buildSubmissionAnswers()
        onSubmit(
            SurveySubmission(
                surveyID: state.survey.id,
                surveyVersion: state.survey.version,
                answers: answers
            )
        )
    }

    func validateFields() -> [String: SurveyValidationError] {
        var result: [String: SurveyValidationError] = [:]

        for field in state.survey.fields {
            if let error = validate(field: field) {
                result[field.id] = error
            }
        }

        return result
    }

    func validate(field: SurveyField) -> SurveyValidationError? {
        switch field.type {
        case .ratingScale:
            let rating = ratingValue(for: field.id)
            guard field.isRequired else { return nil }
            return rating == nil ? .required : nil

        case let .textInput(config):
            let text = textValue(for: field.id).trimmingCharacters(in: .whitespacesAndNewlines)

            if field.isRequired && text.isEmpty {
                return .required
            }

            if let minLength = config.minLength,
               !text.isEmpty,
               text.count < minLength {
                return .minLength(minLength)
            }

            if let maxLength = config.maxLength,
               text.count > maxLength {
                return .maxLength(maxLength)
            }

            return nil

        case .singleChoice:
            guard field.isRequired else { return nil }
            let selectedOption = singleChoiceValue(for: field.id)
            return selectedOption == nil ? .required : nil

        case let .multiChoice(config):
            let selectedOptions = multiChoiceValues(for: field.id)
            let minimum = config.minSelections ?? (field.isRequired ? 1 : 0)
            if selectedOptions.count < minimum {
                return .minSelections(minimum)
            }
            if let maximum = config.maxSelections,
               selectedOptions.count > maximum {
                return .maxSelections(maximum)
            }
            return nil

        case let .ratingWithComment(config):
            let rating = ratingValue(for: field.id)
            let comment = commentText(for: field.id).trimmingCharacters(in: .whitespacesAndNewlines)

            if field.isRequired && rating == nil {
                return .required
            }

            if let threshold = config.commentRequiredAtOrBelow,
               let rating,
               rating <= threshold,
               comment.isEmpty {
                return .commentRequired
            }

            if let maxCommentLength = config.commentMaxLength,
               comment.count > maxCommentLength {
                return .maxLength(maxCommentLength)
            }

            return nil
        }
    }

    func buildSubmissionAnswers() -> [SurveyAnswer] {
        var answers: [SurveyAnswer] = []

        for field in state.survey.fields {
            switch field.type {
            case .ratingScale:
                if let rating = ratingValue(for: field.id) {
                    answers.append(SurveyAnswer(fieldID: field.id, value: .rating(rating)))
                }

            case .textInput:
                let text = textValue(for: field.id).trimmingCharacters(in: .whitespacesAndNewlines)
                if !text.isEmpty {
                    answers.append(SurveyAnswer(fieldID: field.id, value: .text(text)))
                }

            case .singleChoice:
                if let optionID = singleChoiceValue(for: field.id) {
                    answers.append(SurveyAnswer(fieldID: field.id, value: .singleChoice(optionID: optionID)))
                }

            case .multiChoice:
                let optionIDs = Array(multiChoiceValues(for: field.id)).sorted()
                if !optionIDs.isEmpty {
                    answers.append(SurveyAnswer(fieldID: field.id, value: .multiChoice(optionIDs: optionIDs)))
                }

            case .ratingWithComment:
                let rating = ratingValue(for: field.id)
                let comment = commentText(for: field.id).trimmingCharacters(in: .whitespacesAndNewlines)
                if rating != nil || !comment.isEmpty {
                    answers.append(
                        SurveyAnswer(
                            fieldID: field.id,
                            value: .ratingWithComment(
                                rating: rating,
                                comment: comment.isEmpty ? nil : comment
                            )
                        )
                    )
                }
            }
        }

        return answers
    }

    func singleChoiceValue(for fieldID: String) -> String? {
        guard let answer = draftAnswers[fieldID],
              case let .singleChoice(value) = answer else {
            return nil
        }
        return value
    }

    func multiChoiceValues(for fieldID: String) -> Set<String> {
        guard let answer = draftAnswers[fieldID],
              case let .multiChoice(values) = answer else {
            return []
        }
        return values
    }

    func commentText(for fieldID: String) -> String {
        guard let answer = draftAnswers[fieldID],
              case let .ratingWithComment(_, comment) = answer else {
            return ""
        }
        return comment
    }
}

private enum SurveyDraftAnswer: Sendable {
    case rating(Int)
    case text(String)
    case singleChoice(String)
    case multiChoice(Set<String>)
    case ratingWithComment(rating: Int?, comment: String)
}

private enum SurveyDraftAnswerFactory {
    static func makeInitialAnswers(for survey: SurveyModel) -> [String: SurveyDraftAnswer] {
        var result: [String: SurveyDraftAnswer] = [:]

        for field in survey.fields {
            switch field.type {
            case .ratingScale:
                continue
            case .textInput:
                result[field.id] = .text("")
            case .singleChoice:
                continue
            case .multiChoice:
                result[field.id] = .multiChoice([])
            case .ratingWithComment:
                result[field.id] = .ratingWithComment(rating: nil, comment: "")
            }
        }

        return result
    }
}

enum SurveyValidationError: Sendable, Equatable {
    case required
    case minLength(Int)
    case maxLength(Int)
    case minSelections(Int)
    case maxSelections(Int)
    case commentRequired

    var message: String {
        switch self {
        case .required:
            return String(
                localized: "survey_validation_required",
                defaultValue: "Required field",
                bundle: .module
            )
        case .minLength(let minLength):
            return String(
                localized: "survey_validation_min_length",
                defaultValue: "Minimum \(minLength) characters",
                bundle: .module
            )
        case .maxLength(let maxLength):
            return String(
                localized: "survey_validation_max_length",
                defaultValue: "Maximum \(maxLength) characters",
                bundle: .module
            )
        case .minSelections(let minimum):
            return String(
                localized: "survey_validation_min_selections",
                defaultValue: "Select at least \(minimum)",
                bundle: .module
            )
        case .maxSelections(let maximum):
            return String(
                localized: "survey_validation_max_selections",
                defaultValue: "Select up to \(maximum)",
                bundle: .module
            )
        case .commentRequired:
            return String(
                localized: "survey_validation_comment_required",
                defaultValue: "Please add a comment for this rating",
                bundle: .module
            )
        }
    }
}
