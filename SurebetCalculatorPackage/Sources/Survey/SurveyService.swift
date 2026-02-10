import Foundation

public protocol SurveyService: Sendable {
    func fetchActiveSurvey(localeIdentifier: String) async throws -> SurveyModel?
}

public enum SurveyServiceError: Error, Sendable {
    case invalidBaseURL
    case badResponse
    case unsupportedPayload
}

public struct RemoteSurveyService: SurveyService, @unchecked Sendable {
    private let baseURL: URL
    private let session: URLSession
    private let endpointPath: String
    private let timeout: TimeInterval

    public init(
        baseURL: URL,
        session: URLSession = .shared,
        endpointPath: String = "survey/active",
        timeout: TimeInterval = 10
    ) {
        self.baseURL = baseURL
        self.session = session
        self.endpointPath = endpointPath
        self.timeout = timeout
    }

    public func fetchActiveSurvey(localeIdentifier: String) async throws -> SurveyModel? {
        let url = baseURL.appendingPathComponent(endpointPath)

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = timeout
        request.setValue(localeIdentifier, forHTTPHeaderField: "Accept-Language")
        request.setValue(localeIdentifier, forHTTPHeaderField: "X-App-Locale")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw SurveyServiceError.badResponse
        }

        switch httpResponse.statusCode {
        case 204:
            return nil
        case 200..<300:
            break
        default:
            throw SurveyServiceError.badResponse
        }

        guard !data.isEmpty else { return nil }
        let decoder = JSONDecoder()

        if let survey = try? decoder.decode(SurveyModel.self, from: data) {
            return survey
        }

        if let envelope = try? decoder.decode(SurveyEnvelope.self, from: data) {
            return envelope.survey
        }

        if let envelope = try? decoder.decode(ActiveSurveyEnvelope.self, from: data) {
            return envelope.activeSurvey
        }

        throw SurveyServiceError.unsupportedPayload
    }
}

public struct MockSurveyService: SurveyService, @unchecked Sendable {
    private let scenario: SurveyMockScenario
    private let defaults: UserDefaults

    public init(
        scenario: SurveyMockScenario = .rotation,
        defaults: UserDefaults = .standard
    ) {
        self.scenario = scenario
        self.defaults = defaults
    }

    public func fetchActiveSurvey(localeIdentifier: String) async throws -> SurveyModel? {
        switch scenario {
        case .none:
            return nil
        case .ratingScale:
            return SurveyMockData.ratingScale
        case .textInput:
            return SurveyMockData.textInput
        case .singleChoice:
            return SurveyMockData.singleChoice
        case .multiChoice:
            return SurveyMockData.multiChoice
        case .ratingWithComment:
            return SurveyMockData.ratingWithComment
        case .rotation:
            return SurveyMockData.rotating(defaults: defaults)
        }
    }
}

private struct SurveyEnvelope: Decodable, Sendable {
    let survey: SurveyModel?
}

private struct ActiveSurveyEnvelope: Decodable, Sendable {
    let activeSurvey: SurveyModel?

    enum CodingKeys: String, CodingKey {
        case activeSurvey = "active_survey"
    }
}
