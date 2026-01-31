import AnalyticsManager
import Onboarding
import SurebetCalculator

struct OnboardingAnalyticsAdapter: OnboardingAnalytics {
    private let analyticsService: AnalyticsService

    init(analyticsService: AnalyticsService) {
        self.analyticsService = analyticsService
    }

    func onboardingStarted() {
        analyticsService.log(event: .onboardingStarted)
    }

    func onboardingPageViewed(pageIndex: Int, pageTitle: String) {
        analyticsService.log(
            event: .onboardingPageViewed(pageIndex: pageIndex, pageTitle: pageTitle)
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

    func calculatorRowAdded(rowCount: Int) {
        analyticsService.log(event: .calculatorRowAdded(rowCount: rowCount))
    }

    func calculatorRowRemoved(rowCount: Int) {
        analyticsService.log(event: .calculatorRowRemoved(rowCount: rowCount))
    }

    func calculatorCleared() {
        analyticsService.log(event: .calculatorCleared)
    }

    func calculationPerformed(rowCount: Int, profitPercentage: Double) {
        analyticsService.log(
            event: .calculationPerformed(
                rowCount: rowCount,
                profitPercentage: profitPercentage
            )
        )
    }
}
