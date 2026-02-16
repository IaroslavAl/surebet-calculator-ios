import Foundation

struct OnboardingPage: Identifiable, Sendable {
    enum Illustration: String, Sendable {
        case stakeDistribution = "function"
        case calculatorTips = "list.bullet.clipboard"
        case guaranteedResult = "chart.bar.fill"
    }

    let id: Int
    let illustration: Illustration
    let pageID: String
    let description: String

    static func createPages(locale: Locale) -> [OnboardingPage] {
        [
            .init(
                id: 0,
                illustration: .stakeDistribution,
                pageID: "onboarding_page_1",
                description: description1(locale)
            ),
            .init(
                id: 1,
                illustration: .calculatorTips,
                pageID: "onboarding_page_2",
                description: description2(locale)
            ),
            .init(
                id: 2,
                illustration: .guaranteedResult,
                pageID: "onboarding_page_3",
                description: description3(locale)
            )
        ]
    }
}

private extension OnboardingPage {
    static func description1(_ locale: Locale) -> String {
        OnboardingLocalizationKey.page1Description.localized(locale)
    }
    static func description2(_ locale: Locale) -> String {
        OnboardingLocalizationKey.page2Description.localized(locale)
    }
    static func description3(_ locale: Locale) -> String {
        OnboardingLocalizationKey.page3Description.localized(locale)
    }
}
