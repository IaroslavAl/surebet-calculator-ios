import Foundation

public struct SurveyModel: Codable, Sendable, Equatable, Identifiable {
    public let id: String
    public let version: Int?
    public let title: String
    public let body: String
    public let submitButtonTitle: String
    public let fields: [SurveyField]

    enum CodingKeys: String, CodingKey {
        case id
        case version
        case title
        case body
        case submitButtonTitle = "submit_button_title"
        case submitButtonText = "submit_button_text"
        case fields
    }

    public init(
        id: String,
        version: Int? = nil,
        title: String,
        body: String,
        submitButtonTitle: String,
        fields: [SurveyField]
    ) {
        self.id = id
        self.version = version
        self.title = title
        self.body = body
        self.submitButtonTitle = submitButtonTitle
        self.fields = fields
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        version = try container.decodeIfPresent(Int.self, forKey: .version)
        title = try container.decode(String.self, forKey: .title)
        body = try container.decode(String.self, forKey: .body)

        if let submitButtonTitle = try container.decodeIfPresent(String.self, forKey: .submitButtonTitle) {
            self.submitButtonTitle = submitButtonTitle
        } else {
            self.submitButtonTitle = try container.decode(String.self, forKey: .submitButtonText)
        }

        fields = try container.decode([SurveyField].self, forKey: .fields)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(version, forKey: .version)
        try container.encode(title, forKey: .title)
        try container.encode(body, forKey: .body)
        try container.encode(submitButtonTitle, forKey: .submitButtonTitle)
        try container.encode(fields, forKey: .fields)
    }
}

public struct SurveyField: Codable, Sendable, Equatable, Identifiable {
    public let id: String
    public let title: String
    public let subtitle: String?
    public let isRequired: Bool
    public let type: SurveyFieldType

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case subtitle
        case isRequired = "is_required"
        case required
        case type
    }

    public init(
        id: String,
        title: String,
        subtitle: String? = nil,
        isRequired: Bool,
        type: SurveyFieldType
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.isRequired = isRequired
        self.type = type
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle)
        if let value = try container.decodeIfPresent(Bool.self, forKey: .isRequired) {
            isRequired = value
        } else {
            isRequired = try container.decodeIfPresent(Bool.self, forKey: .required) ?? false
        }
        type = try container.decode(SurveyFieldType.self, forKey: .type)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encodeIfPresent(subtitle, forKey: .subtitle)
        try container.encode(isRequired, forKey: .isRequired)
        try container.encode(type, forKey: .type)
    }
}

public enum SurveyFieldType: Sendable, Equatable {
    case ratingScale(config: SurveyRatingScaleConfig)
    case textInput(config: SurveyTextInputConfig)
    case singleChoice(config: SurveyChoiceConfig)
    case multiChoice(config: SurveyChoiceConfig)
    case ratingWithComment(config: SurveyRatingWithCommentConfig)
}

extension SurveyFieldType: Codable {
    enum FieldTypeKind: String, Codable {
        case ratingScale = "rating_scale"
        case textInput = "text_input"
        case singleChoice = "single_choice"
        case multiChoice = "multi_choice"
        case ratingWithComment = "rating_with_comment"
    }

    enum CodingKeys: String, CodingKey {
        case kind = "kind"
        case type
        case minValue = "min_value"
        case maxValue = "max_value"
        case step
        case placeholder
        case isMultiline = "is_multiline"
        case minLength = "min_length"
        case maxLength = "max_length"
        case options
        case minSelections = "min_selections"
        case maxSelections = "max_selections"
        case commentPlaceholder = "comment_placeholder"
        case commentRequiredAtOrBelow = "comment_required_at_or_below"
        case commentMaxLength = "comment_max_length"
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let kind = try container.decodeIfPresent(FieldTypeKind.self, forKey: .kind)
            ?? container.decode(FieldTypeKind.self, forKey: .type)

        switch kind {
        case .ratingScale:
            let config = SurveyRatingScaleConfig(
                minValue: try container.decodeIfPresent(Int.self, forKey: .minValue) ?? 1,
                maxValue: try container.decodeIfPresent(Int.self, forKey: .maxValue) ?? 10,
                step: try container.decodeIfPresent(Int.self, forKey: .step) ?? 1
            )
            self = .ratingScale(config: config)

        case .textInput:
            let config = SurveyTextInputConfig(
                placeholder: try container.decodeIfPresent(String.self, forKey: .placeholder),
                isMultiline: try container.decodeIfPresent(Bool.self, forKey: .isMultiline) ?? true,
                minLength: try container.decodeIfPresent(Int.self, forKey: .minLength),
                maxLength: try container.decodeIfPresent(Int.self, forKey: .maxLength)
            )
            self = .textInput(config: config)

        case .singleChoice:
            let config = SurveyChoiceConfig(
                options: try container.decode([SurveyChoiceOption].self, forKey: .options),
                minSelections: try container.decodeIfPresent(Int.self, forKey: .minSelections),
                maxSelections: try container.decodeIfPresent(Int.self, forKey: .maxSelections)
            )
            self = .singleChoice(config: config)

        case .multiChoice:
            let config = SurveyChoiceConfig(
                options: try container.decode([SurveyChoiceOption].self, forKey: .options),
                minSelections: try container.decodeIfPresent(Int.self, forKey: .minSelections),
                maxSelections: try container.decodeIfPresent(Int.self, forKey: .maxSelections)
            )
            self = .multiChoice(config: config)

        case .ratingWithComment:
            let config = SurveyRatingWithCommentConfig(
                minValue: try container.decodeIfPresent(Int.self, forKey: .minValue) ?? 1,
                maxValue: try container.decodeIfPresent(Int.self, forKey: .maxValue) ?? 10,
                step: try container.decodeIfPresent(Int.self, forKey: .step) ?? 1,
                commentPlaceholder: try container.decodeIfPresent(String.self, forKey: .commentPlaceholder),
                commentRequiredAtOrBelow: try container.decodeIfPresent(Int.self, forKey: .commentRequiredAtOrBelow),
                commentMaxLength: try container.decodeIfPresent(Int.self, forKey: .commentMaxLength)
            )
            self = .ratingWithComment(config: config)
        }
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case let .ratingScale(config):
            try container.encode(FieldTypeKind.ratingScale, forKey: .type)
            try container.encode(config.minValue, forKey: .minValue)
            try container.encode(config.maxValue, forKey: .maxValue)
            try container.encode(config.step, forKey: .step)

