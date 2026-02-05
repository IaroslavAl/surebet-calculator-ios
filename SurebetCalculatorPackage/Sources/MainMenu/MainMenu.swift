import SurebetCalculator
import SwiftUI

public enum MainMenu {
    public static func view(calculatorAnalytics: CalculatorAnalytics) -> some View {
        MainMenuView(calculatorAnalytics: calculatorAnalytics)
    }
}
