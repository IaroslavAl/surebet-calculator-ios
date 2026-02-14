import Foundation

/// Константы, специфичные для Root-модуля.
enum RootConstants {
    static let onboardingIsShownKey = "onboardingIsShown"
    static let requestReviewWasShownKey = "1.7.0"
    static let numberOfOpeningsKey = "numberOfOpenings"

    /// Задержка перед показом запроса отзыва (1 секунда).
    static let reviewRequestDelay: UInt64 = NSEC_PER_SEC * 1
}
