import Foundation

protocol RootStateStore: Sendable {
    func onboardingIsShown() -> Bool
    func setOnboardingIsShown(_ value: Bool)
    func requestReviewWasShown() -> Bool
    func setRequestReviewWasShown(_ value: Bool)
    func sessionNumber() -> Int
    func setSessionNumber(_ value: Int)
    func installID() -> String?
    func setInstallID(_ value: String)
    func sessionID() -> String?
    func setSessionID(_ value: String?)
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

    func sessionNumber() -> Int {
        userDefaults.integer(forKey: RootConstants.sessionNumberKey)
    }

    func setSessionNumber(_ value: Int) {
        userDefaults.set(value, forKey: RootConstants.sessionNumberKey)
    }

    func installID() -> String? {
        userDefaults.string(forKey: RootConstants.installIDKey)
    }

    func setInstallID(_ value: String) {
        userDefaults.set(value, forKey: RootConstants.installIDKey)
    }

    func sessionID() -> String? {
        userDefaults.string(forKey: RootConstants.sessionIDKey)
    }

    func setSessionID(_ value: String?) {
        if let value {
            userDefaults.set(value, forKey: RootConstants.sessionIDKey)
        } else {
            userDefaults.removeObject(forKey: RootConstants.sessionIDKey)
        }
    }
}
