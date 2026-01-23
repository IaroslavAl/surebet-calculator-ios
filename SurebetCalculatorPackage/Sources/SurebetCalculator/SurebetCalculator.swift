import SwiftUI

public enum SurebetCalculator {
    // MARK: - Public Methods

    @MainActor
    public static func view() -> some View {
        SurebetCalculatorView()
    }
}
