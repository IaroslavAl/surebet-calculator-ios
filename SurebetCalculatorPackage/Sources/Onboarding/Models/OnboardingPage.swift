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
    static var image1: String { Device.isIPad ? "iPad1" : "iPhone1" }
    static var image2: String { Device.isIPad ? "iPad2" : "iPhone2" }
    static var image3: String { Device.isIPad ? "iPad3" : "iPhone3" }
    static var description1: String {
        String(localized: "Calculate by inputting the total bet amount and coefficients for all outcomes.")
    }
    static var description2: String {
        String(localized: "Input the bet size for a single outcome and coefficients for all outcomes to calculate.")
    }
    static var description3: String {
        String(localized: "Enter the bet amount and coefficients for all outcomes after deactivating all switches.")
    }
}
