import SwiftUI

struct OnboardingPage: Identifiable, Sendable {
    let image: String
    let description: String

    static func createPages() -> [OnboardingPage] {
        [
            .init(image: image1, description: description1),
            .init(image: image2, description: description2),
            .init(image: image3, description: description3)
        ]
    }

    var id: String { image }
}

private extension OnboardingPage {
    static var image1: String { Device.isIPadUnsafe ? "iPad1" : "iPhone1" }
    static var image2: String { Device.isIPadUnsafe ? "iPad2" : "iPhone2" }
    static var image3: String { Device.isIPadUnsafe ? "iPad3" : "iPhone3" }
    static var description1: String {
        OnboardingLocalizationKey.page1Description.localized
    }
    static var description2: String {
        OnboardingLocalizationKey.page2Description.localized
    }
    static var description3: String {
        OnboardingLocalizationKey.page3Description.localized
    }
}
