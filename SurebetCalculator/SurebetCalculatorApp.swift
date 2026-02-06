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
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Обработка launch arguments для UI тестов
        processUITestArguments()

        #if !DEBUG
        let apiKey = "f7e1f335-475a-4b6c-ba4a-77988745bc7a"
        if let configuration = AppMetricaConfiguration(apiKey: apiKey) {
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
}
