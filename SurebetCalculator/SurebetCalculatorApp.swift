import Root
import Settings
import SwiftUI

@main
struct SurebetCalculatorApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var delegate
    @StateObject private var languageStore = AppLanguageStore()

    var body: some Scene {
        WindowGroup {
            Root.view()
                .environment(\.locale, languageStore.locale)
                .environmentObject(languageStore)
        }
    }
}

final class AppDelegate: NSObject, UIApplicationDelegate {
    private enum ConfigurationKeys {
        static let appMetricaAPIKey = "AppMetricaApiKey"
        static let appMetricaAPIKeyEnvironment = "APPMETRICA_API_KEY"
        static let appMetricaLegacyEnvironment = "AppMetrica_Key"
    }

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Обработка launch arguments для UI тестов
        processUITestArguments()

        #if !DEBUG
        if let apiKey = appMetricaAPIKey(),
           let configuration = makeAppMetricaConfiguration(apiKey: apiKey) {
            AppMetrica.activate(with: configuration)
        }
        #endif
        return true
    }

    // MARK: - Private Methods

    /// Обрабатывает launch arguments для UI тестов
    private func processUITestArguments() {
        let arguments = ProcessInfo.processInfo.arguments

        // Сброс UserDefaults для чистого состояния
        if arguments.contains("-resetUserDefaults") {
            if let bundleID = Bundle.main.bundleIdentifier {
                UserDefaults.standard.removePersistentDomain(forName: bundleID)
            }
        }

        // Пропуск онбординга
        if arguments.contains("-onboardingIsShown") {
            UserDefaults.standard.set(true, forKey: "onboardingIsShown")
        }
    }

    /// Совместимо с SDK, где initializer может быть failable/non-failable.
    private func makeAppMetricaConfiguration(apiKey: String) -> AppMetricaConfiguration? {
        AppMetricaConfiguration(apiKey: apiKey)
    }

    /// Ключ читается из env/Info.plist и не хранится в репозитории.
    private func appMetricaAPIKey() -> String? {
        let environment = ProcessInfo.processInfo.environment
        let candidates: [String?] = [
            environment[ConfigurationKeys.appMetricaAPIKeyEnvironment],
            environment[ConfigurationKeys.appMetricaLegacyEnvironment],
            Bundle.main.object(forInfoDictionaryKey: ConfigurationKeys.appMetricaAPIKey) as? String
        ]

        for candidate in candidates {
            guard let value = normalizedAPIKey(candidate) else { continue }
            return value
        }
        return nil
    }

    private func normalizedAPIKey(_ rawValue: String?) -> String? {
        guard let rawValue else { return nil }
        let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        guard !trimmed.hasPrefix("$(") else { return nil }
        return trimmed
    }
}
