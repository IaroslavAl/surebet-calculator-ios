import SwiftUI

public enum SurebetCalculator {
    // MARK: - Public Methods

    @MainActor
    public static func view(
        analytics: CalculatorAnalytics = NoopCalculatorAnalytics()
    ) -> some View {
        SurebetCalculatorView(
            viewModel: SurebetCalculatorViewModel(analytics: analytics)
        )
    }
}
