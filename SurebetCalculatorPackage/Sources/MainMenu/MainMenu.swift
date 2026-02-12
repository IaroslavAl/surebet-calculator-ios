import Settings
import SurebetCalculator
import SwiftUI

public enum MainMenuSection: String, Sendable {
    case calculator
    case settings
    case instructions
}

public enum MainMenu {
    public struct Dependencies: Sendable {
        public let calculator: SurebetCalculator.Dependencies
        public let settings: Settings.Dependencies

        public init(
            calculator: SurebetCalculator.Dependencies,
            settings: Settings.Dependencies
        ) {
            self.calculator = calculator
            self.settings = settings
        }
    }

    @MainActor
    public static func view(
        dependencies: Dependencies,
        onSectionOpened: ((MainMenuSection) -> Void)? = nil
    ) -> some View {
        MainMenuView(
            dependencies: dependencies,
            onSectionOpened: onSectionOpened
        )
    }
}
