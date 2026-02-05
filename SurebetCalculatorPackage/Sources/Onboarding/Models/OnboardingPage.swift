import DesignSystem
import Foundation

struct OnboardingPage: Identifiable, Sendable {
    let image: String
    let description: String

    static func createPages(locale: Locale) -> [OnboardingPage] {
        [
            .init(image: image1, description: description1(locale)),
            .init(image: image2, description: description2(locale)),
            .init(image: image3, description: description3(locale))
        ]
    }

    var id: String { image }
}

private extension OnboardingPage {
    static var image1: String { Device.isIPadUnsafe ? "iPad1" : "iPhone1" }
    static var image2: String { Device.isIPadUnsafe ? "iPad2" : "iPhone2" }
    static var image3: String { Device.isIPadUnsafe ? "iPad3" : "iPhone3" }
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
