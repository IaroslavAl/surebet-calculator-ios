import SwiftUI

public enum SurebetCalculator {
    // MARK: - Public Methods

    @MainActor
    public static func view(
        analytics: CalculatorAnalytics = NoopCalculatorAnalytics()
    ) -> some View {
        SurebetCalculatorContainerView(analytics: analytics)
    }
}

@MainActor
private struct SurebetCalculatorContainerView: View {
    // Keep a stable VM lifetime for NavigationLink destination.
    // Recreating VM from the destination builder causes SwiftUI update cycles on iOS 16.
    @StateObject private var viewModel: SurebetCalculatorViewModel

    init(analytics: CalculatorAnalytics) {
        _viewModel = StateObject(wrappedValue: SurebetCalculatorViewModel(analytics: analytics))
    }

    var body: some View {
        SurebetCalculatorView(viewModel: viewModel)
    }
}
