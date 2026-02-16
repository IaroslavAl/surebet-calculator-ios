import AnalyticsManager
import Onboarding
import Settings
import SurebetCalculator

struct OnboardingAnalyticsAdapter: OnboardingAnalytics {
    private let analyticsService: AnalyticsService

    init(analyticsService: AnalyticsService) {
        self.analyticsService = analyticsService
    }

    func onboardingStarted() {
        analyticsService.log(event: .onboardingStarted)
    }

    func onboardingPageViewed(pageIndex: Int, pageID: String) {
        analyticsService.log(
            event: .onboardingPageViewed(pageIndex: pageIndex, pageID: pageID)
        )
    }

    func onboardingCompleted(pagesViewed: Int) {
        analyticsService.log(event: .onboardingCompleted(pagesViewed: pagesViewed))
    }

    func onboardingSkipped(lastPageIndex: Int) {
        analyticsService.log(event: .onboardingSkipped(lastPageIndex: lastPageIndex))
    }
}

struct CalculatorAnalyticsAdapter: CalculatorAnalytics {
    private let analyticsService: AnalyticsService

    init(analyticsService: AnalyticsService) {
        self.analyticsService = analyticsService
    }

    func calculatorRowsCountChanged(
        rowCount: Int,
        changeDirection: CalculatorRowsCountChangeDirection
    ) {
        analyticsService.log(
            event: .calculatorRowsCountChanged(
                rowCount: rowCount,
                changeDirection: changeDirection.rawValue
            )
        )
    }

    func calculatorModeSelected(mode: CalculatorMode) {
        analyticsService.log(event: .calculatorModeSelected(mode: mode.rawValue))
    }

    func calculatorCleared() {
        analyticsService.log(event: .calculatorCleared)
    }

    func calculatorCalculationPerformed(
        rowCount: Int,
        mode: CalculatorMode,
        profitPercentage: Double,
        isProfitable: Bool
    ) {
        analyticsService.log(
            event: .calculatorCalculationPerformed(
                rowCount: rowCount,
                mode: mode.rawValue,
                profitPercentage: profitPercentage,
                isProfitable: isProfitable
            )
        )
    }
}

struct SettingsAnalyticsAdapter: SettingsAnalytics {
    private let analyticsService: AnalyticsService

    init(analyticsService: AnalyticsService) {
        self.analyticsService = analyticsService
    }

    func settingsThemeChanged(theme: SettingsTheme) {
        analyticsService.log(event: .settingsThemeChanged(theme: theme.rawValue))
    }

    func settingsLanguageChanged(from: SettingsLanguage, toLanguage: SettingsLanguage) {
        analyticsService.log(
            event: .settingsLanguageChanged(
                fromLanguage: from.rawValue,
                toLanguage: toLanguage.rawValue
            )
        )
    }
}
