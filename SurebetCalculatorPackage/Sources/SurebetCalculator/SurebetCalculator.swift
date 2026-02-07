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
    // Важно для iOS 16: destination в NavigationLink может пересоздаваться.
    // Если создавать VM в builder-е destination, SwiftUI уходит в update cycle
    // (AttributeGraph), и экран меню/калькулятора перестает быть интерактивным.
    @StateObject private var viewModel: SurebetCalculatorViewModel

    init(analytics: CalculatorAnalytics) {
        _viewModel = StateObject(wrappedValue: SurebetCalculatorViewModel(analytics: analytics))
    }

    var body: some View {
        SurebetCalculatorView(viewModel: viewModel)
    }
}
