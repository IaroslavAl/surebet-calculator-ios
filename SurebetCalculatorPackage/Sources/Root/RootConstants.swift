import Foundation

/// Константы, специфичные для Root-модуля.
enum RootConstants {
    static let onboardingIsShownKey = "onboardingIsShown"
    static let requestReviewWasShownKey = "1.7.0"
    static let sessionNumberKey = "analytics_session_number"
    static let installIDKey = "analytics_install_id"
    static let sessionIDKey = "analytics_session_id"

    /// Задержка перед показом запроса отзыва (1 секунда).
    static let reviewRequestDelay: UInt64 = NSEC_PER_SEC * 1
}
