import SwiftUI

public enum SurebetCalculator {
    public struct Dependencies: Sendable {
        public let analytics: any CalculatorAnalytics

        public init(analytics: any CalculatorAnalytics) {
            self.analytics = analytics
        }
    }

    // MARK: - Public Methods

    @MainActor
    public static func view(dependencies: Dependencies) -> some View {
        SurebetCalculatorContainerView(dependencies: dependencies)
    }
}

@MainActor
private struct SurebetCalculatorContainerView: View {
    // Важно для iOS 16: push destination builder может пересоздаваться.
    // Если создавать VM в builder-е destination, SwiftUI уходит в update cycle
    // (AttributeGraph), и экран меню/калькулятора перестает быть интерактивным.
    @StateObject private var viewModel: SurebetCalculatorViewModel

    init(dependencies: SurebetCalculator.Dependencies) {
        _viewModel = StateObject(
            wrappedValue: SurebetCalculatorViewModel(
                calculationService: DefaultCalculationService(),
                analytics: dependencies.analytics,
                delay: SystemCalculationAnalyticsDelay()
            )
        )
    }

    var body: some View {
        SurebetCalculatorView(viewModel: viewModel)
    }
}
