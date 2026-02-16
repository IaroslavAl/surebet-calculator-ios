import AnalyticsManager
import Foundation
import Settings

/// Декоратор AnalyticsService, автоматически добавляющий единый контекст v2 к каждому событию.
struct ContextualAnalyticsService: AnalyticsService, @unchecked Sendable {
    private enum Keys {
        static let eventVersion = "event_version"
        static let installID = "install_id"
        static let sessionID = "session_id"
        static let sessionNumber = "session_number"
        static let appLanguage = "app_language"
        static let appTheme = "app_theme"
        static let appVersion = "app_version"
        static let buildNumber = "build_number"
        static let platform = "platform"
    }

    private enum Values {
        static let eventVersion = 2
        static let platform = "ios"
        static let unknown = "unknown"
    }

    private enum BundleKeys {
        static let appVersion = "CFBundleShortVersionString"
        static let buildNumber = "CFBundleVersion"
    }

    private let baseService: any AnalyticsService
    private let rootStateStore: RootStateStore
    private let userDefaults: UserDefaults
    private let bundle: Bundle

    init(
        baseService: any AnalyticsService,
        rootStateStore: RootStateStore,
        userDefaults: UserDefaults = .standard,
        bundle: Bundle = .main
    ) {
        self.baseService = baseService
        self.rootStateStore = rootStateStore
        self.userDefaults = userDefaults
        self.bundle = bundle
    }

    func log(event: AnalyticsEvent) {
        log(name: event.name, parameters: event.parameters)
    }

    func log(name: String, parameters: [String: AnalyticsParameterValue]?) {
        var mergedParameters = parameters ?? [:]
        for (key, value) in makeContextParameters() {
            mergedParameters[key] = value
        }
        baseService.log(name: name, parameters: mergedParameters)
    }
}

private extension ContextualAnalyticsService {
    func makeContextParameters() -> [String: AnalyticsParameterValue] {
        [
            Keys.eventVersion: .int(Values.eventVersion),
            Keys.installID: .string(resolvedInstallID()),
            Keys.sessionID: .string(resolvedSessionID()),
            Keys.sessionNumber: .int(max(0, rootStateStore.sessionNumber())),
            Keys.appLanguage: .string(resolvedLanguage()),
            Keys.appTheme: .string(resolvedTheme()),
            Keys.appVersion: .string(bundleValue(BundleKeys.appVersion)),
            Keys.buildNumber: .string(bundleValue(BundleKeys.buildNumber)),
            Keys.platform: .string(Values.platform)
        ]
    }

    func resolvedInstallID() -> String {
        if let installID = rootStateStore.installID(), !installID.isEmpty {
            return installID
        }
        let newInstallID = UUID().uuidString
        rootStateStore.setInstallID(newInstallID)
        return newInstallID
    }

    func resolvedSessionID() -> String {
        let sessionID = rootStateStore.sessionID() ?? ""
        return sessionID.isEmpty ? Values.unknown : sessionID
    }

    func resolvedLanguage() -> String {
        let language = userDefaults.string(forKey: SettingsStorage.languageKey)
            ?? SettingsLanguage.system.rawValue
        return language.isEmpty ? SettingsLanguage.system.rawValue : language
    }

    func resolvedTheme() -> String {
        let theme = userDefaults.string(forKey: SettingsStorage.themeKey)
            ?? SettingsTheme.system.rawValue
        return theme.isEmpty ? SettingsTheme.system.rawValue : theme
    }

    func bundleValue(_ key: String) -> String {
        let value = bundle.object(forInfoDictionaryKey: key) as? String ?? Values.unknown
        return value.isEmpty ? Values.unknown : value
    }
}
