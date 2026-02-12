import Foundation

protocol RootStateStore: Sendable {
    func onboardingIsShown() -> Bool
    func setOnboardingIsShown(_ value: Bool)
    func requestReviewWasShown() -> Bool
    func setRequestReviewWasShown(_ value: Bool)
    func numberOfOpenings() -> Int
    func setNumberOfOpenings(_ value: Int)
    func handledSurveyIDs() -> Set<String>
    func setHandledSurveyIDs(_ ids: Set<String>)
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

    func handledSurveyIDs() -> Set<String> {
        Set(userDefaults.stringArray(forKey: RootConstants.handledSurveyIDsKey) ?? [])
    }

    func setHandledSurveyIDs(_ ids: Set<String>) {
        userDefaults.set(Array(ids).sorted(), forKey: RootConstants.handledSurveyIDsKey)
    }
}
