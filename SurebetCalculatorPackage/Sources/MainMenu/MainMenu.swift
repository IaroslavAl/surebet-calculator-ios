import SurebetCalculator
import SwiftUI

public enum MainMenuSection: String, Sendable {
    case calculator
    case settings
    case instructions
}

public enum MainMenu {
    @MainActor
    public static func view(
        calculatorAnalytics: CalculatorAnalytics,
        onSectionOpened: (@Sendable (MainMenuSection) -> Void)? = nil
    ) -> some View {
        MainMenuView(
            calculatorAnalytics: calculatorAnalytics,
            onSectionOpened: onSectionOpened
        )
    }
}
