import AnalyticsManager
import Banner
import Foundation
import MainMenu
import ReviewHandler
import Survey
import SwiftUI

/// ViewModel для управления состоянием и бизнес-логикой RootView
@MainActor
final class RootViewModel: ObservableObject {
    // MARK: - Properties

    @Published private(set) var alertIsPresented = false
    @Published private(set) var fullscreenBannerIsPresented = false
    @Published private(set) var isAnimation = false
    @Published private(set) var surveyIsPresented = false
    @Published private(set) var activeSurvey: SurveyModel?

    @AppStorage("onboardingIsShown") private var onboardingIsShown = false
    @AppStorage("1.7.0") private var requestReviewWasShown = false
    @AppStorage("numberOfOpenings") private var numberOfOpenings = 0

    private let analyticsService: AnalyticsService
    private let reviewService: ReviewService
    private let delay: Delay
    private let isOnboardingEnabled: Bool
    private let bannerFetcher: @Sendable () async -> Void
    private let bannerCacheChecker: @Sendable () -> Bool
    private let surveyService: SurveyService
    private let surveyLocaleProvider: @Sendable () -> String
    private let surveyDefaults: UserDefaults
    private let isSurveyEnabled: Bool

    private var bannerFetchTask: Task<Void, Never>?
    private var surveyFetchTask: Task<Void, Never>?
    private var surveyPresentationTask: Task<Void, Never>?
    private var surveyShownInSession = false
    private var latestOpenedSection: MainMenuSection?
    private var surveyPresentationSection: MainMenuSection?
    private var surveyDismissReason: SurveyDismissReason?

    // MARK: - Initialization

    init(
        analyticsService: AnalyticsService = AnalyticsManager(),
        reviewService: ReviewService = ReviewHandler(),
        delay: Delay = SystemDelay(),
        isOnboardingEnabled: Bool = true,
        bannerFetcher: @escaping @Sendable () async -> Void = { try? await Banner.fetchBanner() },
        bannerCacheChecker: @escaping @Sendable () -> Bool = { Banner.isBannerFullyCached },
        surveyService: SurveyService = MockSurveyService(scenario: .rotation),
        surveyLocaleProvider: @escaping @Sendable () -> String = { Locale.autoupdatingCurrent.identifier },
        surveyDefaults: UserDefaults = .standard,
        isSurveyEnabled: Bool = false
    ) {
        self.analyticsService = analyticsService
        self.reviewService = reviewService
        self.delay = delay
        self.isOnboardingEnabled = isOnboardingEnabled
        self.bannerFetcher = bannerFetcher
        self.bannerCacheChecker = bannerCacheChecker
        self.surveyService = surveyService
        self.surveyLocaleProvider = surveyLocaleProvider
        self.surveyDefaults = surveyDefaults
        self.isSurveyEnabled = isSurveyEnabled
    }

    // MARK: - Public Methods

    enum Action {
        case onAppear
        case showOnboardingView
        case showRequestReview
        case showFullscreenBanner
        case fetchBanner
        case fetchSurvey
        case sectionOpened(MainMenuSection)
        case surveySubmitted(SurveySubmission)
        case surveyCloseTapped
        case surveySheetDismissed
        case handleReviewNo
        case handleReviewYes
        case updateOnboardingShown(Bool)
        case setAlertPresented(Bool)
        case setFullscreenBannerPresented(Bool)
        case setSurveyPresented(Bool)
    }

    func send(_ action: Action) {
        switch action {
        case .onAppear:
            handleOnAppear()
        case .showOnboardingView:
            enableOnboardingAnimation()
        case .showRequestReview:
            requestReviewIfNeeded()
        case .showFullscreenBanner:
            showFullscreenBannerIfAvailable()
        case .fetchBanner:
            fetchBannerIfNeeded()
        case .fetchSurvey:
            fetchSurveyIfNeeded()
        case let .sectionOpened(section):
            handleSectionOpened(section)
        case let .surveySubmitted(submission):
            handleSurveySubmitted(submission)
        case .surveyCloseTapped:
            handleSurveyCloseTapped()
        case .surveySheetDismissed:
            handleSurveySheetDismissed()
        case .handleReviewNo:
            handleReviewNoInternal()
        case .handleReviewYes:
            Task { await handleReviewYesInternal() }
        case let .updateOnboardingShown(value):
            updateOnboardingShownInternal(value)
        case let .setAlertPresented(isPresented):
            guard alertIsPresented != isPresented else { return }
            alertIsPresented = isPresented
        case let .setFullscreenBannerPresented(isPresented):
            guard fullscreenBannerIsPresented != isPresented else { return }
            fullscreenBannerIsPresented = isPresented
        case let .setSurveyPresented(isPresented):
            guard surveyIsPresented != isPresented else { return }
            surveyIsPresented = isPresented
        }
    }

