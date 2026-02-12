import Combine

@MainActor
public protocol LanguageStoreAdapter: ObservableObject {
    var selectedLanguage: SettingsLanguage { get }
    func setLanguage(_ language: SettingsLanguage)
}

extension AppLanguageStore: LanguageStoreAdapter {}
