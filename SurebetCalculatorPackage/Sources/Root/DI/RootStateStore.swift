import Foundation

protocol RootStateStore: Sendable {
    func onboardingIsShown() -> Bool
    func setOnboardingIsShown(_ value: Bool)
    func requestReviewWasShown() -> Bool
    func setRequestReviewWasShown(_ value: Bool)
    func numberOfOpenings() -> Int
    func setNumberOfOpenings(_ value: Int)
}

struct UserDefaultsRootStateStore: RootStateStore, @unchecked Sendable {
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func onboardingIsShown() -> Bool {
        userDefaults.bool(forKey: RootConstants.onboardingIsShownKey)
    }

    func setOnboardingIsShown(_ value: Bool) {
        userDefaults.set(value, forKey: RootConstants.onboardingIsShownKey)
    }

    func requestReviewWasShown() -> Bool {
        userDefaults.bool(forKey: RootConstants.requestReviewWasShownKey)
    }

    func setRequestReviewWasShown(_ value: Bool) {
        userDefaults.set(value, forKey: RootConstants.requestReviewWasShownKey)
    }

    func numberOfOpenings() -> Int {
        userDefaults.integer(forKey: RootConstants.numberOfOpeningsKey)
    }

    func setNumberOfOpenings(_ value: Int) {
        userDefaults.set(value, forKey: RootConstants.numberOfOpeningsKey)
    }
}