        case let .textInput(config):
            try container.encode(FieldTypeKind.textInput, forKey: .type)
            try container.encodeIfPresent(config.placeholder, forKey: .placeholder)
            try container.encode(config.isMultiline, forKey: .isMultiline)
            try container.encodeIfPresent(config.minLength, forKey: .minLength)
            try container.encodeIfPresent(config.maxLength, forKey: .maxLength)

        case let .singleChoice(config):
            try container.encode(FieldTypeKind.singleChoice, forKey: .type)
            try container.encode(config.options, forKey: .options)
            try container.encodeIfPresent(config.minSelections, forKey: .minSelections)
            try container.encodeIfPresent(config.maxSelections, forKey: .maxSelections)

        case let .multiChoice(config):
            try container.encode(FieldTypeKind.multiChoice, forKey: .type)
            try container.encode(config.options, forKey: .options)
            try container.encodeIfPresent(config.minSelections, forKey: .minSelections)
            try container.encodeIfPresent(config.maxSelections, forKey: .maxSelections)

        case let .ratingWithComment(config):
            try container.encode(FieldTypeKind.ratingWithComment, forKey: .type)
            try container.encode(config.minValue, forKey: .minValue)
            try container.encode(config.maxValue, forKey: .maxValue)
            try container.encode(config.step, forKey: .step)
            try container.encodeIfPresent(config.commentPlaceholder, forKey: .commentPlaceholder)
            try container.encodeIfPresent(config.commentRequiredAtOrBelow, forKey: .commentRequiredAtOrBelow)
            try container.encodeIfPresent(config.commentMaxLength, forKey: .commentMaxLength)
        }
    }
}

public struct SurveyChoiceOption: Codable, Sendable, Equatable, Identifiable {
    public let id: String
    public let title: String

    public init(id: String, title: String) {
        self.id = id
        self.title = title
    }
}

public struct SurveyRatingScaleConfig: Codable, Sendable, Equatable {
    public let minValue: Int
    public let maxValue: Int
    public let step: Int

    public init(minValue: Int, maxValue: Int, step: Int) {
        self.minValue = minValue
        self.maxValue = maxValue
        self.step = step
    }

    public var values: [Int] {
        guard minValue <= maxValue else { return [] }
        return Array(stride(from: minValue, through: maxValue, by: max(step, 1)))
    }
}

public struct SurveyTextInputConfig: Codable, Sendable, Equatable {
    public let placeholder: String?
    public let isMultiline: Bool
    public let minLength: Int?
    public let maxLength: Int?

    public init(
        placeholder: String? = nil,
        isMultiline: Bool = true,
        minLength: Int? = nil,
        maxLength: Int? = nil
    ) {
        self.placeholder = placeholder
        self.isMultiline = isMultiline
        self.minLength = minLength
        self.maxLength = maxLength
    }
}

public struct SurveyChoiceConfig: Codable, Sendable, Equatable {
    public let options: [SurveyChoiceOption]
    public let minSelections: Int?
    public let maxSelections: Int?

    public init(
        options: [SurveyChoiceOption],
        minSelections: Int? = nil,
        maxSelections: Int? = nil
    ) {
        self.options = options
        self.minSelections = minSelections
        self.maxSelections = maxSelections
    }
}

public struct SurveyRatingWithCommentConfig: Codable, Sendable, Equatable {
    public let minValue: Int
    public let maxValue: Int
    public let step: Int
    public let commentPlaceholder: String?
    public let commentRequiredAtOrBelow: Int?
    public let commentMaxLength: Int?

    public init(
        minValue: Int,
        maxValue: Int,
        step: Int,
        commentPlaceholder: String? = nil,
        commentRequiredAtOrBelow: Int? = nil,
        commentMaxLength: Int? = nil
    ) {
        self.minValue = minValue
        self.maxValue = maxValue
        self.step = step
        self.commentPlaceholder = commentPlaceholder
        self.commentRequiredAtOrBelow = commentRequiredAtOrBelow
        self.commentMaxLength = commentMaxLength
    }

    public var values: [Int] {
        guard minValue <= maxValue else { return [] }
        return Array(stride(from: minValue, through: maxValue, by: max(step, 1)))
    }
}
