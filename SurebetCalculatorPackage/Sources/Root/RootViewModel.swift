import AnalyticsManager
import FeatureToggles
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

    private var onboardingIsShown: Bool
    private var numberOfOpenings: Int

    private let analyticsService: AnalyticsService
    private let reviewService: ReviewService
    private let delay: Delay
    private let featureFlags: FeatureFlags
    private let bannerFetcher: @Sendable () async -> Void
    private let bannerCacheChecker: @Sendable () -> Bool
    private let surveyService: SurveyService
    private let surveyLocaleProvider: () -> String
    private let rootStateStore: RootStateStore

    private var bannerFetchTask: Task<Void, Never>?
    private var surveyFetchTask: Task<Void, Never>?
    private var surveyPresentationTask: Task<Void, Never>?
    private var surveyShownInSession = false
    private var latestOpenedSection: MainMenuSection?
    private var surveyPresentationSection: MainMenuSection?
    private var surveyDismissReason: SurveyDismissReason?

    // MARK: - Initialization

    init(
        analyticsService: AnalyticsService,
        reviewService: ReviewService,
        delay: Delay,
        featureFlags: FeatureFlags,
        bannerFetcher: @escaping @Sendable () async -> Void,
        bannerCacheChecker: @escaping @Sendable () -> Bool,
        surveyService: SurveyService,
        surveyLocaleProvider: @escaping () -> String,
        rootStateStore: RootStateStore
    ) {
        self.analyticsService = analyticsService
        self.reviewService = reviewService
        self.delay = delay
        self.featureFlags = featureFlags
        self.bannerFetcher = bannerFetcher
        self.bannerCacheChecker = bannerCacheChecker
        self.surveyService = surveyService
        self.surveyLocaleProvider = surveyLocaleProvider
        self.rootStateStore = rootStateStore
        onboardingIsShown = rootStateStore.onboardingIsShown()
        numberOfOpenings = rootStateStore.numberOfOpenings()
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
        featureFlags.onboarding && !onboardingIsShown
    }

    /// Проверяет, нужно ли показать onboarding с анимацией
    var shouldShowOnboardingWithAnimation: Bool {
        shouldShowOnboarding && isAnimation
    }

    /// Возвращает текущее состояние onboarding
    var isOnboardingShown: Bool {
        onboardingIsShown || !featureFlags.onboarding
    }

    /// Заголовок для запроса отзыва.
    func requestReviewTitle(locale: Locale) -> String {
        RootLocalizationKey.reviewRequestTitle.localized(locale)
    }

    /// Проверяет, доступен ли fullscreen баннер для показа
    var fullscreenBannerIsAvailable: Bool {
        featureFlags.fullscreenBanner &&
            isOnboardingShown &&
            requestReviewWasShown &&
            numberOfOpenings.isMultiple(of: 3)
    }
}

// MARK: - Private Methods

private extension RootViewModel {
    enum SurveyDismissReason {
        case submitted
        case closed
    }

    var requestReviewWasShown: Bool {
        get { rootStateStore.requestReviewWasShown() }
        set { rootStateStore.setRequestReviewWasShown(newValue) }
    }

    var handledSurveyIDs: Set<String> {
        rootStateStore.handledSurveyIDs()
    }

    func handleOnAppear() {
        numberOfOpenings += 1
        rootStateStore.setNumberOfOpenings(numberOfOpenings)
        analyticsService.log(event: .appOpened(sessionNumber: numberOfOpenings))
    }

    func enableOnboardingAnimation() {
        isAnimation = true
    }

    func showFullscreenBannerIfAvailable() {
        guard featureFlags.bannerFetch, fullscreenBannerIsAvailable else { return }
        guard bannerCacheChecker() else { return }
        fullscreenBannerIsPresented = true
    }

    func requestReviewIfNeeded() {
        guard featureFlags.reviewPrompt else { return }
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
        guard featureFlags.onboarding else {
            return
        }
        onboardingIsShown = value
        rootStateStore.setOnboardingIsShown(value)
    }

    func fetchBannerIfNeeded() {
        guard featureFlags.bannerFetch, bannerFetchTask == nil else { return }
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
        guard featureFlags.survey, surveyFetchTask == nil else { return }
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
        guard featureFlags.survey else { return }
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
            guard self.featureFlags.survey else { return }
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
        rootStateStore.setHandledSurveyIDs(ids)
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