    /// Проверяет, нужно ли показать onboarding
    var shouldShowOnboarding: Bool {
        isOnboardingEnabled && !onboardingIsShown
    }

    /// Проверяет, нужно ли показать onboarding с анимацией
    var shouldShowOnboardingWithAnimation: Bool {
        shouldShowOnboarding && isAnimation
    }

    /// Возвращает текущее состояние onboarding
    var isOnboardingShown: Bool {
        onboardingIsShown || !isOnboardingEnabled
    }

    /// Заголовок для запроса отзыва.
    func requestReviewTitle(locale: Locale) -> String {
        RootLocalizationKey.reviewRequestTitle.localized(locale)
    }

    /// Проверяет, доступен ли fullscreen баннер для показа
    var fullscreenBannerIsAvailable: Bool {
        isOnboardingShown && requestReviewWasShown && numberOfOpenings.isMultiple(of: 3)
    }
}

// MARK: - Private Methods

private extension RootViewModel {
    enum SurveyDismissReason {
        case submitted
        case closed
    }

    var handledSurveyIDs: Set<String> {
        Set(surveyDefaults.stringArray(forKey: RootConstants.handledSurveyIDsKey) ?? [])
    }

    func handleOnAppear() {
        numberOfOpenings += 1
        analyticsService.log(event: .appOpened(sessionNumber: numberOfOpenings))
    }

    func enableOnboardingAnimation() {
        isAnimation = true
    }

    func showFullscreenBannerIfAvailable() {
        guard RootConstants.isBannerFetchEnabled, fullscreenBannerIsAvailable else { return }
        guard bannerCacheChecker() else { return }
        fullscreenBannerIsPresented = true
    }

    func requestReviewIfNeeded() {
#if !DEBUG
        Task {
            await delay.sleep(nanoseconds: RootConstants.reviewRequestDelay)
            if !requestReviewWasShown, numberOfOpenings >= 2, isOnboardingShown {
                alertIsPresented = true
                requestReviewWasShown = true
                analyticsService.log(event: .reviewPromptShown)
            }
        }
#endif
    }

    func handleReviewNoInternal() {
        alertIsPresented = false
        analyticsService.log(event: .reviewResponse(enjoyingApp: false))
    }

    func handleReviewYesInternal() async {
        alertIsPresented = false
        await reviewService.requestReview()
        analyticsService.log(event: .reviewResponse(enjoyingApp: true))
    }

    func updateOnboardingShownInternal(_ value: Bool) {
        guard isOnboardingEnabled else {
            return
        }
        onboardingIsShown = value
    }

    func fetchBannerIfNeeded() {
        guard RootConstants.isBannerFetchEnabled, bannerFetchTask == nil else { return }
        bannerFetchTask = Task { @MainActor [weak self] in
            guard let self else { return }
            let bannerFetcher = self.bannerFetcher
            let fetchTask = Task.detached(priority: .utility) {
                await bannerFetcher()
            }
            await fetchTask.value
            self.bannerFetchTask = nil
        }
    }

    func fetchSurveyIfNeeded() {
        guard isSurveyEnabled, surveyFetchTask == nil else { return }
        guard activeSurvey == nil else { return }

        surveyFetchTask = Task { @MainActor [weak self] in
            guard let self else { return }
            let service = self.surveyService
            let localeIdentifier = self.surveyLocaleProvider()
            let fetchTask = Task.detached(priority: .utility) {
                try? await service.fetchActiveSurvey(localeIdentifier: localeIdentifier)
            }
            let survey = await fetchTask.value
            if let survey, !self.handledSurveyIDs.contains(survey.id) {
                self.activeSurvey = survey
                self.presentSurveyIfPossible()
            }
            self.surveyFetchTask = nil
        }
    }

