/// Идентификаторы доступности для UI элементов онбординга.
/// Используются для UI тестов.
public enum OnboardingAccessibilityIdentifiers: Sendable {
    public static let view = "onboarding_view"
    public static let closeButton = "onboarding_close_button"
    public static let nextButton = "onboarding_next_button"
    public static let tabView = "onboarding_tab_view"

    public static func pageView(_ index: Int) -> String {
        "onboarding_page_\(index)"
    }

    public static func pageIndicator(_ index: Int) -> String {
        "onboarding_page_indicator_\(index)"
    }
}