    func handleSectionOpened(_ section: MainMenuSection) {
        latestOpenedSection = section
        presentSurveyIfPossible()
    }

    func presentSurveyIfPossible() {
        guard isSurveyEnabled else { return }
        guard !surveyShownInSession else { return }
        guard surveyPresentationTask == nil else { return }

        surveyPresentationTask = Task { @MainActor [weak self] in
            guard let self else { return }
            defer { self.surveyPresentationTask = nil }
            let delay = self.delay

            // Separate survey presentation from navigation tap cycle (especially on iOS 16).
            await Task.yield()
            await delay.sleep(nanoseconds: RootConstants.surveyPresentationDelay)

            guard !Task.isCancelled else { return }
            guard self.isSurveyEnabled else { return }
            guard !self.surveyShownInSession else { return }
            guard let survey = self.activeSurvey else { return }
            guard !self.handledSurveyIDs.contains(survey.id) else { return }
            guard let section = self.latestOpenedSection else { return }

            self.surveyShownInSession = true
            self.surveyPresentationSection = section
            self.surveyDismissReason = nil
            self.surveyIsPresented = true

            self.analyticsService.log(
                event: .surveyShown(
                    surveyId: survey.id,
                    surveyVersion: survey.version,
                    sourceScreen: section.rawValue
                )
            )
        }
    }

    func handleSurveySubmitted(_ submission: SurveySubmission) {
        guard let section = surveyPresentationSection else { return }

        markSurveyHandled(submission.surveyID)
        surveyDismissReason = .submitted
        surveyIsPresented = false

        analyticsService.log(
            event: .surveySubmitted(
                surveyId: submission.surveyID,
                surveyVersion: submission.surveyVersion,
                sourceScreen: section.rawValue,
                answers: buildSurveyAnalyticsAnswers(from: submission)
            )
        )
    }

    func handleSurveyCloseTapped() {
        surveyDismissReason = .closed
        surveyIsPresented = false
    }

    func handleSurveySheetDismissed() {
        guard let survey = activeSurvey else { return }
        let sourceScreen = surveyPresentationSection?.rawValue ?? "unknown"

        switch surveyDismissReason {
        case .submitted:
            clearSurveyPresentationState()

        case .closed, .none:
            markSurveyHandled(survey.id)
            analyticsService.log(
                event: .surveyClosed(
                    surveyId: survey.id,
                    surveyVersion: survey.version,
                    sourceScreen: sourceScreen
                )
            )
            clearSurveyPresentationState()
        }
    }

    func clearSurveyPresentationState() {
        surveyPresentationTask?.cancel()
        surveyPresentationTask = nil
        activeSurvey = nil
        surveyDismissReason = nil
        surveyPresentationSection = nil
    }

    func markSurveyHandled(_ surveyID: String) {
        var ids = handledSurveyIDs
        ids.insert(surveyID)
        surveyDefaults.set(Array(ids).sorted(), forKey: RootConstants.handledSurveyIDsKey)
    }

    func buildSurveyAnalyticsAnswers(
        from submission: SurveySubmission
    ) -> [String: AnalyticsParameterValue] {
        var result: [String: AnalyticsParameterValue] = [:]

        for answer in submission.answers {
            let key = sanitizedSurveyFieldID(answer.fieldID)

            switch answer.value {
            case let .rating(value):
                result["\(key)_rating"] = .int(value)

            case let .text(text):
                result["\(key)_text"] = .string(text)

            case let .singleChoice(optionID):
                result["\(key)_option_id"] = .string(optionID)

            case let .multiChoice(optionIDs):
                result["\(key)_option_ids"] = .string(optionIDs.joined(separator: ","))

            case let .ratingWithComment(rating, comment):
                if let rating {
                    result["\(key)_rating"] = .int(rating)
                }
                if let comment {
                    result["\(key)_text"] = .string(comment)
                }
            }
        }

        return result
    }

    func sanitizedSurveyFieldID(_ value: String) -> String {
        let result = value.unicodeScalars.map { scalar -> String in
            if CharacterSet.alphanumerics.contains(scalar) {
                return String(scalar)
            }
            return "_"
        }
        .joined()
        return result.isEmpty ? "field" : result
    }
}
